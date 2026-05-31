import 'package:flutter/material.dart';

import '../../models/categoria_veiculo.dart';
import '../../models/veiculo.dart';
import '../../theme/app_colors.dart';

class VeiculoResumoHeader extends StatelessWidget {
  const VeiculoResumoHeader({
    super.key,
    required this.veiculo,
    this.onCompletarCadastro,
  });

  final Veiculo veiculo;
  final VoidCallback? onCompletarCadastro;

  String get _rotuloCategoria {
    if (veiculo.precisaCompletarCategoria) return 'Pendente';
    return veiculo.categoriaEnum!.rotulo;
  }

  @override
  Widget build(BuildContext context) {
    final categoria = veiculo.categoriaEnum;
    final icone = VeiculoCategoriaVisual.iconePara(categoria);
    final cor = VeiculoCategoriaVisual.corPara(categoria);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (veiculo.precisaCompletarCategoria && onCompletarCadastro != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: AppColors.red),
                      SizedBox(width: 8),
                      Text(
                        'Categoria pendente',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onCompletarCadastro,
                      child: const Text('Completar cadastro'),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Icon(icone, color: cor, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      veiculo.rotulo,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${veiculo.marca} ${veiculo.modelo}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipInfo(
                label: 'Km',
                valor: '${veiculo.kmAtual} km',
              ),
              _ChipInfo(label: 'Categoria', valor: _rotuloCategoria),
              if (veiculo.ano != null)
                _ChipInfo(label: 'Ano', valor: veiculo.ano.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  const _ChipInfo({required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: $valor',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
