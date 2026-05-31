import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../services/alertas_dashboard_service.dart';
import '../services/alertas_notificados_storage.dart';
import '../services/api_client.dart';
import '../services/notificacoes_alerta_service.dart';
import '../services/token_storage.dart';

const alertasBackgroundTaskName = 'verificarAlertas';
const alertasBackgroundUniqueName = 'veiculos_alertas_sync';

@pragma('vm:entry-point')
void alertasBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == alertasBackgroundTaskName ||
        task == Workmanager.iOSBackgroundTask) {
      await AlertasBackgroundExecutor.executar();
    }
    return true;
  });
}

/// Verificação periódica em background (Android) — consulta API e notifica.
abstract final class AlertasBackgroundExecutor {
  static Future<void> executar() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) return;

    await NotificacoesAlertaService.initialize();

    final service = AlertasDashboardService(apiClient: ApiClient());
    try {
      final resposta = await service.buscar();
      await NotificacoesAlertaService.sincronizarNotificacoes(resposta.alertas);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AlertasBackgroundExecutor: $error');
      }
    } finally {
      service.dispose();
    }
  }

  static Future<void> registrarTarefaPeriodica() async {
    await Workmanager().registerPeriodicTask(
      alertasBackgroundUniqueName,
      alertasBackgroundTaskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  static Future<void> cancelarTarefa() async {
    await Workmanager().cancelByUniqueName(alertasBackgroundUniqueName);
    await AlertasNotificadosStorage.limpar();
  }
}
