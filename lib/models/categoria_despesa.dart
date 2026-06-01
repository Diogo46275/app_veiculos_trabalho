class CategoriaDespesa {
  const CategoriaDespesa({
    required this.id,
    required this.veiculoId,
    required this.nome,
    required this.icone,
  });

  final int id;
  final int veiculoId;
  final String nome;
  final String icone;

  factory CategoriaDespesa.fromJson(Map<String, dynamic> json) {
    return CategoriaDespesa(
      id: json['id'] as int,
      veiculoId: json['veiculo_id'] as int,
      nome: json['nome'] as String,
      icone: json['icone'] as String? ?? '📋',
    );
  }
}
