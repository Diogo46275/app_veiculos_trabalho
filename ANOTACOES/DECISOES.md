# DECISOES.md — App Veículos Mobile

_Registro de decisões de arquitetura e produto._

_Última atualização: 31/05/2026_

---

## Stack

| Decisão | Escolha | Motivo |
|---------|---------|--------|
| Framework | Flutter (Dart 3.12+) | App mobile multiplataforma |
| Estado | `provider` ^6.1.5 | Documentado em `biblioteca/provider_flutter.md` |
| HTTP | `http` ^1.6.0 | Documentado em `biblioteca/http_dart.md` |
| Persistência JWT | `shared_preferences` ^2.5.5 | Documentado em `biblioteca/shared_preferences_flutter.md` |
| Swipe to Action | `flutter_slidable` ^4.0.3 | `Dismissible` nativo falha em listas com scroll; slidable equivalente funcional |
| API | REST existente (FastAPI) | Mesma base do web app |

## Escopo do app

- **Apenas veículos de trabalho** (`tipo: "trabalho"`) — filtro na API e client-side.
- Cadastro sempre com tipo fixo **Trabalho** (sem opção no formulário).
- **Placa obrigatória** no cadastro/edição mobile.

## Categoria física do veículo

- Campo API: `categoria` — valores: `moto`, `carro`, `van`, `caminhao`, `carreta`.
- Obrigatória no **POST** (novos veículos).
- Veículos legados sem categoria: **obrigar completar cadastro** antes de ver detalhes.
- Ícones e cores por categoria em `lib/models/categoria_veiculo.dart` (PADRAO_CORES).

## Navegação (validada)

- Bottom Bar: Dashboard | Veículos | Perfil + FAB central.
- Zona central **72px** vazia (`_fabSlotWidth = 72.0` em `main_shell.dart`).
- FAB `centerDocked` com `BottomAppBar` + notch — nunca sobrepõe ícones.

## Swipe to Action (veículos — layout validado pelo Diogo)

- Deslizar **direita** (→) → **Editar** (azul) + **Excluir** (vermelho) no mesmo lado.
- Deslizar **esquerda** (←) → **Gestão** (verde) → tela de detalhe com abas.
- Toque no item → mesma navegação que Gestão (detalhe).
- Widget: `VeiculoSwipeTile` (`flutter_slidable`).
- **Efeito de descoberta:** ~500ms ao montar lista; re-dispara ao trocar aba. Layout 3 ações validado via RF-005 (Gestão).

## Dashboard

- Endpoint principal: `GET /dashboard/`.
- Fallback se 404: combina `GET /dashboard/rentabilidade` + `GET /alertas/dashboard`.

## Tema

- Dark mode padrão (`AppTheme.dark`).
- Cores de `referencia/PADRAO_CORES.md` → `lib/theme/app_colors.dart`.
- **Locale:** `pt_BR` global (`AppLocalizacao`) — calendário, botões do sistema e Material em português.

## Navegação — atalho Dashboard

- Ícone `table_chart` no AppBar (`BotaoIrDashboard`) em telas secundárias e abas Veículos/Perfil.
- `NavegacaoProvider` controla índice da Bottom Bar; atalho fecha rotas empilhadas e vai à aba 0.
- Edição **obrigatória** (categoria pendente) não exibe o atalho — fluxo bloqueante preservado.

## API — paths das abas (dupla checagem)

Endpoints reais (FastAPI), **não** aninhados em `/veiculos/{id}/...`:
- `/abastecimentos/veiculo/{veiculo_id}`
- `/manutencoes/veiculo/{veiculo_id}`
- `/alertas/veiculo/{veiculo_id}`
- `/periodos-trabalho/veiculo/{veiculo_id}`

## Upload de anexos

- **RF-006** e **RF-007** validados **sem upload** na entrega original; upload em **RF-006b** / **RF-007b** — ✅ validados 31/05/2026.
- **RF-011 (múltiplos anexos):** backend tabela genérica `anexos` + `AnexoService`; API retorna `anexos_nf` / `anexos_garantia` / `anexos[]` com `id`, `nome_original`, `url`; colunas legadas mantidas; `DELETE /api/anexos/{id}`; máx. 5 anexos, 10 MB/arquivo; path `anexos/{usuario_id}/`.
- Multipart: vários campos `arquivo_nf` ou `arquivo_garantia`; PUT com `remover_anexo_ids`; mobile envia **sequencialmente** (1 arquivo/requisição) via `enviarAnexosSequencialmente`.
- Mobile: `SecaoAnexosFormulario` — multi-seleção; detalhe recarrega da API; editar lista todos os anexos.
- **Compressão (IMP-026):** câmera usa `ImagePicker` (1280px, q=72); galeria/arquivo passa por `comprimirImagemAnexoBytes()` — mesma regra antes do limite de upload (~1 MB nginx).
- **RF-010b:** foto perfil via `image_picker` → `POST /auth/perfil/foto` — ✅ validado 31/05/2026.

## Documentação

- **Fonte de verdade:** `ANOTACOES/` (este diretório).
- `base_compatilhada/ideias/veiculos_app_mobile.md` — briefing inicial; **não reflete estado atual**.
