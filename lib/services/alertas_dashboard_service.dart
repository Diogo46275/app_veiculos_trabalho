import '../models/alerta_dashboard.dart';
import 'api_client.dart';

class AlertasDashboardService {
  AlertasDashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AlertaDashboardResposta> buscar() async {
    final json = await _apiClient.getJson('/alertas/dashboard');
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida dos alertas.');
    }
    return AlertaDashboardResposta.fromJson(json);
  }

  void dispose() => _apiClient.dispose();
}
