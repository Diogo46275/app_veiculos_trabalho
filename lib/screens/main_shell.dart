import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alertas_provider.dart';
import '../providers/navegacao_provider.dart';
import '../theme/app_colors.dart';
import 'cadastro_veiculo_screen.dart';
import 'dashboard_screen.dart';
import 'perfil_tab_screen.dart';
import 'veiculos_tab_screen.dart';
import 'widgets/botao_central_alertas.dart';

/// Largura reservada no centro da barra para o FAB (zona sem toque).
const _fabSlotWidth = 72.0;

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertasProvider>().inicializar();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AlertasProvider>().sincronizar(notificar: true);
    }
  }

  void _onFabPressed() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.directions_car_outlined,
                    color: AppColors.gold,
                  ),
                  title: const Text(
                    'Novo veículo',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CadastroVeiculoScreen(),
                          ),
                        )
                        .then((_) {
                      if (context.mounted) {
                        context.read<NavegacaoProvider>().selecionarAba(1);
                      }
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.local_gas_station_outlined,
                    color: AppColors.gold,
                  ),
                  title: const Text(
                    'Novo abastecimento',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Abra um veículo > aba Abastecimentos para registrar.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final indiceAtual = context.watch<NavegacaoProvider>().indiceAtual;
    final navegacao = context.read<NavegacaoProvider>();
    final totalAlertas = context.watch<AlertasProvider>().totalPendentes;

    return Scaffold(
      body: IndexedStack(
        index: indiceAtual,
        children: [
          DashboardScreen(visivel: indiceAtual == 0),
          VeiculosTabScreen(visivel: indiceAtual == 1),
          const PerfilTabScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        elevation: 8,
        highlightElevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        color: AppColors.card,
        elevation: 8,
        shadowColor: Colors.black54,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metade = (constraints.maxWidth - _fabSlotWidth) / 2;

            return Row(
              children: [
                SizedBox(
                  width: metade,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BottomNavItem(
                          label: 'Dashboard',
                          icon: Icons.table_chart_outlined,
                          selectedIcon: Icons.table_chart,
                          selecionado: indiceAtual == 0,
                          badge: totalAlertas,
                          onTap: () => navegacao.selecionarAba(0),
                        ),
                      ),
                      Expanded(
                        child: _BottomNavItem(
                          label: 'Veículos',
                          icon: Icons.directions_car_outlined,
                          selectedIcon: Icons.directions_car,
                          selecionado: indiceAtual == 1,
                          onTap: () => navegacao.selecionarAba(1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: _fabSlotWidth),
                SizedBox(
                  width: metade,
                  child: _BottomNavItem(
                    label: 'Perfil',
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    selecionado: indiceAtual == 2,
                    onTap: () => navegacao.selecionarAba(2),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selecionado,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selecionado;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? AppColors.gold : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (badge > 0)
                BadgeIconeAlertas(
                  icone: selecionado ? selectedIcon : icon,
                  contagem: badge,
                  tamanhoIcone: 24,
                )
              else
                Icon(selecionado ? selectedIcon : icon, color: cor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: cor,
                  fontSize: 12,
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
