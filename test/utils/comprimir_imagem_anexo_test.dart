import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:veiculos_app/utils/comprimir_imagem_anexo.dart';
import 'package:veiculos_app/utils/seletor_arquivo.dart';

void main() {
  group('comprimirImagemAnexoBytes', () {
    test('reduz imagem grande para caber no limite de upload', () {
      final imagem = img.Image(width: 4000, height: 3000);
      for (var y = 0; y < imagem.height; y += 4) {
        for (var x = 0; x < imagem.width; x += 4) {
          imagem.setPixelRgb(x, y, x % 256, y % 256, (x + y) % 256);
        }
      }
      final grande = img.encodeJpg(imagem, quality: 100);

      final comprimida = comprimirImagemAnexoBytes(
        grande,
        tamanhoMaxBytes: tamanhoMaxUploadAnexoBytes,
      );

      expect(comprimida.length, lessThanOrEqualTo(tamanhoMaxUploadAnexoBytes));
      final decodificada = img.decodeImage(Uint8List.fromList(comprimida));
      expect(decodificada, isNotNull);
      expect(decodificada!.width, lessThanOrEqualTo(larguraMaxImagemAnexo));
    });

    test('nomeImagemAnexoComprimida usa extensão jpg', () {
      expect(
        nomeImagemAnexoComprimida('nota_fiscal.PNG'),
        'nota_fiscal.jpg',
      );
    });
  });
}
