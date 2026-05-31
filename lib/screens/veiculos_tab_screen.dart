import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/veiculo.dart';
import '../providers/dashboard_provider.dart';
import '../providers/veiculos_provider.dart';
import '../theme/app_colors.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'cadastro_veiculo_screen.dart';
import 'editar_veiculo_screen.dart';
import 'veiculo_detalhe_screen.dart';
import 'widgets/veiculo_swipe_tile.dart';

class VeiculosTabScreen extends StatefulWidget {
  const VeiculosTabScreen({super.key, this.visivel = true});

  final bool visivel;

  @override
  State<VeiculosTabScreen> createState() => _VeiculosTabScreenState();
}

class _VeiculosTabScreenState extends State<VeiculosTabScreen> {
  bool _executarDescobertaSwipe = false;

  @override
  void initState() {
    super.initState();
    if (widget.visivel) {
      _executarDescobertaSwipe = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VeiculosProvider>().load();
    });
  }

  @override
  void didUpdateWidget(covariant VeiculosTabScreen oldWidget) {
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

  void _cadastrarVeiculo() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CadastroVeiculoScreen(),
      ),
    );
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

    final provider = context.read<VeiculosProvider>();
    final ok = await provider.excluir(veiculo.id);

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ?? 'Erro ao excluir veículo.',
        ),
      ),
    );
    return false;
  }

  void _abrirVeiculo(Veiculo veiculo) {
    if (veiculo.precisaCompletarCategoria) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EditarVeiculoScreen(
            veiculo: veiculo,
            obrigatorio: true,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VeiculoDetalheScreen(veiculo: veiculo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VeiculosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(VeiculosProvider provider) {
    if (provider.isLoading && !provider.carregado) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blueText),
      );
    }

    if (provider.errorMessage != null && !provider.carregado) {
      return Center(
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
                onPressed: () => provider.load(forcar: true),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () => provider.load(refresh: true),
      child: SlidableAutoCloseBehavior(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Veículos de trabalho (${provider.veiculos.length})',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (provider.veiculos.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Deslize → editar/excluir · ← gestão',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (provider.errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
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
              ),
            ),
          if (provider.veiculos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Nenhum veículo cadastrado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _cadastrarVeiculo,
                          icon: const Icon(Icons.add),
                          label: const Text('Cadastrar primeiro veículo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              sliver: SliverList.separated(
                itemCount: provider.veiculos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final veiculo = provider.veiculos[index];
                  final total = provider.veiculos.length;
                  return VeiculoSwipeTile(
                    veiculo: veiculo,
                    onTap: () => _abrirVeiculo(veiculo),
                    onEdit: () => _editarVeiculo(veiculo),
                    onConfirmDelete: () => _excluirVeiculo(veiculo),
                    executarDescoberta:
                        _executarDescobertaSwipe && provider.carregado,
                    mostrarAmbasDirecoes: index == 0,
                    atrasoDescoberta: Duration(milliseconds: index * 80),
                    onDescobertaConcluida: index == total - 1
                        ? () {
                            if (mounted) {
                              setState(() => _executarDescobertaSwipe = false);
                            }
                          }
                        : null,
                  );
                },
              ),
            ),
          if (provider.isRefreshing)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.blueText,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }
}
