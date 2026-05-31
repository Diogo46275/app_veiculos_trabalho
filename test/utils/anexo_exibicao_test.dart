import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/models/anexo_registro.dart';
import 'package:veiculos_app/utils/anexo_exibicao.dart';

void main() {
  group('combinarAnexosParaExibicao', () {
    test('une anexos da API com URL legada sem duplicar', () {
      const url1 = 'https://bytes-techus.com.br/veiculos/anexos/nf1.pdf';
      const url2 = 'https://bytes-techus.com.br/veiculos/anexos/nf2.pdf';

      final lista = combinarAnexosParaExibicao(
        anexos: const [
          AnexoRegistro(id: 2, url: url2),
        ],
        urlLegado: url1,
      );

      expect(lista, hasLength(2));
      expect(lista[0].url, url2);
      expect(lista[1].url, url1);
    });

    test('ignora legado quando já está na lista', () {
      const url = 'https://bytes-techus.com.br/veiculos/anexos/nf1.pdf';

      final lista = combinarAnexosParaExibicao(
        anexos: const [AnexoRegistro(id: 1, url: url)],
        urlLegado: url,
      );

      expect(lista, hasLength(1));
    });

    test('retorna só legado quando lista vazia', () {
      const url = 'https://bytes-techus.com.br/veiculos/anexos/nf1.pdf';

      final lista = combinarAnexosParaExibicao(
        anexos: const [],
        urlLegado: url,
      );

      expect(lista, hasLength(1));
      expect(lista.first.id, 0);
      expect(lista.first.url, url);
    });
  });

  group('anexosVisiveisEdicao', () {
    test('mostra todos os anexos na edição sem perder legado', () {
      const url1 = 'https://bytes-techus.com.br/veiculos/anexos/nf1.pdf';
      const url2 = 'https://bytes-techus.com.br/veiculos/anexos/nf2.pdf';
      final anexos = combinarAnexosParaExibicao(
        anexos: const [AnexoRegistro(id: 2, url: url2)],
        urlLegado: url1,
      );

      final visiveis = anexosVisiveisEdicao(
        anexos,
        idsRemover: {},
        urlsRemover: {},
      );

      expect(visiveis, hasLength(2));
    });

    test('remove anexo legado pela url sem afetar os demais', () {
      const url1 = 'https://bytes-techus.com.br/veiculos/anexos/nf1.pdf';
      const url2 = 'https://bytes-techus.com.br/veiculos/anexos/nf2.pdf';
      final anexos = combinarAnexosParaExibicao(
        anexos: const [AnexoRegistro(id: 2, url: url2)],
        urlLegado: url1,
      );

      final visiveis = anexosVisiveisEdicao(
        anexos,
        idsRemover: {},
        urlsRemover: {url1},
      );

      expect(visiveis, hasLength(1));
      expect(visiveis.first.url, url2);
    });
  });
}
