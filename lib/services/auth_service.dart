import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const _loginUrl =
      'https://bytes-techus.com.br/veiculos/api/auth/login';

  final http.Client _client;

  Future<String> login({
    required String email,
    required String senha,
  }) async {
    http.Response response;

    try {
      response = await _client.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );
    } catch (_) {
      throw AuthException('Erro de conexão. Verifique sua internet.');
    }

    Map<String, dynamic>? body;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        }
      } catch (_) {
        // Resposta não-JSON: usa mensagem genérica abaixo.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final token = _extractToken(body);
      if (token != null && token.isNotEmpty) {
        return token;
      }
      throw AuthException('Resposta inválida: token não encontrado.');
    }

    throw AuthException(_extractErrorMessage(body, response.statusCode));
  }

  String? _extractToken(Map<String, dynamic>? body) {
    if (body == null) return null;

    const directKeys = ['token', 'access_token', 'jwt', 'jwt_token'];
    for (final key in directKeys) {
      final value = body[key];
      if (value is String && value.isNotEmpty) return value;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      for (final key in directKeys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }

    return null;
  }

  String _extractErrorMessage(Map<String, dynamic>? body, int statusCode) {
    if (body != null) {
      for (final key in ['message', 'mensagem', 'error', 'erro', 'detail']) {
        final value = body[key];
        if (value is String && value.isNotEmpty) return value;
      }
    }

    return 'Falha no login (código $statusCode).';
  }

  void dispose() {
    _client.close();
  }
}
