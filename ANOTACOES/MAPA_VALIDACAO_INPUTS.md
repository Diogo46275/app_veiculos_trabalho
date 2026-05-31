# MAPA_VALIDACAO_INPUTS.md — App Veículos Mobile

_Mapeamento de validação de inputs conforme VALIDACOES.md § Validação Expressa._

_Última atualização: 30/05/2026_

---

## LoginScreen

| CAMPO | REGRAS | MSG ATUAL | STATUS |
|-------|--------|-----------|--------|
| E-mail | obrigatório, formato email | "E-mail é obrigatório" / "Informe um e-mail válido" | ✅ |
| Senha | obrigatório | "Senha é obrigatória" | ✅ |

---

## CadastroVeiculoScreen / EditarVeiculoScreen

| CAMPO | REGRAS | MSG ATUAL | STATUS |
|-------|--------|-----------|--------|
| Categoria | obrigatório (enum) | "Categoria é obrigatória" | ✅ |
| Marca | obrigatório, max 60 | "Marca é obrigatória" / "A marca deve ter no máximo 60 caracteres" | ✅ |
| Modelo | obrigatório, max 60 | "Modelo é obrigatório" / "O modelo deve ter no máximo 60 caracteres" | ✅ |
| Placa | obrigatório, 7 chars ABC1234 ou ABC1D23 | "Placa é obrigatória" / "Placa inválida. Use ABC1234 ou Mercosul ABC1D23" | ✅ (corrigido formato) |
| Ano | opcional, int 1900–(ano+1) | "Informe um ano válido" / "O ano deve estar entre 1900 e {max}" | ✅ |
| Km atual | obrigatório, int ≥ 0 | "Km atual é obrigatório" / "O km deve ser zero ou maior" | ✅ (corrigido ≥) |

---

## FormAbastecimentoScreen

| CAMPO | REGRAS | MSG ATUAL | STATUS |
|-------|--------|-----------|--------|
| Data | obrigatório, não futura | "Selecione a data do abastecimento" / "A data não pode ser no futuro" | ✅ (adicionado) |
| Km | obrigatório, int ≥ 0 | "Km é obrigatório" / "O km deve ser zero ou maior" | ✅ |
| Litros | obrigatório, > 0, max 2 decimais | "Os litros devem ser maior que zero" / "Use no máximo 2 casas decimais nos litros" | ✅ |
| Valor (R$) | obrigatório, ≥ 0, max 2 decimais | "O valor deve ser zero ou maior" / "Use no máximo 2 casas decimais no valor" | ✅ |
| Posto | opcional, max 120 | "O nome do posto deve ter no máximo 120 caracteres" | ✅ (adicionado) |
| Documento NF | enum fixo (sem/CPF/CNPJ) | — (sempre válido) | ✅ |

---

## FormManutencaoScreen

| CAMPO | REGRAS | MSG ATUAL | STATUS |
|-------|--------|-----------|--------|
| Tipo | obrigatório (dropdown API) | "Selecione o tipo de manutenção" | ✅ |
| Data | obrigatório, não futura | reutiliza validadores abastecimento | ✅ |
| Km | opcional, int ≥ 0 | "O km deve ser zero ou maior" | ✅ |
| Valor (R$) | obrigatório, ≥ 0, max 2 decimais | reutiliza validadores abastecimento | ✅ |
| Descrição | opcional, max 2000 | "A descrição deve ter no máximo 2000 caracteres" | ✅ |
| Garantia (dias) | opcional, int ≥ 0 | "Os dias de garantia devem ser zero ou maior" | ✅ |
| Documento NF | enum fixo (sem/CPF/CNPJ) | — (sempre válido) | ✅ |

---

## FormAlertaScreen

| CAMPO | REGRAS | MSG ATUAL | STATUS |
|-------|--------|-----------|--------|
| Tipo | obrigatório (km / data) | "Selecione o tipo de alerta" | ✅ |
| Título | obrigatório, max 120 | msgs tituloAlerta* | ✅ |
| Intervalo | obrigatório, int > 0, max 1.000.000 | msgs valorAlerta* | ✅ |
| Ativo | bool (switch) | — (sempre válido) | ✅ |

---

## Telas sem inputs de formulário

- DashboardScreen, VeiculosTabScreen, PerfilTabScreen, VeiculoDetalheScreen (somente listas/abas)

---

## Implementação centralizada

- Mensagens: `lib/validacao/mensagens_validacao.dart`
- Validadores: `lib/validacao/validadores_formulario.dart`
- Testes: `test/validacao/*.dart`
