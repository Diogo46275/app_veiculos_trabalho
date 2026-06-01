import 'package:flutter/material.dart';

import '../models/despesa.dart';
import '../theme/app_colors.dart';
import 'api_client.dart';

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

  Future<Despesa> criar({
    required int veiculoId,
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
  }) async {
    final body = <String, dynamic>{
      'categoria_despesa_id': categoriaDespesaId,
      'data': dataIso,
      'valor': valor,
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      if (km != null) 'km': km,
    };
    final json = await _apiClient.postJson(
      '/despesas/veiculo/$veiculoId',
      body: body,
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao registrar despesa.');
    }
    return Despesa.fromJson(json);
  }

  Future<Despesa> atualizar({
    required int id,
    required int categoriaDespesaId,
    required String dataIso,
    required double valor,
    String? descricao,
    int? km,
  }) async {
    final body = <String, dynamic>{
      'categoria_despesa_id': categoriaDespesaId,
      'data': dataIso,
      'valor': valor,
      if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      if (km != null) 'km': km,
    };
    final json = await _apiClient.putJson('/despesas/$id', body: body);
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar despesa.');
    }
    return Despesa.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/despesas/$id');
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
