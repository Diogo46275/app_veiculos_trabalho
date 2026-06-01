import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/despesa.dart';
import '../theme/app_colors.dart';
import '../utils/seletor_arquivo.dart';
import '../utils/upload_anexos_sequencial.dart';
import 'api_client.dart';

/// Despesas enviam todos os anexos novos em uma única requisição multipart.
/// O backend coleta vários `arquivo_nf` via `coletar_arquivos_form` (FIN-003).
/// Evita 2ª requisição PUT que falhava com 500 em produção (nginx/proxy).
class DespesasService {
  DespesasService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Despesa>> listarPorVeiculo(int veiculoId) async {
    final lista = await _apiClient.getJsonList('/despesas/veiculo/$veiculoId');
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Despesa.fromJson)
        .toList();
  }

  Future<Despesa?> obterPorVeiculo(int veiculoId, int id) async {
    final lista = await listarPorVeiculo(veiculoId);
    for (final item in lista) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<Despesa> criar({
    required int veiculoId,
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
    List<ArquivoSelecionado> arquivosNf = const [],
  }) async {
    return _criarMultipart(
      veiculoId: veiculoId,
      categoriaDespesaId: categoriaDespesaId,
      dataIso: dataIso,
      valor: valor,
      descricao: descricao,
      km: km,
      arquivosNf: arquivosNf,
    );
  }

  Future<Despesa> atualizar({
    required int id,
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
    List<ArquivoSelecionado> arquivosNf = const [],
    bool removerNf = false,
    List<int> removerAnexoIds = const [],
  }) async {
    return _atualizarMultipart(
      id: id,
      categoriaDespesaId: categoriaDespesaId,
      dataIso: dataIso,
      valor: valor,
      descricao: descricao,
      km: km,
      arquivosNf: arquivosNf,
      removerNf: removerNf,
      removerAnexoIds: removerAnexoIds,
    );
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/despesas/$id');
  }

  Future<Despesa> _criarMultipart({
    required int veiculoId,
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
    required List<ArquivoSelecionado> arquivosNf,
  }) async {
    final json = await _apiClient.postMultipart(
      '/despesas/veiculo/$veiculoId',
      fields: _camposForm(
        categoriaDespesaId: categoriaDespesaId,
        dataIso: dataIso,
        valor: valor,
        descricao: descricao,
        km: km,
      ),
      arquivos: arquivosMultipartCampo(campo: 'arquivo_nf', arquivos: arquivosNf),
    );
    return _parseResposta(json, 'registrar');
  }

  Future<Despesa> _atualizarMultipart({
    required int id,
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
    required List<ArquivoSelecionado> arquivosNf,
    bool removerNf = false,
    List<int> removerAnexoIds = const [],
  }) async {
    final json = await _apiClient.putMultipart(
      '/despesas/$id',
      fields: _camposForm(
        categoriaDespesaId: categoriaDespesaId,
        dataIso: dataIso,
        valor: valor,
        descricao: descricao,
        km: km,
        removerNf: removerNf,
        removerAnexoIds: removerAnexoIds,
      ),
      arquivos: arquivosMultipartCampo(campo: 'arquivo_nf', arquivos: arquivosNf),
    );
    return _parseResposta(json, 'atualizar');
  }

  Despesa _parseResposta(Object? json, String acao) {
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao $acao despesa.');
    }
    return Despesa.fromJson(json);
  }

  Map<String, String> _camposForm({
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
    bool removerNf = false,
    List<int> removerAnexoIds = const [],
  }) {
    final campos = <String, String>{
      'categoria_despesa_id': categoriaDespesaId.toString(),
      'data': dataIso,
      'valor': valor.toStringAsFixed(2),
      'remover_anexo_ids': jsonEncode(removerAnexoIds),
    };
    final descricaoLimpa = descricao?.trim();
    if (descricaoLimpa != null && descricaoLimpa.isNotEmpty) {
      campos['descricao'] = descricaoLimpa;
    }
    if (km != null) {
      campos['km'] = km.toString();
    }
    if (removerNf) {
      campos['remover_nf'] = 'true';
    }
    return campos;
  }
}

Future<bool> confirmarExclusaoDespesa(BuildContext context, Despesa item) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir despesa'),
      content: Text(
        'Excluir ${item.rotuloCategoria} · ${item.valor.toStringAsFixed(2)}?\n'
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
