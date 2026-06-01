/// Mensagens de validação exibidas ao usuário (pt-BR).
abstract final class MensagensValidacao {
  // Login
  static const emailObrigatorio = 'E-mail é obrigatório';
  static const emailInvalido = 'Informe um e-mail válido';
  static const senhaObrigatoria = 'Senha é obrigatória';

  // Veículo
  static const categoriaObrigatoria = 'Categoria é obrigatória';
  static const marcaObrigatoria = 'Marca é obrigatória';
  static const marcaMaxLength =
      'A marca deve ter no máximo 60 caracteres';
  static const modeloObrigatorio = 'Modelo é obrigatório';
  static const modeloMaxLength =
      'O modelo deve ter no máximo 60 caracteres';
  static const placaObrigatoria = 'Placa é obrigatória';
  static const placaInvalida =
      'Placa inválida. Use ABC1234 ou Mercosul ABC1D23';
  static const anoInvalido = 'Informe um ano válido';
  static String anoForaIntervalo(int maxAno) =>
      'O ano deve estar entre 1900 e $maxAno';
  static const kmAtualObrigatorio = 'Km atual é obrigatório';
  static const kmInvalido = 'O km deve ser zero ou maior';

  // Abastecimento
  static const dataObrigatoria = 'Selecione a data do abastecimento';
  static const dataFutura = 'A data não pode ser no futuro';
  static const kmAbastObrigatorio = 'Km é obrigatório';
  static const kmAbastInvalido = 'O km deve ser zero ou maior';
  static const litrosInvalido = 'Os litros devem ser maior que zero';
  static const litrosDecimais =
      'Use no máximo 2 casas decimais nos litros';
  static const valorInvalido = 'O valor deve ser zero ou maior';
  static const valorDecimais =
      'Use no máximo 2 casas decimais no valor';
  static const postoMaxLength =
      'O nome do posto deve ter no máximo 120 caracteres';

  // Manutenção
  static const tipoManutencaoObrigatorio = 'Selecione o tipo de manutenção';
  static const descricaoManutencaoMaxLength =
      'A descrição deve ter no máximo 2000 caracteres';
  static const kmManutencaoInvalido = 'O km deve ser zero ou maior';
  static const garantiaDiasInvalido =
      'Os dias de garantia devem ser zero ou maior';

  // Alerta
  static const tipoAlertaObrigatorio = 'Selecione o tipo de alerta';
  static const valorAlertaObrigatorio = 'Informe o intervalo do alerta';
  static const valorAlertaInvalido =
      'O intervalo deve ser um número inteiro maior que zero';
  static const valorAlertaMaximo = 'Intervalo muito grande (máx. 1.000.000)';
  static const tituloAlertaObrigatorio = 'Informe o título do alerta';
  static const tituloAlertaMaxLength =
      'O título deve ter no máximo 120 caracteres';
  static const antecedenciaAlertaObrigatoria =
      'Informe a antecedência do alerta';
  static const antecedenciaAlertaInvalida =
      'A antecedência deve ser um número inteiro maior que zero';
  static const antecedenciaAlertaMenorQueIntervalo =
      'A antecedência deve ser menor que o intervalo do alerta';

  // Período de trabalho
  static const kmPeriodoObrigatorio = 'Informe o km do hodômetro';
  static const kmPeriodoInvalido = 'O km deve ser zero ou maior';
  static const kmFimMenorQueInicio =
      'Km final deve ser maior que o km inicial';
  static const dataHoraFimAntesInicio =
      'Data/hora de fim deve ser posterior ao início';
  static const dataHoraPeriodoObrigatoria = 'Selecione data e hora';
  static const dataHoraFimObrigatoria =
      'Selecione data e hora de fim do turno';

  // Receita (ganho)
  static const plataformaObrigatoria = 'Selecione a plataforma';
  static const dataReceitaObrigatoria = 'Selecione a data do ganho';
  static const valorReceitaObrigatorio = 'Informe o valor do ganho';
  static const valorReceitaInvalido =
      'O valor deve ser maior que zero';
  static const valorReceitaDecimais =
      'Use no máximo 2 casas decimais no valor';
  static const descricaoReceitaMaxLength =
      'A descrição deve ter no máximo 255 caracteres';
  static String dataReceitaForaPeriodo(String inicio, String fim) =>
      'Data do ganho deve estar entre $inicio e $fim (período do turno)';

  // Perfil
  static const nomePerfilObrigatorio = 'Nome é obrigatório';
  static const nomePerfilCurto = 'O nome deve ter pelo menos 2 caracteres';
  static const nomePerfilMaxLength =
      'O nome deve ter no máximo 120 caracteres';
  static const cpfPerfilInvalido = 'CPF deve ter 11 dígitos';
  static const cnpjPerfilInvalido = 'CNPJ deve ter 14 dígitos';
  static const senhaAtualObrigatoria = 'Informe a senha atual';
  static const senhaNovaCurta =
      'A nova senha deve ter pelo menos 6 caracteres';
  static const senhaNovaIgualAtual =
      'A nova senha deve ser diferente da senha atual';
  static const confirmarSenhaObrigatoria = 'Confirme a nova senha';
  static const confirmarSenhaDiferente = 'As senhas não coincidem';
  static const nomeCadastroPerfilObrigatorio = 'Informe o nome';
  static const nomeCadastroPerfilMaxLength =
      'O nome deve ter no máximo 60 caracteres';

  static const categoriaDespesaObrigatoria = 'Selecione a categoria';
  static const valorDespesaObrigatorio = 'Informe o valor';
  static const valorDespesaInvalido = 'Valor inválido';
  static const descricaoDespesaMaxLength =
      'A descrição deve ter no máximo 255 caracteres';
  static const kmDespesaInvalido = 'Km inválido';
}
