import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  group('validarEmail', () {
    test('vazio retorna obrigatório', () {
      expect(validarEmail(''), MensagensValidacao.emailObrigatorio);
      expect(validarEmail(null), MensagensValidacao.emailObrigatorio);
    });

    test('sem @ retorna inválido', () {
      expect(validarEmail('usuario.com'), MensagensValidacao.emailInvalido);
    });

    test('domínio inválido (@.gmail.com) retorna inválido', () {
      expect(
        validarEmail('diogo46275@.gmail.com'),
        MensagensValidacao.emailInvalido,
      );
    });

    test('email válido passa', () {
      expect(validarEmail('usuario@exemplo.com'), isNull);
    });
  });

  group('validarSenha', () {
    test('vazio retorna obrigatório', () {
      expect(validarSenha(''), MensagensValidacao.senhaObrigatoria);
      expect(validarSenha(null), MensagensValidacao.senhaObrigatoria);
    });

    test('preenchida passa', () {
      expect(validarSenha('123456'), isNull);
    });
  });
}
