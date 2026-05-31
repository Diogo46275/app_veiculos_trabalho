import 'package:flutter/foundation.dart';

import '../background/alertas_background.dart';
import '../models/alerta_dashboard.dart';
import '../services/alertas_dashboard_service.dart';
import '../services/api_client.dart';
import '../services/notificacoes_alerta_service.dart';

class AlertasProvider extends ChangeNotifier {
  AlertasProvider({AlertasDashboardService? service})
      : _service = service ?? AlertasDashboardService();

  final AlertasDashboardService _service;

  AlertaDashboardResposta? _resposta;
  bool _carregando = false;
  String? _erro;
  bool _inicializado = false;

  AlertaDashboardResposta? get resposta => _resposta;
  bool get carregando => _carregando;
  String? get erro => _erro;

  int get totalPendentes => _resposta?.totalPendentes ?? 0;
  int get totalVencidos => _resposta?.totalVencidos ?? 0;
  int get totalProximos => _resposta?.totalProximos ?? 0;
  List<AlertaDashboardItem> get itens => _resposta?.alertas ?? const [];

  Future<void> inicializar() async {
    if (_inicializado) return;
    _inicializado = true;

    await NotificacoesAlertaService.initialize();
    await NotificacoesAlertaService.solicitarPermissao();

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await AlertasBackgroundExecutor.registrarTarefaPeriodica();
    }

    await sincronizar(notificar: true);
  }

  Future<void> sincronizar({bool notificar = false}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final dados = await _service.buscar();
      _resposta = dados;
      if (notificar) {
        await NotificacoesAlertaService.sincronizarNotificacoes(dados.alertas);
      }
    } on ApiException catch (error) {
      _erro = error.message;
    } catch (_) {
      _erro = 'Erro ao carregar alertas.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> aposResetAlerta(int alertaId) async {
    await NotificacoesAlertaService.aoResetarAlerta(alertaId);
    await sincronizar(notificar: false);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
