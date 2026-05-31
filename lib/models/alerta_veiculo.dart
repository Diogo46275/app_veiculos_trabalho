class AlertaVeiculo {
  const AlertaVeiculo({
    required this.id,
    required this.veiculoId,
    required this.titulo,
    required this.tipo,
    required this.valorAlerta,
    required this.antecedencia,
    required this.ativo,
    required this.status,
    this.kmLimite,
    this.dataLimite,
    this.kmRestante,
    this.diasRestantes,
  });

  final int id;
  final int veiculoId;
  final String titulo;
  final String tipo;
  final int valorAlerta;
  final int antecedencia;
  final bool ativo;
  final String status;
  final int? kmLimite;
  final String? dataLimite;
  final int? kmRestante;
  final int? diasRestantes;

  factory AlertaVeiculo.fromJson(Map<String, dynamic> json) {
    return AlertaVeiculo(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      titulo: json['titulo'] as String? ?? _tituloLegado(json['tipo'] as String),
      tipo: json['tipo'] as String,
      valorAlerta: json['valor_alerta'] as int,
      antecedencia: json['antecedencia'] as int? ?? 1,
      ativo: json['ativo'] as bool? ?? true,
      status: json['status'] as String? ?? 'ok',
      kmLimite: json['km_limite'] as int?,
      dataLimite: json['data_limite'] as String?,
      kmRestante: json['km_restante'] as int?,
      diasRestantes: json['dias_restantes'] as int?,
    );
  }

  static String _tituloLegado(String tipo) {
    return tipo == 'km' ? 'Alerta por km' : 'Alerta por data';
  }
}
