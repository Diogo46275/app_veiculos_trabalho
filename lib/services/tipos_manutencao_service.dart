import 'package:flutter/material.dart';

import '../models/tipo_manutencao.dart';
import '../theme/app_colors.dart';
import 'api_client.dart';

class TiposManutencaoService {
  TiposManutencaoService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<TipoManutencao>> listar() async {
    final lista = await _apiClient.getJsonList('/tipos-manutencao/');
    return lista
        .whereType<Map<String, dynamic>>()
        .map(TipoManutencao.fromJson)
        .toList();
  }

  Future<TipoManutencao> criar(String nome) async {
    final json = await _apiClient.postJson(
      '/tipos-manutencao/',
      body: {'nome': nome.trim()},
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao cadastrar tipo.');
    }
    return TipoManutencao.fromJson(json);
  }

  Future<TipoManutencao> atualizar({required int id, required String nome}) async {
    final json = await _apiClient.putJson(
      '/tipos-manutencao/$id',
      body: {'nome': nome.trim()},
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar tipo.');
    }
    return TipoManutencao.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/tipos-manutencao/$id');
  }
}

Future<bool> confirmarExclusaoTipoManutencao(
  BuildContext context,
  TipoManutencao item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir tipo de manutenção'),
      content: Text(
        'Excluir "${item.nome}"?\nEsta ação não pode ser desfeita.',
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
