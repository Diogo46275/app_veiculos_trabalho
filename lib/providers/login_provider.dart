import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/token_storage.dart';

enum LoginStatus { idle, loading, success, error }

class LoginProvider extends ChangeNotifier {
  LoginProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  LoginStatus _status = LoginStatus.idle;
  String? _errorMessage;
  String? _errorCampo;

  LoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get errorCampo => _errorCampo;
  bool get isLoading => _status == LoginStatus.loading;

  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    _status = LoginStatus.loading;
    _errorMessage = null;
    _errorCampo = null;
    notifyListeners();

    try {
      final token = await _authService.login(email: email, senha: senha);
      await TokenStorage.saveToken(token);
      _status = LoginStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _status = LoginStatus.error;
      _errorMessage = error.message;
      _errorCampo = error.campo;
      notifyListeners();
      return false;
    } catch (_) {
      _status = LoginStatus.error;
      _errorMessage = 'Erro inesperado. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null && _errorCampo == null) return;
    _errorMessage = null;
    _errorCampo = null;
    if (_status == LoginStatus.error) {
      _status = LoginStatus.idle;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
