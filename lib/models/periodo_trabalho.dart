import 'resumo_plataforma.dart';

class PeriodoTrabalho {
  const PeriodoTrabalho({
    required this.id,
    required this.veiculoId,
    required this.dataHoraInicio,
    required this.kmInicio,
    required this.status,
    this.dataHoraFim,
    this.kmFim,
    this.kmRodado,
    this.totalGanhos = 0,
    this.horasTrabalhadas,
    this.ganhoPorHora,
    this.plataformaDestaque,
    this.resumoPlataformas = const [],
  });

  final int id;
  final int veiculoId;
  final String dataHoraInicio;
  final int kmInicio;
  final String status;
  final String? dataHoraFim;
  final int? kmFim;
  final int? kmRodado;
  final double totalGanhos;
  final double? horasTrabalhadas;
  final double? ganhoPorHora;
  final String? plataformaDestaque;
  final List<ResumoPlataforma> resumoPlataformas;

  bool get aberto => status == 'aberto';

  factory PeriodoTrabalho.fromJson(Map<String, dynamic> json) {
    final resumo = json['resumo_plataformas'];
    return PeriodoTrabalho(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      dataHoraInicio: json['data_hora_inicio'] as String,
      kmInicio: json['km_inicio'] as int,
      status: json['status'] as String? ?? 'fechado',
      dataHoraFim: json['data_hora_fim'] as String?,
      kmFim: json['km_fim'] as int?,
      kmRodado: json['km_rodado'] as int?,
      totalGanhos: (json['total_ganhos'] as num?)?.toDouble() ?? 0,
      horasTrabalhadas: (json['horas_trabalhadas'] as num?)?.toDouble(),
      ganhoPorHora: (json['ganho_por_hora'] as num?)?.toDouble(),
      plataformaDestaque: json['plataforma_destaque'] as String?,
      resumoPlataformas: resumo is List
          ? resumo
              .whereType<Map<String, dynamic>>()
              .map(ResumoPlataforma.fromJson)
              .toList()
          : const [],
    );
  }
}
