import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/arquivo_multipart.dart';
import '../models/manutencao.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/seletor_arquivo.dart';
import '../utils/upload_anexos_sequencial.dart';
import 'api_client.dart';

class ManutencoesService {
  ManutencoesService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Manutencao> criar({
    required int veiculoId,
    required int tipoManutencaoId,
    required String data,
    required double valor,
    String? descricao,
    int? km,
    int? garantiaDias,
    String documentoTipo = 'sem',
    List<ArquivoSelecionado> arquivosNf = const [],
    List<ArquivoSelecionado> arquivosGarantia = const [],
  }) async {
    var item = await _criarMultipart(
      veiculoId: veiculoId,
      tipoManutencaoId: tipoManutencaoId,
      data: data,
      valor: valor,
      descricao: descricao,
      km: km,
      garantiaDias: garantiaDias,
      documentoTipo: documentoTipo,
      arquivosNf: arquivosNf.isNotEmpty ? [arquivosNf.first] : const [],
      arquivosGarantia:
          arquivosGarantia.isNotEmpty ? [arquivosGarantia.first] : const [],
    );

    item = await _anexarExtrasManutencao(
      item: item,
      tipoManutencaoId: tipoManutencaoId,
      data: data,
      valor: valor,
      descricao: descricao,
      km: km,
      garantiaDias: garantiaDias,
      documentoTipo: documentoTipo,
      arquivosNf: arquivosNf.length > 1 ? arquivosNf.sublist(1) : const [],
      arquivosGarantia:
          arquivosGarantia.length > 1 ? arquivosGarantia.sublist(1) : const [],
    );
    return item;
  }

  Future<Manutencao> atualizar({
    required int id,
    required int tipoManutencaoId,
    required String data,
    required double valor,
    String? descricao,
    int? km,
    int? garantiaDias,
    String documentoTipo = 'sem',
    List<ArquivoSelecionado> arquivosNf = const [],
    List<ArquivoSelecionado> arquivosGarantia = const [],
    bool removerNf = false,
    bool removerGarantia = false,
    List<int> removerAnexoNfIds = const [],
    List<int> removerAnexoGarantiaIds = const [],
  }) async {
    var item = await _atualizarMultipart(
      id: id,
      tipoManutencaoId: tipoManutencaoId,
      data: data,
      valor: valor,
      descricao: descricao,
      km: km,
      garantiaDias: garantiaDias,
      documentoTipo: documentoTipo,
      arquivosNf: arquivosNf.isNotEmpty ? [arquivosNf.first] : const [],
      arquivosGarantia:
          arquivosGarantia.isNotEmpty ? [arquivosGarantia.first] : const [],
      removerNf: removerNf,
      removerGarantia: removerGarantia,
      removerAnexoNfIds: removerAnexoNfIds,
      removerAnexoGarantiaIds: removerAnexoGarantiaIds,
    );

    item = await _anexarExtrasManutencao(
      item: item,
      tipoManutencaoId: tipoManutencaoId,
      data: data,
      valor: valor,
      descricao: descricao,
      km: km,
      garantiaDias: garantiaDias,
      documentoTipo: documentoTipo,
      arquivosNf: arquivosNf.length > 1 ? arquivosNf.sublist(1) : const [],
      arquivosGarantia:
          arquivosGarantia.length > 1 ? arquivosGarantia.sublist(1) : const [],
    );
    return item;
  }

  Future<Manutencao> _anexarExtrasManutencao({
    required Manutencao item,
    required int tipoManutencaoId,
    required String data,
    required double valor,
    String? descricao,
    int? km,
    int? garantiaDias,
    required String documentoTipo,
    required List<ArquivoSelecionado> arquivosNf,
    required List<ArquivoSelecionado> arquivosGarantia,
  }) async {
    var atual = item;
    for (final arquivo in arquivosNf) {
      atual = await _atualizarMultipart(
        id: atual.id,
        tipoManutencaoId: tipoManutencaoId,
        data: data,
        valor: valor,
        descricao: descricao,
        km: km,
        garantiaDias: garantiaDias,
        documentoTipo: documentoTipo,
        arquivosNf: [arquivo],
      );
    }
    for (final arquivo in arquivosGarantia) {
      atual = await _atualizarMultipart(
        id: atual.id,
        tipoManutencaoId: tipoManutencaoId,
        data: data,
        valor: valor,
        descricao: descricao,
        km: km,
        garantiaDias: garantiaDias,
        documentoTipo: documentoTipo,
        arquivosGarantia: [arquivo],
      );
    }
    return atual;
  }

  Future<void> excluir(int id) async {
    await _apiClient.deleteJson('/manutencoes/$id');
  }

  Future<Manutencao> _criarMultipart({
    required int veiculoId,
    required int tipoManutencaoId,
    required String data,
    required double valor,
    String? descricao,
    int? km,
    int? garantiaDias,
    required String documentoTipo,
    required List<ArquivoSelecionado> arquivosNf,
    required List<ArquivoSelecionado> arquivosGarantia,
  }) async {
    final json = await _apiClient.postMultipart(
      '/manutencoes/veiculo/$veiculoId',
      fields: _camposForm(
        tipoManutencaoId: tipoManutencaoId,
        data: data,
        valor: valor,
        descricao: descricao,
        km: km,
        garantiaDias: garantiaDias,
        documentoTipo: documentoTipo,
      ),
      arquivos: _arquivos(
        arquivosNf: arquivosNf,
        arquivosGarantia: arquivosGarantia,
      ),
    );
    return _parseResposta(json, 'cadastrar');
  }

  Future<Manutencao> _atualizarMultipart({
    required int id,
    required int tipoManutencaoId,
    required String data,
    required double valor,
    String? descricao,
    int? km,
    int? garantiaDias,
    required String documentoTipo,
    List<ArquivoSelecionado> arquivosNf = const [],
    List<ArquivoSelecionado> arquivosGarantia = const [],
    bool removerNf = false,
    bool removerGarantia = false,
    List<int> removerAnexoNfIds = const [],
    List<int> removerAnexoGarantiaIds = const [],
  }) async {
    final json = await _apiClient.putMultipart(
      '/manutencoes/$id',
      fields: _camposForm(
        tipoManutencaoId: tipoManutencaoId,
        data: data,
        valor: valor,
        descricao: descricao,
        km: km,
        garantiaDias: garantiaDias,
        documentoTipo: documentoTipo,
        removerNf: removerNf,
        removerGarantia: removerGarantia,
        removerAnexoNfIds: removerAnexoNfIds,
        removerAnexoGarantiaIds: removerAnexoGarantiaIds,
      ),
      arquivos: _arquivos(
        arquivosNf: arquivosNf,
        arquivosGarantia: arquivosGarantia,
      ),
    );
    return _parseResposta(json, 'atualizar');
  }

  Manutencao _parseResposta(Object? json, String acao) {
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao $acao manutenção.');
    }
    return Manutencao.fromJson(json);
  }

  Map<String, String> _camposForm({
    required int tipoManutencaoId,
    required String data,
    required double valor,
    String? descricao,
    int? km,
    int? garantiaDias,
    required String documentoTipo,
    bool removerNf = false,
    bool removerGarantia = false,
    List<int> removerAnexoNfIds = const [],
    List<int> removerAnexoGarantiaIds = const [],
  }) {
    final campos = <String, String>{
      'tipo_manutencao_id': tipoManutencaoId.toString(),
      'data': data,
      'valor': _formatarDecimal(valor),
      'documento_tipo': documentoTipo,
      'remover_anexo_nf_ids': jsonEncode(removerAnexoNfIds),
      'remover_anexo_garantia_ids': jsonEncode(removerAnexoGarantiaIds),
    };

    final descricaoLimpa = descricao?.trim();
    if (descricaoLimpa != null && descricaoLimpa.isNotEmpty) {
      campos['descricao'] = descricaoLimpa;
    }
    if (km != null) {
      campos['km'] = km.toString();
    }
    if (garantiaDias != null) {
      campos['garantia_dias'] = garantiaDias.toString();
    }
    if (removerNf) {
      campos['remover_nf'] = 'true';
    }
    if (removerGarantia) {
      campos['remover_garantia'] = 'true';
    }
    return campos;
  }

  List<ArquivoMultipart> _arquivos({
    required List<ArquivoSelecionado> arquivosNf,
    required List<ArquivoSelecionado> arquivosGarantia,
  }) {
    return [
      ...arquivosMultipartCampo(campo: 'arquivo_nf', arquivos: arquivosNf),
      ...arquivosMultipartCampo(
        campo: 'arquivo_garantia',
        arquivos: arquivosGarantia,
      ),
    ];
  }

  String _formatarDecimal(double valor) => valor.toStringAsFixed(2);
}

Future<bool> confirmarExclusaoManutencao(
  BuildContext context,
  Manutencao item,
) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Excluir manutenção'),
      content: Text(
        'Excluir manutenção "${item.tipo}" de ${Formatacao.data(item.data)}?\n'
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
