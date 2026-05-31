import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/categoria_veiculo.dart';
import '../providers/dashboard_provider.dart';
import '../providers/veiculos_provider.dart';
import '../theme/app_colors.dart';
import '../validacao/mensagens_validacao.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class CadastroVeiculoScreen extends StatefulWidget {
  const CadastroVeiculoScreen({super.key});

  @override
  State<CadastroVeiculoScreen> createState() => _CadastroVeiculoScreenState();
}

class _CadastroVeiculoScreenState extends State<CadastroVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  final _kmController = TextEditingController(text: '0');

  final _marcaFocus = FocusNode();
  final _modeloFocus = FocusNode();
  final _placaFocus = FocusNode();
  final _anoFocus = FocusNode();
  final _kmFocus = FocusNode();

  String? _erroGeral;
  CategoriaVeiculo? _categoria = CategoriaVeiculo.carro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _marcaFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    _kmController.dispose();
    _marcaFocus.dispose();
    _modeloFocus.dispose();
    _placaFocus.dispose();
    _anoFocus.dispose();
    _kmFocus.dispose();
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
      setState(
        () => _erroGeral = MensagensValidacao.categoriaObrigatoria,
      );
      return;
    }

    final provider = context.read<VeiculosProvider>();
    final veiculo = await provider.cadastrar(
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
      SnackBar(content: Text('Veículo ${veiculo.rotulo} cadastrado')),
    );
    Navigator.of(context).pop(veiculo);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<VeiculosProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo veículo'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                focusNode: _marcaFocus,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                enabled: !isSaving,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Marca *'),
                validator: validarMarca,
                onFieldSubmitted: (_) => _modeloFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modeloController,
                focusNode: _modeloFocus,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                enabled: !isSaving,
                maxLength: 60,
                decoration: const InputDecoration(labelText: 'Modelo *'),
                validator: validarModelo,
                onFieldSubmitted: (_) => _placaFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaController,
                focusNode: _placaFocus,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                enabled: !isSaving,
                maxLength: 8,
                decoration: const InputDecoration(labelText: 'Placa *'),
                validator: validarPlaca,
                onFieldSubmitted: (_) => _anoFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _anoController,
                focusNode: _anoFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  hintText: 'Opcional',
                ),
                validator: validarAnoVeiculo,
                onFieldSubmitted: (_) => _kmFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmController,
                focusNode: _kmFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !isSaving,
                decoration: const InputDecoration(labelText: 'Km atual *'),
                validator: validarKmVeiculo,
                onFieldSubmitted: (_) => _submit(),
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
    );
  }
}
