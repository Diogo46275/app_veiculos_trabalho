# FLUXOS.md — App Veículos Mobile

_Diagramas Mermaid dos fluxos principais._

_Última atualização: 30/05/2026_

---

## App — visão geral

```mermaid
flowchart TD
    A[LoginScreen] -->|JWT ok| B[MainShell]
    B --> C[DashboardScreen]
    B --> D[VeiculosTabScreen]
    B --> E[PerfilTabScreen]
    B -->|FAB| F[Menu: Novo veículo / Abastecimento]
    F --> G[CadastroVeiculoScreen]
    F -->|RF-006| H[SnackBar Em breve]
    G -->|salvar| D
```

## RF-001 — Login

```mermaid
flowchart LR
    A[Email + Senha] --> B[AuthService POST /auth/login]
    B --> C{access_token?}
    C -->|sim| D[TokenStorage.save]
    D --> E[Navigator → MainShell]
    C -->|não| F[Erro no formulário]
```

## RF-002 — Dashboard

```mermaid
flowchart LR
    A[DashboardProvider.load] --> B[GET /dashboard/]
    B -->|404| C[Fallback rentabilidade + alertas]
    B -->|200| D[DashboardData]
    C --> D
    D --> E[Cards km / economia / manutenções]
    E --> F[Pull-to-refresh]
```

## RF-003 / RF-003b — Lista + Swipe

```mermaid
flowchart TD
    A[VeiculosTabScreen] --> B[GET /veiculos/?tipo=trabalho]
    B --> C[Lista VeiculoSwipeTile]
    C -->|toque ou swipe ← Gestão| D{categoria ok?}
    D -->|não| E[EditarVeiculoScreen obrigatório]
    D -->|sim| F[VeiculoDetalheScreen]
    C -->|swipe → Editar| G[EditarVeiculoScreen]
    C -->|swipe → Excluir| H[AlertDialog]
    H -->|confirmar| I[DELETE /veiculos/id]
    I --> J[SnackBar + refresh dashboard]
```

## RF-004 — Cadastro

```mermaid
flowchart LR
    A[Formulário] --> B{validação}
    B -->|ok| C[POST /veiculos/]
    C --> D[tipo=trabalho + categoria + placa]
    D --> E[Refresh lista + dashboard]
    E --> F[SnackBar + volta aba Veículos]
```

## RF-004b / RF-004c — Categoria

```mermaid
flowchart TD
    A[Veículo sem categoria] --> B[precisaCompletarCategoria=true]
    B --> C[Borda vermelha + ícone aviso]
    B --> D[Toque → Editar bloqueante PopScope]
    D --> E[PUT /veiculos/id com categoria]
    E --> F[Lista normal + detalhe liberado]
```

## RF-005 — Detalhe com abas

```mermaid
flowchart TD
    A[Toque veículo] --> B[VeiculoDetalheScreen]
    B --> C[Resumo header]
    B --> D[TabBar 4 abas]
    D --> E[GET abastecimentos/veiculo/id]
    D --> F[GET manutencoes/veiculo/id]
    D --> G[GET alertas/veiculo/id]
    D --> H[GET periodos-trabalho/veiculo/id]
    E --> I[Lista cards ou empty]
    F --> I
    G --> I
    H --> I
    B -->|editar| J[EditarVeiculoScreen]
    J -->|pop Veiculo| C
```

## RF-007 — Manutenções CRUD

```mermaid
flowchart TD
    A[Aba Manutenções] --> B[FAB + ou botão empty]
    B --> C[GET /tipos-manutencao/]
    C --> D[FormManutencaoScreen]
    D --> E{validação}
    E -->|ok| F[POST ou PUT multipart /manutencoes/]
    F --> G[Refresh lista + km veículo]
    A --> H[Editar card]
    H --> D
    A --> I[Excluir + AlertDialog]
    I --> J[DELETE /manutencoes/id]
    J --> G
```

## RF-008 — Alertas CRUD + ciclo de vida (badge / notificação)

```mermaid
stateDiagram-v2
    [*] --> OK: criar / reset
    OK --> Proximo: km ou data entra na margem
    Proximo --> Vencido: km ou data atinge limite
    Vencido --> OK: reset manual
    OK --> Inativo: toggle off
    Proximo --> Inativo: toggle off
    Vencido --> Inativo: toggle off
    Inativo --> OK: toggle on + recalcular limite

    note right of OK
      Badge = 0
      Fora da central
    end note
    note right of Proximo
      Badge +1
      Notificação (1x por status)
    end note
    note right of Vencido
      Badge +1
      Notificação prioridade alta
    end note
```

```mermaid
flowchart TD
    A[Aba Alertas] --> B[FAB + ou botão empty]
    B --> C[FormAlertaScreen]
    C --> D{validação}
    D -->|ok| E[POST ou PUT JSON /alertas/]
    E --> F[Refresh lista]
    F --> G[AlertasProvider.sincronizar]
    G --> H[Badge + card Dashboard + cortina se vencido/próximo]
    A --> I[Resetar + confirmação]
    I --> J[POST /alertas/id/reset]
    J --> K[Status OK se fora da margem]
    K --> L[aposResetAlerta: cancel notif + GET dashboard]
    L --> M[Badge deve ir a 0]
    A --> N[Abastecimento sobe km]
    N --> O[AlertasProvider.sincronizar notificar]
```

## RF-009 — Turnos de trabalho + ganhos

```mermaid
flowchart TD
    A[Aba Períodos] --> B{turno aberto?}
    B -->|não| C[FAB / Iniciar turno]
    C --> D[POST /periodos-trabalho/veiculo/id/iniciar]
    D --> E[PeriodoTurnoAbertoScreen]
    B -->|sim| E
    E --> F[+ Ganho]
    F --> G[POST /receitas/periodo/id]
    E --> H[Finalizar turno]
    H --> I[POST /periodos-trabalho/id/finalizar]
    I --> J[Histórico encerrado]
    A --> K[Editar turno fechado]
    K --> L[PUT /periodos-trabalho/id]
    A --> M[Excluir + AlertDialog]
    M --> N[DELETE /periodos-trabalho/id]
    D --> O[Refresh km veículo + alertas]
    I --> O
```

## RF-008 — Alertas CRUD (legado resumido)

## MainShell — Bottom Bar + FAB

```mermaid
flowchart LR
    subgraph bar [BottomAppBar]
        D1[Dashboard]
        D2[Veículos]
        SLOT[72px vazio]
        D3[Perfil]
    end
    FAB[FAB centerDocked] --- SLOT
```

## Navegação secundária (stack)

```mermaid
flowchart TD
    A[MainShell IndexedStack] --> B[push CadastroVeiculoScreen]
    A --> C[push EditarVeiculoScreen]
    A --> D[push VeiculoDetalheScreen]
    B -->|pop| A
    C -->|pop| A
    D -->|pop| A
```
