import 'categoria_veiculo.dart';

class Veiculo {
  const Veiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.kmAtual,
    required this.tipo,
    this.placa,
    this.ano,
    this.categoria,
  });

  final int id;
  final String marca;
  final String modelo;
  final int kmAtual;
  final String tipo;
  final String? placa;
  final int? ano;
  final String? categoria;

  bool get precisaCompletarCategoria =>
      categoria == null || categoria!.isEmpty;

  CategoriaVeiculo? get categoriaEnum =>
      CategoriaVeiculo.fromValor(categoria);

  String get rotulo {
    final base = '$marca $modelo';
    if (placa != null && placa!.isNotEmpty) {
      return '$base · $placa';
    }
    return base;
  }

  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      id: json['id'] as int,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      kmAtual: json['km_atual'] as int? ?? 0,
      tipo: json['tipo'] as String? ?? 'trabalho',
      placa: json['placa'] as String?,
      ano: json['ano'] as int?,
      categoria: json['categoria'] as String?,
    );
  }
}
