import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'estado_lista_tab.dart';

/// Lista com formulário inline para cadastros de nome (plataformas, tipos).
class PerfilSecaoListaNome extends StatelessWidget {
  const PerfilSecaoListaNome({
    super.key,
    required this.titulo,
    required this.ajuda,
    required this.labelCampo,
    required this.placeholder,
    required this.itens,
    required this.nomeController,
    required this.editandoId,
    required this.salvando,
    required this.erro,
    required this.onSalvar,
    required this.onCancelarEdicao,
    required this.onEditar,
    required this.onExcluir,
  });

  final String titulo;
  final String ajuda;
  final String labelCampo;
  final String placeholder;
  final List<({int id, String nome})> itens;
  final TextEditingController nomeController;
  final int? editandoId;
  final bool salvando;
  final String? erro;
  final VoidCallback onSalvar;
  final VoidCallback onCancelarEdicao;
  final void Function(int id, String nome) onEditar;
  final void Function(int id, String nome) onExcluir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ajuda,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (erro != null) ...[
            const SizedBox(height: 12),
            Text(erro!, style: TextStyle(color: AppColors.red)),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: nomeController,
            enabled: !salvando,
            decoration: InputDecoration(
              labelText: labelCampo,
              hintText: placeholder,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: salvando ? null : onSalvar,
                  child: Text(editandoId == null ? 'Adicionar' : 'Salvar'),
                ),
              ),
              if (editandoId != null)
                SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: salvando ? null : onCancelarEdicao,
                    child: const Text('Cancelar'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (itens.isEmpty)
            Text(
              'Nenhum registro cadastrado.',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            for (final item in itens)
              DetalheItemCard(
                titulo: item.nome,
                linhas: const [],
                onEdit: () => onEditar(item.id, item.nome),
                onDelete: () => onExcluir(item.id, item.nome),
              ),
        ],
      ),
    );
  }
}
