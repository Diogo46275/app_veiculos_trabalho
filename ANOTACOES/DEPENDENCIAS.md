# DEPENDENCIAS.md — App Veículos Mobile

_Mapa de dependências entre funcionalidades e arquivos._

_Última atualização: 31/05/2026_

---

## 🔷 Autenticação (RF-001)

**Arquivo(s):** `lib/services/auth_service.dart`, `lib/services/token_storage.dart`, `lib/providers/login_provider.dart`, `lib/screens/login_screen.dart`

**Depende de:** IMP-001 (ApiConfig), IMP-004 (ApiClient parcial — login sem Bearer)

**É usado por:** Todos os endpoints autenticados

⚠️ Se alterar token storage → testar: login, qualquer GET/POST autenticado, sessão expirada

**Risco:** 🔴 Crítico

---

## 🔷 ApiClient (IMP-004)

**Arquivo(s):** `lib/services/api_client.dart`

**Depende de:** TokenStorage (headers Bearer)

**É usado por:** auth_service, dashboard_service, veiculos_service, perfil_service

⚠️ Se alterar ApiClient → testar: login, dashboard, lista veículos, CRUD veículo, mensagens de erro

**Risco:** 🔴 Crítico

---

## 🔷 Dashboard (RF-002)

**Arquivo(s):** `lib/services/dashboard_service.dart`, `lib/providers/dashboard_provider.dart`, `lib/screens/dashboard_screen.dart`

**Depende de:** ApiClient, PerfilService (nome usuário)

**É usado por:** MainShell aba 0; refresh após cadastro/exclusão veículo

⚠️ Se alterar dashboard → testar: cards indicadores, fallback 404, pull-to-refresh

**Risco:** 🟡 Médio

---

## 🔷 Veículos — lista e CRUD (RF-003, RF-004)

**Arquivo(s):** `lib/services/veiculos_service.dart`, `lib/providers/veiculos_provider.dart`, `lib/screens/veiculos_tab_screen.dart`

**Depende de:** ApiClient, model Veiculo

**É usado por:** Cadastro, edição, swipe excluir, dashboard refresh

⚠️ Se alterar VeiculosProvider → testar: lista, cadastro, editar, excluir, empty state, erro rede

**Risco:** 🔴 Crítico

---

## 🔷 Categoria veículo (RF-004b)

**Arquivo(s):** `lib/models/categoria_veiculo.dart`, `lib/models/veiculo.dart`, `lib/screens/cadastro_veiculo_screen.dart`, `lib/screens/editar_veiculo_screen.dart`, `lib/screens/widgets/veiculo_list_tile.dart`

**Depende de:** API campo `categoria` (backend)

**É usado por:** Lista, cadastro, edição, detalhe, navegação condicional

⚠️ Se alterar categoria → testar: POST novo, PUT legado, ícones/cores, bloqueio sem categoria

**Risco:** 🟡 Médio

---

## 🔷 Swipe to Action (RF-003b)

**Arquivo(s):** `lib/screens/widgets/veiculo_swipe_tile.dart`, `flutter_slidable`

**Depende de:** VeiculosProvider.excluir, EditarVeiculoScreen, confirmarExclusaoVeiculo

**É usado por:** VeiculosTabScreen, DashboardScreen (lista "Meus veículos")

⚠️ Se alterar swipe → testar: gesto horizontal vs scroll vertical, editar, excluir com dialog, SnackBar

**Risco:** 🟢 Baixo (UI isolada)

---

## 🔷 MainShell + FAB (RF-002 navegação)

**Arquivo(s):** `lib/screens/main_shell.dart`

**Depende de:** DashboardScreen, VeiculosTabScreen, PerfilTabScreen, CadastroVeiculoScreen

**É usado por:** App após login

⚠️ Se alterar shell → testar: troca abas, FAB menu, zona 72px sem toque, notch

**Risco:** 🟡 Médio

---

## 🔷 Detalhe veículo + abas (RF-005)

**Arquivo(s):** `lib/screens/veiculo_detalhe_screen.dart`, `lib/services/veiculo_modulos_service.dart`, models abastecimento/manutencao/alerta/periodo

**Depende de:** ApiClient, VeiculosService.obter, endpoints:
- `GET /abastecimentos/veiculo/{id}`
- `GET /manutencoes/veiculo/{id}`
- `GET /alertas/veiculo/{id}`
- `GET /periodos-trabalho/veiculo/{id}`

**É usado por:** Navegação a partir da lista (VeiculosTab, Dashboard)

⚠️ Se alterar detalhe → testar: abas, loading, empty, erro rede, pull-to-refresh, editar e resumo

**Risco:** 🟡 Médio

---

## 🔷 Manutenções CRUD (RF-007)

**Arquivo(s):** `lib/services/manutencoes_service.dart`, `lib/services/tipos_manutencao_service.dart`, `lib/screens/form_manutencao_screen.dart`, aba em `veiculo_detalhe_screen.dart`

**Depende de:** ApiClient (multipart), GET `/tipos-manutencao/`, RF-005 (aba Manutenções)

**Endpoints:**
- `GET /tipos-manutencao/` — tipos do usuário (dropdown)
- `POST /manutencoes/veiculo/{id}` — criar
- `PUT /manutencoes/{id}` — editar
- `DELETE /manutencoes/{id}` — excluir

**É usado por:** VeiculoDetalheScreen aba 1, dashboard refresh após salvar

⚠️ Se alterar manutenções → testar: tipos vazios, CRUD, km veículo, garantia status, documento CPF/CNPJ

**Risco:** 🟡 Médio

---

## 🔷 Alertas CRUD (RF-008)

**Arquivo(s):** `lib/services/alertas_service.dart`, `lib/screens/form_alerta_screen.dart`, aba em `veiculo_detalhe_screen.dart`

**Depende de:** ApiClient (JSON POST/PUT), RF-005 (aba Alertas)

**Endpoints:**
- `POST /alertas/veiculo/{id}` — criar
- `PUT /alertas/{id}` — editar
- `POST /alertas/{id}/reset` — reset manual
- `DELETE /alertas/{id}` — excluir

**É usado por:** VeiculoDetalheScreen aba 2, dashboard refresh após salvar/reset

⚠️ Se alterar alertas → testar: km/data, ativo/inativo, reset, status calculado, dashboard

**Risco:** 🟡 Médio

---

## 🔷 Períodos de trabalho + ganhos (RF-009)

**Arquivo(s):** `periodos_trabalho_service.dart`, `receitas_service.dart`, `plataformas_service.dart`, forms em `lib/screens/form_*periodo*`, `periodo_turno_aberto_screen.dart`, aba em `veiculo_detalhe_screen.dart`

**Depende de:** ApiClient (JSON), RF-005 (aba Períodos), plataformas cadastradas (web Perfil)

**Endpoints (dupla checagem com backend FastAPI):**
- `GET /periodos-trabalho/veiculo/{id}` — listar
- `GET /periodos-trabalho/veiculo/{id}/aberto` — turno aberto
- `POST /periodos-trabalho/veiculo/{id}/iniciar` — iniciar
- `POST /periodos-trabalho/{id}/finalizar` — finalizar
- `PUT /periodos-trabalho/{id}` — editar (só fechado)
- `DELETE /periodos-trabalho/{id}` — excluir (só fechado)
- `GET/POST /receitas/periodo/{id}` — ganhos do turno
- `PUT/DELETE /receitas/{id}` — editar/excluir ganho
- `GET /plataformas/` — dropdown ganhos

**É usado por:** VeiculoDetalheScreen aba 3, dashboard/alertas após mudança de km

⚠️ Se alterar períodos → testar: 1 turno aberto por veículo, km fim > início, ganhos só com turno aberto, refresh km/alertas

**Risco:** 🟡 Médio

---

```
RF-001 → IMP-002, IMP-003, login_screen
RF-002 → IMP-004, IMP-005, dashboard_provider, main_shell
RF-003 → IMP-006, IMP-007, IMP-014, veiculos_tab_screen ✅
RF-003b/c → IMP-013, IMP-014 ✅
RF-004 → IMP-006, IMP-008, IMP-012 ✅
RF-004b/c → IMP-012, IMP-013 ✅
RF-005 → IMP-009, IMP-015 ✅
RF-006 → IMP-016 ✅
RF-007 → IMP-019 ✅
RF-008 → IMP-020, IMP-021 ✅
RF-009 → IMP-022, IMP-023 ✅
RF-010 → IMP-010, IMP-024 ✅
RF-006b → IMP-016, IMP-025, IMP-026 ✅
RF-007b → IMP-019, IMP-025, IMP-026 ✅
RF-010b → IMP-010, IMP-025 ✅
RF-011 → IMP-025, IMP-026 ✅
```

---

## ⚠️ Atenção — funcionalidades mais críticas

| Funcionalidade | Dependentes | Risco |
|----------------|-------------|-------|
| ApiClient + TokenStorage | Todo o app autenticado | 🔴 |
| VeiculosProvider / Service | Lista, FAB cadastro, swipe, dashboard | 🔴 |
| LoginProvider / AuthService | Entrada do app | 🔴 |
| DashboardService | Aba inicial pós-login | 🟡 |
| Categoria (model + API) | Cadastro, lista, edição bloqueante | 🟡 |

---

## Dupla checagem — regras cruzadas

| Aspecto | Mobile | Backend/API | Status |
|---------|--------|-------------|--------|
| Filtro tipo trabalho | `?tipo=trabalho` + filter client | GET /veiculos/ | ✅ |
| Placa obrigatória | Form validator + POST body | Schema POST | ✅ |
| Categoria obrigatória (novo) | Dropdown cadastro | POST validação | ✅ |
| Categoria legado null | Edição bloqueante | nullable DB | ✅ |
| Excluir veículo | DELETE + dialog | DELETE /veiculos/{id} | ✅ |
| Swipe direções | → editar+excluir, ← gestão | DECISOES.md | ✅ |
| Efeito descoberta swipe | Animação ao montar/trocar aba | PREFERENCES_MOBILE §Rede | ✅ |
