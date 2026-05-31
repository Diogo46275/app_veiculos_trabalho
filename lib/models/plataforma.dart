class Plataforma {
  const Plataforma({
    required this.id,
    required this.nome,
  });

  final int id;
  final String nome;

  factory Plataforma.fromJson(Map<String, dynamic> json) {
    return Plataforma(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }
}
