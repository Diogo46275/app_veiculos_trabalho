import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/abastecimento.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/seletor_arquivo.dart';
import '../utils/upload_anexos_sequencial.dart';
import 'api_client.dart';

class AbastecimentosService {
  AbastecimentosService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Abastecimento> criar({
    required int veiculoId,
    required String data,
    required int km,
    required double litros,
    required double valor,
    String? posto,
    String documentoTipo = 'sem',
    List<ArquivoSelecionado> arquivosNf = const [],
  }) async {
    return enviarAnexosSequencialmente<Abastecimento>(
      arquivos: arquivosNf,
      enviar: (lote) => _criarMultipart(
        veiculoId: veiculoId,
        data: data,
        km: km,
        litros: litros,
        valor: valor,
        posto: posto,
        documentoTipo: documentoTipo,
        arquivosNf: lote,
      ),
      anexarExtra: (item, arquivo) => _atualizarMultipart(
        id: item.id,
        data: data,
        km: km,
        litros: litros,
        valor: valor,
        posto: posto,
        documentoTipo: documentoTipo,
        arquivosNf: [arquivo],
      ),
    );
  }

  Future<Abastecimento> atualizar({
    required int id,
    required String data,
    required int km,
    required double litros,
    required double valor,
    String? posto,
    String documentoTipo = 'sem',
    List<ArquivoSelecionado> arquivosNf = const [],
    bool removerNf = false,
    List<int> removerAnexoIds = const [],
  }) async {
    return enviarAnexosSequencialmente<Abastecimento>(
      arquivos: arquivosNf,
      enviar: (lote) => _atualizarMultipart(
        id: id,
        data: data,
        km: km,
        litros: litros,
        valor: valor,
        posto: posto,
        documentoTipo: documentoTipo,
        arquivosNf: lote,
        removerNf: removerNf,
        removerAnexoIds: removerAnexoIds,
      ),
      anexarExtra: (item, arquivo) => _atualizarMultipart(
        id: item.id,
        data: data,
        km: km,
        litros: litros,
        valor: valor,
        posto: posto,
        documentoTipo: documentoTipo,
        arquivosNf: [arquivo],
      ),
    );
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/abastecimentos/$id');
  }

  Future<Abastecimento> _criarMultipart({
    required int veiculoId,
    required String data,
    required int km,
    required double litros,
    required double valor,
    String? posto,
    required String documentoTipo,
    required List<ArquivoSelecionado> arquivosNf,
  }) async {
    final json = await _apiClient.postMultipart(
      '/abastecimentos/veiculo/$veiculoId',
      fields: _camposForm(
        data: data,
        km: km,
        litros: litros,
        valor: valor,
        posto: posto,
        documentoTipo: documentoTipo,
      ),
      arquivos: arquivosMultipartCampo(campo: 'arquivo_nf', arquivos: arquivosNf),
    );
    return _parseResposta(json, 'cadastrar');
  }

  Future<Abastecimento> _atualizarMultipart({
    required int id,
    required String data,
    required int km,
    required double litros,
    required double valor,
    String? posto,
    required String documentoTipo,
    required List<ArquivoSelecionado> arquivosNf,
    bool removerNf = false,
    List<int> removerAnexoIds = const [],
  }) async {
    final json = await _apiClient.putMultipart(
      '/abastecimentos/$id',
      fields: _camposForm(
        data: data,
        km: km,
        litros: litros,
        valor: valor,
        posto: posto,
        documentoTipo: documentoTipo,
        removerNf: removerNf,
        removerAnexoIds: removerAnexoIds,
      ),
      arquivos: arquivosMultipartCampo(campo: 'arquivo_nf', arquivos: arquivosNf),
    );
    return _parseResposta(json, 'atualizar');
  }

  Abastecimento _parseResposta(Object? json, String acao) {
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao $acao abastecimento.');
    }
    return Abastecimento.fromJson(json);
  }

  Map<String, String> _camposForm({
    required String data,
    required int km,
    required double litros,
    required double valor,
    String? posto,
    required String documentoTipo,
    bool removerNf = false,
    List<int> removerAnexoIds = const [],
  }) {
    final campos = <String, String>{
      'data': data,
      'km': km.toString(),
      'litros': _formatarDecimal(litros),
      'valor': _formatarDecimal(valor),
      'documento_tipo': documentoTipo,
      'remover_anexo_ids': jsonEncode(removerAnexoIds),
    };
    final postoLimpo = posto?.trim();
    if (postoLimpo != null && postoLimpo.isNotEmpty) {
      campos['posto'] = postoLimpo;
    }
    if (removerNf) {
      campos['remover_nf'] = 'true';
    }
    return campos;
  }

  String _formatarDecimal(double valor) => valor.toStringAsFixed(2);
}

Future<bool> confirmarExclusaoAbastecimento(
  BuildContext context,
  Abastecimento item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir abastecimento'),
      content: Text(
        'Excluir abastecimento de ${Formatacao.data(item.data)} '
        '(${Formatacao.km(item.km)})?\nEsta ação não pode ser desfeita.',
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
