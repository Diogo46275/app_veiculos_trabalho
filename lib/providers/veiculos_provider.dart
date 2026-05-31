import 'package:flutter/foundation.dart';

import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/veiculos_service.dart';

class VeiculosProvider extends ChangeNotifier {
  VeiculosProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient() {
    _veiculosService = VeiculosService(apiClient: _apiClient);
  }

  final ApiClient _apiClient;
  late final VeiculosService _veiculosService;

  List<Veiculo> _veiculos = const [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isSaving = false;
  String? _errorMessage;
  bool _carregado = false;

  List<Veiculo> get veiculos => _veiculos;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get carregado => _carregado;

  Future<void> load({bool refresh = false, bool forcar = false}) async {
    if (_isLoading || _isRefreshing) return;
    if (_carregado && !refresh && !forcar) return;

    if (refresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      _veiculos = await _veiculosService.listarTrabalho();
      _carregado = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Erro inesperado ao carregar veículos.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<Veiculo?> cadastrar({
    required String marca,
    required String modelo,
    required String placa,
    required String categoria,
    int? ano,
    int kmAtual = 0,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final veiculo = await _veiculosService.criarTrabalho(
        marca: marca,
        modelo: modelo,
        placa: placa,
        categoria: categoria,
        ano: ano,
        kmAtual: kmAtual,
      );
      await load(forcar: true);
      return veiculo;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Erro inesperado ao cadastrar veículo.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<Veiculo?> atualizar({
    required int id,
    required String marca,
    required String modelo,
    required String placa,
    required String categoria,
    int? ano,
    required int kmAtual,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final veiculo = await _veiculosService.atualizarTrabalho(
        id: id,
        marca: marca,
        modelo: modelo,
        placa: placa,
        categoria: categoria,
        ano: ano,
        kmAtual: kmAtual,
      );
      await load(forcar: true);
      return veiculo;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Erro inesperado ao atualizar veículo.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> excluir(int id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _veiculosService.excluir(id);
      _veiculos = _veiculos.where((v) => v.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Erro inesperado ao excluir veículo.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
