import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class EstadoListaTab extends StatelessWidget {
  const EstadoListaTab({
    super.key,
    required this.carregando,
    required this.erro,
    required this.vazio,
    required this.mensagemVazio,
    required this.onRecarregar,
    required this.child,
    this.iconeVazio = Icons.inbox_outlined,
  });

  final bool carregando;
  final String? erro;
  final bool vazio;
  final String mensagemVazio;
  final VoidCallback onRecarregar;
  final Widget child;
  final IconData iconeVazio;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onRecarregar,
                  child: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (vazio) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconeVazio, color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 12),
              Text(
                mensagemVazio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}

class DetalheItemCard extends StatelessWidget {
  const DetalheItemCard({
    super.key,
    required this.titulo,
    required this.linhas,
    this.corTitulo,
    this.destaque,
    this.corDestaque,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onReset,
  });

  final String titulo;
  final List<String> linhas;
  final Color? corTitulo;
  final String? destaque;
  final Color? corDestaque;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titulo,
                            style: TextStyle(
                              color: corTitulo ?? AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (destaque != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (corDestaque ?? AppColors.blueText)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              destaque!,
                              style: TextStyle(
                                color: corDestaque ?? AppColors.blueText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (onTap != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...linhas.map(
                      (linha) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          linha,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onEdit != null || onDelete != null || onReset != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.blueText,
                        minimumSize: const Size(44, 44),
                      ),
                    ),
                  if (onReset != null)
                    TextButton.icon(
                      onPressed: onReset,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Resetar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        minimumSize: const Size(44, 44),
                      ),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Excluir'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.red,
                        minimumSize: const Size(44, 44),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
