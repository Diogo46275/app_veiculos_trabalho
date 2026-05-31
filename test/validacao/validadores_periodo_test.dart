import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  group('validarKmPeriodo', () {
    test('vazio retorna obrigatório', () {
      expect(validarKmPeriodo(''), MensagensValidacao.kmPeriodoObrigatorio);
    });

    test('km válido passa', () {
      expect(validarKmPeriodo('10000'), isNull);
      expect(validarKmPeriodo('0'), isNull);
    });

    test('km negativo retorna inválido', () {
      expect(validarKmPeriodo('-1'), MensagensValidacao.kmPeriodoInvalido);
    });
  });

  group('validarKmFimPeriodo', () {
    test('km fim menor ou igual ao início retorna erro', () {
      expect(
        validarKmFimPeriodo('100', kmInicioTexto: '100'),
        MensagensValidacao.kmFimMenorQueInicio,
      );
      expect(
        validarKmFimPeriodo('50', kmInicioTexto: '100'),
        MensagensValidacao.kmFimMenorQueInicio,
      );
    });

    test('km fim maior passa', () {
      expect(
        validarKmFimPeriodo('150', kmInicioTexto: '100'),
        isNull,
      );
    });
  });

  group('validarDataHoraFimPeriodo', () {
    test('fim antes do início retorna erro', () {
      final inicio = DateTime(2026, 5, 28, 10);
      final fim = DateTime(2026, 5, 28, 9);
      expect(
        validarDataHoraFimPeriodo(fim, inicio: inicio),
        MensagensValidacao.dataHoraFimAntesInicio,
      );
    });

    test('fim após início passa', () {
      final inicio = DateTime(2026, 5, 28, 8);
      final fim = DateTime(2026, 5, 28, 18);
      expect(validarDataHoraFimPeriodo(fim, inicio: inicio), isNull);
    });
  });

  group('validarValorReceita', () {
    test('vazio retorna obrigatório', () {
      expect(
        validarValorReceita(''),
        MensagensValidacao.valorReceitaObrigatorio,
      );
    });

    test('zero retorna inválido', () {
      expect(
        validarValorReceita('0'),
        MensagensValidacao.valorReceitaInvalido,
      );
    });

    test('valor válido passa', () {
      expect(validarValorReceita('150,50'), isNull);
      expect(validarValorReceita('10'), isNull);
    });
  });

  group('validarDataReceita', () {
    test('data fora do período retorna erro', () {
      final inicio = DateTime(2026, 5, 28, 8);
      final fim = DateTime(2026, 5, 28, 20);
      final data = DateTime(2026, 5, 27);
      expect(
        validarDataReceita(data, inicioTurno: inicio, fimTurno: fim),
        isNotNull,
      );
    });

    test('data dentro do período passa', () {
      final inicio = DateTime(2026, 5, 28, 8);
      final fim = DateTime(2026, 5, 28, 20);
      final data = DateTime(2026, 5, 28);
      expect(
        validarDataReceita(data, inicioTurno: inicio, fimTurno: fim),
        isNull,
      );
    });
  });
}
