class TipoManutencao {
  const TipoManutencao({required this.id, required this.nome});

  final int id;
  final String nome;

  factory TipoManutencao.fromJson(Map<String, dynamic> json) {
    return TipoManutencao(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }
}
