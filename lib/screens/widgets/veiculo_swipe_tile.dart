import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/veiculo.dart';
import '../../theme/app_colors.dart';
import 'veiculo_list_tile.dart';

/// Swipe to Action — PREFERENCES_MOBILE.md:
/// deslizar direita (→) = editar | deslizar esquerda (←) = editar + excluir.
class VeiculoSwipeTile extends StatelessWidget {
  const VeiculoSwipeTile({
    super.key,
    required this.veiculo,
    required this.onTap,
    required this.onEdit,
    required this.onConfirmDelete,
  });

  final Veiculo veiculo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Future<bool> Function() onConfirmDelete;

  /// Largura de um botão (~100px em telas comuns).
  static const _umBotaoRatio = 0.28;

  /// Largura para editar + excluir lado a lado.
  static const _doisBotoesRatio = 0.52;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Slidable(
        key: ValueKey<int>(veiculo.id),
        groupTag: 'veiculos',
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: _umBotaoRatio,
          openThreshold: 0.12,
          closeThreshold: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppColors.blueBackground,
              foregroundColor: AppColors.textPrimary,
              icon: Icons.edit_outlined,
              label: 'Editar',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: _doisBotoesRatio,
          openThreshold: 0.12,
          closeThreshold: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppColors.blueBackground,
              foregroundColor: AppColors.textPrimary,
              icon: Icons.edit_outlined,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (_) => onConfirmDelete(),
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.textPrimary,
              icon: Icons.delete_outline,
              label: 'Excluir',
            ),
          ],
        ),
        child: VeiculoListTile(
          veiculo: veiculo,
          onTap: onTap,
        ),
      ),
    );
  }
}

Future<bool> confirmarExclusaoVeiculo(
  BuildContext context,
  Veiculo veiculo,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir veículo'),
      content: Text(
        'Excluir ${veiculo.rotulo}?\nEsta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.red),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
