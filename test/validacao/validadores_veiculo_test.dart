import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/models/categoria_veiculo.dart';
import 'package:veiculos_app/validacao/mensagens_validacao.dart';
import 'package:veiculos_app/validacao/validadores_formulario.dart';

void main() {
  const maxAno = 2027;

  group('validarCategoriaVeiculo', () {
    test('null retorna obrigatório', () {
      expect(
        validarCategoriaVeiculo(null),
        MensagensValidacao.categoriaObrigatoria,
      );
    });

    test('valor selecionado passa', () {
      expect(
        validarCategoriaVeiculo(CategoriaVeiculo.carro),
        isNull,
      );
    });
  });

  group('validarMarca', () {
    test('vazio retorna obrigatório', () {
      expect(validarMarca(''), MensagensValidacao.marcaObrigatoria);
    });

    test('61 caracteres retorna max length', () {
      expect(validarMarca('A' * 61), MensagensValidacao.marcaMaxLength);
    });

    test('marca válida passa', () {
      expect(validarMarca('Fiat'), isNull);
    });
  });

  group('validarModelo', () {
    test('vazio retorna obrigatório', () {
      expect(validarModelo('  '), MensagensValidacao.modeloObrigatorio);
    });

    test('61 caracteres retorna max length', () {
      expect(validarModelo('X' * 61), MensagensValidacao.modeloMaxLength);
    });

    test('modelo válido passa', () {
      expect(validarModelo('Uno'), isNull);
    });
  });

  group('validarPlaca', () {
    test('vazio retorna obrigatório', () {
      expect(validarPlaca(''), MensagensValidacao.placaObrigatoria);
    });

    test('formato inválido', () {
      expect(validarPlaca('ABC12'), MensagensValidacao.placaInvalida);
      expect(validarPlaca('1234567'), MensagensValidacao.placaInvalida);
    });

    test('placa antiga passa', () {
      expect(validarPlaca('ABC1234'), isNull);
    });

    test('placa Mercosul passa', () {
      expect(validarPlaca('ABC1D23'), isNull);
    });
  });

  group('validarAnoVeiculo', () {
    test('vazio passa (opcional)', () {
      expect(validarAnoVeiculo('', anoMaximo: maxAno), isNull);
    });

    test('texto inválido', () {
      expect(
        validarAnoVeiculo('abc', anoMaximo: maxAno),
        MensagensValidacao.anoInvalido,
      );
    });

    test('fora do intervalo', () {
      expect(
        validarAnoVeiculo('1800', anoMaximo: maxAno),
        MensagensValidacao.anoForaIntervalo(maxAno),
      );
    });

    test('ano válido passa', () {
      expect(validarAnoVeiculo('2020', anoMaximo: maxAno), isNull);
    });
  });

  group('validarKmVeiculo', () {
    test('vazio retorna obrigatório', () {
      expect(validarKmVeiculo(''), MensagensValidacao.kmAtualObrigatorio);
    });

    test('negativo retorna inválido', () {
      expect(validarKmVeiculo('-1'), MensagensValidacao.kmInvalido);
    });

    test('zero passa', () {
      expect(validarKmVeiculo('0'), isNull);
    });

    test('positivo passa', () {
      expect(validarKmVeiculo('15000'), isNull);
    });
  });
}
