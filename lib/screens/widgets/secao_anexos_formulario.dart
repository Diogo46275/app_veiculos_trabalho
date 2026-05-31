import 'package:flutter/material.dart';

import '../../models/anexo_registro.dart';
import '../../theme/app_colors.dart';
import '../../utils/anexo_exibicao.dart';
import '../../utils/seletor_arquivo.dart';
import 'lista_anexos_abrir.dart';

class SecaoAnexosFormulario extends StatelessWidget {
  const SecaoAnexosFormulario({
    super.key,
    required this.rotulo,
    required this.anexosAtuais,
    required this.idsRemover,
    required this.urlsRemover,
    required this.arquivosNovos,
    required this.desabilitado,
    required this.onTirarFoto,
    required this.onEscolherOutro,
    required this.onRemoverExistente,
    required this.onRemoverUrlLegado,
    required this.onRemoverNovo,
    this.ajuda =
        'Tire foto ou anexe PDF/imagem (até $maxAnexosPorRegistro por seção, 10 MB cada). '
        'Toque em um anexo para abrir. Fotos são comprimidas para envio.',
  });

  final String rotulo;
  final List<AnexoRegistro> anexosAtuais;
  final Set<int> idsRemover;
  final Set<String> urlsRemover;
  final List<ArquivoSelecionado> arquivosNovos;
  final bool desabilitado;
  final VoidCallback onTirarFoto;
  final VoidCallback onEscolherOutro;
  final ValueChanged<int> onRemoverExistente;
  final ValueChanged<String> onRemoverUrlLegado;
  final ValueChanged<int> onRemoverNovo;
  final String ajuda;

  List<AnexoRegistro> get _anexosExistentesVisiveis {
    return anexosVisiveisEdicao(
      anexosAtuais,
      idsRemover: idsRemover,
      urlsRemover: urlsRemover,
    );
  }

  bool get _temConteudo =>
      _anexosExistentesVisiveis.isNotEmpty || arquivosNovos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          rotulo,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        if (_temConteudo)
          ListaAnexosAbrir(
            anexos: _anexosExistentesVisiveis,
            desabilitado: desabilitado,
            mostrarRemover: true,
            onRemoverPersistido: onRemoverExistente,
            onRemoverUrlLegado: onRemoverUrlLegado,
            onRemoverNovo: onRemoverNovo,
            arquivosNovos: arquivosNovos,
          )
        else
          Text(
            ajuda,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: desabilitado ? null : onTirarFoto,
              icon: const Icon(Icons.photo_camera_outlined, size: 18),
              label: const Text('Tirar foto'),
            ),
            OutlinedButton.icon(
              onPressed: desabilitado ? null : onEscolherOutro,
              icon: const Icon(Icons.attach_file, size: 18),
              label: const Text('PDF / galeria'),
            ),
          ],
        ),
      ],
    );
  }
}
