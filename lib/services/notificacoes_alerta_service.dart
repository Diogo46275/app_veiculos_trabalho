import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/alerta_dashboard.dart';
import '../navigation/app_navigator.dart';
import '../screens/central_alertas_screen.dart';
import '../screens/veiculo_detalhe_screen.dart';
import '../services/alertas_notificados_storage.dart';
import '../services/veiculos_service.dart';
import 'api_client.dart';

/// Canais e IDs para Notification Shade (Android) e banner (iOS).
abstract final class NotificacoesAlertaService {
  static const _canalId = 'alertas_manutencao';
  static const _canalNome = 'Alertas de manutenção';
  static const _canalDescricao =
      'Avisos quando um alerta de km ou data está próximo ou vencido';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _inicializado = false;

  static Future<void> initialize() async {
    if (_inicializado) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _aoTocarNotificacao,
      onDidReceiveBackgroundNotificationResponse: _aoTocarNotificacaoBackground,
    );

    await _criarCanalAndroid();
    _inicializado = true;
  }

  static Future<void> _criarCanalAndroid() async {
    const canal = AndroidNotificationChannel(
      _canalId,
      _canalNome,
      description: _canalDescricao,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(canal);
  }

  /// Android 13+ — pede permissão POST_NOTIFICATIONS.
  static Future<bool> solicitarPermissao() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final ok = await android.requestNotificationsPermission();
        return ok ?? false;
      }
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final ok = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return ok ?? false;
      }
    }
    return true;
  }

  /// Após reset manual — limpa histórico de notificação deste alerta.
  static Future<void> aoResetarAlerta(int alertaId) async {
    await AlertasNotificadosStorage.limparChavesDoAlerta(alertaId);
    await _plugin.cancel(id: alertaId);
  }

  /// Compara alertas da API com o histórico e dispara notificações novas.
  static Future<void> sincronizarNotificacoes(
    List<AlertaDashboardItem> alertas,
  ) async {
    if (!_inicializado) await initialize();

    final chavesAtuais = alertas.map((a) => a.chaveNotificacao).toSet();
    final chavesNotificadas = await AlertasNotificadosStorage.lerChaves();

    // Remove chaves de alertas que saíram de vencido/próximo.
    final chavesValidas =
        chavesNotificadas.where(chavesAtuais.contains).toSet();

    final novos = alertas
        .where((a) => !chavesValidas.contains(a.chaveNotificacao))
        .toList();

    if (novos.isEmpty) {
      await AlertasNotificadosStorage.salvarChaves(chavesValidas);
      return;
    }

    if (novos.length == 1) {
      await _mostrarAlerta(novos.first);
    } else {
      await _mostrarResumo(novos.length, novos);
    }

    for (final item in novos) {
      chavesValidas.add(item.chaveNotificacao);
    }
    await AlertasNotificadosStorage.salvarChaves(chavesValidas);
  }

  static Future<void> _mostrarAlerta(AlertaDashboardItem item) async {
    final vencido = item.status == 'vencido';
    await _plugin.show(
      id: item.id,
      title: vencido ? 'Manutenção vencida' : 'Manutenção próxima',
      body: '${item.titulo}\n${item.veiculoRotulo} — ${item.rotuloRestante}',
      notificationDetails: _detalhes(vencido: vencido),
      payload: _payload(veiculoId: item.veiculoId, alertaId: item.id),
    );
  }

  static Future<void> _mostrarResumo(
    int quantidade,
    List<AlertaDashboardItem> itens,
  ) async {
    final vencidos = itens.where((a) => a.status == 'vencido').length;
    final proximos = quantidade - vencidos;
    final partes = <String>[];
    if (vencidos > 0) partes.add('$vencidos vencido(s)');
    if (proximos > 0) partes.add('$proximos próximo(s)');

    await _plugin.show(
      id: 0,
      title: '$quantidade alertas de manutenção',
      body: '${partes.join(' · ')}\nToque para ver a lista',
      notificationDetails: _detalhes(vencido: vencidos > 0),
      payload: _payload(),
    );
  }

  static NotificationDetails _detalhes({required bool vencido}) {
    final android = AndroidNotificationDetails(
      _canalId,
      _canalNome,
      channelDescription: _canalDescricao,
      importance: vencido ? Importance.max : Importance.high,
      priority: vencido ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return NotificationDetails(android: android, iOS: ios);
  }

  static String _payload({int? veiculoId, int? alertaId}) {
    return jsonEncode({
      if (veiculoId != null) 'veiculo_id': veiculoId,
      if (alertaId != null) 'alerta_id': alertaId,
    });
  }

  static void _aoTocarNotificacao(NotificationResponse response) {
    _navegarPorPayload(response.payload);
  }

  @pragma('vm:entry-point')
  static void _aoTocarNotificacaoBackground(NotificationResponse response) {
    _navegarPorPayload(response.payload);
  }

  static Future<void> _navegarPorPayload(String? payload) async {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    int? veiculoId;
    if (payload != null && payload.isNotEmpty) {
      try {
        final map = jsonDecode(payload);
        if (map is Map<String, dynamic>) {
          veiculoId = map['veiculo_id'] as int?;
        }
      } catch (_) {
        // Abre central de alertas.
      }
    }

    if (veiculoId != null) {
      try {
        final apiClient = ApiClient();
        final service = VeiculosService(apiClient: apiClient);
        final veiculo = await service.obter(veiculoId);
        apiClient.dispose();
        if (!navigator.mounted) return;
        await navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => VeiculoDetalheScreen(
              veiculo: veiculo,
              abaInicial: 2,
            ),
          ),
        );
        return;
      } catch (_) {
        // Fallback: central de alertas.
      }
    }

    if (!navigator.mounted) return;
    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => const CentralAlertasScreen()),
    );
  }
}
