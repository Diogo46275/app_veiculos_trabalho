import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/categoria_despesa.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/categorias_despesa_service.dart';
import '../theme/app_colors.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class CategoriasDespesaScreen extends StatefulWidget {
  const CategoriasDespesaScreen({super.key, required this.veiculo});

  final Veiculo veiculo;

  @override
  State<CategoriasDespesaScreen> createState() => _CategoriasDespesaScreenState();
}

class _CategoriasDespesaScreenState extends State<CategoriasDespesaScreen> {
  late final CategoriasDespesaService _service;
  final _nomeController = TextEditingController();
  final _iconeController = TextEditingController(text: '📋');

  List<CategoriaDespesa> _itens = const [];
  bool _carregando = true;
  bool _salvando = false;
  String? _erroLista;
  String? _erroForm;
  int? _editandoId;

  @override
  void initState() {
    super.initState();
    _service = CategoriasDespesaService(apiClient: ApiClient());
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _iconeController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroLista = null;
    });
    try {
      final lista = await _service.listarPorVeiculo(widget.veiculo.id);
      if (!mounted) return;
      setState(() {
        _itens = lista;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroLista = e.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroLista = 'Erro ao carregar categorias.';
        _carregando = false;
      });
    }
  }

  void _iniciarEdicao(CategoriaDespesa item) {
    setState(() {
      _editandoId = item.id;
      _nomeController.text = item.nome;
      _iconeController.text = item.icone;
      _erroForm = null;
    });
  }

  void _cancelarEdicao() {
    setState(() {
      _editandoId = null;
      _nomeController.clear();
      _iconeController.text = '📋';
      _erroForm = null;
    });
  }

  String? _validarIcone(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Informe um ícone (emoji)';
    if (texto.runes.length > 4) {
      return 'Use um emoji curto';
    }
    return null;
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    final icone = _iconeController.text.trim();
    final erroNome = validarNomeCadastroPerfil(nome);
    final erroIcone = _validarIcone(icone);
    if (erroNome != null || erroIcone != null) {
      setState(() => _erroForm = erroNome ?? erroIcone);
      return;
    }

    setState(() {
      _salvando = true;
      _erroForm = null;
    });

    final eraNovo = _editandoId == null;
    try {
      if (eraNovo) {
        await _service.criar(
          veiculoId: widget.veiculo.id,
          nome: nome,
          icone: icone,
        );
      } else {
        await _service.atualizar(
          id: _editandoId!,
          nome: nome,
          icone: icone,
        );
      }
      if (!mounted) return;
      _cancelarEdicao();
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            eraNovo ? 'Categoria cadastrada' : 'Categoria atualizada',
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroForm = e.message;
        _salvando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroForm = 'Erro ao salvar categoria.';
        _salvando = false;
      });
    } finally {
      if (mounted && _salvando) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _excluir(CategoriaDespesa item) async {
    final ok = await confirmarExclusaoCategoriaDespesa(context, item);
    if (!ok || !mounted) return;

    try {
      await _service.excluir(item.id);
      if (!mounted) return;
      if (_editandoId == item.id) _cancelarEdicao();
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria excluída')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias de despesa'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: _carregar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              widget.veiculo.rotulo,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Categorias deste veículo. Ao criar o veículo, sugerimos Abastecimento, '
              'Manutenção, Seguro e outras. Você pode editar, incluir ou excluir.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _editandoId == null ? 'Nova categoria' : 'Editar categoria',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_erroForm != null) ...[
                    const SizedBox(height: 8),
                    Text(_erroForm!, style: TextStyle(color: AppColors.red)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: TextFormField(
                          controller: _iconeController,
                          enabled: !_salvando,
                          maxLength: 8,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(8),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Ícone',
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nomeController,
                          enabled: !_salvando,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            hintText: 'Ex.: Lavagem',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        child: Text(_editandoId == null ? 'Adicionar' : 'Salvar'),
                      ),
                      if (_editandoId != null)
                        TextButton(
                          onPressed: _salvando ? null : _cancelarEdicao,
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_carregando)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.blueText),
                ),
              )
            else if (_erroLista != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _erroLista!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _carregar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            else if (_itens.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhuma categoria. Puxe para atualizar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ..._itens.map(
                (item) => Card(
                  color: AppColors.card,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Text(
                      item.icone,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      item.nome,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Editar',
                          onPressed: () => _iniciarEdicao(item),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.red),
                          tooltip: 'Excluir',
                          onPressed: () => _excluir(item),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
