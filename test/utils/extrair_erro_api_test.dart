import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/utils/extrair_erro_api.dart';

void main() {
  group('erroValidacaoEmail', () {
    test('422 com loc email retorna true', () {
      expect(
        erroValidacaoEmail({
          'detail': [
            {
              'type': 'value_error',
              'loc': ['body', 'email'],
              'msg': 'value is not a valid email address',
            },
          ],
        }),
        isTrue,
      );
    });

    test('422 sem email retorna false', () {
      expect(
        erroValidacaoEmail({
          'detail': [
            {'loc': ['body', 'senha'], 'msg': 'Field required'},
          ],
        }),
        isFalse,
      );
    });
  });

  group('extrairMensagemErroApi', () {
    test('detail em lista extrai msg', () {
      expect(
        extrairMensagemErroApi({
          'detail': [
            {'msg': 'E-mail ou senha incorretos'},
          ],
        }, 401),
        'E-mail ou senha incorretos',
      );
    });
  });

  group('mensagemCorpoNaoJson', () {
    test('html 413 sugere tirar foto', () {
      expect(
        mensagemCorpoNaoJson('<html><body>Too Large</body></html>', 413),
        contains('Tirar foto'),
      );
    });

    test('texto simples repassa primeira linha', () {
      expect(
        mensagemCorpoNaoJson('Internal Server Error', 500),
        'Erro interno no servidor (código 500). Tente novamente.',
      );
    });
  });
}
