import '../utils/anexo_url.dart';

class Perfil {
  const Perfil({
    required this.id,
    required this.nome,
    required this.email,
    this.cpf,
    this.cnpj,
    this.fotoUrl,
  });

  final int id;
  final String nome;
  final String email;
  final String? cpf;
  final String? cnpj;
  final String? fotoUrl;

  String? get fotoUrlAbsoluta => AnexoUrl.absoluta(fotoUrl);

  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty) return '?';
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
      cpf: json['cpf'] as String?,
      cnpj: json['cnpj'] as String?,
      fotoUrl: json['foto_url'] as String?,
    );
  }
}
