import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/iso_datetime.dart';
import 'api_client.dart';

class ReceitasService {
  ReceitasService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Receita>> listarPorPeriodo(int periodoId) async {
    final lista = await _apiClient.getJsonList(
      '/receitas/periodo/$periodoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(Receita.fromJson)
        .toList();
  }

  Future<Receita> criar({
    required int periodoId,
    required int plataformaId,
    required DateTime data,
    required double valor,
    String? descricao,
  }) async {
    final json = await _apiClient.postJson(
      '/receitas/periodo/$periodoId',
      body: _corpo(
        plataformaId: plataformaId,
        data: data,
        valor: valor,
        descricao: descricao,
      ),
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao registrar ganho.');
    }
    return Receita.fromJson(json);
  }

  Future<Receita> atualizar({
    required int id,
    required int plataformaId,
    required DateTime data,
    required double valor,
    String? descricao,
  }) async {
    final json = await _apiClient.putJson(
      '/receitas/$id',
      body: _corpo(
        plataformaId: plataformaId,
        data: data,
        valor: valor,
        descricao: descricao,
      ),
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar ganho.');
    }
    return Receita.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/receitas/$id');
  }

  Map<String, dynamic> _corpo({
    required int plataformaId,
    required DateTime data,
    required double valor,
    String? descricao,
  }) {
    final corpo = <String, dynamic>{
      'plataforma_id': plataformaId,
      'data': IsoDatetime.data(data),
      'valor': double.parse(valor.toStringAsFixed(2)),
    };
    final descricaoLimpa = descricao?.trim();
    if (descricaoLimpa != null && descricaoLimpa.isNotEmpty) {
      corpo['descricao'] = descricaoLimpa;
    }
    return corpo;
  }
}

Future<bool> confirmarExclusaoReceita(
  BuildContext context,
  Receita item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir ganho'),
      content: Text(
        'Excluir ganho de ${Formatacao.moeda(item.valor)} '
        '(${item.plataformaNome ?? 'plataforma'})?',
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
