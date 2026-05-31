import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/perfil.dart';
import '../models/plataforma.dart';
import '../models/tipo_manutencao.dart';
import '../navigation/app_navigator.dart';
import '../providers/dashboard_provider.dart';
import '../services/api_client.dart';
import '../services/perfil_service.dart';
import '../services/plataformas_service.dart';
import '../services/tipos_manutencao_service.dart';
import '../services/token_storage.dart';
import '../theme/app_colors.dart';
import '../utils/seletor_arquivo.dart';
import '../validacao/validadores_formulario.dart';
import 'login_screen.dart';
import 'widgets/botao_ir_dashboard.dart';
import 'widgets/perfil_secao_lista_nome.dart';

class PerfilTabScreen extends StatefulWidget {
  const PerfilTabScreen({super.key});

  @override
  State<PerfilTabScreen> createState() => _PerfilTabScreenState();
}

class _PerfilTabScreenState extends State<PerfilTabScreen> {
  final _dadosFormKey = GlobalKey<FormState>();
  final _senhaFormKey = GlobalKey<FormState>();

  late final PerfilService _perfilService;
  late final PlataformasService _plataformasService;
  late final TiposManutencaoService _tiposService;

  late final TextEditingController _nomeController;
  late final TextEditingController _cpfController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _senhaAtualController;
  late final TextEditingController _senhaNovaController;
  late final TextEditingController _senhaConfirmarController;
  late final TextEditingController _plataformaController;
  late final TextEditingController _tipoManutencaoController;

  Perfil? _perfil;
  List<Plataforma> _plataformas = const [];
  List<TipoManutencao> _tipos = const [];

  bool _carregando = true;
  bool _salvandoDados = false;
  bool _salvandoSenha = false;
  bool _salvandoPlataforma = false;
  bool _salvandoTipo = false;
  bool _enviandoFoto = false;
  String? _erroGeral;
  String? _erroDados;
  String? _erroSenha;
  String? _erroFoto;
  String? _erroPlataformas;
  String? _erroTipos;
  int? _editandoPlataformaId;
  int? _editandoTipoId;

  bool _obscureSenhaAtual = true;
  bool _obscureSenhaNova = true;
  bool _obscureSenhaConfirmar = true;

  @override
  void initState() {
    super.initState();
    final client = ApiClient();
    _perfilService = PerfilService(apiClient: client);
    _plataformasService = PlataformasService(apiClient: client);
    _tiposService = TiposManutencaoService(apiClient: client);
    _nomeController = TextEditingController();
    _cpfController = TextEditingController();
    _cnpjController = TextEditingController();
    _senhaAtualController = TextEditingController();
    _senhaNovaController = TextEditingController();
    _senhaConfirmarController = TextEditingController();
    _plataformaController = TextEditingController();
    _tipoManutencaoController = TextEditingController();
    _carregar();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _senhaAtualController.dispose();
    _senhaNovaController.dispose();
    _senhaConfirmarController.dispose();
    _plataformaController.dispose();
    _tipoManutencaoController.dispose();
    super.dispose();
  }

  void _preencherDados(Perfil perfil) {
    _nomeController.text = perfil.nome;
    _cpfController.text = perfil.cpf ?? '';
    _cnpjController.text = perfil.cnpj ?? '';
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroGeral = null;
    });
    try {
      final results = await Future.wait([
        _perfilService.fetchPerfil(),
        _plataformasService.listar(),
        _tiposService.listar(),
      ]);
      if (!mounted) return;
      final perfil = results[0] as Perfil;
      setState(() {
        _perfil = perfil;
        _plataformas = results[1] as List<Plataforma>;
        _tipos = results[2] as List<TipoManutencao>;
        _carregando = false;
      });
      _preencherDados(perfil);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroGeral = error.message;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroGeral = 'Erro ao carregar perfil.';
        _carregando = false;
      });
    }
  }

  Future<void> _salvarDados() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroDados = null);
    if (!(_dadosFormKey.currentState?.validate() ?? false)) return;

    setState(() => _salvandoDados = true);
    try {
      final atualizado = await _perfilService.atualizar(
        nome: _nomeController.text,
        cpf: _cpfController.text,
        cnpj: _cnpjController.text,
      );
      if (!mounted) return;
      setState(() => _perfil = atualizado);
      await context.read<DashboardProvider>().load(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados salvos')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroDados = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroDados = 'Erro ao salvar dados.');
    } finally {
      if (mounted) setState(() => _salvandoDados = false);
    }
  }

  Future<void> _salvarSenha() async {
    FocusScope.of(context).unfocus();
    setState(() => _erroSenha = null);
    if (!(_senhaFormKey.currentState?.validate() ?? false)) return;

    setState(() => _salvandoSenha = true);
    try {
      await _perfilService.alterarSenha(
        senhaAtual: _senhaAtualController.text,
        senhaNova: _senhaNovaController.text,
      );
      if (!mounted) return;
      _senhaAtualController.clear();
      _senhaNovaController.clear();
      _senhaConfirmarController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroSenha = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erroSenha = 'Erro ao alterar senha.');
    } finally {
      if (mounted) setState(() => _salvandoSenha = false);
    }
  }

  Future<void> _salvarPlataforma() async {
    final nome = _plataformaController.text.trim();
    final erro = validarNomeCadastroPerfil(nome);
    if (erro != null) {
      setState(() => _erroPlataformas = erro);
      return;
    }

    setState(() {
      _erroPlataformas = null;
      _salvandoPlataforma = true;
    });
    final editando = _editandoPlataformaId != null;
    try {
      if (editando) {
        await _plataformasService.atualizar(
          id: _editandoPlataformaId!,
          nome: nome,
        );
      } else {
        await _plataformasService.criar(nome);
      }
      if (!mounted) return;
      _plataformaController.clear();
      setState(() => _editandoPlataformaId = null);
      await _recarregarListas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editando ? 'Plataforma atualizada' : 'Plataforma cadastrada',
            ),
          ),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroPlataformas = error.message);
    } finally {
      if (mounted) setState(() => _salvandoPlataforma = false);
    }
  }

  Future<void> _salvarTipo() async {
    final nome = _tipoManutencaoController.text.trim();
    final erro = validarNomeCadastroPerfil(nome);
    if (erro != null) {
      setState(() => _erroTipos = erro);
      return;
    }

    setState(() {
      _erroTipos = null;
      _salvandoTipo = true;
    });
    try {
      if (_editandoTipoId != null) {
        await _tiposService.atualizar(id: _editandoTipoId!, nome: nome);
      } else {
        await _tiposService.criar(nome);
      }
      if (!mounted) return;
      _tipoManutencaoController.clear();
      setState(() => _editandoTipoId = null);
      await _recarregarListas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo de manutenção salvo')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _erroTipos = error.message);
    } finally {
      if (mounted) setState(() => _salvandoTipo = false);
    }
  }

  Future<void> _recarregarListas() async {
    final plataformas = await _plataformasService.listar();
    final tipos = await _tiposService.listar();
    if (!mounted) return;
    setState(() {
      _plataformas = plataformas;
      _tipos = tipos;
    });
  }

  Future<void> _excluirPlataforma(int id, String nome) async {
    final item = Plataforma(id: id, nome: nome);
    final confirmado = await confirmarExclusaoPlataforma(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _plataformasService.excluir(id);
      if (!mounted) return;
      if (_editandoPlataformaId == id) {
        _plataformaController.clear();
        setState(() => _editandoPlataformaId = null);
      }
      await _recarregarListas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plataforma excluída')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _excluirTipo(int id, String nome) async {
    final item = TipoManutencao(id: id, nome: nome);
    final confirmado = await confirmarExclusaoTipoManutencao(context, item);
    if (!confirmado || !mounted) return;

    try {
      await _tiposService.excluir(id);
      if (!mounted) return;
      if (_editandoTipoId == id) {
        _tipoManutencaoController.clear();
        setState(() => _editandoTipoId = null);
      }
      await _recarregarListas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipo excluído')),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  Future<void> _enviarFoto() async {
    setState(() {
      _erroFoto = null;
    });

    try {
      final arquivo = await selecionarFotoPerfil();
      if (!mounted || arquivo == null) return;

      setState(() => _enviandoFoto = true);
      final perfil = await _perfilService.enviarFoto(arquivo);
      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _enviandoFoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada')),
      );
    } on SelecaoArquivoException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroFoto = error.message;
        _enviandoFoto = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _erroFoto = error.message;
        _enviandoFoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erroFoto = 'Erro inesperado ao enviar foto.';
        _enviandoFoto = false;
      });
    }
  }

  Future<void> _sair() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    await TokenStorage.clearToken();
    if (!mounted) return;

    final navigator = appNavigatorKey.currentState;
    if (navigator != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Widget _avatar(Perfil perfil) {
    final url = perfil.fotoUrlAbsoluta;
    return CircleAvatar(
      radius: 36,
      backgroundColor: AppColors.blueBackground,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Text(
              perfil.iniciais,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: acoesAppBarComDashboard(const []),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erroGeral != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _erroGeral!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _carregar,
                            child: const Text('Tentar novamente'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_perfil != null) ...[
                          Center(child: _avatar(_perfil!)),
                          const SizedBox(height: 12),
                          if (_erroFoto != null) ...[
                            Text(
                              _erroFoto!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.red),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: _enviandoFoto ? null : _enviarFoto,
                              icon: _enviandoFoto
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.photo_camera_outlined),
                              label: const Text('Enviar foto'),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'JPG ou PNG, até 2 MB',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _perfil!.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Form(
                          key: _dadosFormKey,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Dados cadastrais',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_erroDados != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _erroDados!,
                                    style: const TextStyle(color: AppColors.red),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nomeController,
                                  enabled: !_salvandoDados,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome *',
                                  ),
                                  validator: validarNomePerfil,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _cpfController,
                                  enabled: !_salvandoDados,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'CPF (opcional)',
                                    hintText: '000.000.000-00',
                                  ),
                                  validator: validarCpfPerfil,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _cnpjController,
                                  enabled: !_salvandoDados,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'CNPJ (opcional)',
                                    hintText: '00.000.000/0000-00',
                                  ),
                                  validator: validarCnpjPerfil,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        _salvandoDados ? null : _salvarDados,
                                    child: _salvandoDados
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text('Salvar dados'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _senhaFormKey,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Alterar senha',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_erroSenha != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _erroSenha!,
                                    style: const TextStyle(color: AppColors.red),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _senhaAtualController,
                                  obscureText: _obscureSenhaAtual,
                                  enabled: !_salvandoSenha,
                                  decoration: InputDecoration(
                                    labelText: 'Senha atual *',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureSenhaAtual
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureSenhaAtual =
                                            !_obscureSenhaAtual,
                                      ),
                                    ),
                                  ),
                                  validator: validarSenhaAtualPerfil,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _senhaNovaController,
                                  obscureText: _obscureSenhaNova,
                                  enabled: !_salvandoSenha,
                                  decoration: InputDecoration(
                                    labelText: 'Nova senha *',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureSenhaNova
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () =>
                                            _obscureSenhaNova = !_obscureSenhaNova,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => validarSenhaNovaPerfil(
                                    v,
                                    senhaAtual: _senhaAtualController.text,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _senhaConfirmarController,
                                  obscureText: _obscureSenhaConfirmar,
                                  enabled: !_salvandoSenha,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar nova senha *',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureSenhaConfirmar
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureSenhaConfirmar =
                                            !_obscureSenhaConfirmar,
                                      ),
                                    ),
                                  ),
                                  validator: (v) => validarConfirmarSenhaPerfil(
                                    v,
                                    senhaNova: _senhaNovaController.text,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        _salvandoSenha ? null : _salvarSenha,
                                    child: _salvandoSenha
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text('Atualizar senha'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PerfilSecaoListaNome(
                          titulo: 'Plataformas de ganho',
                          ajuda:
                              'Uber, 99, iFood… Usadas nos turnos de trabalho.',
                          labelCampo: 'Nome da plataforma',
                          placeholder: 'Ex.: Uber',
                          itens: _plataformas
                              .map((p) => (id: p.id, nome: p.nome))
                              .toList(),
                          nomeController: _plataformaController,
                          editandoId: _editandoPlataformaId,
                          salvando: _salvandoPlataforma,
                          erro: _erroPlataformas,
                          onSalvar: _salvarPlataforma,
                          onCancelarEdicao: () {
                            _plataformaController.clear();
                            setState(() => _editandoPlataformaId = null);
                          },
                          onEditar: (id, nome) {
                            _plataformaController.text = nome;
                            setState(() => _editandoPlataformaId = id);
                          },
                          onExcluir: _excluirPlataforma,
                        ),
                        const SizedBox(height: 16),
                        PerfilSecaoListaNome(
                          titulo: 'Tipos de manutenção',
                          ajuda:
                              'Óleo, Revisão, Pneus… Usados ao registrar manutenções.',
                          labelCampo: 'Nome do tipo',
                          placeholder: 'Ex.: Revisão',
                          itens: _tipos
                              .map((t) => (id: t.id, nome: t.nome))
                              .toList(),
                          nomeController: _tipoManutencaoController,
                          editandoId: _editandoTipoId,
                          salvando: _salvandoTipo,
                          erro: _erroTipos,
                          onSalvar: _salvarTipo,
                          onCancelarEdicao: () {
                            _tipoManutencaoController.clear();
                            setState(() => _editandoTipoId = null);
                          },
                          onEditar: (id, nome) {
                            _tipoManutencaoController.text = nome;
                            setState(() => _editandoTipoId = id);
                          },
                          onExcluir: _excluirTipo,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _sair,
                            icon: const Icon(Icons.logout),
                            label: const Text('Sair'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }
}
