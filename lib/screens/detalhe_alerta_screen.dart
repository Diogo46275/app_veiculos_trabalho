import 'package:flutter/material.dart';

import '../models/alerta_veiculo.dart';
import '../models/veiculo.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_alerta_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/detalhe_campo.dart';

class DetalheAlertaScreen extends StatelessWidget {
  const DetalheAlertaScreen({
    super.key,
    required this.veiculo,
    required this.item,
  });

  final Veiculo veiculo;
  final AlertaVeiculo item;

  Color _corStatus() {
    return switch (item.status) {
      'vencido' => AppColors.red,
      'proximo' => AppColors.gold,
      _ => AppColors.green,
    };
  }

  String _rotuloStatus() {
    return switch (item.status) {
      'vencido' => 'Vencido',
      'proximo' => 'Próximo',
      _ => 'Ok',
    };
  }

  String _rotuloTipo() =>
      item.tipo == 'km' ? 'Alerta por km' : 'Alerta por data';

  String _rotuloAntecedencia() {
    if (item.tipo == 'km') {
      return '${Formatacao.km(item.antecedencia)} antes do limite';
    }
    return '${item.antecedencia} dia(s) antes do limite';
  }

  String _rotuloLimite() {
    if (item.tipo == 'km' && item.kmLimite != null) {
      return Formatacao.km(item.kmLimite);
    }
    if (item.tipo == 'data' && item.dataLimite != null) {
      return Formatacao.data(item.dataLimite);
    }
    return '—';
  }

  String _rotuloRestante() {
    if (!item.ativo) return '—';
    if (item.tipo == 'km' && item.kmRestante != null) {
      if (item.kmRestante! < 0) {
        return '${Formatacao.km(-item.kmRestante!)} além do limite';
      }
      return Formatacao.km(item.kmRestante);
    }
    if (item.tipo == 'data' && item.diasRestantes != null) {
      if (item.diasRestantes! < 0) {
        return '${-item.diasRestantes!} dia(s) além do limite';
      }
      return '${item.diasRestantes} dia(s)';
    }
    return '—';
  }

  Future<void> _editar(BuildContext context) async {
    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormAlertaScreen(
          veiculo: veiculo,
          alerta: item,
        ),
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
        title: const Text('Alerta'),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.titulo,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _corStatus().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _rotuloStatus(),
                    style: TextStyle(
                      color: _corStatus(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DetalheCampo(rotulo: 'Tipo', valor: _rotuloTipo()),
            DetalheCampo(
              rotulo: 'Valor do alerta',
              valor: item.tipo == 'km'
                  ? Formatacao.km(item.valorAlerta)
                  : '${item.valorAlerta} dia(s)',
            ),
            DetalheCampo(
              rotulo: 'Antecedência',
              valor: _rotuloAntecedencia(),
            ),
            DetalheCampo(rotulo: 'Próximo limite', valor: _rotuloLimite()),
            DetalheCampo(rotulo: 'Restante', valor: _rotuloRestante()),
            DetalheCampo(
              rotulo: 'Ativo',
              valor: item.ativo ? 'Sim' : 'Não',
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _editar(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar alerta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
