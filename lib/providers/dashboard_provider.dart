import 'package:flutter/foundation.dart';

import '../models/dashboard_data.dart';
import '../models/perfil.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/dashboard_service.dart';
import '../services/perfil_service.dart';
import '../services/veiculos_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient() {
    _perfilService = PerfilService(apiClient: _apiClient);
    _dashboardService = DashboardService(apiClient: _apiClient);
    _veiculosService = VeiculosService(apiClient: _apiClient);
  }

  final ApiClient _apiClient;
  late final PerfilService _perfilService;
  late final DashboardService _dashboardService;
  late final VeiculosService _veiculosService;

  Perfil? _perfil;
  DashboardData? _dashboard;
  List<Veiculo> _veiculos = const [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  Perfil? get perfil => _perfil;
  DashboardData? get dashboard => _dashboard;
  List<Veiculo> get veiculos => _veiculos;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading || _isRefreshing) return;

    if (refresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _perfilService.fetchPerfil(),
        _dashboardService.fetchDashboard(),
        _veiculosService.listarTrabalho(),
      ]);

      _perfil = results[0] as Perfil;
      _dashboard = results[1] as DashboardData;
      _veiculos = results[2] as List<Veiculo>;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Erro inesperado ao carregar dashboard.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
