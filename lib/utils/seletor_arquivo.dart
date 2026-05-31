import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Limite da API (FastAPI).
const tamanhoMaxAnexoBytes = 5 * 1024 * 1024;

/// Limite prático de envio — nginx/proxy costuma bloquear acima de ~1 MB (HTTP 413).
const tamanhoMaxUploadAnexoBytes = 1024 * 1024;

const tamanhoMaxFotoPerfilBytes = 2 * 1024 * 1024;

const extensoesAnexo = ['pdf', 'jpg', 'jpeg', 'png'];
const extensoesFotoPerfil = ['jpg', 'jpeg', 'png'];

/// Redimensionamento para NF/garantia (câmera e galeria).
const _larguraMaxImagemAnexo = 1280;
const _alturaMaxImagemAnexo = 1280;
const _qualidadeImagemAnexo = 72;

enum OrigemAnexo {
  camera,
  galeria,
  pdf,
}

class ArquivoSelecionado {
  const ArquivoSelecionado({
    required this.nome,
    required this.bytes,
  });

  final String nome;
  final List<int> bytes;
}

class SelecaoArquivoException implements Exception {
  SelecaoArquivoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Menu: câmera, galeria ou PDF.
Future<ArquivoSelecionado?> escolherAnexoComDialog(BuildContext context) async {
  final origem = await showModalBottomSheet<OrigemAnexo>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tirar foto'),
            subtitle: const Text('Ideal para nota fiscal — comprime automaticamente'),
            onTap: () => Navigator.of(context).pop(OrigemAnexo.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Escolher da galeria'),
            subtitle: const Text('Imagem comprimida para envio'),
            onTap: () => Navigator.of(context).pop(OrigemAnexo.galeria),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Escolher PDF'),
            onTap: () => Navigator.of(context).pop(OrigemAnexo.pdf),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (origem == null) return null;

  return switch (origem) {
    OrigemAnexo.camera => selecionarImagemAnexo(ImageSource.camera),
    OrigemAnexo.galeria => selecionarImagemAnexo(ImageSource.gallery),
    OrigemAnexo.pdf => selecionarPdfAnexo(),
  };
}

Future<ArquivoSelecionado?> selecionarImagemAnexo(ImageSource source) async {
  final picker = ImagePicker();
  final imagem = await picker.pickImage(
    source: source,
    maxWidth: _larguraMaxImagemAnexo.toDouble(),
    maxHeight: _alturaMaxImagemAnexo.toDouble(),
    imageQuality: _qualidadeImagemAnexo,
    preferredCameraDevice: CameraDevice.rear,
  );

  if (imagem == null) return null;

  final bytes = await imagem.readAsBytes();
  final nome = _nomeImagemAnexo(imagem.name, source);

  _validarExtensao(nome, extensoesAnexo, 'Use JPG ou PNG.');
  _validarTamanhoUpload(bytes.length);

  return ArquivoSelecionado(nome: nome, bytes: bytes);
}

Future<ArquivoSelecionado?> selecionarPdfAnexo() async {
  final resultado = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
    withData: true,
    allowMultiple: false,
  );

  if (resultado == null || resultado.files.isEmpty) return null;

  final arquivo = resultado.files.single;
  final bytes = arquivo.bytes;
  final nome = arquivo.name.trim();

  if (bytes == null || bytes.isEmpty) {
    throw SelecaoArquivoException('Não foi possível ler o PDF selecionado.');
  }
  if (nome.isEmpty) {
    throw SelecaoArquivoException('Arquivo sem nome.');
  }

  _validarExtensao(nome, const ['pdf'], 'Use PDF.');
  _validarTamanho(bytes.length, tamanhoMaxAnexoBytes, 'PDF maior que 5 MB.');
  _validarTamanhoUpload(bytes.length);

  return ArquivoSelecionado(nome: nome, bytes: bytes);
}

Future<ArquivoSelecionado?> selecionarFotoPerfil() async {
  final picker = ImagePicker();
  final imagem = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
  );

  if (imagem == null) return null;

  final bytes = await imagem.readAsBytes();
  final nome = imagem.name.trim().isNotEmpty ? imagem.name : 'foto.jpg';

  _validarExtensao(nome, extensoesFotoPerfil, 'Use JPG ou PNG.');
  _validarTamanho(
    bytes.length,
    tamanhoMaxFotoPerfilBytes,
    'Arquivo maior que 2 MB.',
  );

  return ArquivoSelecionado(nome: nome, bytes: bytes);
}

String _nomeImagemAnexo(String nomeOriginal, ImageSource source) {
  final limpo = nomeOriginal.trim();
  if (limpo.isNotEmpty && limpo.contains('.')) {
    final ext = limpo.split('.').last.toLowerCase();
    if (extensoesAnexo.contains(ext)) return limpo;
  }
  final prefixo = source == ImageSource.camera ? 'nf_camera' : 'nf_galeria';
  return '$prefixo.jpg';
}

void _validarExtensao(
  String nome,
  List<String> permitidas,
  String mensagem,
) {
  final ponto = nome.lastIndexOf('.');
  if (ponto < 0) throw SelecaoArquivoException(mensagem);
  final ext = nome.substring(ponto + 1).toLowerCase();
  if (!permitidas.contains(ext)) {
    throw SelecaoArquivoException(mensagem);
  }
}

void _validarTamanho(int bytes, int maximo, String mensagem) {
  if (bytes > maximo) throw SelecaoArquivoException(mensagem);
}

void _validarTamanhoUpload(int bytes) {
  if (bytes <= tamanhoMaxUploadAnexoBytes) return;

  throw SelecaoArquivoException(
    'Arquivo ainda grande demais (${_formatarTamanho(bytes)}). '
    'Para foto, aproxime-se do documento. Para PDF, use arquivo menor que 1 MB '
    'ou envie sem anexo.',
  );
}

String _formatarTamanho(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024).round()} KB';
}

/// Nome seguro para multipart (sem caminho, caracteres problemáticos).
String nomeArquivoUploadSeguro(String nome) {
  final base = nome.split(RegExp(r'[/\\]')).last.trim();
  if (base.isEmpty) return 'anexo.bin';
  return base.replaceAll(RegExp(r'[^\w.\- ]'), '_');
}
