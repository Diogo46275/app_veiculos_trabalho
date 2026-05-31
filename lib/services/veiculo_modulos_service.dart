import '../models/abastecimento.dart';
import '../models/alerta_veiculo.dart';
import '../models/manutencao.dart';
import '../models/periodo_trabalho.dart';
import '../models/veiculo.dart';
import 'api_client.dart';
import 'veiculos_service.dart';

class VeiculoModulosService {
  VeiculoModulosService({ApiClient? apiClient}) {
    final client = apiClient ?? ApiClient();
    _apiClient = client;
    _veiculosService = VeiculosService(apiClient: client);
  }

  late final ApiClient _apiClient;
  late final VeiculosService _veiculosService;

  Future<Veiculo> obterVeiculo(int id) => _veiculosService.obter(id);

  Future<List<Abastecimento>> listarAbastecimentos(int veiculoId) async {
    final lista = await _apiClient.getJsonList(
      '/abastecimentos/veiculo/$veiculoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Abastecimento.fromJson)
        .toList();
  }

  Future<List<Manutencao>> listarManutencoes(int veiculoId) async {
    final lista = await _apiClient.getJsonList(
      '/manutencoes/veiculo/$veiculoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Manutencao.fromJson)
        .toList();
  }

  Future<List<AlertaVeiculo>> listarAlertas(int veiculoId) async {
    final lista = await _apiClient.getJsonList(
      '/alertas/veiculo/$veiculoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(AlertaVeiculo.fromJson)
        .toList();
  }

  Future<List<PeriodoTrabalho>> listarPeriodos(int veiculoId) async {
    final lista = await _apiClient.getJsonList(
      '/periodos-trabalho/veiculo/$veiculoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(PeriodoTrabalho.fromJson)
        .toList();
  }

  Future<Abastecimento?> obterAbastecimento(int veiculoId, int id) async {
    final lista = await listarAbastecimentos(veiculoId);
    for (final item in lista) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<Manutencao?> obterManutencao(int veiculoId, int id) async {
    final lista = await listarManutencoes(veiculoId);
    for (final item in lista) {
      if (item.id == id) return item;
    }
    return null;
  }

  void dispose() => _apiClient.dispose();
}
