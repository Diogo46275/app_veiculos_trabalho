import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/anexo_registro.dart';
import '../models/categoria_despesa.dart';
import '../models/despesa.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/categorias_despesa_service.dart';
import '../services/despesas_service.dart';
import '../theme/app_colors.dart';
import '../utils/anexo_exibicao.dart';
import '../utils/formatacao.dart';
import '../utils/iso_datetime.dart';
import '../utils/parse_numero.dart';
import '../utils/seletor_arquivo.dart';
import '../utils/seletor_data_br.dart';
import '../validacao/validadores_formulario.dart';
import 'categorias_despesa_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/secao_anexos_formulario.dart';

class FormDespesaScreen extends StatefulWidget {
  const FormDespesaScreen({
    super.key,
    required this.veiculo,
    this.despesa,
  });

  final Veiculo veiculo;
  final Despesa? despesa;

  bool get editando => despesa != null;

  @override
  State<FormDespesaScreen> createState() => _FormDespesaScreenState();
}

class _FormDespesaScreenState extends State<FormDespesaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final DespesasService _service;
  late final CategoriasDespesaService _categoriasService;
  late final TextEditingController _valorController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _kmController;
  late DateTime _data;

  List<CategoriaDespesa> _categorias = const [];
  CategoriaDespesa? _categoriaSelecionada;
  List<AnexoRegistro> _anexosNfAtuais = const [];
  final Set<int> _idsRemoverNf = {};
  final Set<String> _urlsRemoverNf = {};
  final List<ArquivoSelecionado> _arquivosNovosNf = [];
  bool _carregandoCategorias = true;
  bool _carregandoRegistro = false;
  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _service = DespesasService(apiClient: ApiClient());
    _categoriasService = CategoriasDespesaService(apiClient: ApiClient());
    final item = widget.despesa;
    if (item != null) {
      _carregandoRegistro = true;
      _data = DateTime.tryParse(item.data) ?? DateTime.now();
      _valorController = TextEditingController(
        text: Formatacao.decimal(item.valor),
      );
      _descricaoController = TextEditingController(text: item.descricao ?? '');
      _kmController = TextEditingController(
        text: item.km?.toString() ?? '',
      );
      _aplicarAnexos(item);
      _carregarRegistro();
    } else {
      _data = DateTime.now();
      _valorController = TextEditingController();
      _descricaoController = TextEditingController();
      _kmController = TextEditingController(
        text: widget.veiculo.kmAtual.toString(),
      );
    }
    _carregarCategorias();
  }

  void _aplicarAnexos(Despesa item) {
    _anexosNfAtuais = List.from(item.anexosNfParaExibicao);
    _idsRemoverNf.clear();
    _urlsRemoverNf.clear();
    _arquivosNovosNf.clear();
  }

  void _atualizarCampos(Despesa item) {
    _data = DateTime.tryParse(item.data) ?? _data;
    _valorController.text = Formatacao.decimal(item.valor);
    _descricaoController.text = item.descricao ?? '';
    _kmController.text = item.km?.toString() ?? '';
    _aplicarAnexos(item);
  }

  Future<void> _carregarRegistro() async {
    final item = widget.despesa;
    if (item == null) return;

    try {
      final atualizado = await _service.obterPorVeiculo(
        widget.veiculo.id,
        item.id,
      );
      if (!mounted) return;
      setState(() {
        if (atualizado != null) {
          _atualizarCampos(atualizado);
        }
        _carregandoRegistro = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroGeral = error.message;
        _carregandoRegistro = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoRegistro = false);
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    setState(() {
      _carregandoCategorias = true;
      _erroGeral = null;
    });
    try {
      final lista =
          await _categoriasService.listarPorVeiculo(widget.veiculo.id);
      if (!mounted) return;
      CategoriaDespesa? selecionada;
      if (widget.despesa != null) {
        for (final c in lista) {
          if (c.id == widget.despesa!.categoriaDespesaId) {
            selecionada = c;
            break;
          }
        }
      } else if (lista.isNotEmpty) {
        selecionada = lista.first;
      }
      setState(() {
        _categorias = lista;
        _categoriaSelecionada = selecionada;
        _carregandoCategorias = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroGeral = e.message;
        _carregandoCategorias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Erro ao carregar categorias.';
        _carregandoCategorias = false;
      });
    }
  }

  Future<void> _abrirCategorias() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoriasDespesaScreen(veiculo: widget.veiculo),
      ),
    );
    if (mounted) await _carregarCategorias();
  }

  Future<void> _adicionarAnexosNf(List<ArquivoSelecionado> arquivos) async {
    if (!mounted || arquivos.isEmpty) return;
    if (excedeLimiteAnexos(
      _anexosNfAtuais,
      idsRemover: _idsRemoverNf,
      urlsRemover: _urlsRemoverNf,
      arquivosNovos: _arquivosNovosNf.length,
      adicionar: arquivos.length,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de $maxAnexosPorRegistro anexos por registro.'),
        ),
      );
      return;
    }
    setState(() => _arquivosNovosNf.addAll(arquivos));
  }

  Future<void> _adicionarAnexoNf(ArquivoSelecionado? arquivo) async {
    if (arquivo == null) return;
    await _adicionarAnexosNf([arquivo]);
  }

  Future<void> _tratarErroAnexo(SelecaoArquivoException error) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  }

  Future<void> _tirarFotoNf() async {
    try {
      await _adicionarAnexoNf(await selecionarImagemAnexo(ImageSource.camera));
    } on SelecaoArquivoException catch (error) {
      await _tratarErroAnexo(error);
    }
  }

  Future<void> _escolherOutroNf() async {
    try {
      await _adicionarAnexosNf(await selecionarMultiplosAnexos());
    } on SelecaoArquivoException catch (error) {
      await _tratarErroAnexo(error);
    }
  }

  void _removerAnexoExistenteNf(int id) {
    setState(() => _idsRemoverNf.add(id));
  }

  void _removerAnexoUrlLegadoNf(String url) {
    setState(() => _urlsRemoverNf.add(chaveUrlAnexo(AnexoRegistro(id: 0, url: url))));
  }

  void _removerAnexoNovoNf(int indice) {
    setState(() => _arquivosNovosNf.removeAt(indice));
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoriaSelecionada == null) {
      setState(() => _erroGeral = 'Selecione uma categoria.');
      return;
    }

    final valor = ParseNumero.decimal(_valorController.text);
    if (valor == null) return;

    final kmTexto = _kmController.text.trim();
    final km = kmTexto.isEmpty ? null : int.tryParse(kmTexto);

    setState(() => _salvando = true);

    try {
      final dataIso = IsoDatetime.data(_data);
      final descricao = _descricaoController.text.trim();
      final removerTodosNf = todosAnexosMarcadosRemover(
        _anexosNfAtuais,
        idsRemover: _idsRemoverNf,
        urlsRemover: _urlsRemoverNf,
      );

      if (widget.editando) {
        await _service.atualizar(
          id: widget.despesa!.id,
          categoriaDespesaId: _categoriaSelecionada!.id,
          dataIso: dataIso,
          valor: valor,
          descricao: descricao.isEmpty ? null : descricao,
          km: km,
          arquivosNf: _arquivosNovosNf,
          removerNf: removerTodosNf && _arquivosNovosNf.isEmpty,
          removerAnexoIds: _idsRemoverNf.toList(),
        );
      } else {
        await _service.criar(
          veiculoId: widget.veiculo.id,
          categoriaDespesaId: _categoriaSelecionada!.id,
          dataIso: dataIso,
          valor: valor,
          descricao: descricao.isEmpty ? null : descricao,
          km: km,
          arquivosNf: _arquivosNovosNf,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erroGeral = e.message;
        _salvando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Erro ao salvar despesa.';
        _salvando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = _carregandoCategorias || _carregandoRegistro;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar despesa' : 'Nova despesa'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blueText),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_erroGeral != null) ...[
                      Text(_erroGeral!, style: TextStyle(color: AppColors.red)),
                      const SizedBox(height: 12),
                    ],
                    if (_categorias.isEmpty) ...[
                      Text(
                        'Cadastre categorias antes de lançar despesas.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _abrirCategorias,
                        child: const Text('Gerenciar categorias'),
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<CategoriaDespesa>(
                              value: _categoriaSelecionada,
                              decoration: const InputDecoration(
                                labelText: 'Categoria *',
                              ),
                              items: _categorias
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text('${c.icone} ${c.nome}'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _salvando
                                  ? null
                                  : (v) => setState(
                                        () => _categoriaSelecionada = v,
                                      ),
                              validator: validarCategoriaDespesa,
                            ),
                          ),
                          IconButton(
                            onPressed: _salvando ? null : _abrirCategorias,
                            tooltip: 'Categorias',
                            icon: const Icon(Icons.category_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Data *'),
                        subtitle: Text(
                          Formatacao.data(IsoDatetime.data(_data)),
                        ),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: _salvando
                            ? null
                            : () async {
                                final escolhida = await selecionarDataBr(
                                  context,
                                  dataInicial: _data,
                                  primeiraData: DateTime(2000),
                                  ultimaData: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                );
                                if (escolhida != null && mounted) {
                                  setState(() => _data = escolhida);
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valorController,
                        enabled: !_salvando,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Valor (R\$) *',
                        ),
                        validator: validarValorDespesa,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _kmController,
                        enabled: !_salvando,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Km (opcional)',
                          hintText: 'Hodômetro no lançamento',
                        ),
                        validator: validarKmDespesa,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descricaoController,
                        enabled: !_salvando,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descrição (opcional)',
                        ),
                        validator: validarDescricaoDespesa,
                      ),
                      const SizedBox(height: 16),
                      SecaoAnexosFormulario(
                        rotulo: 'Comprovantes (anexos)',
                        anexosAtuais: _anexosNfAtuais,
                        idsRemover: _idsRemoverNf,
                        urlsRemover: _urlsRemoverNf,
                        arquivosNovos: _arquivosNovosNf,
                        desabilitado: _salvando,
                        onTirarFoto: _tirarFotoNf,
                        onEscolherOutro: _escolherOutroNf,
                        onRemoverExistente: _removerAnexoExistenteNf,
                        onRemoverUrlLegado: _removerAnexoUrlLegadoNf,
                        onRemoverNovo: _removerAnexoNovoNf,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _salvando ? null : _salvar,
                          child: _salvando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(widget.editando ? 'Salvar' : 'Registrar'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
