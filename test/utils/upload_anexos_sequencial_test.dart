import 'package:flutter_test/flutter_test.dart';
import 'package:veiculos_app/utils/seletor_arquivo.dart';
import 'package:veiculos_app/utils/upload_anexos_sequencial.dart';

void main() {
  group('enviarAnexosSequencialmente', () {
    test('envia um lote quando há só um arquivo', () async {
      final arquivo = ArquivoSelecionado(
        nome: 'a.jpg',
        bytes: [1, 2, 3],
      );
      var chamadas = 0;

      final resultado = await enviarAnexosSequencialmente<int>(
        arquivos: [arquivo],
        enviar: (lote) async {
          chamadas++;
          expect(lote, [arquivo]);
          return 1;
        },
        anexarExtra: (_, __) async => 2,
      );

      expect(resultado, 1);
      expect(chamadas, 1);
    });

    test('envia um arquivo por requisição quando há vários', () async {
      final arquivos = [
        ArquivoSelecionado(nome: 'a.jpg', bytes: [1]),
        ArquivoSelecionado(nome: 'b.jpg', bytes: [2]),
        ArquivoSelecionado(nome: 'c.jpg', bytes: [3]),
      ];
      final lotes = <List<ArquivoSelecionado>>[];

      final resultado = await enviarAnexosSequencialmente<int>(
        arquivos: arquivos,
        enviar: (lote) async {
          lotes.add(List.from(lote));
          return lotes.length;
        },
        anexarExtra: (item, arquivo) async {
          lotes.add([arquivo]);
          return item + 1;
        },
      );

      expect(resultado, 3);
      expect(lotes, [
        [arquivos[0]],
        [arquivos[1]],
        [arquivos[2]],
      ]);
    });
  });
}
