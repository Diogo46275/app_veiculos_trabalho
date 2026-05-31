import '../models/anexo_registro.dart';
import 'anexo_url.dart';
import 'seletor_arquivo.dart';

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

/// Rotulo amigável para exibição de anexo (nome original ou URL).
String rotuloAnexo(AnexoRegistro anexo, int indice) {
  final nome = anexo.nomeOriginal?.trim();
  if (nome != null && nome.isNotEmpty) {
    return nome;
  }
  final url = anexo.url;
  final nomeUrl = url.split('/').where((p) => p.isNotEmpty).lastOrNull;
  if (nomeUrl != null && nomeUrl.contains('.')) {
    return 'Anexo ${indice + 1} — $nomeUrl';
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

int totalAnexosVisiveis(
  List<AnexoRegistro> anexos, {
  required Set<int> idsRemover,
  required Set<String> urlsRemover,
  required int arquivosNovos,
}) {
  return anexosVisiveisEdicao(
        anexos,
        idsRemover: idsRemover,
        urlsRemover: urlsRemover,
      ).length +
      arquivosNovos;
}

bool excedeLimiteAnexos(
  List<AnexoRegistro> anexos, {
  required Set<int> idsRemover,
  required Set<String> urlsRemover,
  required int arquivosNovos,
  int adicionar = 1,
}) {
  return totalAnexosVisiveis(
        anexos,
        idsRemover: idsRemover,
        urlsRemover: urlsRemover,
        arquivosNovos: arquivosNovos,
      ) +
          adicionar >
      maxAnexosPorRegistro;
}
