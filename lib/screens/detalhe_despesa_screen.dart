import 'package:flutter/material.dart';

import '../models/despesa.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/despesas_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_despesa_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/detalhe_campo.dart';
import 'widgets/lista_anexos_abrir.dart';

class DetalheDespesaScreen extends StatefulWidget {
  const DetalheDespesaScreen({
    super.key,
    required this.veiculo,
    required this.item,
  });

  final Veiculo veiculo;
  final Despesa item;

  @override
  State<DetalheDespesaScreen> createState() => _DetalheDespesaScreenState();
}

class _DetalheDespesaScreenState extends State<DetalheDespesaScreen> {
  late final DespesasService _service;
  late Despesa _item;
  bool _carregando = true;
  String? _erro;
  bool _listaPrecisaAtualizar = false;

  @override
  void initState() {
    super.initState();
    _service = DespesasService(apiClient: ApiClient());
    _item = widget.item;
    _recarregar();
  }

  Future<void> _recarregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final atualizado = await _service.obterPorVeiculo(
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

  Future<void> _editar() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormDespesaScreen(veiculo: widget.veiculo, despesa: _item),
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
          title: const Text('Despesa'),
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
                    DetalheCampo(
                      rotulo: 'Categoria',
                      valor: _item.rotuloCategoria,
                    ),
                    DetalheCampo(
                      rotulo: 'Data',
                      valor: Formatacao.data(_item.data),
                    ),
                    DetalheCampo(
                      rotulo: 'Valor',
                      valor: Formatacao.moeda(_item.valor),
                    ),
                    if (_item.km != null)
                      DetalheCampo(
                        rotulo: 'Km',
                        valor: Formatacao.km(_item.km!),
                      ),
                    if (_item.descricao != null && _item.descricao!.isNotEmpty)
                      DetalheCampo(
                        rotulo: 'Descrição',
                        valor: _item.descricao!,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Comprovantes (anexos)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListaAnexosAbrir(
                      anexos: _item.anexosNfParaExibicao,
                      mensagemVazio: 'Nenhum comprovante anexado.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _editar,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar despesa'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
