class Perfil {
  const Perfil({
    required this.id,
    required this.nome,
    required this.email,
  });

  final int id;
  final String nome;
  final String email;

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }
}
