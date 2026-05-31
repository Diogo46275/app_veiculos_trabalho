import 'package:flutter/material.dart';

import '../models/periodo_trabalho.dart';
import '../models/plataforma.dart';
import '../models/receita.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/plataformas_service.dart';
import '../services/receitas_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/parse_numero.dart';
import '../utils/seletor_data_br.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class FormReceitaScreen extends StatefulWidget {
  const FormReceitaScreen({
    super.key,
    required this.veiculo,
    required this.periodo,
    this.receita,
  });

  final Veiculo veiculo;
  final PeriodoTrabalho periodo;
  final Receita? receita;

  bool get editando => receita != null;

  @override
  State<FormReceitaScreen> createState() => _FormReceitaScreenState();
}

class _FormReceitaScreenState extends State<FormReceitaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ReceitasService _service;
  late final PlataformasService _plataformasService;
  late final TextEditingController _valorController;
  late final TextEditingController _descricaoController;
  late DateTime _data;

  List<Plataforma> _plataformas = const [];
  Plataforma? _plataformaSelecionada;
  bool _carregandoPlataformas = true;
  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    final client = ApiClient();
    _service = ReceitasService(apiClient: client);
    _plataformasService = PlataformasService(apiClient: client);
    final item = widget.receita;
    if (item != null) {
      _data = DateTime.tryParse(item.data) ?? DateTime.now();
      _valorController = TextEditingController(
        text: Formatacao.decimal(item.valor),
      );
      _descricaoController = TextEditingController(text: item.descricao ?? '');
    } else {
      final inicio =
          DateTime.tryParse(widget.periodo.dataHoraInicio) ?? DateTime.now();
      _data = DateTime(inicio.year, inicio.month, inicio.day);
      _valorController = TextEditingController();
      _descricaoController = TextEditingController();
    }
    _carregarPlataformas(item?.plataformaId);
  }

  Future<void> _carregarPlataformas(int? plataformaIdEdicao) async {
    setState(() {
      _carregandoPlataformas = true;
      _erroGeral = null;
    });
    try {
      final lista = await _plataformasService.listar();
      if (!mounted) return;
      Plataforma? selecionada;
      if (plataformaIdEdicao != null) {
        for (final p in lista) {
          if (p.id == plataformaIdEdicao) {
            selecionada = p;
            break;
          }
        }
      } else if (lista.length == 1) {
        selecionada = lista.first;
      }
      setState(() {
        _plataformas = lista;
        _plataformaSelecionada = selecionada;
        _carregandoPlataformas = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroGeral = error.message;
        _carregandoPlataformas = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Erro ao carregar plataformas.';
        _carregandoPlataformas = false;
      });
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  DateTime? get _inicioTurno =>
      DateTime.tryParse(widget.periodo.dataHoraInicio);

  DateTime? get _fimTurno {
    if (widget.periodo.dataHoraFim != null) {
      return DateTime.tryParse(widget.periodo.dataHoraFim!);
    }
    return widget.periodo.aberto ? DateTime.now() : null;
  }

  Future<void> _selecionarData() async {
    final inicio = _inicioTurno ?? DateTime.now();
    final selecionada = await selecionarDataBr(
      context,
      dataInicial: _data,
      primeiraData: DateTime(inicio.year, inicio.month, inicio.day),
      ultimaData: DateTime.now().add(const Duration(days: 1)),
    );
    if (selecionada == null || !mounted) return;
    setState(() => _data = selecionada);
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (_plataformas.isEmpty) {
      setState(() {
        _erroGeral =
            'Cadastre plataformas na aba Perfil antes de registrar ganhos.';
      });
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final erroData = validarDataReceita(
      _data,
      inicioTurno: _inicioTurno,
      fimTurno: _fimTurno,
    );
    if (erroData != null) {
      setState(() => _erroGeral = erroData);
      return;
    }

    final valor = ParseNumero.decimal(_valorController.text);
    if (valor == null) return;

    setState(() => _salvando = true);

    try {
      if (widget.editando) {
        await _service.atualizar(
          id: widget.receita!.id,
          plataformaId: _plataformaSelecionada!.id,
          data: _data,
          valor: valor,
          descricao: _descricaoController.text,
        );
      } else {
        await _service.criar(
          periodoId: widget.periodo.id,
          plataformaId: _plataformaSelecionada!.id,
          data: _data,
          valor: valor,
          descricao: _descricaoController.text,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editando ? 'Ganho atualizado' : 'Ganho registrado',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao salvar ganho.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoPlataformas) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.editando ? 'Editar ganho' : 'Novo ganho'),
          actions: acoesAppBarComDashboard(const []),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar ganho' : 'Novo ganho'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_erroGeral != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<Plataforma>(
                value: _plataformaSelecionada,
                decoration: const InputDecoration(labelText: 'Plataforma *'),
                items: _plataformas
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.nome),
                      ),
                    )
                    .toList(),
                onChanged: _salvando
                    ? null
                    : (valor) => setState(() => _plataformaSelecionada = valor),
                validator: (_) => validarPlataformaReceita(_plataformaSelecionada),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data *'),
                subtitle: Text(Formatacao.data(_data.toIso8601String())),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _salvando ? null : _selecionarData,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: !_salvando,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$) *',
                ),
                validator: validarValorReceita,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                enabled: !_salvando,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                ),
                validator: validarDescricaoReceita,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(widget.editando ? 'Salvar' : 'Registrar ganho'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
