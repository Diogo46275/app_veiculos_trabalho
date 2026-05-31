import '../utils/parse_numero.dart';
import 'mensagens_validacao.dart';

const _maxMarcaModelo = 60;
const _maxPosto = 120;
const _maxDescricaoManutencao = 2000;
const _maxDescricaoReceita = 255;
const _maxNomePerfil = 120;
const _maxNomeCadastroPerfil = 60;
const _minSenha = 6;
const _maxValorAlerta = 1000000;
const _maxTituloAlerta = 120;
const _regexPlaca = r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$';
const _regexEmail =
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$';

int get anoMaximoPermitido => DateTime.now().year + 1;

String _normalizarPlaca(String placa) {
  return placa.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
}

bool _temNoMaximoDuasCasasDecimais(String texto) {
  final limpo = texto.trim().replaceAll(',', '.');
  final partes = limpo.split('.');
  if (partes.length <= 1) return true;
  return partes[1].length <= 2;
}

// --- Login ---

String? validarEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return MensagensValidacao.emailObrigatorio;
  if (!RegExp(_regexEmail).hasMatch(email)) {
    return MensagensValidacao.emailInvalido;
  }
  return null;
}

String? validarSenha(String? value) {
  if (value == null || value.isEmpty) {
    return MensagensValidacao.senhaObrigatoria;
  }
  return null;
}

// --- Veículo ---

String? validarCategoriaVeiculo(Object? value) {
  if (value == null) return MensagensValidacao.categoriaObrigatoria;
  return null;
}

String? validarMarca(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.marcaObrigatoria;
  if (texto.length > _maxMarcaModelo) {
    return MensagensValidacao.marcaMaxLength;
  }
  return null;
}

String? validarModelo(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.modeloObrigatorio;
  if (texto.length > _maxMarcaModelo) {
    return MensagensValidacao.modeloMaxLength;
  }
  return null;
}

String? validarPlaca(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.placaObrigatoria;
  final limpa = _normalizarPlaca(texto);
  if (limpa.length != 7 || !RegExp(_regexPlaca).hasMatch(limpa)) {
    return MensagensValidacao.placaInvalida;
  }
  return null;
}

String? validarAnoVeiculo(String? value, {int? anoMaximo}) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return null;
  final ano = int.tryParse(texto);
  if (ano == null) return MensagensValidacao.anoInvalido;
  final maxAno = anoMaximo ?? anoMaximoPermitido;
  if (ano < 1900 || ano > maxAno) {
    return MensagensValidacao.anoForaIntervalo(maxAno);
  }
  return null;
}

String? validarKmVeiculo(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.kmAtualObrigatorio;
  final km = int.tryParse(texto);
  if (km == null || km < 0) return MensagensValidacao.kmInvalido;
  return null;
}

// --- Abastecimento ---

String? validarDataAbastecimento(DateTime? data) {
  if (data == null) return MensagensValidacao.dataObrigatoria;
  final hoje = DateTime.now();
  final limite = DateTime(hoje.year, hoje.month, hoje.day);
  final informada = DateTime(data.year, data.month, data.day);
  if (informada.isAfter(limite)) {
    return MensagensValidacao.dataFutura;
  }
  return null;
}

String? validarKmAbastecimento(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.kmAbastObrigatorio;
  final km = int.tryParse(texto);
  if (km == null || km < 0) return MensagensValidacao.kmAbastInvalido;
  return null;
}

String? validarLitros(String? value) {
  final bruto = value ?? '';
  if (bruto.trim().isEmpty) return MensagensValidacao.litrosInvalido;
  if (!_temNoMaximoDuasCasasDecimais(bruto)) {
    return MensagensValidacao.litrosDecimais;
  }
  final litros = ParseNumero.decimal(bruto);
  if (litros == null || litros <= 0) {
    return MensagensValidacao.litrosInvalido;
  }
  return null;
}

String? validarValorAbastecimento(String? value) {
  final bruto = value ?? '';
  if (bruto.trim().isEmpty) return MensagensValidacao.valorInvalido;
  if (!_temNoMaximoDuasCasasDecimais(bruto)) {
    return MensagensValidacao.valorDecimais;
  }
  final valor = ParseNumero.decimal(bruto);
  if (valor == null || valor < 0) {
    return MensagensValidacao.valorInvalido;
  }
  return null;
}

String? validarPosto(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return null;
  if (texto.length > _maxPosto) {
    return MensagensValidacao.postoMaxLength;
  }
  return null;
}

// --- Manutenção ---

String? validarTipoManutencao(Object? value) {
  if (value == null) return MensagensValidacao.tipoManutencaoObrigatorio;
  return null;
}

String? validarKmManutencao(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return null;
  final km = int.tryParse(texto);
  if (km == null || km < 0) return MensagensValidacao.kmManutencaoInvalido;
  return null;
}

String? validarDescricaoManutencao(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return null;
  if (texto.length > _maxDescricaoManutencao) {
    return MensagensValidacao.descricaoManutencaoMaxLength;
  }
  return null;
}

String? validarGarantiaDias(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return null;
  final dias = int.tryParse(texto);
  if (dias == null || dias < 0) {
    return MensagensValidacao.garantiaDiasInvalido;
  }
  return null;
}

// --- Alerta ---

enum TipoAlerta {
  km('km', 'Por km'),
  data('data', 'Por data');

  const TipoAlerta(this.valor, this.rotulo);

  final String valor;
  final String rotulo;

  static TipoAlerta fromValor(String? valor) {
    return TipoAlerta.values.firstWhere(
      (item) => item.valor == valor,
      orElse: () => TipoAlerta.km,
    );
  }
}

String? validarTipoAlerta(Object? value) {
  if (value == null) return MensagensValidacao.tipoAlertaObrigatorio;
  return null;
}

String? validarValorAlerta(String? value, {TipoAlerta? tipo}) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.valorAlertaObrigatorio;
  final intervalo = int.tryParse(texto);
  if (intervalo == null || intervalo <= 0) {
    return MensagensValidacao.valorAlertaInvalido;
  }
  if (intervalo > _maxValorAlerta) {
    return MensagensValidacao.valorAlertaMaximo;
  }
  return null;
}

String? validarTituloAlerta(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.tituloAlertaObrigatorio;
  if (texto.length > _maxTituloAlerta) {
    return MensagensValidacao.tituloAlertaMaxLength;
  }
  return null;
}

String? validarAntecedenciaAlerta(
  String? value, {
  required String? intervaloTexto,
}) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.antecedenciaAlertaObrigatoria;
  final antecedencia = int.tryParse(texto);
  if (antecedencia == null || antecedencia <= 0) {
    return MensagensValidacao.antecedenciaAlertaInvalida;
  }
  final intervalo = int.tryParse(intervaloTexto?.trim() ?? '');
  if (intervalo != null && antecedencia >= intervalo) {
    return MensagensValidacao.antecedenciaAlertaMenorQueIntervalo;
  }
  return null;
}

// --- Período de trabalho ---

String? validarKmPeriodo(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.kmPeriodoObrigatorio;
  final km = int.tryParse(texto);
  if (km == null || km < 0) {
    return MensagensValidacao.kmPeriodoInvalido;
  }
  return null;
}

String? validarKmFimPeriodo(String? kmFimTexto, {required String? kmInicioTexto}) {
  final base = validarKmPeriodo(kmFimTexto);
  if (base != null) return base;
  final kmFim = int.parse(kmFimTexto!.trim());
  final kmInicio = int.tryParse(kmInicioTexto?.trim() ?? '');
  if (kmInicio != null && kmFim <= kmInicio) {
    return MensagensValidacao.kmFimMenorQueInicio;
  }
  return null;
}

String? validarDataHoraPeriodo(DateTime? valor) {
  if (valor == null) return MensagensValidacao.dataHoraPeriodoObrigatoria;
  return null;
}

String? validarDataHoraFimPeriodo(
  DateTime? fim, {
  required DateTime? inicio,
}) {
  if (fim == null) return MensagensValidacao.dataHoraFimObrigatoria;
  if (inicio != null && !fim.isAfter(inicio)) {
    return MensagensValidacao.dataHoraFimAntesInicio;
  }
  return null;
}

// --- Receita (ganho) ---

String? validarPlataformaReceita(Object? value) {
  if (value == null) return MensagensValidacao.plataformaObrigatoria;
  return null;
}

String? validarDataReceita(
  DateTime? data, {
  required DateTime? inicioTurno,
  required DateTime? fimTurno,
}) {
  if (data == null) return MensagensValidacao.dataReceitaObrigatoria;

  if (inicioTurno != null) {
    final inicioDia = DateTime(
      inicioTurno.year,
      inicioTurno.month,
      inicioTurno.day,
    );
    final fimDia = fimTurno != null
        ? DateTime(fimTurno.year, fimTurno.month, fimTurno.day)
        : DateTime.now();
    final dataGanho = DateTime(data.year, data.month, data.day);
    if (dataGanho.isBefore(inicioDia) || dataGanho.isAfter(fimDia)) {
      return MensagensValidacao.dataReceitaForaPeriodo(
        '${inicioDia.day.toString().padLeft(2, '0')}/'
        '${inicioDia.month.toString().padLeft(2, '0')}/'
        '${inicioDia.year}',
        '${fimDia.day.toString().padLeft(2, '0')}/'
        '${fimDia.month.toString().padLeft(2, '0')}/'
        '${fimDia.year}',
      );
    }
  }
  return null;
}

String? validarValorReceita(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.valorReceitaObrigatorio;
  if (!_temNoMaximoDuasCasasDecimais(texto)) {
    return MensagensValidacao.valorReceitaDecimais;
  }
  final valor = ParseNumero.decimal(texto);
  if (valor == null || valor <= 0) {
    return MensagensValidacao.valorReceitaInvalido;
  }
  return null;
}

String? validarDescricaoReceita(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.length > _maxDescricaoReceita) {
    return MensagensValidacao.descricaoReceitaMaxLength;
  }
  return null;
}

// --- Perfil ---

String _somenteDigitos(String? value) =>
    value?.replaceAll(RegExp(r'\D'), '') ?? '';

String? validarNomePerfil(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.nomePerfilObrigatorio;
  if (texto.length < 2) return MensagensValidacao.nomePerfilCurto;
  if (texto.length > _maxNomePerfil) {
    return MensagensValidacao.nomePerfilMaxLength;
  }
  return null;
}

String? validarCpfPerfil(String? value) {
  final digitos = _somenteDigitos(value);
  if (digitos.isEmpty) return null;
  if (digitos.length != 11) return MensagensValidacao.cpfPerfilInvalido;
  return null;
}

String? validarCnpjPerfil(String? value) {
  final digitos = _somenteDigitos(value);
  if (digitos.isEmpty) return null;
  if (digitos.length != 14) return MensagensValidacao.cnpjPerfilInvalido;
  return null;
}

String? validarSenhaAtualPerfil(String? value) {
  if (value == null || value.isEmpty) {
    return MensagensValidacao.senhaAtualObrigatoria;
  }
  return null;
}

String? validarSenhaNovaPerfil(String? value, {String? senhaAtual}) {
  if (value == null || value.isEmpty) {
    return MensagensValidacao.senhaObrigatoria;
  }
  if (value.length < _minSenha) {
    return MensagensValidacao.senhaNovaCurta;
  }
  if (senhaAtual != null && value == senhaAtual) {
    return MensagensValidacao.senhaNovaIgualAtual;
  }
  return null;
}

String? validarConfirmarSenhaPerfil(
  String? value, {
  required String? senhaNova,
}) {
  if (value == null || value.isEmpty) {
    return MensagensValidacao.confirmarSenhaObrigatoria;
  }
  if (value != senhaNova) {
    return MensagensValidacao.confirmarSenhaDiferente;
  }
  return null;
}

String? validarNomeCadastroPerfil(String? value) {
  final texto = value?.trim() ?? '';
  if (texto.isEmpty) return MensagensValidacao.nomeCadastroPerfilObrigatorio;
  if (texto.length > _maxNomeCadastroPerfil) {
    return MensagensValidacao.nomeCadastroPerfilMaxLength;
  }
  return null;
}
