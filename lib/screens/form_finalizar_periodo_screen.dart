import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/periodo_trabalho.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/periodos_trabalho_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/seletor_data_hora_br.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class FormFinalizarPeriodoScreen extends StatefulWidget {
  const FormFinalizarPeriodoScreen({
    super.key,
    required this.veiculo,
    required this.periodo,
  });

  final Veiculo veiculo;
  final PeriodoTrabalho periodo;

  @override
  State<FormFinalizarPeriodoScreen> createState() =>
      _FormFinalizarPeriodoScreenState();
}

class _FormFinalizarPeriodoScreenState extends State<FormFinalizarPeriodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PeriodosTrabalhoService _service;
  late final TextEditingController _kmController;
  late DateTime _dataHoraFim;

  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _service = PeriodosTrabalhoService(apiClient: ApiClient());
    _dataHoraFim = DateTime.now();
    _kmController = TextEditingController(
      text: widget.veiculo.kmAtual.toString(),
    );
  }

  @override
  void dispose() {
    _kmController.dispose();
    super.dispose();
  }

  DateTime get _inicioTurno {
    return DateTime.tryParse(widget.periodo.dataHoraInicio) ?? DateTime.now();
  }

  Future<void> _selecionarFim() async {
    final selecionada = await selecionarDataHoraBr(
      context,
      dataInicial: _dataHoraFim,
      primeiraData: DateTime(
        _inicioTurno.year,
        _inicioTurno.month,
        _inicioTurno.day,
      ),
      ultimaData: DateTime.now().add(const Duration(days: 1)),
    );
    if (selecionada == null || !mounted) return;
    setState(() => _dataHoraFim = selecionada);
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final erroFim = validarDataHoraFimPeriodo(
      _dataHoraFim,
      inicio: _inicioTurno,
    );
    if (erroFim != null) {
      setState(() => _erroGeral = erroFim);
      return;
    }

    final km = int.parse(_kmController.text.trim());
    setState(() => _salvando = true);

    try {
      await _service.finalizar(
        periodoId: widget.periodo.id,
        kmFim: km,
        dataHoraFim: _dataHoraFim,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno finalizado')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao finalizar turno.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar turno'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Início: ${Formatacao.dataHora(widget.periodo.dataHoraInicio)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Km inicial: ${Formatacao.km(widget.periodo.kmInicio)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
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
                title: const Text('Fim *'),
                subtitle: Text(Formatacao.dataHora(_dataHoraFim.toIso8601String())),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _salvando ? null : _selecionarFim,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_salvando,
                decoration: const InputDecoration(
                  labelText: 'Km final (hodômetro) *',
                ),
                validator: (value) => validarKmFimPeriodo(
                  value,
                  kmInicioTexto: widget.periodo.kmInicio.toString(),
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
                      : const Text('Finalizar turno'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
