import '../models/perfil.dart';
import 'api_client.dart';

class PerfilService {
  PerfilService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Perfil> fetchPerfil() async {
    final json = await _apiClient.getJson('/auth/perfil');
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida do perfil.');
    }
    return Perfil.fromJson(json);
  }
}
