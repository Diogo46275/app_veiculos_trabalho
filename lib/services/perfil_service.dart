import '../models/arquivo_multipart.dart';
import '../models/perfil.dart';
import '../utils/seletor_arquivo.dart';
import 'api_client.dart';

class PerfilService {
  PerfilService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Perfil> fetchPerfil() async {
    final json = await _apiClient.getJson('/auth/perfil');
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida do perfil.');
    }
    return Perfil.fromJson(json);
  }

  Future<Perfil> atualizar({
    required String nome,
    String? cpf,
    String? cnpj,
  }) async {
    final body = <String, dynamic>{'nome': nome.trim()};
    final cpfLimpo = cpf?.trim();
    final cnpjLimpo = cnpj?.trim();
    body['cpf'] = (cpfLimpo == null || cpfLimpo.isEmpty) ? null : cpfLimpo;
    body['cnpj'] = (cnpjLimpo == null || cnpjLimpo.isEmpty) ? null : cnpjLimpo;

    final json = await _apiClient.putJson('/auth/perfil', body: body);
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao salvar perfil.');
    }
    return Perfil.fromJson(json);
  }

  Future<void> alterarSenha({
    required String senhaAtual,
    required String senhaNova,
  }) async {
    await _apiClient.putJson(
      '/auth/perfil/senha',
      body: {
        'senha_atual': senhaAtual,
        'senha_nova': senhaNova,
      },
    );
  }

  Future<Perfil> enviarFoto(ArquivoSelecionado arquivo) async {
    final json = await _apiClient.postMultipart(
      '/auth/perfil/foto',
      fields: const {},
      arquivos: [
        ArquivoMultipart(
          campo: 'arquivo',
          bytes: arquivo.bytes,
          nomeArquivo: nomeArquivoUploadSeguro(arquivo.nome),
        ),
      ],
    );
    if (json is! Map<String, dynamic>) {
      throw ApiException('Resposta inválida ao enviar foto.');
    }
    return Perfil.fromJson(json);
  }
}
