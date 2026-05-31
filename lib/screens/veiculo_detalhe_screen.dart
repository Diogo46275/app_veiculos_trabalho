import 'package:flutter/material.dart';

import '../models/categoria_veiculo.dart';
import '../models/veiculo.dart';
import '../theme/app_colors.dart';
import 'editar_veiculo_screen.dart';

class VeiculoDetalheScreen extends StatelessWidget {
  const VeiculoDetalheScreen({super.key, required this.veiculo});

  final Veiculo veiculo;

  String get _rotuloCategoria {
    if (veiculo.precisaCompletarCategoria) return 'Pendente';
    return veiculo.categoriaEnum!.rotulo;
  }

  void _abrirEdicao(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditarVeiculoScreen(veiculo: veiculo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoria = veiculo.categoriaEnum;
    final icone = VeiculoCategoriaVisual.iconePara(categoria);
    final cor = VeiculoCategoriaVisual.corPara(categoria);

    return Scaffold(
      appBar: AppBar(
        title: Text(veiculo.rotulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => _abrirEdicao(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (veiculo.precisaCompletarCategoria)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, color: AppColors.red),
                        SizedBox(width: 8),
                        Text(
                          'Categoria pendente',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete o cadastro para usar este veículo normalmente.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => _abrirEdicao(context),
                        child: const Text('Completar cadastro'),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Icon(icone, color: cor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    veiculo.rotulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'Marca', value: veiculo.marca),
            _InfoRow(label: 'Modelo', value: veiculo.modelo),
            if (veiculo.placa != null)
              _InfoRow(label: 'Placa', value: veiculo.placa!),
            if (veiculo.ano != null)
              _InfoRow(label: 'Ano', value: veiculo.ano.toString()),
            _InfoRow(
              label: 'Km atual',
              value: '${veiculo.kmAtual.toString()} km',
            ),
            _InfoRow(label: 'Categoria', value: _rotuloCategoria),
            _InfoRow(label: 'Tipo', value: veiculo.tipo),
            const SizedBox(height: 24),
            const Text(
              'Detalhes completos em breve (RF-005).',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
