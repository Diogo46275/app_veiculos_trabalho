import '../models/anexo_registro.dart';
import 'anexo_url.dart';

List<AnexoRegistro> combinarAnexosParaExibicao({
  required List<AnexoRegistro> anexos,
  required String? urlLegado,
}) {
  final urlsVistas = <String>{};
  final lista = <AnexoRegistro>[];

  void incluir(AnexoRegistro anexo) {
    final chave = AnexoUrl.absoluta(anexo.url) ?? anexo.url;
    if (urlsVistas.add(chave)) {
      lista.add(anexo);
    }
  }

  for (final anexo in anexos) {
    incluir(anexo);
  }

  final legado = urlLegado;
  if (legado != null && legado.isNotEmpty) {
    incluir(AnexoRegistro(id: 0, url: legado));
  }

  return lista;
}

/// Rotulo amigável para exibição de anexo (índice + nome do arquivo).
String rotuloAnexo(AnexoRegistro anexo, int indice) {
  final url = anexo.url;
  final nome = url.split('/').where((p) => p.isNotEmpty).lastOrNull;
  if (nome != null && nome.contains('.')) {
    return 'Anexo ${indice + 1} — $nome';
  }
  return 'Anexo ${indice + 1}';
}

List<AnexoRegistro> anexosNfEfetivos({
  required List<AnexoRegistro> anexos,
  required String? urlLegado,
}) {
  if (anexos.isNotEmpty) return anexos;
  if (urlLegado != null && urlLegado.isNotEmpty) {
    return [AnexoRegistro(id: 0, url: urlLegado)];
  }
  return const [];
}

String chaveUrlAnexo(AnexoRegistro anexo) {
  return AnexoUrl.absoluta(anexo.url) ?? anexo.url;
}

bool anexoMarcadoRemover(
  AnexoRegistro anexo, {
  required Set<int> idsRemover,
  required Set<String> urlsRemover,
}) {
  if (anexo.id > 0) return idsRemover.contains(anexo.id);
  return urlsRemover.contains(chaveUrlAnexo(anexo));
}

List<AnexoRegistro> anexosVisiveisEdicao(
  List<AnexoRegistro> anexos, {
  required Set<int> idsRemover,
  required Set<String> urlsRemover,
}) {
  return anexos
      .where(
        (anexo) => !anexoMarcadoRemover(
          anexo,
          idsRemover: idsRemover,
          urlsRemover: urlsRemover,
        ),
      )
      .toList();
}

bool todosAnexosMarcadosRemover(
  List<AnexoRegistro> anexos, {
  required Set<int> idsRemover,
  required Set<String> urlsRemover,
}) {
  if (anexos.isEmpty) return false;
  return anexos.every(
    (anexo) => anexoMarcadoRemover(
      anexo,
      idsRemover: idsRemover,
      urlsRemover: urlsRemover,
    ),
  );
}
