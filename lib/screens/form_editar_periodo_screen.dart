import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/periodo_trabalho.dart';
import '../models/receita.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/periodos_trabalho_service.dart';
import '../services/receitas_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/seletor_data_hora_br.dart';
import '../validacao/validadores_formulario.dart';
import 'form_receita_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/estado_lista_tab.dart';

class FormEditarPeriodoScreen extends StatefulWidget {
  const FormEditarPeriodoScreen({
    super.key,
    required this.veiculo,
    required this.periodo,
  });

  final Veiculo veiculo;
  final PeriodoTrabalho periodo;

  @override
  State<FormEditarPeriodoScreen> createState() =>
      _FormEditarPeriodoScreenState();
}

class _FormEditarPeriodoScreenState extends State<FormEditarPeriodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PeriodosTrabalhoService _periodosService;
  late final ReceitasService _receitasService;
  late final TextEditingController _kmInicioController;
  late final TextEditingController _kmFimController;
  late DateTime _dataHoraInicio;
  late DateTime _dataHoraFim;

  List<Receita> _ganhos = const [];
  bool _carregandoGanhos = true;
  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    final client = ApiClient();
    _periodosService = PeriodosTrabalhoService(apiClient: client);
    _receitasService = ReceitasService(apiClient: client);
    final p = widget.periodo;
    _kmInicioController = TextEditingController(text: p.kmInicio.toString());
    _kmFimController = TextEditingController(text: p.kmFim?.toString() ?? '');
    _dataHoraInicio =
        DateTime.tryParse(p.dataHoraInicio) ?? DateTime.now();
    _dataHoraFim = DateTime.tryParse(p.dataHoraFim ?? '') ?? DateTime.now();
    _carregarGanhos();
  }

  Future<void> _carregarGanhos() async {
    setState(() {
      _carregandoGanhos = true;
      _erroGeral = null;
    });
    try {
      final lista = await _receitasService.listarPorPeriodo(widget.periodo.id);
      if (!mounted) return;
      setState(() {
        _ganhos = lista;
        _carregandoGanhos = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroGeral = error.message;
        _carregandoGanhos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Erro ao carregar ganhos do turno.';
        _carregandoGanhos = false;
      });
    }
  }

  @override
  void dispose() {
    _kmInicioController.dispose();
    _kmFimController.dispose();
    super.dispose();
  }

  Future<void> _selecionarInicio() async {
    final selecionada = await selecionarDataHoraBr(
      context,
      dataInicial: _dataHoraInicio,
      primeiraData: DateTime(2000),
      ultimaData: DateTime.now().add(const Duration(days: 365)),
    );
    if (selecionada == null || !mounted) return;
    setState(() => _dataHoraInicio = selecionada);
  }

  Future<void> _selecionarFim() async {
    final selecionada = await selecionarDataHoraBr(
      context,
      dataInicial: _dataHoraFim,
      primeiraData: DateTime(
        _dataHoraInicio.year,
        _dataHoraInicio.month,
        _dataHoraInicio.day,
      ),
      ultimaData: DateTime.now().add(const Duration(days: 365)),
    );
    if (selecionada == null || !mounted) return;
    setState(() => _dataHoraFim = selecionada);
  }

  Future<void> _editarGanho(Receita item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormReceitaScreen(
          veiculo: widget.veiculo,
          periodo: widget.periodo,
          receita: item,
        ),
      ),
    );
    if (salvo == true && mounted) await _carregarGanhos();
  }

  Future<void> _excluirGanho(Receita item) async {
    final confirmado = await confirmarExclusaoReceita(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _receitasService.excluir(item.id);
      if (!mounted) return;
      await _carregarGanhos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ganho excluído')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final erroFim = validarDataHoraFimPeriodo(
      _dataHoraFim,
      inicio: _dataHoraInicio,
    );
    if (erroFim != null) {
      setState(() => _erroGeral = erroFim);
      return;
    }

    setState(() => _salvando = true);

    try {
      await _periodosService.atualizar(
        periodoId: widget.periodo.id,
        kmInicio: int.parse(_kmInicioController.text.trim()),
        kmFim: int.parse(_kmFimController.text.trim()),
        dataHoraInicio: _dataHoraInicio,
        dataHoraFim: _dataHoraFim,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno atualizado')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao salvar turno.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar turno'),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Início *'),
                subtitle:
                    Text(Formatacao.dataHora(_dataHoraInicio.toIso8601String())),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _salvando ? null : _selecionarInicio,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fim *'),
                subtitle:
                    Text(Formatacao.dataHora(_dataHoraFim.toIso8601String())),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _salvando ? null : _selecionarFim,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kmInicioController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_salvando,
                decoration: const InputDecoration(labelText: 'Km inicial *'),
                validator: validarKmPeriodo,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmFimController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_salvando,
                decoration: const InputDecoration(labelText: 'Km final *'),
                validator: (value) => validarKmFimPeriodo(
                  value,
                  kmInicioTexto: _kmInicioController.text,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ganhos do turno',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              if (_carregandoGanhos)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_ganhos.isEmpty)
                const Text(
                  'Nenhum ganho registrado neste turno.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                ..._ganhos.map(
                  (item) => DetalheItemCard(
                    titulo: item.plataformaNome ?? 'Plataforma',
                    linhas: [
                      'Data: ${Formatacao.data(item.data)}',
                      'Valor: ${Formatacao.moeda(item.valor)}',
                      if (item.descricao != null && item.descricao!.isNotEmpty)
                        item.descricao!,
                    ],
                    onEdit: () => _editarGanho(item),
                    onDelete: () => _excluirGanho(item),
                  ),
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
                      : const Text('Salvar turno'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
