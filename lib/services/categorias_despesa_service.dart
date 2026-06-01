import 'package:flutter/material.dart';

import '../models/categoria_despesa.dart';
import '../theme/app_colors.dart';
import 'api_client.dart';

class CategoriasDespesaService {
  CategoriasDespesaService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<CategoriaDespesa>> listarPorVeiculo(int veiculoId) async {
    final lista = await _apiClient.getJsonList(
      '/categorias-despesa/veiculo/$veiculoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(CategoriaDespesa.fromJson)
        .toList();
  }

  Future<CategoriaDespesa> criar({
    required int veiculoId,
    required String nome,
    required String icone,
  }) async {
    final json = await _apiClient.postJson(
      '/categorias-despesa/veiculo/$veiculoId',
      body: {'nome': nome.trim(), 'icone': icone.trim()},
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao cadastrar categoria.');
    }
    return CategoriaDespesa.fromJson(json);
  }

  Future<CategoriaDespesa> atualizar({
    required int id,
    required String nome,
    required String icone,
  }) async {
    final json = await _apiClient.putJson(
      '/categorias-despesa/$id',
      body: {'nome': nome.trim(), 'icone': icone.trim()},
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar categoria.');
    }
    return CategoriaDespesa.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/categorias-despesa/$id');
  }
}

Future<bool> confirmarExclusaoCategoriaDespesa(
  BuildContext context,
  CategoriaDespesa item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir categoria'),
      content: Text(
        'Excluir "${item.icone} ${item.nome}"?\nEsta ação não pode ser desfeita.',
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
