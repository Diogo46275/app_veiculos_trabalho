import '../utils/anexo_exibicao.dart';
import 'anexo_registro.dart';

class Despesa {
  const Despesa({
    required this.id,
    required this.veiculoId,
    required this.categoriaDespesaId,
    required this.categoriaNome,
    required this.categoriaIcone,
    required this.data,
    required this.valor,
    this.descricao,
    this.km,
    this.anexosNf = const [],
  });

  final int id;
  final int veiculoId;
  final int categoriaDespesaId;
  final String categoriaNome;
  final String categoriaIcone;
  final String data;
  final double valor;
  final String? descricao;
  final int? km;
  final List<AnexoRegistro> anexosNf;

  String get rotuloCategoria => '$categoriaIcone $categoriaNome';

  bool get temAnexoNf => anexosNfParaExibicao.isNotEmpty;

  int get quantidadeAnexosNf => anexosNfParaExibicao.length;

  List<AnexoRegistro> get anexosNfParaExibicao =>
      combinarAnexosParaExibicao(anexos: anexosNf, urlLegado: null);

  factory Despesa.fromJson(Map<String, dynamic> json) {
    final anexosRaw = json['anexos_nf'] as List<dynamic>?;
    final anexosNf = anexosRaw == null
        ? const <AnexoRegistro>[]
        : anexosRaw
            .whereType<Map<String, dynamic>>()
            .map(AnexoRegistro.fromJson)
            .toList();

    return Despesa(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      categoriaDespesaId: json['categoria_despesa_id'] as int,
      categoriaNome: json['categoria_nome'] as String? ?? '',
      categoriaIcone: json['categoria_icone'] as String? ?? '📋',
      data: json['data'] as String,
      valor: (json['valor'] as num).toDouble(),
      descricao: json['descricao'] as String?,
      km: json['km'] as int?,
      anexosNf: anexosNf,
    );
  }
}
