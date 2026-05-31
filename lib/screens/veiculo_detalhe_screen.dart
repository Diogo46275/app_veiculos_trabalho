import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/abastecimento.dart';
import '../models/alerta_veiculo.dart';
import '../models/manutencao.dart';
import '../models/periodo_trabalho.dart';
import '../models/veiculo.dart';
import '../providers/alertas_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/abastecimentos_service.dart';
import '../services/alertas_service.dart';
import '../services/api_client.dart';
import '../services/manutencoes_service.dart';
import '../services/notificacoes_alerta_service.dart';
import '../services/periodos_trabalho_service.dart';
import '../services/veiculo_modulos_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'detalhe_abastecimento_screen.dart';
import 'detalhe_alerta_screen.dart';
import 'detalhe_manutencao_screen.dart';
import 'detalhe_periodo_screen.dart';
import 'editar_veiculo_screen.dart';
import 'form_abastecimento_screen.dart';
import 'form_alerta_screen.dart';
import 'form_iniciar_periodo_screen.dart';
import 'form_editar_periodo_screen.dart';
import 'form_manutencao_screen.dart';
import 'periodo_turno_aberto_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/estado_lista_tab.dart';
import 'widgets/veiculo_resumo_header.dart';

class VeiculoDetalheScreen extends StatefulWidget {
  const VeiculoDetalheScreen({
    super.key,
    required this.veiculo,
    this.abaInicial = 0,
  });

  final Veiculo veiculo;

  /// 0 Abastecimentos, 1 Manutenções, 2 Alertas, 3 Períodos.
  final int abaInicial;

  @override
  State<VeiculoDetalheScreen> createState() => _VeiculoDetalheScreenState();
}

class _VeiculoDetalheScreenState extends State<VeiculoDetalheScreen>
    with SingleTickerProviderStateMixin {
  late final VeiculoModulosService _service;
  late final AbastecimentosService _abastecimentosService;
  late final ManutencoesService _manutencoesService;
  late final AlertasService _alertasService;
  late final PeriodosTrabalhoService _periodosService;
  late final TabController _tabController;
  late Veiculo _veiculo;

  List<Abastecimento> _abastecimentos = const [];
  List<Manutencao> _manutencoes = const [];
  List<AlertaVeiculo> _alertas = const [];
  List<PeriodoTrabalho> _periodos = const [];
  PeriodoTrabalho? _periodoAberto;

  bool _carregandoAbast = true;
  bool _carregandoManut = true;
  bool _carregandoAlertas = true;
  bool _carregandoPeriodos = true;

  String? _erroAbast;
  String? _erroManut;
  String? _erroAlertas;
  String? _erroPeriodos;

  @override
  void initState() {
    super.initState();
    _veiculo = widget.veiculo;
    _service = VeiculoModulosService();
    _abastecimentosService = AbastecimentosService(apiClient: ApiClient());
    _manutencoesService = ManutencoesService(apiClient: ApiClient());
    _alertasService = AlertasService(apiClient: ApiClient());
    _periodosService = PeriodosTrabalhoService(apiClient: ApiClient());
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.abaInicial.clamp(0, 3),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        // Aba Alertas: status depende do km_atual — recarrega ao entrar na aba.
        if (_tabController.index == 2) {
          _carregarAlertas();
        }
        if (_tabController.index == 3) {
          _carregarPeriodos();
        }
      }
    });
    _carregarTudo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _carregarTudo() async {
    await Future.wait([
      _carregarAbastecimentos(),
      _carregarManutencoes(),
      _carregarAlertas(),
      _carregarPeriodos(),
    ]);
  }

  Future<void> _carregarAbastecimentos() async {
    setState(() {
      _carregandoAbast = true;
      _erroAbast = null;
    });
    try {
      final lista = await _service.listarAbastecimentos(_veiculo.id);
      if (!mounted) return;
      setState(() {
        _abastecimentos = lista;
        _carregandoAbast = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroAbast = error.message;
        _carregandoAbast = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroAbast = 'Erro ao carregar abastecimentos.';
        _carregandoAbast = false;
      });
    }
  }

  Future<void> _carregarManutencoes() async {
    setState(() {
      _carregandoManut = true;
      _erroManut = null;
    });
    try {
      final lista = await _service.listarManutencoes(_veiculo.id);
      if (!mounted) return;
      setState(() {
        _manutencoes = lista;
        _carregandoManut = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroManut = error.message;
        _carregandoManut = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroManut = 'Erro ao carregar manutenções.';
        _carregandoManut = false;
      });
    }
  }

  Future<void> _carregarAlertas() async {
    setState(() {
      _carregandoAlertas = true;
      _erroAlertas = null;
    });
    try {
      final lista = await _service.listarAlertas(_veiculo.id);
      if (!mounted) return;
      setState(() {
        _alertas = lista;
        _carregandoAlertas = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroAlertas = error.message;
        _carregandoAlertas = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroAlertas = 'Erro ao carregar alertas.';
        _carregandoAlertas = false;
      });
    }
  }

  Future<void> _carregarPeriodos() async {
    setState(() {
      _carregandoPeriodos = true;
      _erroPeriodos = null;
    });
    try {
      final lista = await _periodosService.listar(_veiculo.id);
      final aberto = await _periodosService.obterAberto(_veiculo.id);
      if (!mounted) return;
      setState(() {
        _periodos = lista;
        _periodoAberto = aberto;
        _carregandoPeriodos = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroPeriodos = error.message;
        _carregandoPeriodos = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroPeriodos = 'Erro ao carregar períodos.';
        _carregandoPeriodos = false;
      });
    }
  }

  Future<void> _atualizarAposPeriodo() async {
    await _recarregarVeiculo();
    await _carregarPeriodos();
    await _carregarAlertas();
    if (!mounted) return;
    await context.read<DashboardProvider>().load(refresh: true);
    await context.read<AlertasProvider>().sincronizar(notificar: true);
  }

  Future<void> _iniciarPeriodo() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormIniciarPeriodoScreen(veiculo: _veiculo),
      ),
    );
    if (salvo == true && mounted) {
      await _atualizarAposPeriodo();
      if (!mounted || _periodoAberto == null) return;
      await _abrirTurnoAberto(_periodoAberto!);
    }
  }

  Future<void> _abrirTurnoAberto(PeriodoTrabalho periodo) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PeriodoTurnoAbertoScreen(
          veiculo: _veiculo,
          periodo: periodo,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _atualizarAposPeriodo();
    }
  }

  Future<void> _verPeriodo(PeriodoTrabalho item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalhePeriodoScreen(
          veiculo: _veiculo,
          item: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _atualizarAposPeriodo();
    }
  }

  Future<void> _editarPeriodo(PeriodoTrabalho item) async {
    if (item.aberto) {
      await _abrirTurnoAberto(item);
      return;
    }
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormEditarPeriodoScreen(
          veiculo: _veiculo,
          periodo: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _atualizarAposPeriodo();
    }
  }

  Future<void> _excluirPeriodo(PeriodoTrabalho item) async {
    final confirmado = await confirmarExclusaoPeriodo(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _periodosService.excluir(item.id);
      if (!mounted) return;
      await _atualizarAposPeriodo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno excluído')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir turno.')),
      );
    }
  }

  Future<void> _abrirEdicao() async {
    final kmAnterior = _veiculo.kmAtual;
    final atualizado = await Navigator.of(context).push<Veiculo>(
      MaterialPageRoute(
        builder: (_) => EditarVeiculoScreen(veiculo: _veiculo),
      ),
    );
    if (!mounted || atualizado == null) return;
    setState(() => _veiculo = atualizado);
    if (atualizado.kmAtual != kmAnterior) {
      await _carregarAlertas();
      if (mounted) {
        context.read<DashboardProvider>().load(refresh: true);
      }
    }
  }

  /// Abastecimento/manutenção alteram km_atual no backend — alertas precisam recarregar.
  Future<void> _atualizarAposMudancaKm() async {
    await _recarregarVeiculo();
    await _carregarAlertas();
    if (!mounted) return;
    await context.read<DashboardProvider>().load(refresh: true);
    await context.read<AlertasProvider>().sincronizar(notificar: true);
  }

  Future<void> _novoAbastecimento() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAbastecimentoScreen(veiculo: _veiculo),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarAbastecimentos();
      await _atualizarAposMudancaKm();
    }
  }

  Future<void> _verAbastecimento(Abastecimento item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalheAbastecimentoScreen(
          veiculo: _veiculo,
          item: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarAbastecimentos();
      await _atualizarAposMudancaKm();
    }
  }

  Future<void> _editarAbastecimento(Abastecimento item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAbastecimentoScreen(
          veiculo: _veiculo,
          abastecimento: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarAbastecimentos();
      await _atualizarAposMudancaKm();
    }
  }

  Future<void> _excluirAbastecimento(Abastecimento item) async {
    final confirmado = await confirmarExclusaoAbastecimento(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _abastecimentosService.excluir(item.id);
      if (!mounted) return;
      await _carregarAbastecimentos();
      await _atualizarAposMudancaKm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abastecimento excluído')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir abastecimento.')),
      );
    }
  }

  Future<void> _novaManutencao() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormManutencaoScreen(veiculo: _veiculo),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarManutencoes();
      await _atualizarAposMudancaKm();
    }
  }

  Future<void> _verManutencao(Manutencao item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalheManutencaoScreen(
          veiculo: _veiculo,
          item: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarManutencoes();
      await _atualizarAposMudancaKm();
    }
  }

  Future<void> _editarManutencao(Manutencao item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormManutencaoScreen(
          veiculo: _veiculo,
          manutencao: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarManutencoes();
      await _atualizarAposMudancaKm();
    }
  }

  Future<void> _excluirManutencao(Manutencao item) async {
    final confirmado = await confirmarExclusaoManutencao(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _manutencoesService.excluir(item.id);
      if (!mounted) return;
      await _carregarManutencoes();
      await _atualizarAposMudancaKm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manutenção excluída')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir manutenção.')),
      );
    }
  }

  Future<void> _novoAlerta() async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAlertaScreen(veiculo: _veiculo),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarAlertas();
      if (!mounted) return;
      await context.read<DashboardProvider>().load(refresh: true);
      await context.read<AlertasProvider>().sincronizar(notificar: true);
    }
  }

  Future<void> _verAlerta(AlertaVeiculo item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetalheAlertaScreen(
          veiculo: _veiculo,
          item: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarAlertas();
      if (!mounted) return;
      await context.read<DashboardProvider>().load(refresh: true);
      await context.read<AlertasProvider>().sincronizar(notificar: true);
    }
  }

  Future<void> _editarAlerta(AlertaVeiculo item) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAlertaScreen(
          veiculo: _veiculo,
          alerta: item,
        ),
      ),
    );
    if (salvo == true && mounted) {
      await _carregarAlertas();
      if (!mounted) return;
      await context.read<DashboardProvider>().load(refresh: true);
      await context.read<AlertasProvider>().sincronizar(notificar: true);
    }
  }

  Future<void> _resetarAlerta(AlertaVeiculo item) async {
    final confirmado = await confirmarResetAlerta(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _alertasService.resetar(item.id);
      if (!mounted) return;
      await _carregarAlertas();
      if (!mounted) return;
      await context.read<AlertasProvider>().aposResetAlerta(item.id);
      if (!mounted) return;
      await context.read<DashboardProvider>().load(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta resetado')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao resetar alerta.')),
      );
    }
  }

  Future<void> _excluirAlerta(AlertaVeiculo item) async {
    final confirmado = await confirmarExclusaoAlerta(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _alertasService.excluir(item.id);
      if (!mounted) return;
      await _carregarAlertas();
      if (!mounted) return;
      await NotificacoesAlertaService.aoResetarAlerta(item.id);
      await context.read<DashboardProvider>().load(refresh: true);
      await context.read<AlertasProvider>().sincronizar(notificar: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta excluído')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir alerta.')),
      );
    }
  }

  Future<void> _recarregarVeiculo() async {
    try {
      final atualizado = await _service.obterVeiculo(_veiculo.id);
      if (mounted) setState(() => _veiculo = atualizado);
    } catch (_) {
      // Mantém dados locais se falhar refresh do veículo.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_veiculo.rotulo),
        actions: acoesAppBarComDashboard([
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: _abrirEdicao,
          ),
        ]),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary.withValues(alpha: 0.55),
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Abastecimentos'),
            Tab(text: 'Manutenções'),
            Tab(text: 'Alertas'),
            Tab(text: 'Períodos'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VeiculoResumoHeader(
            veiculo: _veiculo,
            onCompletarCadastro:
                _veiculo.precisaCompletarCategoria ? _abrirEdicao : null,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AbaAbastecimentos(
                  carregando: _carregandoAbast,
                  erro: _erroAbast,
                  itens: _abastecimentos,
                  onRecarregar: _carregarAbastecimentos,
                  onNovo: _novoAbastecimento,
                  onVer: _verAbastecimento,
                  onEditar: _editarAbastecimento,
                  onExcluir: _excluirAbastecimento,
                ),
                _AbaManutencoes(
                  carregando: _carregandoManut,
                  erro: _erroManut,
                  itens: _manutencoes,
                  onRecarregar: _carregarManutencoes,
                  onNovo: _novaManutencao,
                  onVer: _verManutencao,
                  onEditar: _editarManutencao,
                  onExcluir: _excluirManutencao,
                ),
                _AbaAlertas(
                  carregando: _carregandoAlertas,
                  erro: _erroAlertas,
                  itens: _alertas,
                  onRecarregar: _carregarAlertas,
                  onNovo: _novoAlerta,
                  onVer: _verAlerta,
                  onEditar: _editarAlerta,
                  onResetar: _resetarAlerta,
                  onExcluir: _excluirAlerta,
                ),
                _AbaPeriodos(
                  carregando: _carregandoPeriodos,
                  erro: _erroPeriodos,
                  periodoAberto: _periodoAberto,
                  itens: _periodos.where((p) => !p.aberto).toList(),
                  onRecarregar: _carregarPeriodos,
                  onIniciar: _iniciarPeriodo,
                  onAbrirTurno: _abrirTurnoAberto,
                  onVer: _verPeriodo,
                  onEditar: _editarPeriodo,
                  onExcluir: _excluirPeriodo,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _novoAbastecimento,
              tooltip: 'Novo abastecimento',
              child: const Icon(Icons.add),
            )
          : _tabController.index == 1
              ? FloatingActionButton(
                  onPressed: _novaManutencao,
                  tooltip: 'Nova manutenção',
                  child: const Icon(Icons.add),
                )
              : _tabController.index == 2
                  ? FloatingActionButton(
                      onPressed: _novoAlerta,
                      tooltip: 'Novo alerta',
                      child: const Icon(Icons.add),
                    )
                  : _tabController.index == 3
                      ? FloatingActionButton(
                          onPressed: _periodoAberto != null
                              ? () => _abrirTurnoAberto(_periodoAberto!)
                              : _iniciarPeriodo,
                          tooltip: _periodoAberto != null
                              ? 'Turno em andamento'
                              : 'Iniciar turno',
                          child: Icon(
                            _periodoAberto != null
                                ? Icons.schedule
                                : Icons.add,
                          ),
                        )
                      : null,
    );
  }
}

class _AbaAbastecimentos extends StatelessWidget {
  const _AbaAbastecimentos({
    required this.carregando,
    required this.erro,
    required this.itens,
    required this.onRecarregar,
    required this.onNovo,
    required this.onVer,
    required this.onEditar,
    required this.onExcluir,
  });

  final bool carregando;
  final String? erro;
  final List<Abastecimento> itens;
  final Future<void> Function() onRecarregar;
  final VoidCallback onNovo;
  final void Function(Abastecimento item) onVer;
  final void Function(Abastecimento item) onEditar;
  final Future<void> Function(Abastecimento item) onExcluir;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => onRecarregar(),
                  child: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_gas_station_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhum abastecimento registrado.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onNovo,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar primeiro'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRecarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          for (final item in itens)
            DetalheItemCard(
              titulo: Formatacao.data(item.data),
              linhas: [
                'Km: ${Formatacao.km(item.km)}',
                'Litros: ${Formatacao.decimal(item.litros)} L',
                'Total: ${Formatacao.moeda(item.valor)}',
                if (item.litros > 0)
                  'Preço/litro: ${Formatacao.moeda(item.valor / item.litros)}',
                if (item.posto != null && item.posto!.isNotEmpty)
                  'Posto: ${item.posto}',
                if (item.consumoKmL != null)
                  'Consumo: ${Formatacao.decimal(item.consumoKmL)} km/L',
                if (item.temAnexoNf)
                  'NF: ${item.quantidadeAnexosNf} anexo(s)',
              ],
              onTap: () => onVer(item),
              onEdit: () => onEditar(item),
              onDelete: () => onExcluir(item),
            ),
        ],
      ),
    );
  }
}

class _AbaManutencoes extends StatelessWidget {
  const _AbaManutencoes({
    required this.carregando,
    required this.erro,
    required this.itens,
    required this.onRecarregar,
    required this.onNovo,
    required this.onVer,
    required this.onEditar,
    required this.onExcluir,
  });

  final bool carregando;
  final String? erro;
  final List<Manutencao> itens;
  final Future<void> Function() onRecarregar;
  final VoidCallback onNovo;
  final void Function(Manutencao item) onVer;
  final void Function(Manutencao item) onEditar;
  final Future<void> Function(Manutencao item) onExcluir;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => onRecarregar(),
                  child: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.build_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhuma manutenção registrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onNovo,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar primeira'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRecarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          for (final item in itens)
            DetalheItemCard(
              titulo: item.tipo,
              linhas: [
                'Data: ${Formatacao.data(item.data)}',
                if (item.km != null) 'Km: ${Formatacao.km(item.km)}',
                'Valor: ${Formatacao.moeda(item.valor)}',
                if (item.descricao != null && item.descricao!.isNotEmpty)
                  item.descricao!,
                'Garantia: ${_rotuloGarantia(item)}',
                if (item.quantidadeAnexosNf > 0 || item.quantidadeAnexosGarantia > 0)
                  'Anexos: ${_rotuloAnexos(item)}',
              ],
              onTap: () => onVer(item),
              onEdit: () => onEditar(item),
              onDelete: () => onExcluir(item),
            ),
        ],
      ),
    );
  }

  String _rotuloGarantia(Manutencao item) {
    if (item.garantiaDias == null || item.garantiaDias == 0) {
      return 'Sem garantia';
    }
    final status = switch (item.garantiaStatus) {
      'em_garantia' => 'Em garantia',
      'fora_garantia' => 'Fora da garantia',
      _ => 'Sem garantia',
    };
    final venc = item.garantiaVencimento != null
        ? ' até ${Formatacao.data(item.garantiaVencimento)}'
        : '';
    return '$status$venc';
  }

  String _rotuloAnexos(Manutencao item) {
    final partes = <String>[];
    if (item.quantidadeAnexosNf > 0) {
      partes.add('NF (${item.quantidadeAnexosNf})');
    }
    if (item.quantidadeAnexosGarantia > 0) {
      partes.add('Garantia (${item.quantidadeAnexosGarantia})');
    }
    return partes.join(', ');
  }
}

class _AbaAlertas extends StatelessWidget {
  const _AbaAlertas({
    required this.carregando,
    required this.erro,
    required this.itens,
    required this.onRecarregar,
    required this.onNovo,
    required this.onVer,
    required this.onEditar,
    required this.onResetar,
    required this.onExcluir,
  });

  final bool carregando;
  final String? erro;
  final List<AlertaVeiculo> itens;
  final Future<void> Function() onRecarregar;
  final VoidCallback onNovo;
  final void Function(AlertaVeiculo item) onVer;
  final void Function(AlertaVeiculo item) onEditar;
  final Future<void> Function(AlertaVeiculo item) onResetar;
  final Future<void> Function(AlertaVeiculo item) onExcluir;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => onRecarregar(),
                  child: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhum alerta configurado.\nEx.: "Trocar óleo" a cada 10.000 km.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onNovo,
                  icon: const Icon(Icons.add),
                  label: const Text('Criar primeiro alerta'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRecarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          for (final item in itens)
            DetalheItemCard(
              titulo: item.titulo,
              corTitulo: _corStatus(item.status),
              destaque: _rotuloStatus(item.status),
              linhas: [
                item.tipo == 'km'
                    ? 'Tipo: por km'
                    : 'Tipo: por data',
                _rotuloIntervalo(item),
                _rotuloAntecedencia(item),
                _rotuloLimite(item),
                _rotuloRestante(item),
                if (!item.ativo) 'Inativo',
              ],
              onTap: () => onVer(item),
              onEdit: () => onEditar(item),
              onReset: item.ativo ? () => onResetar(item) : null,
              onDelete: () => onExcluir(item),
            ),
        ],
      ),
    );
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'vencido':
        return AppColors.red;
      case 'proximo':
        return AppColors.gold;
      case 'inativo':
        return AppColors.textSecondary;
      default:
        return AppColors.green;
    }
  }

  String _rotuloStatus(String status) {
    switch (status) {
      case 'vencido':
        return 'Vencido';
      case 'proximo':
        return 'Próximo';
      case 'inativo':
        return 'Inativo';
      default:
        return 'OK';
    }
  }

  String _rotuloIntervalo(AlertaVeiculo item) {
    if (item.tipo == 'km') {
      return 'Intervalo: a cada ${Formatacao.km(item.valorAlerta)}';
    }
    return 'Intervalo: a cada ${item.valorAlerta} dia(s)';
  }

  String _rotuloAntecedencia(AlertaVeiculo item) {
    if (item.tipo == 'km') {
      return 'Antecedência: ${Formatacao.km(item.antecedencia)} antes';
    }
    return 'Antecedência: ${item.antecedencia} dia(s) antes';
  }

  String _rotuloLimite(AlertaVeiculo item) {
    if (item.tipo == 'km' && item.kmLimite != null) {
      return 'Próximo limite: ${Formatacao.km(item.kmLimite)}';
    }
    if (item.tipo == 'data' && item.dataLimite != null) {
      return 'Próximo limite: ${Formatacao.data(item.dataLimite)}';
    }
    return 'Próximo limite: —';
  }

  String _rotuloRestante(AlertaVeiculo item) {
    if (!item.ativo) return 'Restante: —';
    if (item.tipo == 'km' && item.kmRestante != null) {
      if (item.kmRestante! < 0) {
        return 'Restante: ${Formatacao.km(-item.kmRestante!)} além';
      }
      return 'Restante: ${Formatacao.km(item.kmRestante)}';
    }
    if (item.tipo == 'data' && item.diasRestantes != null) {
      if (item.diasRestantes! < 0) {
        return 'Restante: ${-item.diasRestantes!} dia(s) além';
      }
      return 'Restante: ${item.diasRestantes} dia(s)';
    }
    return 'Restante: —';
  }
}

class _AbaPeriodos extends StatelessWidget {
  const _AbaPeriodos({
    required this.carregando,
    required this.erro,
    required this.periodoAberto,
    required this.itens,
    required this.onRecarregar,
    required this.onIniciar,
    required this.onAbrirTurno,
    required this.onVer,
    required this.onEditar,
    required this.onExcluir,
  });

  final bool carregando;
  final String? erro;
  final PeriodoTrabalho? periodoAberto;
  final List<PeriodoTrabalho> itens;
  final Future<void> Function() onRecarregar;
  final VoidCallback onIniciar;
  final void Function(PeriodoTrabalho item) onAbrirTurno;
  final void Function(PeriodoTrabalho item) onVer;
  final void Function(PeriodoTrabalho item) onEditar;
  final Future<void> Function(PeriodoTrabalho item) onExcluir;

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.red, size: 40),
              const SizedBox(height: 12),
              Text(
                erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: () => onRecarregar(),
                  child: const Text('Tentar novamente'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (periodoAberto == null && itens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhum período registrado.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onIniciar,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar turno'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRecarregar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          if (periodoAberto != null) ...[
            DetalheItemCard(
              titulo: Formatacao.dataHora(periodoAberto!.dataHoraInicio),
              destaque: 'Em andamento',
              corDestaque: AppColors.green,
              linhas: [
                'Km início: ${Formatacao.km(periodoAberto!.kmInicio)}',
                'Ganhos: ${Formatacao.moeda(periodoAberto!.totalGanhos)}',
                if (periodoAberto!.plataformaDestaque != null)
                  'Destaque: ${periodoAberto!.plataformaDestaque}',
              ],
              onTap: () => onVer(periodoAberto!),
              onEdit: () => onAbrirTurno(periodoAberto!),
            ),
            const SizedBox(height: 8),
            const Text(
              'Histórico',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (itens.isEmpty && periodoAberto != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Nenhum turno finalizado ainda.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          for (final item in itens)
            DetalheItemCard(
              titulo: Formatacao.dataHora(item.dataHoraInicio),
              destaque: 'Encerrado',
              linhas: [
                if (item.dataHoraFim != null)
                  'Fim: ${Formatacao.dataHora(item.dataHoraFim)}',
                'Km: ${Formatacao.km(item.kmInicio)} → ${Formatacao.km(item.kmFim)}',
                if (item.kmRodado != null)
                  'Km rodado: ${Formatacao.km(item.kmRodado)}',
                'Ganhos: ${Formatacao.moeda(item.totalGanhos)}',
                if (item.horasTrabalhadas != null)
                  'Horas: ${Formatacao.decimal(item.horasTrabalhadas)} h',
                if (item.ganhoPorHora != null)
                  'Ganho/hora: ${Formatacao.moeda(item.ganhoPorHora)}',
                if (item.plataformaDestaque != null)
                  'Destaque: ${item.plataformaDestaque}',
              ],
              onTap: () => onVer(item),
              onEdit: () => onEditar(item),
              onDelete: () => onExcluir(item),
            ),
        ],
      ),
    );
  }
}
