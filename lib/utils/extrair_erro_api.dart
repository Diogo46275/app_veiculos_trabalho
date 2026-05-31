/// Extrai mensagem legível do corpo JSON de erro da API (FastAPI).
String extrairMensagemErroApi(dynamic body, int statusCode) {
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

/// Quando o corpo não é JSON (HTML do proxy, timeout, etc.).
String mensagemCorpoNaoJson(String corpo, int statusCode) {
  final limpo = corpo.trim();
  if (limpo.isEmpty) {
    return 'Resposta vazia do servidor (código $statusCode).';
  }

  final html = limpo.startsWith('<!DOCTYPE') ||
      limpo.startsWith('<html') ||
      limpo.startsWith('<HTML');
  if (html) {
    if (statusCode == 413) {
      return 'Foto ou PDF grande demais para o servidor. Use o botão '
          '"Tirar foto" (comprime automaticamente) ou um PDF menor que 1 MB.';
    }
    if (statusCode == 502 || statusCode == 504) {
      return 'Servidor indisponível no momento (código $statusCode). Tente novamente.';
    }
    return 'Servidor retornou página de erro (código $statusCode). '
        'Se anexou NF, tente sem anexo ou arquivo menor.';
  }

  if (statusCode >= 500) {
    return 'Erro interno no servidor (código $statusCode). Tente novamente.';
  }

  final linha = limpo.split(RegExp(r'\r?\n')).first.trim();
  if (linha.isNotEmpty && linha.length <= 160) {
    return linha;
  }
  if (linha.length > 160) {
    return '${linha.substring(0, 157)}...';
  }

  return 'Resposta inesperada do servidor (código $statusCode).';
}

/// Indica se o 422 do FastAPI é falha de validação do campo e-mail.
bool erroValidacaoEmail(dynamic body) {
  if (body is! Map<String, dynamic>) return false;
  final detail = body['detail'];
  if (detail is! List) return false;

  for (final item in detail) {
    if (item is! Map) continue;
    final loc = item['loc'];
    if (loc is List && loc.any((parte) => parte == 'email')) {
      return true;
    }
    final msg = item['msg'];
    if (msg is String && msg.toLowerCase().contains('email')) {
      return true;
    }
  }
  return false;
}
