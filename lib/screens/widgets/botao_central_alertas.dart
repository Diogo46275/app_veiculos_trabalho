import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/alertas_provider.dart';
import '../../theme/app_colors.dart';
import '../central_alertas_screen.dart';

/// Ícone de sino com badge — abre a central de alertas.
class BotaoCentralAlertas extends StatelessWidget {
  const BotaoCentralAlertas({super.key});

  void _abrirCentral(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CentralAlertasScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = context.watch<AlertasProvider>().totalPendentes;

    return IconButton(
      tooltip: 'Alertas de manutenção',
      onPressed: () => _abrirCentral(context),
      icon: BadgeIconeAlertas(
        icone: Icons.notifications_outlined,
        contagem: total,
      ),
    );
  }
}

class BadgeIconeAlertas extends StatelessWidget {
  const BadgeIconeAlertas({
    super.key,
    required this.icone,
    required this.contagem,
    this.tamanhoIcone = 24,
  });

  final IconData icone;
  final int contagem;
  final double tamanhoIcone;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icone, size: tamanhoIcone),
        if (contagem > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.card, width: 1.5),
              ),
              child: Text(
                contagem > 99 ? '99+' : '$contagem',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
