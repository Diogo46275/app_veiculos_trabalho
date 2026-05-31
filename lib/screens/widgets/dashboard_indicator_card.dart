import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DashboardIndicatorCard extends StatelessWidget {
  const DashboardIndicatorCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.corValor,
  });

  final String titulo;
  final String valor;
  final Color corValor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              color: corValor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
