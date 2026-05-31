import '../utils/anexo_exibicao.dart';
import 'anexo_registro.dart';

class Abastecimento {
  const Abastecimento({
    required this.id,
    required this.veiculoId,
    required this.data,
    required this.km,
    required this.litros,
    required this.valor,
    this.posto,
    this.consumoKmL,
    this.documentoTipo = 'sem',
    this.arquivoNfUrl,
    this.anexosNf = const [],
  });

  final int id;
  final int veiculoId;
  final String data;
  final int km;
  final double litros;
  final double valor;
  final String? posto;
  final double? consumoKmL;
  final String documentoTipo;
  final String? arquivoNfUrl;
  final List<AnexoRegistro> anexosNf;

  bool get temAnexoNf => anexosNfParaExibicao.isNotEmpty;

  int get quantidadeAnexosNf => anexosNfParaExibicao.length;

  List<AnexoRegistro> get anexosNfParaExibicao =>
      combinarAnexosParaExibicao(
        anexos: anexosNf,
        urlLegado: arquivoNfUrl,
      );

  factory Abastecimento.fromJson(Map<String, dynamic> json) {
    final anexosRaw = json['anexos_nf'] as List<dynamic>?;
    final anexosNf = anexosRaw == null
        ? const <AnexoRegistro>[]
        : anexosRaw
            .whereType<Map<String, dynamic>>()
            .map(AnexoRegistro.fromJson)
            .toList();

    return Abastecimento(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      data: json['data'] as String,
      km: json['km'] as int,
      litros: (json['litros'] as num).toDouble(),
      valor: (json['valor'] as num).toDouble(),
      posto: json['posto'] as String?,
      consumoKmL: (json['consumo_km_l'] as num?)?.toDouble(),
      documentoTipo: json['documento_tipo'] as String? ?? 'sem',
      arquivoNfUrl: json['arquivo_nf_url'] as String?,
      anexosNf: anexosNf,
    );
  }
}
