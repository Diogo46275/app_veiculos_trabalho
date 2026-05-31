import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/veiculo.dart';
import '../../theme/app_colors.dart';
import 'veiculo_list_tile.dart';

/// Swipe to Action — layout veículos:
/// deslizar → (start): Editar + Excluir | deslizar ← (end): Gestão (detalhe/abas).
/// Efeito de descoberta ao montar a lista (~500ms).
class VeiculoSwipeTile extends StatefulWidget {
  const VeiculoSwipeTile({
    super.key,
    required this.veiculo,
    required this.onTap,
    required this.onEdit,
    required this.onConfirmDelete,
    this.executarDescoberta = false,
    this.mostrarAmbasDirecoes = false,
    this.atrasoDescoberta = Duration.zero,
    this.onDescobertaConcluida,
  });

  final Veiculo veiculo;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final Future<bool> Function() onConfirmDelete;
  final bool executarDescoberta;
  final bool mostrarAmbasDirecoes;
  final Duration atrasoDescoberta;
  final VoidCallback? onDescobertaConcluida;

  static const _botaoRatio = 0.28;
  static const _painelDoisBotoesRatio = 0.52;
  static const _parcialDescoberta = 0.34;
  static const _parcialDescobertaDoisBotoes = 0.42;
  static const _duracaoDescoberta = Duration(milliseconds: 500);

  @override
  State<VeiculoSwipeTile> createState() => _VeiculoSwipeTileState();
}

class _VeiculoSwipeTileState extends State<VeiculoSwipeTile>
    with SingleTickerProviderStateMixin {
  late final SlidableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
    if (widget.executarDescoberta) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _animarDescoberta());
    }
  }

  @override
  void didUpdateWidget(covariant VeiculoSwipeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.executarDescoberta && !oldWidget.executarDescoberta) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _animarDescoberta());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animarDescoberta() async {
    await Future<void>.delayed(widget.atrasoDescoberta);
    if (!mounted) return;

    await _controller.openTo(
      VeiculoSwipeTile._parcialDescobertaDoisBotoes,
      duration: VeiculoSwipeTile._duracaoDescoberta,
      curve: Curves.easeOut,
    );
    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    await _controller.close(duration: const Duration(milliseconds: 280));
    if (!mounted) return;

    if (widget.mostrarAmbasDirecoes) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;

      await _controller.openTo(
        -VeiculoSwipeTile._parcialDescoberta,
        duration: VeiculoSwipeTile._duracaoDescoberta,
        curve: Curves.easeOut,
      );
      if (!mounted) return;

      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;

      await _controller.close(duration: const Duration(milliseconds: 280));
    }

    widget.onDescobertaConcluida?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Slidable(
        key: ValueKey<int>(widget.veiculo.id),
        controller: _controller,
        groupTag: 'veiculos',
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: VeiculoSwipeTile._painelDoisBotoesRatio,
          openThreshold: 0.12,
          closeThreshold: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) => widget.onEdit(),
              backgroundColor: AppColors.blueBackground,
              foregroundColor: AppColors.textPrimary,
              icon: Icons.edit_outlined,
              label: 'Editar',
              flex: 1,
            ),
            SlidableAction(
              onPressed: (_) => widget.onConfirmDelete(),
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.textPrimary,
              icon: Icons.delete_outline,
              label: 'Excluir',
              flex: 1,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: VeiculoSwipeTile._botaoRatio,
          openThreshold: 0.12,
          closeThreshold: 0.2,
          children: [
            SlidableAction(
              onPressed: (_) => widget.onTap(),
              backgroundColor: AppColors.green,
              foregroundColor: AppColors.textPrimary,
              icon: Icons.dashboard_customize_outlined,
              label: 'Gestão',
            ),
          ],
        ),
        child: VeiculoListTile(
          veiculo: widget.veiculo,
          onTap: widget.onTap,
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
        'Excluir ${veiculo.rotulo}?\n\n'
        'Todos os abastecimentos, manutenções, alertas e períodos '
        'deste veículo serão apagados.\n'
        'Esta ação não pode ser desfeita.',
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
