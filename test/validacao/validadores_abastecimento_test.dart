import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  group('validarDataAbastecimento', () {
    test('null retorna obrigatório', () {
      expect(
        validarDataAbastecimento(null),
        MensagensValidacao.dataObrigatoria,
      );
    });

    test('data futura retorna erro', () {
      final amanha = DateTime.now().add(const Duration(days: 2));
      expect(
        validarDataAbastecimento(amanha),
        MensagensValidacao.dataFutura,
      );
    });

    test('data de hoje passa', () {
      expect(validarDataAbastecimento(DateTime.now()), isNull);
    });
  });

  group('validarKmAbastecimento', () {
    test('vazio retorna obrigatório', () {
      expect(validarKmAbastecimento(''), MensagensValidacao.kmAbastObrigatorio);
    });

    test('negativo retorna inválido', () {
      expect(validarKmAbastecimento('-5'), MensagensValidacao.kmAbastInvalido);
    });

    test('km válido passa', () {
      expect(validarKmAbastecimento('45000'), isNull);
    });
  });

  group('validarLitros', () {
    test('vazio retorna inválido', () {
      expect(validarLitros(''), MensagensValidacao.litrosInvalido);
    });

    test('zero retorna inválido', () {
      expect(validarLitros('0'), MensagensValidacao.litrosInvalido);
    });

    test('mais de 2 casas decimais', () {
      expect(validarLitros('10,123'), MensagensValidacao.litrosDecimais);
    });

    test('litros válidos passam', () {
      expect(validarLitros('45,50'), isNull);
      expect(validarLitros('30'), isNull);
    });
  });

  group('validarValorAbastecimento', () {
    test('vazio retorna inválido', () {
      expect(validarValorAbastecimento(''), MensagensValidacao.valorInvalido);
    });

    test('negativo retorna inválido', () {
      expect(validarValorAbastecimento('-1'), MensagensValidacao.valorInvalido);
    });

    test('mais de 2 casas decimais', () {
      expect(validarValorAbastecimento('100,999'), MensagensValidacao.valorDecimais);
    });

    test('zero passa', () {
      expect(validarValorAbastecimento('0'), isNull);
    });

    test('valor válido passa', () {
      expect(validarValorAbastecimento('250,90'), isNull);
    });
  });

  group('validarPosto', () {
    test('vazio passa (opcional)', () {
      expect(validarPosto(''), isNull);
    });

    test('121 caracteres retorna max length', () {
      expect(validarPosto('P' * 121), MensagensValidacao.postoMaxLength);
    });

    test('nome válido passa', () {
      expect(validarPosto('Shell Centro'), isNull);
    });
  });
}
