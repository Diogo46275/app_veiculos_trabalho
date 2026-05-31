# Veículos App — Flutter Mobile

App mobile para gestão de **veículos de trabalho**. Consome a API REST em `https://bytes-techus.com.br/veiculos/api/`.

## Documentação do projeto

| Arquivo | Conteúdo |
|---------|----------|
| [ANOTACOES/VALIDADOS.md](../ANOTACOES/VALIDADOS.md) | RFs e IMPs — o que está validado |
| [ANOTACOES/PENDENCIAS.md](../ANOTACOES/PENDENCIAS.md) | O que falta fazer |
| [ANOTACOES/FLUXOS.md](../ANOTACOES/FLUXOS.md) | Diagramas Mermaid |
| [ANOTACOES/DECISOES.md](../ANOTACOES/DECISOES.md) | Decisões de arquitetura |
| [MAPA_DIRETORIOS.md](../MAPA_DIRETORIOS.md) | Estrutura de pastas |

Preferências mobile: `base_compatilhada/referencia/PREFERENCES_MOBILE.md`

## Stack

- Flutter / Dart 3.12+
- **provider** — estado
- **http** — API REST
- **shared_preferences** — JWT
- **flutter_slidable** — swipe editar/excluir na lista

## Estrutura `lib/`

```
config/          → api_config.dart
models/          → veiculo, categoria_veiculo, dashboard_data, perfil
providers/       → login, dashboard, veiculos
services/        → api_client, auth, token_storage, veiculos, dashboard, perfil
screens/         → login, main_shell, dashboard, veiculos, cadastro, editar, detalhe, perfil
screens/widgets/ → veiculo_list_tile, veiculo_swipe_tile, dashboard_indicator_card
theme/           → app_colors, app_theme (dark)
```

## Funcionalidades atuais

| RF | Status |
|----|--------|
| Login JWT | ✅ Validado |
| Dashboard + Bottom Bar + FAB | ✅ Validado |
| Lista veículos (trabalho) | ✅ Validado |
| Cadastro (placa + categoria) | ✅ Validado |
| Editar / excluir (swipe) | 🧪 Implementado |
| Categoria física + legados | 🧪 Implementado |
| Detalhes com abas | ⏳ Placeholder |
| Perfil | ⏳ Placeholder |

## Comandos

```powershell
cd veiculos_app
flutter pub get
flutter run
flutter analyze
flutter test
```

## API (principais endpoints)

- `POST /auth/login` — login
- `GET /dashboard/` — dashboard (fallback se 404)
- `GET /veiculos/?tipo=trabalho` — lista
- `POST /veiculos/` — cadastro
- `PUT /veiculos/{id}` — editar
- `DELETE /veiculos/{id}` — excluir

Desenvolvido por **BYTES-TECHUS**.
