import 'package:flutter/material.dart';

import '../models/alerta_veiculo.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'api_client.dart';

class AlertasService {
  AlertasService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AlertaVeiculo> criar({
    required int veiculoId,
    required String titulo,
    required String tipo,
    required int valorAlerta,
    required int antecedencia,
    bool ativo = true,
  }) async {
    final json = await _apiClient.postJson(
      '/alertas/veiculo/$veiculoId',
      body: _corpo(
        titulo: titulo,
        tipo: tipo,
        valorAlerta: valorAlerta,
        antecedencia: antecedencia,
        ativo: ativo,
      ),
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao cadastrar alerta.');
    }
    return AlertaVeiculo.fromJson(json);
  }

  Future<AlertaVeiculo> atualizar({
    required int id,
    required String titulo,
    required String tipo,
    required int valorAlerta,
    required int antecedencia,
    required bool ativo,
  }) async {
    final json = await _apiClient.putJson(
      '/alertas/$id',
      body: _corpo(
        titulo: titulo,
        tipo: tipo,
        valorAlerta: valorAlerta,
        antecedencia: antecedencia,
        ativo: ativo,
      ),
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar alerta.');
    }
    return AlertaVeiculo.fromJson(json);
  }

  Future<AlertaVeiculo> resetar(int id) async {
    final json = await _apiClient.postJson('/alertas/$id/reset', body: {});
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao resetar alerta.');
    }
    return AlertaVeiculo.fromJson(json);
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/alertas/$id');
  }

  Map<String, dynamic> _corpo({
    required String titulo,
    required String tipo,
    required int valorAlerta,
    required int antecedencia,
    required bool ativo,
  }) {
    return {
      'titulo': titulo.trim(),
      'tipo': tipo,
      'valor_alerta': valorAlerta,
      'antecedencia': antecedencia,
      'ativo': ativo,
    };
  }
}

Future<bool> confirmarExclusaoAlerta(
  BuildContext context,
  AlertaVeiculo item,
) async {
  final titulo = item.titulo;
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir alerta'),
      content: Text(
        'Excluir $titulo (intervalo ${_rotuloIntervaloCurto(item)})?\n'
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

Future<bool> confirmarResetAlerta(
  BuildContext context,
  AlertaVeiculo item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Resetar alerta'),
      content: const Text(
        'Resetar este alerta a partir do km atual / data de hoje?\n'
        'Manutenções não resetam sozinhas.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.gold),
          child: const Text('Resetar'),
        ),
      ],
    ),
  );
  return resultado ?? false;
}

String _rotuloIntervaloCurto(AlertaVeiculo item) {
  if (item.tipo == 'km') {
    return Formatacao.km(item.valorAlerta);
  }
  return '${item.valorAlerta} dia(s)';
}
