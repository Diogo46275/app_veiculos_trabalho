import '../models/arquivo_multipart.dart';
import '../utils/seletor_arquivo.dart';

/// Envia anexos um por requisição quando há mais de um arquivo novo.
/// Evita perda de arquivos quando o servidor aceita só um por multipart.
Future<T> enviarAnexosSequencialmente<T>({
  required List<ArquivoSelecionado> arquivos,
  required Future<T> Function(List<ArquivoSelecionado> lote) enviar,
  required Future<T> Function(T item, ArquivoSelecionado arquivo) anexarExtra,
}) async {
  if (arquivos.isEmpty) {
    return enviar(const []);
  }
  if (arquivos.length == 1) {
    return enviar(arquivos);
  }

  var resultado = await enviar([arquivos.first]);
  for (var i = 1; i < arquivos.length; i++) {
    resultado = await anexarExtra(resultado, arquivos[i]);
  }
  return resultado;
}

List<ArquivoMultipart> arquivosMultipartCampo({
  required String campo,
  required List<ArquivoSelecionado> arquivos,
}) {
  return arquivos
      .map(
        (arquivo) => ArquivoMultipart(
          campo: campo,
          bytes: arquivo.bytes,
          nomeArquivo: nomeArquivoUploadSeguro(arquivo.nome),
        ),
      )
      .toList();
}
