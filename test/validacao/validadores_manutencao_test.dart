import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  group('validarTipoManutencao', () {
    test('null retorna obrigatório', () {
      expect(
        validarTipoManutencao(null),
        MensagensValidacao.tipoManutencaoObrigatorio,
      );
    });

    test('valor selecionado passa', () {
      expect(validarTipoManutencao(Object()), isNull);
    });
  });

  group('validarKmManutencao', () {
    test('vazio passa (opcional)', () {
      expect(validarKmManutencao(''), isNull);
    });

    test('negativo retorna inválido', () {
      expect(validarKmManutencao('-1'), MensagensValidacao.kmManutencaoInvalido);
    });

    test('km válido passa', () {
      expect(validarKmManutencao('12000'), isNull);
    });
  });

  group('validarDescricaoManutencao', () {
    test('vazio passa (opcional)', () {
      expect(validarDescricaoManutencao(''), isNull);
    });

    test('2001 caracteres retorna max length', () {
      expect(
        validarDescricaoManutencao('D' * 2001),
        MensagensValidacao.descricaoManutencaoMaxLength,
      );
    });

    test('descrição válida passa', () {
      expect(validarDescricaoManutencao('Troca de óleo'), isNull);
    });
  });

  group('validarGarantiaDias', () {
    test('vazio passa (opcional)', () {
      expect(validarGarantiaDias(''), isNull);
    });

    test('negativo retorna inválido', () {
      expect(validarGarantiaDias('-5'), MensagensValidacao.garantiaDiasInvalido);
    });

    test('zero passa', () {
      expect(validarGarantiaDias('0'), isNull);
    });

    test('dias válidos passam', () {
      expect(validarGarantiaDias('180'), isNull);
    });
  });
}
