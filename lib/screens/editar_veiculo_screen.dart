import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/categoria_veiculo.dart';
import '../models/veiculo.dart';
import '../providers/dashboard_provider.dart';
import '../providers/veiculos_provider.dart';
import '../theme/app_colors.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class EditarVeiculoScreen extends StatefulWidget {
  const EditarVeiculoScreen({
    super.key,
    required this.veiculo,
    this.obrigatorio = false,
  });

  final Veiculo veiculo;
  final bool obrigatorio;

  @override
  State<EditarVeiculoScreen> createState() => _EditarVeiculoScreenState();
}

class _EditarVeiculoScreenState extends State<EditarVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _marcaController;
  late final TextEditingController _modeloController;
  late final TextEditingController _placaController;
  late final TextEditingController _anoController;
  late final TextEditingController _kmController;

  CategoriaVeiculo? _categoria;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    final v = widget.veiculo;
    _marcaController = TextEditingController(text: v.marca);
    _modeloController = TextEditingController(text: v.modelo);
    _placaController = TextEditingController(text: v.placa ?? '');
    _anoController = TextEditingController(
      text: v.ano != null ? v.ano.toString() : '',
    );
    _kmController = TextEditingController(text: v.kmAtual.toString());
    _categoria = v.categoriaEnum;
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  int? _parseAno() {
    final texto = _anoController.text.trim();
    if (texto.isEmpty) return null;
    return int.tryParse(texto);
  }

  int _parseKm() {
    return int.tryParse(_kmController.text.trim()) ?? 0;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoria == null) {
      setState(() => _erroGeral = 'Selecione a categoria do veículo.');
      return;
    }

    final provider = context.read<VeiculosProvider>();
    final veiculo = await provider.atualizar(
      id: widget.veiculo.id,
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      placa: _placaController.text.trim(),
      categoria: _categoria!.valor,
      ano: _parseAno(),
      kmAtual: _parseKm(),
    );

    if (!mounted) return;

    if (veiculo == null) {
      setState(() => _erroGeral = provider.errorMessage);
      return;
    }

    await context.read<DashboardProvider>().load(refresh: true);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veículo ${veiculo.rotulo} atualizado')),
    );
    Navigator.of(context).pop(veiculo);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<VeiculosProvider>().isSaving;
    final obrigatorio = widget.obrigatorio || widget.veiculo.precisaCompletarCategoria;

    return PopScope(
      canPop: !obrigatorio,
      child: Scaffold(
        appBar: AppBar(
          title: Text(obrigatorio ? 'Completar cadastro' : 'Editar veículo'),
          automaticallyImplyLeading: !obrigatorio,
          actions: obrigatorio
              ? null
              : acoesAppBarComDashboard(const []),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (obrigatorio)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.red),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, color: AppColors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Este veículo precisa de categoria. '
                            'Complete o cadastro para continuar.',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blueBackground.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.work_outline, color: AppColors.blueText),
                      SizedBox(width: 8),
                      Text(
                        'Tipo: Trabalho',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<CategoriaVeiculo>(
                  value: _categoria,
                  decoration: const InputDecoration(labelText: 'Categoria *'),
                  items: CategoriaVeiculo.values
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Row(
                            children: [
                              Icon(item.icone, color: item.cor, size: 20),
                              const SizedBox(width: 8),
                              Text(item.rotulo),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: isSaving
                      ? null
                      : (valor) => setState(() => _categoria = valor),
                  validator: validarCategoriaVeiculo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _marcaController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isSaving,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Marca *'),
                  validator: validarMarca,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modeloController,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isSaving,
                  maxLength: 60,
                  decoration: const InputDecoration(labelText: 'Modelo *'),
                  validator: validarModelo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _placaController,
                  textCapitalization: TextCapitalization.characters,
                  enabled: !isSaving,
                  maxLength: 8,
                  decoration: const InputDecoration(labelText: 'Placa *'),
                  validator: validarPlaca,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _anoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    hintText: 'Opcional',
                  ),
                  validator: validarAnoVeiculo,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _kmController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  enabled: !isSaving,
                  decoration: const InputDecoration(labelText: 'Km atual *'),
                  validator: validarKmVeiculo,
                ),
                if (_erroGeral != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.red),
                    ),
                    child: Text(
                      _erroGeral!,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.background,
                            ),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
