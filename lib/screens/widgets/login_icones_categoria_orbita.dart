import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/categoria_veiculo.dart';

/// Ícones de categoria em órbita — escala, raio e rotação controlados pelo pai.
class LoginIconesCategoriaOrbita extends StatelessWidget {
  const LoginIconesCategoriaOrbita({
    super.key,
    required this.escala,
    required this.fatorRaio,
    required this.rotacao,
  });

  /// Escala do grupo (0 = centro, 1 = tamanho normal).
  final double escala;

  /// Multiplicador do raio da órbita (0 = centro, 1 = órbita completa).
  final double fatorRaio;

  /// Rotação acumulada em radianos.
  final double rotacao;

  static const tamanhoArea = 136.0;
  static const raioOrbita = 44.0;
  static const tamanhoIcone = 26.0;

  /// Altura reservada na coluna — evita sobrepor título/campos abaixo.
  static const alturaReservada = tamanhoArea + 16.0;

  @override
  Widget build(BuildContext context) {
    final categorias = CategoriaVeiculo.values;
    final centro = tamanhoArea / 2;
    final raioAtual = raioOrbita * fatorRaio.clamp(0.0, 1.0);
    final escalaAtual = escala.clamp(0.0, 1.0);

    return SizedBox(
      width: tamanhoArea,
      height: tamanhoArea,
      child: Transform.scale(
        scale: escalaAtual,
        alignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            for (var i = 0; i < categorias.length; i++)
              _posicionarIcone(
                categoria: categorias[i],
                indice: i,
                total: categorias.length,
                rotacao: rotacao,
                raio: raioAtual,
                centro: centro,
                atrasoEspiral: i / categorias.length,
                fatorRaio: fatorRaio.clamp(0.0, 1.0),
              ),
          ],
        ),
      ),
    );
  }

  Widget _posicionarIcone({
    required CategoriaVeiculo categoria,
    required int indice,
    required int total,
    required double rotacao,
    required double raio,
    required double centro,
    required double atrasoEspiral,
    required double fatorRaio,
  }) {
    // Stagger suave — cada ícone segue a mesma curva, com pequeno atraso.
    final atraso = atrasoEspiral * 0.18;
    final bruto = ((fatorRaio - atraso) / (1 - atraso)).clamp(0.0, 1.0);
    final progressoIcone = Curves.easeOutCubic.transform(bruto);
    final raioIcone = raioOrbita * progressoIcone;
    final angulo =
        rotacao + (2 * math.pi * indice / total) - (math.pi / 2);
    final dx = raioIcone * math.cos(angulo);
    final dy = raioIcone * math.sin(angulo);
    final escalaIcone = 0.35 + (0.65 * progressoIcone);

    return Positioned(
      left: centro + dx - (tamanhoIcone / 2),
      top: centro + dy - (tamanhoIcone / 2),
      child: Transform.scale(
        scale: escalaIcone,
        child: Icon(
          categoria.icone,
          size: tamanhoIcone,
          color: categoria.cor,
        ),
      ),
    );
  }
}
