import 'package:flutter/material.dart';

import '../models/periodo_trabalho.dart';
import '../models/receita.dart';
import '../models/veiculo.dart';
import '../services/api_client.dart';
import '../services/periodos_trabalho_service.dart';
import '../services/receitas_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_finalizar_periodo_screen.dart';
import 'form_receita_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/estado_lista_tab.dart';

class PeriodoTurnoAbertoScreen extends StatefulWidget {
  const PeriodoTurnoAbertoScreen({
    super.key,
    required this.veiculo,
    required this.periodo,
  });

  final Veiculo veiculo;
  final PeriodoTrabalho periodo;

  @override
  State<PeriodoTurnoAbertoScreen> createState() =>
      _PeriodoTurnoAbertoScreenState();
}

class _PeriodoTurnoAbertoScreenState extends State<PeriodoTurnoAbertoScreen> {
  late final PeriodosTrabalhoService _periodosService;
  late final ReceitasService _receitasService;

  late PeriodoTrabalho _periodo;
  List<Receita> _ganhos = const [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final client = ApiClient();
    _periodosService = PeriodosTrabalhoService(apiClient: client);
    _receitasService = ReceitasService(apiClient: client);
    _periodo = widget.periodo;
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final aberto = await _periodosService.obterAberto(widget.veiculo.id);
      final ganhos = await _receitasService.listarPorPeriodo(_periodo.id);
      if (!mounted) return;
      if (aberto == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {
        _periodo = aberto;
        _ganhos = ganhos;
        _carregando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = error.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar turno.';
        _carregando = false;
      });
    }
  }

  Future<void> _novoGanho() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormReceitaScreen(
          veiculo: widget.veiculo,
          periodo: _periodo,
        ),
      ),
    );
    if (salvo == true && mounted) await _carregar();
  }

  Future<void> _editarGanho(Receita item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormReceitaScreen(
          veiculo: widget.veiculo,
          periodo: _periodo,
          receita: item,
        ),
      ),
    );
    if (salvo == true && mounted) await _carregar();
  }

  Future<void> _excluirGanho(Receita item) async {
    final confirmado = await confirmarExclusaoReceita(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _receitasService.excluir(item.id);
      if (!mounted) return;
      await _carregar();
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

  Future<void> _finalizar() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormFinalizarPeriodoScreen(
          veiculo: widget.veiculo,
          periodo: _periodo,
        ),
      ),
    );
    if (salvo == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turno em andamento'),
        actions: acoesAppBarComDashboard(const []),
      ),
      floatingActionButton: _carregando || _erro != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _novoGanho,
              icon: const Icon(Icons.add),
              label: const Text('Ganho'),
            ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: EstadoListaTab(
          carregando: _carregando,
          erro: _erro,
          vazio: false,
          mensagemVazio: '',
          onRecarregar: _carregar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Em andamento',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Início: ${Formatacao.dataHora(_periodo.dataHoraInicio)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Km inicial: ${Formatacao.km(_periodo.kmInicio)}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Total ganhos: ${Formatacao.moeda(_periodo.totalGanhos)}',
                      style: const TextStyle(
                        color: AppColors.blueText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_periodo.horasTrabalhadas != null) ...[
                      Text(
                        'Horas: ${Formatacao.decimal(_periodo.horasTrabalhadas)} h',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      if (_periodo.ganhoPorHora != null)
                        Text(
                          'Ganho/hora: ${Formatacao.moeda(_periodo.ganhoPorHora)}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                    if (_periodo.plataformaDestaque != null)
                      Text(
                        'Destaque: ${_periodo.plataformaDestaque}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    if (_periodo.resumoPlataformas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (final item in _periodo.resumoPlataformas)
                        Text(
                          '${item.plataforma}: ${Formatacao.moeda(item.total)} '
                          '(${item.quantidade} lanç.)',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _finalizar,
                        child: const Text('Finalizar turno'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ganhos registrados',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              if (_ganhos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Nenhum ganho ainda. Toque em + Ganho para registrar.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                for (final item in _ganhos)
                  DetalheItemCard(
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
            ],
          ),
        ),
      ),
    );
  }
}
