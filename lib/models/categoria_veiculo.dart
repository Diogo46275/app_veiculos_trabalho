import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum CategoriaVeiculo {
  moto('moto', 'Moto'),
  carro('carro', 'Carro'),
  van('van', 'Van'),
  caminhao('caminhao', 'Caminhão'),
  carreta('carreta', 'Carreta');

  const CategoriaVeiculo(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static CategoriaVeiculo? fromValor(String? valor) {
    if (valor == null || valor.isEmpty) return null;
    for (final item in CategoriaVeiculo.values) {
      if (item.valor == valor) return item;
    }
    return null;
  }

  IconData get icone {
    switch (this) {
      case CategoriaVeiculo.moto:
        return Icons.two_wheeler;
      case CategoriaVeiculo.carro:
        return Icons.directions_car_outlined;
      case CategoriaVeiculo.van:
        return Icons.airport_shuttle_outlined;
      case CategoriaVeiculo.caminhao:
        return Icons.local_shipping_outlined;
      case CategoriaVeiculo.carreta:
        return Icons.rv_hookup_outlined;
    }
  }

  Color get cor {
    switch (this) {
      case CategoriaVeiculo.moto:
        return AppColors.blueText;
      case CategoriaVeiculo.carro:
        return AppColors.green;
      case CategoriaVeiculo.van:
        return AppColors.gold;
      case CategoriaVeiculo.caminhao:
        return AppColors.blueBackground;
      case CategoriaVeiculo.carreta:
        return const Color(0xFFBB8FCE);
    }
  }
}

abstract final class VeiculoCategoriaVisual {
  static IconData iconePara(CategoriaVeiculo? categoria) {
    if (categoria == null) return Icons.warning_amber_outlined;
    return categoria.icone;
  }

  static Color corPara(CategoriaVeiculo? categoria) {
    if (categoria == null) return AppColors.red;
    return categoria.cor;
  }
}
