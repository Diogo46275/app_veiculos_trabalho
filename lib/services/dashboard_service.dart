import '../models/dashboard_data.dart';
import 'api_client.dart';

class DashboardService {
  DashboardService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DashboardData> fetchDashboard() async {
    try {
      final json = await _apiClient.getJson('/dashboard/');
      if (json is Map<String, dynamic>) {
        return DashboardData.fromJson(json);
      }
      throw ApiException('Resposta inválida do dashboard.');
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return _fetchFallback();
      }
      rethrow;
    }
  }

  Future<DashboardData> _fetchFallback() async {
    final results = await Future.wait<dynamic>([
      _apiClient.getJson('/dashboard/rentabilidade'),
      _apiClient.getJson('/alertas/dashboard'),
    ]);

    final rentabilidade = results[0];
    final alertas = results[1];

    if (rentabilidade is! Map<String, dynamic> ||
        alertas is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida do dashboard.');
    }

    return DashboardData(
      kmTotal: rentabilidade['km_rodado'] as int? ?? 0,
      economia: (rentabilidade['lucro'] as num?)?.toDouble() ?? 0,
      proximasManutencoes: alertas['total_proximos'] as int? ?? 0,
    );
  }
}
