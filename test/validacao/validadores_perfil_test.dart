import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  group('validarNomePerfil', () {
    test('vazio retorna obrigatório', () {
      expect(validarNomePerfil(''), MensagensValidacao.nomePerfilObrigatorio);
    });

    test('1 caractere retorna curto', () {
      expect(validarNomePerfil('A'), MensagensValidacao.nomePerfilCurto);
    });

    test('nome válido passa', () {
      expect(validarNomePerfil('Diogo'), isNull);
    });
  });

  group('validarCpfPerfil', () {
    test('vazio passa', () {
      expect(validarCpfPerfil(''), isNull);
    });

    test('11 dígitos passa', () {
      expect(validarCpfPerfil('12345678901'), isNull);
    });

    test('tamanho errado retorna inválido', () {
      expect(validarCpfPerfil('123'), MensagensValidacao.cpfPerfilInvalido);
    });
  });

  group('validarSenhaNovaPerfil', () {
    test('igual à atual retorna erro', () {
      expect(
        validarSenhaNovaPerfil('senha123', senhaAtual: 'senha123'),
        MensagensValidacao.senhaNovaIgualAtual,
      );
    });

    test('6+ caracteres passa', () {
      expect(validarSenhaNovaPerfil('nova123', senhaAtual: 'antiga'), isNull);
    });
  });

  group('validarConfirmarSenhaPerfil', () {
    test('diferente retorna erro', () {
      expect(
        validarConfirmarSenhaPerfil('abc', senhaNova: 'xyz'),
        MensagensValidacao.confirmarSenhaDiferente,
      );
    });

    test('igual passa', () {
      expect(
        validarConfirmarSenhaPerfil('nova123', senhaNova: 'nova123'),
        isNull,
      );
    });
  });
}
