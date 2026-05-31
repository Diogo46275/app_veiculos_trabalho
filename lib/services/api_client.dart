import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/arquivo_multipart.dart';
import '../utils/extrair_erro_api.dart';
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

  Future<Map<String, String>> _authHeadersBearerOnly() async {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Sessão expirada. Faça login novamente.');
    }

    return {'Authorization': 'Bearer $token'};
  }

  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    List<ArquivoMultipart> arquivos = const [],
  }) async {
    return _sendMultipart('POST', path, fields: fields, arquivos: arquivos);
  }

  Future<dynamic> putMultipart(
    String path, {
    required Map<String, String> fields,
    List<ArquivoMultipart> arquivos = const [],
  }) async {
    return _sendMultipart('PUT', path, fields: fields, arquivos: arquivos);
  }

  Future<dynamic> _sendMultipart(
    String method,
    String path, {
    required Map<String, String> fields,
    List<ArquivoMultipart> arquivos = const [],
  }) async {
    if (arquivos.isEmpty) {
      return _sendFormUrlEncoded(method, path, fields: fields);
    }

    final request = http.MultipartRequest(method, _uri(path));
    request.headers.addAll(await _headersMultipart());
    request.fields.addAll(fields);

    for (final arquivo in arquivos) {
      request.files.add(
        http.MultipartFile.fromBytes(
          arquivo.campo,
          arquivo.bytes,
          filename: arquivo.nomeArquivo,
          contentType: _tipoConteudoArquivo(arquivo.nomeArquivo),
        ),
      );
    }

    http.StreamedResponse streamedResponse;

    try {
      streamedResponse = await _client.send(request);
    } catch (_) {
      throw ApiException('Erro de conexão. Verifique sua internet.');
    }

    final response = await http.Response.fromStream(streamedResponse);
    return _decodeResponse(response);
  }

  Future<Map<String, String>> _headersMultipart() async {
    final headers = await _authHeadersBearerOnly();
    headers['Accept'] = 'application/json';
    return headers;
  }

  Future<dynamic> _sendFormUrlEncoded(
    String method,
    String path, {
    required Map<String, String> fields,
  }) async {
    final headers = await _headersMultipart();
    final uri = _uri(path);
    http.Response response;

    try {
      response = switch (method) {
        'POST' => await _client.post(uri, headers: headers, body: fields),
        'PUT' => await _client.put(uri, headers: headers, body: fields),
        _ => throw ApiException('Método não suportado: $method'),
      };
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException('Erro de conexão. Verifique sua internet.');
    }

    return _decodeResponse(response);
  }

  MediaType? _tipoConteudoArquivo(String nomeArquivo) {
    final ponto = nomeArquivo.lastIndexOf('.');
    if (ponto < 0) return null;
    return switch (nomeArquivo.substring(ponto + 1).toLowerCase()) {
      'pdf' => MediaType('application', 'pdf'),
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      _ => null,
    };
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
    if (response.bodyBytes.isNotEmpty) {
      try {
        final texto = utf8.decode(response.bodyBytes, allowMalformed: true);
        body = jsonDecode(texto);
      } catch (_) {
        final texto = utf8.decode(response.bodyBytes, allowMalformed: true);
        throw ApiException(
          mensagemCorpoNaoJson(texto, response.statusCode),
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      extrairMensagemErroApi(body, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}
