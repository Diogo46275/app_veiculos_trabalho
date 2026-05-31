import 'package:flutter/material.dart';

import '../models/periodo_trabalho.dart';
import '../models/veiculo.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import 'form_editar_periodo_screen.dart';
import 'periodo_turno_aberto_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/detalhe_campo.dart';

class DetalhePeriodoScreen extends StatelessWidget {
  const DetalhePeriodoScreen({
    super.key,
    required this.veiculo,
    required this.item,
  });

  final Veiculo veiculo;
  final PeriodoTrabalho item;

  Future<void> _editar(BuildContext context) async {
    if (item.aberto) {
      final salvo = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PeriodoTurnoAbertoScreen(
            veiculo: veiculo,
            periodo: item,
          ),
        ),
      );
      if (salvo == true && context.mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    final salvo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FormEditarPeriodoScreen(
          veiculo: veiculo,
          periodo: item,
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
        title: Text(item.aberto ? 'Turno em andamento' : 'Período de trabalho'),
        actions: [
          ...acoesAppBarComDashboard(const []),
          IconButton(
            icon: Icon(item.aberto ? Icons.schedule : Icons.edit_outlined),
            tooltip: item.aberto ? 'Continuar turno' : 'Editar',
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
              rotulo: 'Status',
              valor: item.aberto ? 'Em andamento' : 'Encerrado',
            ),
            DetalheCampo(
              rotulo: 'Início',
              valor: Formatacao.dataHora(item.dataHoraInicio),
            ),
            DetalheCampo(
              rotulo: 'Km início',
              valor: Formatacao.km(item.kmInicio),
            ),
            if (item.dataHoraFim != null)
              DetalheCampo(
                rotulo: 'Fim',
                valor: Formatacao.dataHora(item.dataHoraFim!),
              ),
            if (item.kmFim != null)
              DetalheCampo(
                rotulo: 'Km fim',
                valor: Formatacao.km(item.kmFim!),
              ),
            if (item.kmRodado != null)
              DetalheCampo(
                rotulo: 'Km rodado',
                valor: Formatacao.km(item.kmRodado!),
              ),
            DetalheCampo(
              rotulo: 'Total ganhos',
              valor: Formatacao.moeda(item.totalGanhos),
            ),
            if (item.horasTrabalhadas != null)
              DetalheCampo(
                rotulo: 'Horas trabalhadas',
                valor: Formatacao.decimal(item.horasTrabalhadas),
              ),
            if (item.ganhoPorHora != null)
              DetalheCampo(
                rotulo: 'Ganho por hora',
                valor: Formatacao.moeda(item.ganhoPorHora!),
              ),
            if (item.plataformaDestaque != null &&
                item.plataformaDestaque!.isNotEmpty)
              DetalheCampo(
                rotulo: 'Plataforma destaque',
                valor: item.plataformaDestaque!,
              ),
            if (item.resumoPlataformas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ganhos por plataforma',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ...item.resumoPlataformas.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.plataforma,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      Text(
                        Formatacao.moeda(p.total),
                        style: TextStyle(
                          color: AppColors.blueText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _editar(context),
                icon: Icon(item.aberto ? Icons.schedule : Icons.edit_outlined),
                label: Text(
                  item.aberto ? 'Continuar turno' : 'Editar período',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
