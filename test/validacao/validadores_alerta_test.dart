import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  group('validarTipoAlerta', () {
    test('null retorna obrigatório', () {
      expect(
        validarTipoAlerta(null),
        MensagensValidacao.tipoAlertaObrigatorio,
      );
    });

    test('valor selecionado passa', () {
      expect(validarTipoAlerta(TipoAlerta.km), isNull);
    });
  });

  group('validarTituloAlerta', () {
    test('vazio retorna obrigatório', () {
      expect(
        validarTituloAlerta(''),
        MensagensValidacao.tituloAlertaObrigatorio,
      );
    });

    test('121 caracteres retorna max length', () {
      expect(
        validarTituloAlerta('T' * 121),
        MensagensValidacao.tituloAlertaMaxLength,
      );
    });

    test('título válido passa', () {
      expect(validarTituloAlerta('Trocar óleo'), isNull);
    });
  });

  group('validarValorAlerta', () {
    test('vazio retorna obrigatório', () {
      expect(validarValorAlerta(''), MensagensValidacao.valorAlertaObrigatorio);
    });

    test('zero retorna inválido', () {
      expect(validarValorAlerta('0'), MensagensValidacao.valorAlertaInvalido);
    });

    test('negativo retorna inválido', () {
      expect(validarValorAlerta('-5'), MensagensValidacao.valorAlertaInvalido);
    });

    test('acima do máximo retorna erro', () {
      expect(
        validarValorAlerta('1000001'),
        MensagensValidacao.valorAlertaMaximo,
      );
    });

    test('intervalo válido passa', () {
      expect(validarValorAlerta('10000'), isNull);
      expect(validarValorAlerta('180'), isNull);
    });
  });

  group('validarAntecedenciaAlerta', () {
    test('vazio retorna obrigatório', () {
      expect(
        validarAntecedenciaAlerta('', intervaloTexto: '10000'),
        MensagensValidacao.antecedenciaAlertaObrigatoria,
      );
    });

    test('zero retorna inválido', () {
      expect(
        validarAntecedenciaAlerta('0', intervaloTexto: '10000'),
        MensagensValidacao.antecedenciaAlertaInvalida,
      );
    });

    test('maior ou igual ao intervalo retorna erro', () {
      expect(
        validarAntecedenciaAlerta('100', intervaloTexto: '100'),
        MensagensValidacao.antecedenciaAlertaMenorQueIntervalo,
      );
      expect(
        validarAntecedenciaAlerta('5000', intervaloTexto: '5000'),
        MensagensValidacao.antecedenciaAlertaMenorQueIntervalo,
      );
    });

    test('antecedência válida passa', () {
      expect(
        validarAntecedenciaAlerta('500', intervaloTexto: '10000'),
        isNull,
      );
      expect(validarAntecedenciaAlerta('7', intervaloTexto: '30'), isNull);
    });
  });
}
