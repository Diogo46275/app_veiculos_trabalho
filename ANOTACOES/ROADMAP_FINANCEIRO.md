# ROADMAP_FINANCEIRO.md — Cruzamento DOC × PROJ

_Alinhamento entre `base_compatilhada/ideias/REQUISITOS_APP_VEICULOS.md` (entrevista 01/06/2026) e o app validado em `VALIDADOS.md`._

_Última atualização: 01/06/2026_

---

## Aviso de numeração (obrigatório)

Existem **dois conjuntos de RF** com IDs que se sobrepõem:

| Prefixo | Fonte | Exemplo |
|---------|--------|---------|
| **DOC RF-xx** | `base_compatilhada/ideias/REQUISITOS_APP_VEICULOS.md` | DOC RF-05 = despesa genérica + recorrência |
| **PROJ RF-xxx** | `ANOTACOES/VALIDADOS.md` | PROJ RF-011 = múltiplos anexos (validado 31/05) |

**Regra TIER 0:** PROJ RF-001 … RF-011 ✅ não devem ser alterados sem OK explícito do Diogo. Evolução = **estender** (FIN-xxx), não sobrescrever.

**Escopo validado hoje:** `VALIDADOS.md` — RF-001 a RF-011 (mobile + upload) concluídos.

---

## 1. Cruzamento DOC ↔ PROJ ↔ código

| DOC RF | Requisito (doc) | PROJ RF relacionado | Status vs doc | Backend | Flutter |
|--------|-----------------|---------------------|---------------|---------|---------|
| **DOC RF-01** | Auth completa | PROJ **RF-001** (login) | **Parcial** | ✅ registro/login/JWT `api/rotas/auth.py:22-29`; bcrypt `services/auth_service.py:7,43` | ✅ login `lib/services/auth_service.dart:28-39`; ❌ cadastro/biometria/recuperação no app |
| **DOC RF-02** | Trial + assinatura | — | **Não iniciado** | ❌ sem campos em `models/usuario.py:14-29` | ❌ |
| **DOC RF-03** | Veículos | PROJ **RF-003/004/004b/004c** | **Alto** (falta ônibus + ativo) | ✅ CRUD `services/veiculo_service.py:18-51`; `categoria` `models/veiculo.py:24` | ✅ `lib/services/veiculos_service.dart:9-44`; enum `lib/models/categoria_veiculo.dart:5-10` |
| **DOC RF-04** | Categorias despesa/veículo | PROJ **RF-010** (tipos manutenção por **usuário**) | **Não atende** | ✅ `TipoManutencao` `models/tipo_manutencao.py:9-22` — não por veículo | ✅ perfil `lib/screens/perfil_tab_screen.dart:742` |
| **DOC RF-05** | Despesa + recorrência + parcelas | PROJ **RF-006/007/011** (abast/manut + anexos) | **Parcial** | ✅ abast/manut + `anexos`; ❌ sem `Despesa`/parcela/recorrência | ✅ forms + anexos; ❌ despesa genérica |
| **DOC RF-06** | Receita (avulsa opcional) | PROJ **RF-009** (ganhos no turno) | **Parcial** | ✅ `models/receita.py:18-26`; criação só com turno `services/receita_service.py:82-105` | ✅ `form_receita_screen.dart:20-26` exige `periodo` |
| **DOC RF-07** | Período de trabalho | PROJ **RF-009** | **Alto** | ✅ `models/periodo_trabalho.py:9-31`; métricas `services/periodo_trabalho_service.py:261-263` | ✅ `detalhe_periodo_screen.dart:111-120` |
| **DOC RF-08** | Dashboard financeiro | PROJ **RF-002** | **Parcial** | ✅ `services/dashboard_service.py:62-66` | ✅ km/economia/alertas `dashboard_screen.dart:255-272` |
| **DOC RF-09** | Relatórios XLSX/PDF | — | **Só web** | ❌ API `api/main.py:37-59` | ❌ mobile; ✅ web `web/src/utils/exportarTabela.js:3-4,54,104` |
| **DOC RF-10** | Push parcela/recorrência | PROJ **RF-008** (alertas km/data) | **Domínio diferente** | ✅ `api/rotas/alertas.py:70` | ✅ `notificacoes_alerta_service.dart:17-20` |
| **DOC RF-11** | SaaS + admin | (isolamento JWT) | **Parcial** | ✅ `api/dependencias.py:42-48`; ❌ admin | ❌ admin |

**Legenda:** **Alto** ≈ ≥80% do doc; **Parcial** = base existe, faltam itens explícitos; **Não atende** = modelo de produto diferente.

---

## 2. O que o PROJ já validou (não reabrir sem OK)

| PROJ RF | Equivalente aproximado no DOC | Ação futura |
|---------|------------------------------|-------------|
| PROJ RF-001 | DOC RF-01 (só login) | Estender (cadastro app, biometria, etc.) |
| PROJ RF-002 | DOC RF-08 (parcial) | Estender cards/filtros financeiros |
| PROJ RF-003–005 | DOC RF-03 + gestão | Manter; gaps: ônibus, veículo ativo |
| PROJ RF-006–007 | DOC RF-05 (despesas tipadas) | Migrar ou conviver com `Despesa` genérica |
| PROJ RF-008 | DOC RF-10 (outro domínio) | Manter alertas; novo IMP para parcela/recorrência |
| PROJ RF-009 | DOC RF-06 + DOC RF-07 | Estender receita avulsa |
| PROJ RF-010 | ≠ DOC RF-04 | Tipos manutenção ≠ categorias despesa |
| PROJ RF-011 | DOC RF-05 (anexos) | Reutilizar `AnexoService` / IMP-025 |

---

## 3. Backlog priorizado (FIN-xxx)

Ordem alinhada ao risco do doc (`REQUISITOS_APP_VEICULOS.md` § Riscos) e dependências técnicas.

### Fase A — MVP financeiro

| Prioridade | ID | DOC RF | Entrega | Depende de |
|:----------:|-----|--------|---------|------------|
| **P0** | **FIN-001** | DOC RF-04 | `CategoriaDespesa` (veículo_id, nome, ícone) + CRUD API + tela no veículo | — |
| **P0** | **FIN-002** | DOC RF-05 (base) | `Despesa` (veículo, categoria, data, valor, descrição, km) + CRUD mobile | FIN-001 |
| **P0** | **FIN-003** | DOC RF-05 (anexos) | Anexos em `Despesa` (`entidade_tipo=despesa`) — reutilizar IMP-025 / `AnexoService` | FIN-002 |
| **P1** | **FIN-004** | DOC RF-08 | Dashboard: Total Receitas, Despesas, Saldo (período) — API `/dashboard/rentabilidade` + UI | FIN-002 |
| **P1** | **FIN-005** | DOC RF-06 | Receita avulsa (sem turno aberto obrigatório) | — |
| **P1** | **FIN-006** | DOC RF-01 | Cadastro no app + auto-login com JWT salvo | — |

### Fase B — Diferencial e retenção

| Prioridade | ID | DOC RF | Entrega |
|:----------:|-----|--------|---------|
| **P2** | **FIN-007** | DOC RF-05 | Recorrência (geração automática de lançamentos) |
| **P2** | **FIN-008** | DOC RF-05 | Parcelamento (`grupo_parcelamento_id`, “Parcela X de N”) |
| **P2** | **FIN-009** | DOC RF-10 | Push parcela/recorrência |
| **P2** | **FIN-010** | DOC RF-08 | Dashboard: parcelas, recorrências, últimos lançamentos |
| **P2** | **FIN-011** | DOC RF-09 | Relatórios mobile (XLSX/PDF) |

### Fase C — SaaS comercial

| Prioridade | ID | DOC RF | Entrega |
|:----------:|-----|--------|---------|
| **P3** | **FIN-012** | DOC RF-02 | Trial + assinatura (campos usuário + bloqueio API) |
| **P3** | **FIN-013** | DOC RF-02 | Gestão manual de assinatura (placeholder) |
| **P3** | **FIN-014** | DOC RF-11 | Painel admin multi-usuário |
| **P3** | **FIN-015** | DOC RF-01 | Biometria + recuperação de senha |
| **P3** | **FIN-016** | RNF offline | Fila de sincronização |

### Fase D — Ajustes menores

| ID | DOC RF | Item |
|----|--------|------|
| **FIN-017** | DOC RF-03 | Tipo **ônibus** (doc linha 40 vs enum sem ônibus) |
| **FIN-018** | DOC RF-03 | **Veículo ativo** global |
| **FIN-019** | DOC RF-01 | UX “Lembrar de mim” (token já persiste em `token_storage.dart`) |

---

## 4. Sequência sugerida (sprints)

**Sprint 1:** FIN-001 → FIN-002 → FIN-003 → FIN-004  
**Sprint 2:** FIN-005 → FIN-006 → FIN-017 (opcional)  
**Sprint 3:** FIN-007 → FIN-008 → FIN-009 → FIN-010  
**Depois:** FIN-011, FIN-012–014

---

## 5. Decisões (Diogo — 01/06/2026)

| # | Pergunta | Resposta |
|---|----------|----------|
| 1 | Migrar abast/manut para `Despesa` ou manter módulos separados? | **Convivência** |
| 2 | Categorias 100% livres ou pré-popular? | **Sugestões padrão** (seed) |
| 3 | Relatórios mobile: gerar no aparelho ou endpoint? | _Pendente_ |
| 4 | Receita avulsa no ganho/hora só com turno? | _Pendente_ |
| 5 | Prefixo **FIN-xxx** ou PROJ RF-012+? | **FIN-xxx** |

### FIN-001 (em implementação)

- Backend: `models/categoria_despesa.py`, `/api/categorias-despesa/`, seed em `utils/categorias_despesa_padrao.py`
- Flutter: `CategoriasDespesaScreen`, atalho no detalhe do veículo (ícone categorias)
- Status: aguardando validação do Diogo

---

## 6. Resumo

O app validado é um **gestor de veículos de trabalho** com alta aderência a DOC RF-07, parcial a DOC RF-06 (turno), DOC RF-05 (anexos em registros tipados) e DOC RF-08. O **produto financeiro SaaS** do documento exige principalmente **FIN-001 a FIN-004** antes de recorrência/assinatura.

**Repositórios:** Flutter `app_veiculos_trabalho` · Backend `veiculo` (FastAPI) · Doc `base_compatilhada/ideias/REQUISITOS_APP_VEICULOS.md`
