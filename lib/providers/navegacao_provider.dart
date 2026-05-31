import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Índice da Bottom Bar: 0 Dashboard, 1 Veículos, 2 Perfil.
class NavegacaoProvider extends ChangeNotifier {
  int indiceAtual = 0;

  void selecionarAba(int indice) {
    if (indiceAtual == indice) return;
    indiceAtual = indice;
    notifyListeners();
  }

  void irParaDashboard() => selecionarAba(0);
}

/// Volta ao shell principal na aba Dashboard.
void irParaDashboard(BuildContext context) {
  context.read<NavegacaoProvider>().irParaDashboard();
  final navigator = Navigator.of(context);
  if (navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}
