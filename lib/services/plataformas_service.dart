import 'package:flutter/material.dart';

import '../models/plataforma.dart';
import '../theme/app_colors.dart';
import 'api_client.dart';

class PlataformasService {
  PlataformasService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Plataforma>> listar() async {
    final lista = await _apiClient.getJsonList('/plataformas/');
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Plataforma.fromJson)
        .toList();
  }

  Future<Plataforma> criar(String nome) async {
    final json = await _apiClient.postJson(
      '/plataformas/',
      body: {'nome': nome.trim()},
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao cadastrar plataforma.');
    }
    return Plataforma.fromJson(json);
  }

  Future<Plataforma> atualizar({required int id, required String nome}) async {
    final json = await _apiClient.putJson(
      '/plataformas/$id',
      body: {'nome': nome.trim()},
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar plataforma.');
    }
    return Plataforma.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/plataformas/$id');
  }
}

Future<bool> confirmarExclusaoPlataforma(
  BuildContext context,
  Plataforma item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir plataforma'),
      content: Text('Excluir "${item.nome}"?\nEsta ação não pode ser desfeita.'),
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
