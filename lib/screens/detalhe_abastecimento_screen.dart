import 'package:flutter/material.dart';

import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/veiculo_modulos_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_abastecimento_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/detalhe_campo.dart';
import 'widgets/lista_anexos_abrir.dart';

class DetalheAbastecimentoScreen extends StatefulWidget {
  const DetalheAbastecimentoScreen({
    super.key,
    required this.veiculo,
    required this.item,
  });

  final Veiculo veiculo;
  final Abastecimento item;

  @override
  State<DetalheAbastecimentoScreen> createState() =>
      _DetalheAbastecimentoScreenState();
}

class _DetalheAbastecimentoScreenState extends State<DetalheAbastecimentoScreen> {
  late final VeiculoModulosService _service;
  late Abastecimento _item;
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
      final atualizado = await _service.obterAbastecimento(
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

  Future<void> _editar() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAbastecimentoScreen(
          veiculo: widget.veiculo,
          abastecimento: _item,
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
          title: const Text('Abastecimento'),
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
                      rotulo: 'Data',
                      valor: Formatacao.data(_item.data),
                    ),
                    DetalheCampo(rotulo: 'Km', valor: Formatacao.km(_item.km)),
                    DetalheCampo(
                      rotulo: 'Litros',
                      valor: '${Formatacao.decimal(_item.litros)} L',
                    ),
                    DetalheCampo(
                      rotulo: 'Valor',
                      valor: Formatacao.moeda(_item.valor),
                    ),
                    if (_item.litros > 0)
                      DetalheCampo(
                        rotulo: 'Preço por litro',
                        valor: Formatacao.moeda(_item.valor / _item.litros),
                      ),
                    if (_item.posto != null && _item.posto!.isNotEmpty)
                      DetalheCampo(rotulo: 'Posto', valor: _item.posto!),
                    if (_item.consumoKmL != null)
                      DetalheCampo(
                        rotulo: 'Consumo',
                        valor: '${Formatacao.decimal(_item.consumoKmL)} km/L',
                      ),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _editar,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar abastecimento'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
