import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/login_provider.dart';
import '../theme/app_colors.dart';
import '../validacao/validadores_formulario.dart';
import 'main_shell.dart';
import 'widgets/login_icones_categoria_orbita.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.pularIntro = false});

  /// Atalho para testes — exibe o formulário sem aguardar a splash.
  final bool pularIntro;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static const _duracaoEntrada = Duration(milliseconds: 1400);
  static const _voltasRapidasEntrada = 2.0;
  static const _pausaPosEntrada = Duration(seconds: 2);
  static const _duracaoFormulario = Duration(milliseconds: 650);
  static const _alturaZonaIcones = LoginIconesCategoriaOrbita.alturaReservada;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _emailFocus = FocusNode();
  final _senhaFocus = FocusNode();

  late final AnimationController _entradaController;
  late final AnimationController _orbitaController;
  late final AnimationController _formularioController;
  late final Animation<double> _progressoRaioAnim;
  late final Animation<double> _progressoEscalaAnim;
  late final Animation<double> _fadeFormulario;
  late final Animation<Offset> _slideFormulario;

  bool _obscureSenha = true;
  String? _erroEmailApi;
  bool _entradaConcluida = false;
  bool _formularioVisivel = false;

  @override
  void initState() {
    super.initState();
    _entradaController = AnimationController(
      vsync: this,
      duration: _duracaoEntrada,
    );
    _progressoRaioAnim = CurvedAnimation(
      parent: _entradaController,
      curve: Curves.easeOutQuart,
    );
    _progressoEscalaAnim = CurvedAnimation(
      parent: _entradaController,
      curve: const Interval(0, 0.85, curve: Curves.easeOutCubic),
    );
    _orbitaController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _formularioController = AnimationController(
      vsync: this,
      duration: _duracaoFormulario,
    );
    _fadeFormulario = CurvedAnimation(
      parent: _formularioController,
      curve: Curves.easeOut,
    );
    _slideFormulario = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formularioController,
        curve: Curves.easeOutCubic,
      ),
    );

    _iniciarIntro();
  }

  Future<void> _iniciarIntro() async {
    if (widget.pularIntro) {
      _entradaController.value = 1;
      _orbitaController.repeat();
      setState(() {
        _entradaConcluida = true;
        _formularioVisivel = true;
      });
      _formularioController.value = 1;
      return;
    }

    await _entradaController.forward();
    if (!mounted) return;

    setState(() => _entradaConcluida = true);
    _orbitaController.repeat();

    await Future<void>.delayed(_pausaPosEntrada);
    if (!mounted) return;

    setState(() => _formularioVisivel = true);
    await _formularioController.forward();
    if (!mounted) return;

    _emailFocus.requestFocus();
  }

  @override
  void dispose() {
    _entradaController.dispose();
    _orbitaController.dispose();
    _formularioController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _emailFocus.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  double get _rotacaoIcones {
    final rotacaoEntrada =
        _voltasRapidasEntrada * 2 * math.pi * _entradaController.value;
    if (!_entradaConcluida) return rotacaoEntrada;

    final rotacaoBase = _voltasRapidasEntrada * 2 * math.pi;
    return rotacaoBase + _orbitaController.value * 2 * math.pi;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final provider = context.read<LoginProvider>();
    provider.clearError();
    setState(() => _erroEmailApi = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await provider.login(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) return;

    if (!success) {
      if (provider.errorCampo == 'email') {
        setState(() => _erroEmailApi = provider.errorMessage);
        _formKey.currentState?.validate();
        _emailFocus.requestFocus();
      }
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final alturaTela = MediaQuery.sizeOf(context).height;
    final alturaSplash = math.max(alturaTela * 0.36, _alturaZonaIcones + 48);

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _entradaController,
            _progressoRaioAnim,
            _progressoEscalaAnim,
            _orbitaController,
            _formularioController,
          ]),
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRect(
                      child: AnimatedContainer(
                        duration: _duracaoFormulario,
                        curve: Curves.easeOutCubic,
                        height: _formularioVisivel
                            ? _alturaZonaIcones
                            : alturaSplash,
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: _alturaZonaIcones,
                          width: LoginIconesCategoriaOrbita.tamanhoArea,
                          child: LoginIconesCategoriaOrbita(
                            escala: _formularioVisivel
                                ? 1
                                : _progressoEscalaAnim.value,
                            fatorRaio: _formularioVisivel
                                ? 1
                                : _progressoRaioAnim.value,
                            rotacao: _rotacaoIcones,
                          ),
                        ),
                      ),
                    ),
                    if (_formularioVisivel) ...[
                      FadeTransition(
                        opacity: _fadeFormulario,
                        child: SlideTransition(
                          position: _slideFormulario,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                'Veículos',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Entre com sua conta',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: 40),
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                enabled: !loginProvider.isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  hintText: 'seu@email.com',
                                ),
                                validator: (value) {
                                  final base = validarEmail(value);
                                  if (base != null) return base;
                                  if (_erroEmailApi != null) {
                                    return _erroEmailApi;
                                  }
                                  return null;
                                },
                                onChanged: (_) {
                                  if (_erroEmailApi == null) return;
                                  setState(() => _erroEmailApi = null);
                                  context.read<LoginProvider>().clearError();
                                },
                                onFieldSubmitted: (_) =>
                                    _senhaFocus.requestFocus(),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _senhaController,
                                focusNode: _senhaFocus,
                                obscureText: _obscureSenha,
                                textInputAction: TextInputAction.done,
                                enabled: !loginProvider.isLoading,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureSenha
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: loginProvider.isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _obscureSenha = !_obscureSenha;
                                            });
                                          },
                                  ),
                                ),
                                validator: validarSenha,
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              if (loginProvider.errorMessage != null &&
                                  loginProvider.errorCampo == null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.red
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.red),
                                  ),
                                  child: Text(
                                    loginProvider.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: loginProvider.isLoading
                                      ? null
                                      : _submit,
                                  child: loginProvider.isLoading
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: AppColors.background,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text('Entrando...'),
                                          ],
                                        )
                                      : const Text('Entrar'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: loginProvider.isLoading
                                    ? null
                                    : () {},
                                child: const Text('Criar conta'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
