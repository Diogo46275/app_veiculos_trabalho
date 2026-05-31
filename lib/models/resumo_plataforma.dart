class ResumoPlataforma {
  const ResumoPlataforma({
    required this.plataforma,
    required this.total,
    required this.quantidade,
  });

  final String plataforma;
  final double total;
  final int quantidade;

  factory ResumoPlataforma.fromJson(Map<String, dynamic> json) {
    return ResumoPlataforma(
      plataforma: json['plataforma'] as String,
      total: (json['total'] as num).toDouble(),
      quantidade: json['quantidade'] as int,
    );
  }
}
