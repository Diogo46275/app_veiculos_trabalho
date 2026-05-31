class ArquivoMultipart {
  const ArquivoMultipart({
    required this.campo,
    required this.bytes,
    required this.nomeArquivo,
  });

  final String campo;
  final List<int> bytes;
  final String nomeArquivo;
}
