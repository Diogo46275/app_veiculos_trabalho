import 'package:flutter/material.dart';

import '../../models/categoria_veiculo.dart';
import '../../models/veiculo.dart';
import '../../theme/app_colors.dart';

class VeiculoListTile extends StatelessWidget {
  const VeiculoListTile({
    super.key,
    required this.veiculo,
    required this.onTap,
  });

  final Veiculo veiculo;
  final VoidCallback onTap;

  String _subtitulo() {
    final partes = <String>[];
    if (veiculo.precisaCompletarCategoria) {
      partes.add('Categoria pendente');
    } else {
      partes.add(veiculo.categoriaEnum!.rotulo);
    }
    partes.add('${veiculo.kmAtual} km');
    if (veiculo.ano != null) {
      partes.add(veiculo.ano.toString());
    }
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final categoria = veiculo.categoriaEnum;
    final icone = VeiculoCategoriaVisual.iconePara(categoria);
    final cor = VeiculoCategoriaVisual.corPara(categoria);

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: veiculo.precisaCompletarCategoria
                  ? AppColors.red
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icone, color: cor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      veiculo.rotulo,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitulo(),
                      style: TextStyle(
                        color: veiculo.precisaCompletarCategoria
                            ? AppColors.red
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
