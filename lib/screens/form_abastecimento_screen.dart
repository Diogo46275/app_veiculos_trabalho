import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/abastecimento.dart';
import '../models/anexo_registro.dart';
import '../models/veiculo.dart';
import '../services/abastecimentos_service.dart';
import '../services/api_client.dart';
import '../services/veiculo_modulos_service.dart';
import '../theme/app_colors.dart';
import '../utils/anexo_exibicao.dart';
import '../utils/formatacao.dart';
import '../utils/parse_numero.dart';
import '../utils/seletor_arquivo.dart';
import '../utils/seletor_data_br.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/secao_anexos_formulario.dart';

enum DocumentoTipoAbastecimento {
  sem('sem', 'Sem documento'),
  cpf('cpf', 'CPF do usuário'),
  cnpj('cnpj', 'CNPJ do usuário');

  const DocumentoTipoAbastecimento(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static DocumentoTipoAbastecimento fromValor(String? valor) {
    return DocumentoTipoAbastecimento.values.firstWhere(
      (item) => item.valor == valor,
      orElse: () => DocumentoTipoAbastecimento.sem,
    );
  }
}

class FormAbastecimentoScreen extends StatefulWidget {
  const FormAbastecimentoScreen({
    super.key,
    required this.veiculo,
    this.abastecimento,
  });

  final Veiculo veiculo;
  final Abastecimento? abastecimento;

  bool get editando => abastecimento != null;

  @override
  State<FormAbastecimentoScreen> createState() =>
      _FormAbastecimentoScreenState();
}

class _FormAbastecimentoScreenState extends State<FormAbastecimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AbastecimentosService _service;
  late final VeiculoModulosService _modulosService;

  late DateTime _data;
  late final TextEditingController _kmController;
  late final TextEditingController _litrosController;
  late final TextEditingController _valorController;
  late final TextEditingController _postoController;

  DocumentoTipoAbastecimento _documentoTipo = DocumentoTipoAbastecimento.sem;
  List<AnexoRegistro> _anexosNfAtuais = const [];
  final Set<int> _idsRemoverNf = {};
  final Set<String> _urlsRemoverNf = {};
  final List<ArquivoSelecionado> _arquivosNovosNf = [];
  bool _carregandoRegistro = false;
  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _service = AbastecimentosService(apiClient: ApiClient());
    _modulosService = VeiculoModulosService(apiClient: ApiClient());
    final item = widget.abastecimento;
    if (item != null) {
      _carregandoRegistro = true;
      _preencherCampos(item);
      _carregarRegistro();
    } else {
      _data = DateTime.now();
      _kmController = TextEditingController(
        text: widget.veiculo.kmAtual.toString(),
      );
      _litrosController = TextEditingController();
      _valorController = TextEditingController();
      _postoController = TextEditingController();
    }
  }

  void _preencherCampos(Abastecimento item) {
    _data = DateTime.tryParse(item.data) ?? DateTime.now();
    _kmController = TextEditingController(text: item.km.toString());
    _litrosController = TextEditingController(
      text: Formatacao.decimal(item.litros),
    );
    _valorController = TextEditingController(
      text: Formatacao.decimal(item.valor),
    );
    _postoController = TextEditingController(text: item.posto ?? '');
    _documentoTipo = DocumentoTipoAbastecimento.fromValor(item.documentoTipo);
    _aplicarAnexos(item);
  }

  void _atualizarCampos(Abastecimento item) {
    _data = DateTime.tryParse(item.data) ?? _data;
    _kmController.text = item.km.toString();
    _litrosController.text = Formatacao.decimal(item.litros);
    _valorController.text = Formatacao.decimal(item.valor);
    _postoController.text = item.posto ?? '';
    _documentoTipo = DocumentoTipoAbastecimento.fromValor(item.documentoTipo);
    _aplicarAnexos(item);
  }

  void _aplicarAnexos(Abastecimento item) {
    _anexosNfAtuais = List.from(item.anexosNfParaExibicao);
    _idsRemoverNf.clear();
    _urlsRemoverNf.clear();
    _arquivosNovosNf.clear();
  }

  Future<void> _carregarRegistro() async {
    final item = widget.abastecimento;
    if (item == null) return;

    try {
      final atualizado = await _modulosService.obterAbastecimento(
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
    _modulosService.dispose();
    _kmController.dispose();
    _litrosController.dispose();
    _valorController.dispose();
    _postoController.dispose();
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

    final erroData = validarDataAbastecimento(_data);
    if (erroData != null) {
      setState(() => _erroGeral = erroData);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final km = ParseNumero.inteiro(_kmController.text);
    final litros = ParseNumero.decimal(_litrosController.text);
    final valor = ParseNumero.decimal(_valorController.text);

    if (km == null || litros == null || valor == null) return;

    setState(() => _salvando = true);

    try {
      final removerTodosNf = todosAnexosMarcadosRemover(
        _anexosNfAtuais,
        idsRemover: _idsRemoverNf,
        urlsRemover: _urlsRemoverNf,
      );

      if (widget.editando) {
        await _service.atualizar(
          id: widget.abastecimento!.id,
          data: _dataIso,
          km: km,
          litros: litros,
          valor: valor,
          posto: _postoController.text,
          documentoTipo: _documentoTipo.valor,
          arquivosNf: _arquivosNovosNf,
          removerNf: removerTodosNf && _arquivosNovosNf.isEmpty,
          removerAnexoIds: _idsRemoverNf.toList(),
        );
      } else {
        await _service.criar(
          veiculoId: widget.veiculo.id,
          data: _dataIso,
          km: km,
          litros: litros,
          valor: valor,
          posto: _postoController.text,
          documentoTipo: _documentoTipo.valor,
          arquivosNf: _arquivosNovosNf,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editando
                ? 'Abastecimento atualizado'
                : 'Abastecimento registrado',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao salvar abastecimento.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editando ? 'Editar abastecimento' : 'Novo abastecimento',
        ),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: _carregandoRegistro
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
                decoration: const InputDecoration(labelText: 'Km *'),
                validator: validarKmAbastecimento,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litrosController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !_salvando,
                decoration: const InputDecoration(labelText: 'Litros *'),
                validator: validarLitros,
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
                controller: _postoController,
                enabled: !_salvando,
                maxLength: 120,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Posto',
                  hintText: 'Opcional',
                ),
                validator: validarPosto,
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
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
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
