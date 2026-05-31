import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/veiculo.dart';
import '../providers/alertas_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/veiculos_provider.dart';
import '../theme/app_colors.dart';
import 'central_alertas_screen.dart';
import 'editar_veiculo_screen.dart';
import 'veiculo_detalhe_screen.dart';
import 'widgets/botao_central_alertas.dart';
import 'widgets/dashboard_indicator_card.dart';
import 'widgets/veiculo_swipe_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.visivel = true});

  final bool visivel;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _executarDescobertaSwipe = false;

  @override
  void initState() {
    super.initState();
    if (widget.visivel) {
      _executarDescobertaSwipe = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
      context.read<AlertasProvider>().sincronizar(notificar: true);
    });
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visivel && !oldWidget.visivel) {
      _ativarDescobertaSwipe();
    }
  }

  void _ativarDescobertaSwipe() {
    if (!mounted) return;
    setState(() => _executarDescobertaSwipe = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _executarDescobertaSwipe = true);
    });
  }

  void _editarVeiculo(Veiculo veiculo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditarVeiculoScreen(
          veiculo: veiculo,
          obrigatorio: veiculo.precisaCompletarCategoria,
        ),
      ),
    );
  }

  Future<bool> _excluirVeiculo(Veiculo veiculo) async {
    final confirmado = await confirmarExclusaoVeiculo(context, veiculo);
    if (!confirmado || !mounted) return false;

    final veiculosProvider = context.read<VeiculosProvider>();
    final ok = await veiculosProvider.excluir(veiculo.id);

    if (!mounted) return false;

    if (ok) {
      await context.read<DashboardProvider>().load(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veículo ${veiculo.rotulo} excluído')),
        );
      }
      return true;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            veiculosProvider.errorMessage ?? 'Erro ao excluir veículo.',
          ),
        ),
      );
    }
    return false;
  }

  void _abrirVeiculo(Veiculo veiculo) {
    if (veiculo.precisaCompletarCategoria) {
      _editarVeiculo(veiculo);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VeiculoDetalheScreen(veiculo: veiculo),
      ),
    );
  }

  String _formatKm(int km) {
    return '${km.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )} km';
  }

  String _formatMoeda(double valor) {
    final texto = valor.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $texto';
  }

  void _abrirCentralAlertas() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CentralAlertasScreen()),
    );
  }

  String _rotuloAlertas(AlertasProvider alertas) {
    if (alertas.totalPendentes == 0) return '0';
    final partes = <String>[];
    if (alertas.totalVencidos > 0) {
      partes.add('${alertas.totalVencidos} venc.');
    }
    if (alertas.totalProximos > 0) {
      partes.add('${alertas.totalProximos} próx.');
    }
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final alertas = context.watch<AlertasProvider>();

    if (provider.isLoading && provider.dashboard == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.blueText),
        ),
      );
    }

    if (provider.errorMessage != null && provider.dashboard == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.load(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dashboard = provider.dashboard;
    final perfil = provider.perfil;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () async {
          await Future.wait([
            provider.load(refresh: true),
            context.read<AlertasProvider>().sincronizar(notificar: true),
          ]);
        },
        child: SlidableAutoCloseBehavior(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 24),
                color: AppColors.blueBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, ${perfil?.nome ?? '...'}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Visão geral dos seus veículos de trabalho',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const BotaoCentralAlertas(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (provider.errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.red),
                      ),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                  DashboardIndicatorCard(
                    titulo: 'Km total',
                    valor: dashboard != null
                        ? _formatKm(dashboard.kmTotal)
                        : '—',
                    corValor: AppColors.blueText,
                  ),
                  const SizedBox(height: 12),
                  DashboardIndicatorCard(
                    titulo: 'Economia (R\$)',
                    valor: dashboard != null
                        ? _formatMoeda(dashboard.economia)
                        : '—',
                    corValor: AppColors.green,
                  ),
                  const SizedBox(height: 12),
                  DashboardIndicatorCard(
                    titulo: 'Alertas ativos',
                    valor: _rotuloAlertas(alertas),
                    corValor: alertas.totalVencidos > 0
                        ? AppColors.red
                        : (alertas.totalProximos > 0
                            ? AppColors.gold
                            : AppColors.green),
                    onTap: _abrirCentralAlertas,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Meus veículos',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (provider.veiculos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Nenhum dado ainda — cadastre um veículo para começar',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...provider.veiculos.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final veiculo = entry.value;
                        final total = provider.veiculos.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VeiculoSwipeTile(
                            veiculo: veiculo,
                            onTap: () => _abrirVeiculo(veiculo),
                            onEdit: () => _editarVeiculo(veiculo),
                            onConfirmDelete: () => _excluirVeiculo(veiculo),
                            executarDescoberta: _executarDescobertaSwipe,
                            mostrarAmbasDirecoes: index == 0,
                            atrasoDescoberta:
                                Duration(milliseconds: index * 80),
                            onDescobertaConcluida: index == total - 1
                                ? () {
                                    if (mounted) {
                                      setState(
                                        () => _executarDescobertaSwipe = false,
                                      );
                                    }
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  if (provider.isRefreshing) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blueText,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
