import 'package:flutter/material.dart';

import '../models/manutencao.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/veiculo_modulos_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_manutencao_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/detalhe_campo.dart';
import 'widgets/lista_anexos_abrir.dart';

class DetalheManutencaoScreen extends StatefulWidget {
  const DetalheManutencaoScreen({
    super.key,
    required this.veiculo,
    required this.item,
  });

  final Veiculo veiculo;
  final Manutencao item;

  @override
  State<DetalheManutencaoScreen> createState() =>
      _DetalheManutencaoScreenState();
}

class _DetalheManutencaoScreenState extends State<DetalheManutencaoScreen> {
  late final VeiculoModulosService _service;
  late Manutencao _item;
  bool _carregando = true;
  String? _erro;
  bool _listaPrecisaAtualizar = false;

  @override
  void initState() {
    super.initState();
    _service = VeiculoModulosService(apiClient: ApiClient());
    _item = widget.item;
    _recarregar();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _recarregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final atualizado = await _service.obterManutencao(
        widget.veiculo.id,
        widget.item.id,
      );
      if (!mounted) return;
      setState(() {
        _item = atualizado ?? widget.item;
        _carregando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _item = widget.item;
        _erro = error.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _item = widget.item;
        _erro = 'Não foi possível carregar os anexos.';
        _carregando = false;
      });
    }
  }

  String _rotuloDocumento(String tipo) {
    return switch (tipo) {
      'cpf' => 'CPF do usuário',
      'cnpj' => 'CNPJ do usuário',
      _ => 'Sem documento',
    };
  }

  String _rotuloGarantia() {
    if (_item.garantiaDias == null || _item.garantiaDias == 0) {
      return 'Sem garantia';
    }
    final status = switch (_item.garantiaStatus) {
      'em_garantia' => 'Em garantia',
      'fora_garantia' => 'Fora da garantia',
      _ => 'Sem garantia',
    };
    final venc = _item.garantiaVencimento != null
        ? ' até ${Formatacao.data(_item.garantiaVencimento)}'
        : '';
    return '$status$venc (${_item.garantiaDias} dias)';
  }

  Future<void> _editar() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormManutencaoScreen(
          veiculo: widget.veiculo,
          manutencao: _item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      _listaPrecisaAtualizar = true;
      await _recarregar();
    }
  }

  void _voltar() {
    Navigator.of(context).pop(_listaPrecisaAtualizar ? true : null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _voltar();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manutenção'),
          leading: BackButton(onPressed: _voltar),
          actions: [
            ...acoesAppBarComDashboard(const []),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: _carregando ? null : _editar,
            ),
          ],
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.veiculo.rotulo,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _erro!,
                        style: TextStyle(color: AppColors.red, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 16),
                    DetalheCampo(rotulo: 'Tipo', valor: _item.tipo),
                    DetalheCampo(
                      rotulo: 'Data',
                      valor: Formatacao.data(_item.data),
                    ),
                    if (_item.km != null)
                      DetalheCampo(rotulo: 'Km', valor: Formatacao.km(_item.km!)),
                    DetalheCampo(
                      rotulo: 'Valor',
                      valor: Formatacao.moeda(_item.valor),
                    ),
                    DetalheCampo(rotulo: 'Garantia', valor: _rotuloGarantia()),
                    if (_item.descricao != null && _item.descricao!.isNotEmpty)
                      DetalheCampo(rotulo: 'Descrição', valor: _item.descricao!),
                    DetalheCampo(
                      rotulo: 'Documento NF',
                      valor: _rotuloDocumento(_item.documentoTipo),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Notas fiscais (anexos)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListaAnexosAbrir(
                      anexos: _item.anexosNfParaExibicao,
                      mensagemVazio: 'Nenhuma nota fiscal anexada.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Garantia (anexos)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListaAnexosAbrir(
                      anexos: _item.anexosGarantiaParaExibicao,
                      mensagemVazio: 'Nenhum anexo de garantia.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _editar,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar manutenção'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
