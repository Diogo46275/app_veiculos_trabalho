import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/alerta_veiculo.dart';
import '../models/veiculo.dart';
import '../services/alertas_service.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';
import '../utils/formatacao.dart';
import '../utils/parse_numero.dart';
import '../validacao/validadores_formulario.dart';
import 'widgets/botao_ir_dashboard.dart';

class FormAlertaScreen extends StatefulWidget {
  const FormAlertaScreen({
    super.key,
    required this.veiculo,
    this.alerta,
  });

  final Veiculo veiculo;
  final AlertaVeiculo? alerta;

  bool get editando => alerta != null;

  @override
  State<FormAlertaScreen> createState() => _FormAlertaScreenState();
}

class _FormAlertaScreenState extends State<FormAlertaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AlertasService _service;
  late final TextEditingController _valorController;
  late final TextEditingController _tituloController;
  late final TextEditingController _antecedenciaController;

  TipoAlerta _tipo = TipoAlerta.km;
  bool _ativo = true;
  bool _salvando = false;
  String? _erroGeral;

  @override
  void initState() {
    super.initState();
    _service = AlertasService(apiClient: ApiClient());
    final item = widget.alerta;
    if (item != null) {
      _tipo = TipoAlerta.fromValor(item.tipo);
      _tituloController = TextEditingController(text: item.titulo);
      _valorController = TextEditingController(
        text: item.valorAlerta.toString(),
      );
      _antecedenciaController = TextEditingController(
        text: item.antecedencia.toString(),
      );
      _ativo = item.ativo;
    } else {
      _tituloController = TextEditingController();
      _valorController = TextEditingController();
      _antecedenciaController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    _antecedenciaController.dispose();
    super.dispose();
  }

  String get _rotuloIntervalo {
    return _tipo == TipoAlerta.km
        ? 'Intervalo (km) *'
        : 'Intervalo (dias) *';
  }

  String get _dicaIntervalo {
    return _tipo == TipoAlerta.km
        ? 'Ex.: 10000 para revisão a cada 10.000 km'
        : 'Ex.: 180 para alerta a cada 180 dias';
  }

  String get _dicaAntecedencia {
    return _tipo == TipoAlerta.km
        ? 'Ex.: 500 para avisar 500 km antes do limite'
        : 'Ex.: 7 para avisar 7 dias antes do prazo';
  }

  String get _rotuloAntecedencia {
    return _tipo == TipoAlerta.km
        ? 'Antecedência (km) *'
        : 'Antecedência (dias) *';
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroGeral = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final valor = ParseNumero.inteiro(_valorController.text);
    if (valor == null) return;

    final antecedencia = ParseNumero.inteiro(_antecedenciaController.text);
    if (antecedencia == null) return;

    setState(() => _salvando = true);

    try {
      if (widget.editando) {
        await _service.atualizar(
          id: widget.alerta!.id,
          titulo: _tituloController.text,
          tipo: _tipo.valor,
          valorAlerta: valor,
          antecedencia: antecedencia,
          ativo: _ativo,
        );
      } else {
        await _service.criar(
          veiculoId: widget.veiculo.id,
          titulo: _tituloController.text,
          tipo: _tipo.valor,
          valorAlerta: valor,
          antecedencia: antecedencia,
          ativo: _ativo,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editando
                ? 'Alerta atualizado. Use Resetar para recomeçar o prazo.'
                : 'Alerta cadastrado',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroGeral = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroGeral = 'Erro inesperado ao salvar alerta.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar alerta' : 'Novo alerta'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.veiculo.rotulo,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Km atual: ${Formatacao.km(widget.veiculo.kmAtual)}',
                style: const TextStyle(color: AppColors.blueText),
              ),
              const SizedBox(height: 24),
              if (_erroGeral != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
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
              TextFormField(
                controller: _tituloController,
                enabled: !_salvando,
                maxLength: 120,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título do alerta *',
                  hintText: 'Ex.: Trocar óleo do motor',
                ),
                validator: validarTituloAlerta,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoAlerta>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo *'),
                items: TipoAlerta.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.rotulo),
                      ),
                    )
                    .toList(),
                onChanged: _salvando
                    ? null
                    : (valor) {
                        if (valor != null) setState(() => _tipo = valor);
                      },
                validator: validarTipoAlerta,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_salvando,
                decoration: InputDecoration(
                  labelText: _rotuloIntervalo,
                  hintText: _dicaIntervalo,
                ),
                validator: (value) => validarValorAlerta(value, tipo: _tipo),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _antecedenciaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                enabled: !_salvando,
                decoration: InputDecoration(
                  labelText: _rotuloAntecedencia,
                  hintText: _dicaAntecedencia,
                  helperText:
                      'Quando o alerta passa a «Próximo» e dispara aviso',
                ),
                validator: (value) => validarAntecedenciaAlerta(
                  value,
                  intervaloTexto: _valorController.text,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Alerta ativo'),
                subtitle: const Text(
                  'Desative para pausar notificações deste alerta',
                ),
                value: _ativo,
                onChanged: _salvando
                    ? null
                    : (valor) => setState(() => _ativo = valor),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.editando ? 'Salvar' : 'Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
