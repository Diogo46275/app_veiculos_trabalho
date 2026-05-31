import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Sessão expirada. Faça login novamente.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, {Map<String, String>? query}) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalized')
        .replace(queryParameters: query);
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? query,
  }) async {
    http.Response response;

    try {
      response = await _client.get(
        _uri(path, query: query),
        headers: await _authHeaders(),
      );
    } catch (_) {
      throw ApiException('Erro de conexão. Verifique sua internet.');
    }

    return response;
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await get(path, query: query);
    return _decodeResponse(response);
  }

  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, String>? query,
  }) async {
    final decoded = await getJson(path, query: query);
    if (decoded is List) return decoded;
    throw ApiException('Resposta inválida: lista esperada.');
  }

  Future<http.Response> post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    http.Response response;

    try {
      response = await _client.post(
        _uri(path),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );
    } catch (_) {
      throw ApiException('Erro de conexão. Verifique sua internet.');
    }

    return response;
  }

  Future<dynamic> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await post(path, body: body);
    return _decodeResponse(response);
  }

  Future<http.Response> put(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    http.Response response;

    try {
      response = await _client.put(
        _uri(path),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );
    } catch (_) {
      throw ApiException('Erro de conexão. Verifique sua internet.');
    }

    return response;
  }

  Future<dynamic> putJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await put(path, body: body);
    return _decodeResponse(response);
  }

  Future<http.Response> delete(String path) async {
    http.Response response;

    try {
      response = await _client.delete(
        _uri(path),
        headers: await _authHeaders(),
      );
    } catch (_) {
      throw ApiException('Erro de conexão. Verifique sua internet.');
    }

    return response;
  }

  Future<void> deleteJson(String path) async {
    final response = await delete(path);
    _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw ApiException(
          'Resposta inválida do servidor.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      _extractErrorMessage(body, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  String _extractErrorMessage(dynamic body, int statusCode) {
    if (body is Map<String, dynamic>) {
      for (final key in ['detail', 'message', 'mensagem', 'error', 'erro']) {
        final value = body[key];
        if (value is String && value.isNotEmpty) return value;
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is Map && first['msg'] is String) {
            return first['msg'] as String;
          }
        }
      }
    }

    return 'Erro na requisição (código $statusCode).';
  }

  void dispose() {
    _client.close();
  }
}
