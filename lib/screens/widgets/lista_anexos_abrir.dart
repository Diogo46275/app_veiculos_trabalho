import 'package:flutter/material.dart';

import '../../models/anexo_registro.dart';
import '../../theme/app_colors.dart';
import '../../utils/abrir_anexo.dart';
import '../../utils/anexo_exibicao.dart';
import '../../utils/seletor_arquivo.dart';

class ListaAnexosAbrir extends StatelessWidget {
  const ListaAnexosAbrir({
    super.key,
    required this.anexos,
    this.mensagemVazio = 'Nenhum anexo',
    this.desabilitado = false,
    this.mostrarRemover = false,
    this.onRemoverPersistido,
    this.onRemoverUrlLegado,
    this.onRemoverNovo,
    this.arquivosNovos = const [],
  });

  final List<AnexoRegistro> anexos;
  final String mensagemVazio;
  final bool desabilitado;
  final bool mostrarRemover;
  final ValueChanged<int>? onRemoverPersistido;
  final ValueChanged<String>? onRemoverUrlLegado;
  final ValueChanged<int>? onRemoverNovo;
  final List<ArquivoSelecionado> arquivosNovos;

  @override
  Widget build(BuildContext context) {
    final linhas = <Widget>[];
    var indice = 0;

    for (final anexo in anexos) {
      final rotulo = rotuloAnexo(anexo, indice);
      linhas.add(
        _LinhaAnexo(
          rotulo: rotulo,
          desabilitado: desabilitado,
          onAbrir: () => abrirAnexoComFeedback(context, anexo.url),
          onRemover: mostrarRemover && !desabilitado
              ? (anexo.id > 0
                  ? () => onRemoverPersistido?.call(anexo.id)
                  : () => onRemoverUrlLegado?.call(anexo.url))
              : null,
        ),
      );
      indice++;
    }

    for (var i = 0; i < arquivosNovos.length; i++) {
      linhas.add(
        _LinhaAnexo(
          rotulo: arquivosNovos[i].nome,
          desabilitado: desabilitado,
          onAbrir: null,
          onRemover: mostrarRemover && !desabilitado
              ? () => onRemoverNovo?.call(i)
              : null,
          ehNovo: true,
        ),
      );
    }

    if (linhas.isEmpty) {
      return Text(
        mensagemVazio,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: linhas,
    );
  }
}

IconData _iconeAnexo(String rotulo) {
  final lower = rotulo.toLowerCase();
  if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png')) {
    return Icons.image_outlined;
  }
  return Icons.description_outlined;
}

class _LinhaAnexo extends StatelessWidget {
  const _LinhaAnexo({
    required this.rotulo,
    required this.desabilitado,
    required this.onAbrir,
    required this.onRemover,
    this.ehNovo = false,
  });

  final String rotulo;
  final bool desabilitado;
  final VoidCallback? onAbrir;
  final VoidCallback? onRemover;
  final bool ehNovo;

  @override
  Widget build(BuildContext context) {
    final podeAbrir = onAbrir != null && !desabilitado;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: podeAbrir ? onAbrir : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  ehNovo
                      ? Icons.upload_file_outlined
                      : _iconeAnexo(rotulo),
                  color: AppColors.blueText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rotulo,
                    style: TextStyle(color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ehNovo)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      'Novo',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (podeAbrir)
                  Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: AppColors.blueText,
                  ),
                if (onRemover != null)
                  IconButton(
                    onPressed: onRemover,
                    tooltip: 'Remover',
                    icon: Icon(Icons.delete_outline, color: AppColors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
