class Receita {
  const Receita({
    required this.id,
    required this.veiculoId,
    required this.data,
    required this.valor,
    this.periodoTrabalhoId,
    this.plataformaId,
    this.plataformaNome,
    this.descricao,
  });

  final int id;
  final int veiculoId;
  final int? periodoTrabalhoId;
  final int? plataformaId;
  final String? plataformaNome;
  final String data;
  final double valor;
  final String? descricao;

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      periodoTrabalhoId: json['periodo_trabalho_id'] as int?,
      plataformaId: json['plataforma_id'] as int?,
      plataformaNome: json['plataforma_nome'] as String?,
      data: json['data'] as String,
      valor: (json['valor'] as num).toDouble(),
      descricao: json['descricao'] as String?,
    );
  }
}
