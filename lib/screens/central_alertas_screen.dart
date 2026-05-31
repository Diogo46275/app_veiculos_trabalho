import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alerta_dashboard.dart';
import '../providers/alertas_provider.dart';
import '../services/api_client.dart';
import '../services/veiculos_service.dart';
import '../theme/app_colors.dart';
import 'veiculo_detalhe_screen.dart';
import 'widgets/botao_ir_dashboard.dart';

class CentralAlertasScreen extends StatefulWidget {
  const CentralAlertasScreen({super.key});

  @override
  State<CentralAlertasScreen> createState() => _CentralAlertasScreenState();
}

class _CentralAlertasScreenState extends State<CentralAlertasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertasProvider>().sincronizar();
    });
  }

  Future<void> _abrirVeiculo(AlertaDashboardItem item) async {
    final apiClient = ApiClient();
    final service = VeiculosService(apiClient: apiClient);
    try {
      final veiculo = await service.obter(item.veiculoId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VeiculoDetalheScreen(
            veiculo: veiculo,
            abaInicial: 2,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao abrir veículo.')),
      );
    } finally {
      apiClient.dispose();
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'vencido':
        return AppColors.red;
      case 'proximo':
        return AppColors.gold;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de manutenção'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () => provider.sincronizar(),
        child: _buildConteudo(provider),
      ),
    );
  }

  Widget _buildConteudo(AlertasProvider provider) {
    if (provider.carregando && provider.resposta == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(color: AppColors.blueText),
          ),
        ],
      );
    }

    if (provider.erro != null && provider.resposta == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            provider.erro!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => provider.sincronizar(),
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    final itens = provider.itens;
    if (itens.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 48),
          Icon(Icons.notifications_none, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Nenhum alerta vencido ou próximo no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Configure alertas na aba Alertas de cada veículo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _ResumoAlertas(
          vencidos: provider.totalVencidos,
          proximos: provider.totalProximos,
        ),
        const SizedBox(height: 16),
        for (final item in itens) ...[
          _CardAlertaCentral(
            item: item,
            corStatus: _corStatus(item.status),
            onTap: () => _abrirVeiculo(item),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ResumoAlertas extends StatelessWidget {
  const _ResumoAlertas({
    required this.vencidos,
    required this.proximos,
  });

  final int vencidos;
  final int proximos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blueBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '${vencidos + proximos} alerta(s): '
        '${vencidos > 0 ? '$vencidos vencido(s)' : ''}'
        '${vencidos > 0 && proximos > 0 ? ' · ' : ''}'
        '${proximos > 0 ? '$proximos próximo(s)' : ''}',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CardAlertaCentral extends StatelessWidget {
  const _CardAlertaCentral({
    required this.item,
    required this.corStatus,
    required this.onTap,
  });

  final AlertaDashboardItem item;
  final Color corStatus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.titulo,
                      style: TextStyle(
                        color: corStatus,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: corStatus.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: corStatus),
                    ),
                    child: Text(
                      item.rotuloStatus,
                      style: TextStyle(
                        color: corStatus,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.veiculoRotulo,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                item.rotuloRestante,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
