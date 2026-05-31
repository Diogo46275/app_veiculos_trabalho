import 'package:flutter/material.dart';

import '../../providers/navegacao_provider.dart';
import 'botao_central_alertas.dart';

/// Atalho visível no AppBar para ir à aba Dashboard.
class BotaoIrDashboard extends StatelessWidget {
  const BotaoIrDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.table_chart_outlined),
      tooltip: 'Ir para Dashboard',
      onPressed: () => irParaDashboard(context),
    );
  }
}

/// Monta ações do AppBar: alertas, dashboard e extras.
List<Widget> acoesAppBarComDashboard(List<Widget> extras) {
  return [
    const BotaoCentralAlertas(),
    const BotaoIrDashboard(),
    ...extras,
  ];
}
