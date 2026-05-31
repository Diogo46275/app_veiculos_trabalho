import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/periodos_trabalho_service.dart';
import '../services/plataformas_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/seletor_data_hora_br.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class FormIniciarPeriodoScreen extends StatefulWidget {
  const FormIniciarPeriodoScreen({super.key, required this.veiculo});

  final Veiculo veiculo;

  @override
  State<FormIniciarPeriodoScreen> createState() =>
      _FormIniciarPeriodoScreenState();
}

class _FormIniciarPeriodoScreenState extends State<FormIniciarPeriodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final PeriodosTrabalhoService _periodosService;
  late final PlataformasService _plataformasService;
  late final TextEditingController _kmController;
  late DateTime _dataHoraInicio;

  bool _carregandoPlataformas = true;
  bool _salvando = false;
  String? _erroGeral;
  int _qtdPlataformas = 0;

  @override
  void initState() {
    super.initState();
    final client = ApiClient();
    _periodosService = PeriodosTrabalhoService(apiClient: client);
    _plataformasService = PlataformasService(apiClient: client);
    _dataHoraInicio = DateTime.now();
    _kmController = TextEditingController(
      text: widget.veiculo.kmAtual.toString(),
    );
    _carregarPlataformas();
  }

  Future<void> _carregarPlataformas() async {
    setState(() {
      _carregandoPlataformas = true;
      _erroGeral = null;
    });
    try {
      final lista = await _plataformasService.listar();
      if (!mounted) return;
      setState(() {
        _qtdPlataformas = lista.length;
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
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _selecionarInicio() async {
    final selecionada = await selecionarDataHoraBr(
      context,
      dataInicial: _dataHoraInicio,
      primeiraData: DateTime(2000),
      ultimaData: DateTime.now().add(const Duration(days: 1)),
    );
    if (selecionada == null || !mounted) return;
    setState(() => _dataHoraInicio = selecionada);
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (_qtdPlataformas == 0) {
      setState(() {
        _erroGeral =
            'Cadastre plataformas (Uber, 99…) na aba Perfil antes de iniciar.';
      });
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (validarDataHoraPeriodo(_dataHoraInicio) != null) {
      setState(() => _erroGeral = validarDataHoraPeriodo(_dataHoraInicio));
      return;
    }

    final km = int.parse(_kmController.text.trim());
    setState(() => _salvando = true);

    try {
      await _periodosService.iniciar(
        veiculoId: widget.veiculo.id,
        kmInicio: km,
        dataHoraInicio: _dataHoraInicio,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turno iniciado')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao iniciar turno.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoPlataformas) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Iniciar turno'),
          actions: acoesAppBarComDashboard(const []),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar turno'),
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
                widget.veiculo.rotulo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Km atual: ${Formatacao.km(widget.veiculo.kmAtual)}',
                style: const TextStyle(color: AppColors.blueText),
              ),
              const SizedBox(height: 24),
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
              const Text(
                'Data e hora de início vêm preenchidas com o momento atual. '
                'Ajuste se necessário.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Início *'),
                subtitle: Text(Formatacao.dataHora(_dataHoraInicio.toIso8601String())),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: _salvando ? null : _selecionarInicio,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_salvando,
                decoration: const InputDecoration(
                  labelText: 'Km inicial (hodômetro) *',
                ),
                validator: validarKmPeriodo,
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
                      : const Text('Iniciar trabalho'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
