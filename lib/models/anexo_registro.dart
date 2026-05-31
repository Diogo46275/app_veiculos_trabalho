class AnexoRegistro {
  const AnexoRegistro({
    required this.id,
    required this.url,
  });

  final int id;
  final String url;

  factory AnexoRegistro.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final id = idRaw is int ? idRaw : (idRaw as num?)?.toInt() ?? 0;
    return AnexoRegistro(
      id: id,
      url: json['url'] as String,
    );
  }
}
