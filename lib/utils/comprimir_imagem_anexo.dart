import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Mesmos limites do [ImagePicker] em `seletor_arquivo.dart`.
const larguraMaxImagemAnexo = 1280;
const alturaMaxImagemAnexo = 1280;
const qualidadeInicialImagemAnexo = 72;
const qualidadeMinimaImagemAnexo = 40;

const extensoesImagemAnexo = {'jpg', 'jpeg', 'png'};

bool extensaoEhImagemAnexo(String extensao) {
  return extensoesImagemAnexo.contains(extensao.toLowerCase());
}

String? extensaoArquivo(String nome) {
  final ponto = nome.lastIndexOf('.');
  if (ponto < 0) return null;
  return nome.substring(ponto + 1).toLowerCase();
}

bool nomeArquivoEhImagemAnexo(String nome) {
  final ext = extensaoArquivo(nome);
  return ext != null && extensaoEhImagemAnexo(ext);
}

/// Nome de saída após compressão (sempre JPG, como na câmera).
String nomeImagemAnexoComprimida(String nomeOriginal) {
  final base = nomeOriginal.split(RegExp(r'[/\\]')).last.trim();
  if (base.isEmpty) return 'anexo_galeria.jpg';
  final ponto = base.lastIndexOf('.');
  final stem = ponto > 0 ? base.substring(0, ponto) : base;
  return '$stem.jpg';
}

/// Redimensiona e comprime imagem para envio (paridade câmera × arquivo).
List<int> comprimirImagemAnexoBytes(
  List<int> bytes, {
  int tamanhoMaxBytes = 1024 * 1024,
}) {
  final decodificada = img.decodeImage(Uint8List.fromList(bytes));
  if (decodificada == null) {
    throw FormatException('Imagem inválida');
  }

  var imagem = img.bakeOrientation(decodificada);
  imagem = _redimensionarImagemAnexo(imagem);

  var qualidade = qualidadeInicialImagemAnexo;
  List<int> comprimida = img.encodeJpg(imagem, quality: qualidade);

  while (comprimida.length > tamanhoMaxBytes &&
      qualidade > qualidadeMinimaImagemAnexo) {
    qualidade -= 10;
    comprimida = img.encodeJpg(imagem, quality: qualidade);
  }

  return comprimida;
}

img.Image _redimensionarImagemAnexo(img.Image imagem) {
  if (imagem.width <= larguraMaxImagemAnexo &&
      imagem.height <= alturaMaxImagemAnexo) {
    return imagem;
  }

  if (imagem.width >= imagem.height) {
    return img.copyResize(imagem, width: larguraMaxImagemAnexo);
  }
  return img.copyResize(imagem, height: alturaMaxImagemAnexo);
}
