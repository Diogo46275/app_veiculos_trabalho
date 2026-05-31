import 'package:flutter/material.dart';

import '../models/periodo_trabalho.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/iso_datetime.dart';
import 'api_client.dart';

class PeriodosTrabalhoService {
  PeriodosTrabalhoService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<PeriodoTrabalho>> listar(int veiculoId) async {
    final lista = await _apiClient.getJsonList(
      '/periodos-trabalho/veiculo/$veiculoId',
    );
    return lista
        .whereType<Map<String, dynamic>>()
        .map(PeriodoTrabalho.fromJson)
        .toList();
  }

  Future<PeriodoTrabalho?> obterAberto(int veiculoId) async {
    final json = await _apiClient.getJson(
      '/periodos-trabalho/veiculo/$veiculoId/aberto',
    );
    if (json == null) return null;
    if (json is! Map<String, dynamic>) return null;
    return PeriodoTrabalho.fromJson(json);
  }

  Future<PeriodoTrabalho> iniciar({
    required int veiculoId,
    required int kmInicio,
    DateTime? dataHoraInicio,
  }) async {
    final body = <String, dynamic>{
      'km_inicio': kmInicio,
    };
    if (dataHoraInicio != null) {
      body['data_hora_inicio'] = IsoDatetime.dataHora(dataHoraInicio);
    }

    final json = await _apiClient.postJson(
      '/periodos-trabalho/veiculo/$veiculoId/iniciar',
      body: body,
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao iniciar turno.');
    }
    return PeriodoTrabalho.fromJson(json);
  }

  Future<PeriodoTrabalho> finalizar({
    required int periodoId,
    required int kmFim,
    DateTime? dataHoraFim,
  }) async {
    final body = <String, dynamic>{
      'km_fim': kmFim,
    };
    if (dataHoraFim != null) {
      body['data_hora_fim'] = IsoDatetime.dataHora(dataHoraFim);
    }

    final json = await _apiClient.postJson(
      '/periodos-trabalho/$periodoId/finalizar',
      body: body,
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao finalizar turno.');
    }
    return PeriodoTrabalho.fromJson(json);
  }

  Future<PeriodoTrabalho> atualizar({
    required int periodoId,
    required int kmInicio,
    required int kmFim,
    DateTime? dataHoraInicio,
    DateTime? dataHoraFim,
  }) async {
    final body = <String, dynamic>{
      'km_inicio': kmInicio,
      'km_fim': kmFim,
    };
    if (dataHoraInicio != null) {
      body['data_hora_inicio'] = IsoDatetime.dataHora(dataHoraInicio);
    }
    if (dataHoraFim != null) {
      body['data_hora_fim'] = IsoDatetime.dataHora(dataHoraFim);
    }

    final json = await _apiClient.putJson(
      '/periodos-trabalho/$periodoId',
      body: body,
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao atualizar turno.');
    }
    return PeriodoTrabalho.fromJson(json);
  }

  Future<void> excluir(int periodoId) async {
    await _apiClient.deleteJson('/periodos-trabalho/$periodoId');
  }
}

Future<bool> confirmarExclusaoPeriodo(
  BuildContext context,
  PeriodoTrabalho item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir turno'),
      content: Text(
        'Excluir o turno de ${Formatacao.dataHora(item.dataHoraInicio)}?\n'
        'Os ganhos vinculados também serão removidos.',
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
