import '../models/veiculo.dart';
import 'api_client.dart';

class VeiculosService {
  VeiculosService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Veiculo>> listarTrabalho() async {
    final lista = await _apiClient.getJsonList(
      '/veiculos/',
      query: {'tipo': 'trabalho'},
    );

    return lista
        .whereType<Map<String, dynamic>>()
        .map(Veiculo.fromJson)
        .where((veiculo) => veiculo.tipo == 'trabalho')
        .toList();
  }

  Future<Veiculo> criarTrabalho({
    required String marca,
    required String modelo,
    required String placa,
    required String categoria,
    int? ano,
    int kmAtual = 0,
  }) async {
    final body = <String, dynamic>{
      'marca': marca,
      'modelo': modelo,
      'placa': placa.trim(),
      'categoria': categoria,
      'km_atual': kmAtual,
      'tipo': 'trabalho',
    };
    if (ano != null) {
      body['ano'] = ano;
    }

    final json = await _apiClient.postJson('/veiculos/', body: body);
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao cadastrar veículo.');
    }

    return Veiculo.fromJson(json);
  }

  Future<Veiculo> atualizarTrabalho({
    required int id,
    required String marca,
    required String modelo,
    required String placa,
    required String categoria,
    int? ano,
    required int kmAtual,
  }) async {
    final body = <String, dynamic>{
      'marca': marca,
      'modelo': modelo,
      'placa': placa.trim(),
      'categoria': categoria,
      'km_atual': kmAtual,
      'tipo': 'trabalho',
    };
    if (ano != null) {
      body['ano'] = ano;
    }

    final json = await _apiClient.putJson('/veiculos/$id', body: body);
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar veículo.');
    }

    return Veiculo.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/veiculos/$id');
  }
}
