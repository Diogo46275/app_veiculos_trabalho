import '../utils/anexo_exibicao.dart';
import 'anexo_registro.dart';

class Manutencao {
  const Manutencao({
    required this.id,
    required this.veiculoId,
    required this.tipoManutencaoId,
    required this.tipo,
    required this.data,
    required this.valor,
    required this.garantiaStatus,
    required this.documentoTipo,
    this.arquivoNfUrl,
    this.arquivoGarantiaUrl,
    this.anexosNf = const [],
    this.anexosGarantia = const [],
    this.descricao,
    this.km,
    this.garantiaDias,
    this.garantiaVencimento,
  });

  final int id;
  final int veiculoId;
  final int tipoManutencaoId;
  final String tipo;
  final String data;
  final double valor;
  final String garantiaStatus;
  final String documentoTipo;
  final String? arquivoNfUrl;
  final String? arquivoGarantiaUrl;
  final List<AnexoRegistro> anexosNf;
  final List<AnexoRegistro> anexosGarantia;
  final String? descricao;
  final int? km;
  final int? garantiaDias;
  final String? garantiaVencimento;

  int get quantidadeAnexosNf => anexosNfParaExibicao.length;

  int get quantidadeAnexosGarantia => anexosGarantiaParaExibicao.length;

  List<AnexoRegistro> get anexosNfParaExibicao =>
      combinarAnexosParaExibicao(
        anexos: anexosNf,
        urlLegado: arquivoNfUrl,
      );

  List<AnexoRegistro> get anexosGarantiaParaExibicao =>
      combinarAnexosParaExibicao(
        anexos: anexosGarantia,
        urlLegado: arquivoGarantiaUrl,
      );

  factory Manutencao.fromJson(Map<String, dynamic> json) {
    return Manutencao(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      tipoManutencaoId: json['tipo_manutencao_id'] as int,
      tipo: json['tipo'] as String,
      data: json['data'] as String,
      valor: (json['valor'] as num).toDouble(),
      garantiaStatus: json['garantia_status'] as String? ?? 'sem',
      documentoTipo: json['documento_tipo'] as String? ?? 'sem',
      arquivoNfUrl: json['arquivo_nf_url'] as String?,
      arquivoGarantiaUrl: json['arquivo_garantia_url'] as String?,
      anexosNf: _parseAnexos(json['anexos_nf']),
      anexosGarantia: _parseAnexos(json['anexos_garantia']),
      descricao: json['descricao'] as String?,
      km: json['km'] as int?,
      garantiaDias: json['garantia_dias'] as int?,
      garantiaVencimento: json['garantia_vencimento'] as String?,
    );
  }

  static List<AnexoRegistro> _parseAnexos(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AnexoRegistro.fromJson)
        .toList();
  }
}
