import 'package:flutter/material.dart';

import '../models/despesa.dart';
import '../models/veiculo.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_despesa_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/detalhe_campo.dart';

class DetalheDespesaScreen extends StatelessWidget {
  const DetalheDespesaScreen({
    super.key,
    required this.veiculo,
    required this.item,
  });

  final Veiculo veiculo;
  final Despesa item;

  Future<void> _editar(BuildContext context) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormDespesaScreen(veiculo: veiculo, despesa: item),
      ),
    );
    if (salvo == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesa'),
        actions: [
          ...acoesAppBarComDashboard(const []),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => _editar(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              veiculo.rotulo,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            DetalheCampo(
              rotulo: 'Categoria',
              valor: item.rotuloCategoria,
            ),
            DetalheCampo(
              rotulo: 'Data',
              valor: Formatacao.data(item.data),
            ),
            DetalheCampo(
              rotulo: 'Valor',
              valor: Formatacao.moeda(item.valor),
            ),
            if (item.km != null)
              DetalheCampo(
                rotulo: 'Km',
                valor: Formatacao.km(item.km!),
              ),
            if (item.descricao != null && item.descricao!.isNotEmpty)
              DetalheCampo(
                rotulo: 'Descrição',
                valor: item.descricao!,
              ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _editar(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar despesa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
