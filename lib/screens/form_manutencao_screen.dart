import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/anexo_registro.dart';
import '../models/manutencao.dart';
import '../models/tipo_manutencao.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/manutencoes_service.dart';
import '../services/tipos_manutencao_service.dart';
import '../services/veiculo_modulos_service.dart';
import '../theme/app_colors.dart';
import '../utils/anexo_exibicao.dart';
import '../utils/formatacao.dart';
import '../utils/parse_numero.dart';
import '../utils/seletor_arquivo.dart';
import '../utils/seletor_data_br.dart';
import '../validacao/mensagens_validacao.dart';
import '../validacao/validadores_formulario.dart';
import 'form_abastecimento_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/secao_anexos_formulario.dart';

class FormManutencaoScreen extends StatefulWidget {
  const FormManutencaoScreen({
    super.key,
    required this.veiculo,
    this.manutencao,
  });

  final Veiculo veiculo;
  final Manutencao? manutencao;

  bool get editando => manutencao != null;

  @override
  State<FormManutencaoScreen> createState() => _FormManutencaoScreenState();
}

class _FormManutencaoScreenState extends State<FormManutencaoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ManutencoesService _service;
  late final TiposManutencaoService _tiposService;
  late final VeiculoModulosService _modulosService;

  late DateTime _data;
  late final TextEditingController _kmController;
  late final TextEditingController _valorController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _garantiaDiasController;

  List<TipoManutencao> _tipos = const [];
  TipoManutencao? _tipoSelecionado;
  DocumentoTipoAbastecimento _documentoTipo = DocumentoTipoAbastecimento.sem;
  List<AnexoRegistro> _anexosNfAtuais = const [];
  List<AnexoRegistro> _anexosGarantiaAtuais = const [];
  final Set<int> _idsRemoverNf = {};
  final Set<int> _idsRemoverGarantia = {};
  final Set<String> _urlsRemoverNf = {};
  final Set<String> _urlsRemoverGarantia = {};
  final List<ArquivoSelecionado> _arquivosNovosNf = [];
  final List<ArquivoSelecionado> _arquivosNovosGarantia = [];

  bool _carregandoTipos = true;
  bool _carregandoRegistro = false;
  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _service = ManutencoesService(apiClient: ApiClient());
    _tiposService = TiposManutencaoService(apiClient: ApiClient());
    _modulosService = VeiculoModulosService(apiClient: ApiClient());
    final item = widget.manutencao;
    if (item != null) {
      _carregandoRegistro = true;
      _preencherCampos(item);
      _carregarRegistro();
    } else {
      _data = DateTime.now();
      _kmController = TextEditingController(
        text: widget.veiculo.kmAtual.toString(),
      );
      _valorController = TextEditingController();
      _descricaoController = TextEditingController();
      _garantiaDiasController = TextEditingController();
    }
    _carregarTipos();
  }

  void _preencherCampos(Manutencao item) {
    _data = DateTime.tryParse(item.data) ?? DateTime.now();
    _kmController = TextEditingController(
      text: item.km?.toString() ?? '',
    );
    _valorController = TextEditingController(
      text: Formatacao.decimal(item.valor),
    );
    _descricaoController = TextEditingController(text: item.descricao ?? '');
    _garantiaDiasController = TextEditingController(
      text: item.garantiaDias?.toString() ?? '',
    );
    _documentoTipo = DocumentoTipoAbastecimento.fromValor(item.documentoTipo);
    _aplicarAnexos(item);
  }

  void _atualizarCampos(Manutencao item) {
    _data = DateTime.tryParse(item.data) ?? _data;
    _kmController.text = item.km?.toString() ?? '';
    _valorController.text = Formatacao.decimal(item.valor);
    _descricaoController.text = item.descricao ?? '';
    _garantiaDiasController.text = item.garantiaDias?.toString() ?? '';
    _documentoTipo = DocumentoTipoAbastecimento.fromValor(item.documentoTipo);
    _aplicarAnexos(item);
  }

  void _aplicarAnexos(Manutencao item) {
    _anexosNfAtuais = List.from(item.anexosNfParaExibicao);
    _anexosGarantiaAtuais = List.from(item.anexosGarantiaParaExibicao);
    _idsRemoverNf.clear();
    _idsRemoverGarantia.clear();
    _urlsRemoverNf.clear();
    _urlsRemoverGarantia.clear();
    _arquivosNovosNf.clear();
    _arquivosNovosGarantia.clear();
  }

  Future<void> _carregarRegistro() async {
    final item = widget.manutencao;
    if (item == null) return;

    try {
      final atualizado = await _modulosService.obterManutencao(
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

  Future<void> _carregarTipos() async {
    setState(() {
      _carregandoTipos = true;
      _erroGeral = null;
    });
    try {
      final tipos = await _tiposService.listar();
      if (!mounted) return;
      TipoManutencao? selecionado;
      final idEdicao = widget.manutencao?.tipoManutencaoId;
      if (idEdicao != null) {
        for (final tipo in tipos) {
          if (tipo.id == idEdicao) {
            selecionado = tipo;
            break;
          }
        }
      } else if (tipos.length == 1) {
        selecionado = tipos.first;
      }
      setState(() {
        _tipos = tipos;
        _tipoSelecionado = selecionado;
        _carregandoTipos = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroGeral = error.message;
        _carregandoTipos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Erro ao carregar tipos de manutenção.';
        _carregandoTipos = false;
      });
    }
  }

  @override
  void dispose() {
    _modulosService.dispose();
    _kmController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    _garantiaDiasController.dispose();
    super.dispose();
  }

  String get _dataIso {
    final ano = _data.year.toString().padLeft(4, '0');
    final mes = _data.month.toString().padLeft(2, '0');
    final dia = _data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }

  Future<void> _selecionarData() async {
    final escolhida = await selecionarDataBr(
      context,
      dataInicial: _data,
      primeiraData: DateTime(2000),
      ultimaData: DateTime.now().add(const Duration(days: 1)),
    );
    if (escolhida != null) {
      setState(() => _data = escolhida);
    }
  }

  int? _kmInformado() {
    final texto = _kmController.text.trim();
    if (texto.isEmpty) return null;
    return ParseNumero.inteiro(texto);
  }

  int? _garantiaDiasInformada() {
    final texto = _garantiaDiasController.text.trim();
    if (texto.isEmpty) return null;
    return ParseNumero.inteiro(texto);
  }

  Future<void> _tirarFotoNf() async {
    await _anexarImagem(
      source: ImageSource.camera,
      onSelecionado: (arquivo) => setState(() => _arquivosNovosNf.add(arquivo)),
    );
  }

  Future<void> _escolherOutroNf() async {
    await _anexarDialog(
      onSelecionado: (arquivo) => setState(() => _arquivosNovosNf.add(arquivo)),
    );
  }

  Future<void> _tirarFotoGarantia() async {
    await _anexarImagem(
      source: ImageSource.camera,
      onSelecionado: (arquivo) =>
          setState(() => _arquivosNovosGarantia.add(arquivo)),
    );
  }

  Future<void> _escolherOutroGarantia() async {
    await _anexarDialog(
      onSelecionado: (arquivo) =>
          setState(() => _arquivosNovosGarantia.add(arquivo)),
    );
  }

  Future<void> _anexarImagem({
    required ImageSource source,
    required void Function(ArquivoSelecionado arquivo) onSelecionado,
  }) async {
    try {
      final arquivo = await selecionarImagemAnexo(source);
      if (!mounted || arquivo == null) return;
      onSelecionado(arquivo);
    } on SelecaoArquivoException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _anexarDialog({
    required void Function(ArquivoSelecionado arquivo) onSelecionado,
  }) async {
    try {
      final arquivo = await escolherAnexoComDialog(context);
      if (!mounted || arquivo == null) return;
      onSelecionado(arquivo);
    } on SelecaoArquivoException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
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

  void _removerAnexoExistenteGarantia(int id) {
    setState(() => _idsRemoverGarantia.add(id));
  }

  void _removerAnexoUrlLegadoGarantia(String url) {
    setState(
      () => _urlsRemoverGarantia.add(
        chaveUrlAnexo(AnexoRegistro(id: 0, url: url)),
      ),
    );
  }

  void _removerAnexoNovoGarantia(int indice) {
    setState(() => _arquivosNovosGarantia.removeAt(indice));
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    final erroData = validarDataAbastecimento(_data);
    if (erroData != null) {
      setState(() => _erroGeral = erroData);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_tipoSelecionado == null) {
      setState(() => _erroGeral = MensagensValidacao.tipoManutencaoObrigatorio);
      return;
    }

    final valor = ParseNumero.decimal(_valorController.text);
    if (valor == null) return;

    setState(() => _salvando = true);

    try {
      final removerTodosNf = todosAnexosMarcadosRemover(
        _anexosNfAtuais,
        idsRemover: _idsRemoverNf,
        urlsRemover: _urlsRemoverNf,
      );
      final removerTodaGarantia = todosAnexosMarcadosRemover(
        _anexosGarantiaAtuais,
        idsRemover: _idsRemoverGarantia,
        urlsRemover: _urlsRemoverGarantia,
      );

      if (widget.editando) {
        await _service.atualizar(
          id: widget.manutencao!.id,
          tipoManutencaoId: _tipoSelecionado!.id,
          data: _dataIso,
          valor: valor,
          descricao: _descricaoController.text,
          km: _kmInformado(),
          garantiaDias: _garantiaDiasInformada(),
          documentoTipo: _documentoTipo.valor,
          arquivosNf: _arquivosNovosNf,
          arquivosGarantia: _arquivosNovosGarantia,
          removerNf: removerTodosNf && _arquivosNovosNf.isEmpty,
          removerGarantia:
              removerTodaGarantia && _arquivosNovosGarantia.isEmpty,
          removerAnexoNfIds: _idsRemoverNf.toList(),
          removerAnexoGarantiaIds: _idsRemoverGarantia.toList(),
        );
      } else {
        await _service.criar(
          veiculoId: widget.veiculo.id,
          tipoManutencaoId: _tipoSelecionado!.id,
          data: _dataIso,
          valor: valor,
          descricao: _descricaoController.text,
          km: _kmInformado(),
          garantiaDias: _garantiaDiasInformada(),
          documentoTipo: _documentoTipo.valor,
          arquivosNf: _arquivosNovosNf,
          arquivosGarantia: _arquivosNovosGarantia,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editando ? 'Manutenção atualizada' : 'Manutenção registrada',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao salvar manutenção.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editando ? 'Editar manutenção' : 'Nova manutenção',
        ),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: _carregandoTipos || _carregandoRegistro
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.veiculo.rotulo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Km atual do veículo: ${Formatacao.km(widget.veiculo.kmAtual)}',
                      style: const TextStyle(color: AppColors.blueText),
                    ),
                    const SizedBox(height: 24),
                    if (_erroGeral != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.red),
                        ),
                        child: Text(
                          _erroGeral!,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                    if (_tipos.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: const Text(
                          'Nenhum tipo de manutenção cadastrado. '
                          'Cadastre tipos na aba Perfil antes de registrar.',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    DropdownButtonFormField<TipoManutencao>(
                      value: _tipoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de manutenção *',
                      ),
                      items: _tipos
                          .map(
                            (tipo) => DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo.nome),
                            ),
                          )
                          .toList(),
                      onChanged: _salvando || _tipos.isEmpty
                          ? null
                          : (valor) {
                              setState(() => _tipoSelecionado = valor);
                            },
                      validator: validarTipoManutencao,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _salvando ? null : _selecionarData,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data *',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          Formatacao.data(_dataIso),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !_salvando,
                      decoration: const InputDecoration(
                        labelText: 'Km',
                        hintText: 'Opcional',
                      ),
                      validator: validarKmManutencao,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      enabled: !_salvando,
                      decoration: const InputDecoration(labelText: 'Valor (R\$) *'),
                      validator: validarValorAbastecimento,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      enabled: !_salvando,
                      maxLength: 2000,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Opcional',
                      ),
                      validator: validarDescricaoManutencao,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _garantiaDiasController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      enabled: !_salvando,
                      decoration: const InputDecoration(
                        labelText: 'Garantia (dias)',
                        hintText: 'Opcional',
                      ),
                      validator: validarGarantiaDias,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DocumentoTipoAbastecimento>(
                      value: _documentoTipo,
                      decoration: const InputDecoration(labelText: 'Documento NF'),
                      items: DocumentoTipoAbastecimento.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.rotulo),
                            ),
                          )
                          .toList(),
                      onChanged: _salvando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                setState(() => _documentoTipo = valor);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    SecaoAnexosFormulario(
                      rotulo: 'Nota fiscal (anexos)',
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
                    const SizedBox(height: 16),
                    SecaoAnexosFormulario(
                      rotulo: 'Garantia (anexos)',
                      anexosAtuais: _anexosGarantiaAtuais,
                      idsRemover: _idsRemoverGarantia,
                      urlsRemover: _urlsRemoverGarantia,
                      arquivosNovos: _arquivosNovosGarantia,
                      desabilitado: _salvando,
                      onTirarFoto: _tirarFotoGarantia,
                      onEscolherOutro: _escolherOutroGarantia,
                      onRemoverExistente: _removerAnexoExistenteGarantia,
                      onRemoverUrlLegado: _removerAnexoUrlLegadoGarantia,
                      onRemoverNovo: _removerAnexoNovoGarantia,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _salvando || _tipos.isEmpty ? null : _salvar,
                        child: _salvando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.editando ? 'Salvar' : 'Registrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
