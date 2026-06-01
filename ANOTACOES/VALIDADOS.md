# VALIDADOS.md — App Veículos Mobile

_Registro de 🏁 RFs e ⚙️ IMPs. RFs só entram como ✅ após validação explícita do Diogo._

_Última atualização: 01/06/2026 (FIN-002 validado)_

---

## 🏁 Resultados Finais (RF)

| ID | Resultado Final | Status | Teste de aceite | Depende de |
|----|----------------|--------|-----------------|------------|
| RF-001 | Login email/senha → JWT → Home | ✅ Validado | Logar e ir para shell principal | IMP-001, IMP-002, IMP-003 |
| RF-002 | Dashboard com indicadores (km, economia, alertas) | ✅ Validado | Abrir app logado e ver cards | IMP-004, IMP-005 |
| RF-003 | Lista de veículos de trabalho | ✅ Validado | Ver veículos na aba Veículos | IMP-006, IMP-007 |
| RF-004 | Cadastro de veículo (tipo fixo trabalho, placa obrigatória, categoria) | ✅ Validado | FAB → Novo veículo → aparece na lista | IMP-006, IMP-008 |
| RF-005 | Detalhes completos do veículo + abas | ✅ Validado | Toque/Gestão → resumo + abas com dados da API | IMP-009, IMP-015 |
| RF-006 | Abastecimentos — listar, cadastrar, editar, excluir | ✅ Validado | Gestão > Abastecimentos > CRUD completo | IMP-016 |
| RF-007 | Manutenções — listar, cadastrar, editar, excluir | ✅ Validado | Gestão > Manutenções > CRUD completo | IMP-019 |
| RF-008 | Alertas — listar, cadastrar, editar, excluir, resetar | ✅ Validado | Gestão > Alertas > CRUD + reset + notificações + antecedência | IMP-020, IMP-021 |
| RF-009 | Períodos de trabalho — turnos + ganhos por plataforma | ✅ Validado | Gestão > Períodos > iniciar/finalizar + ganhos + editar/excluir | IMP-022, IMP-023 |
| RF-010 | Perfil editável + plataformas + tipos manutenção + sair | ✅ Validado | Aba Perfil > dados, senha, CRUD auxiliares, logout | IMP-010, IMP-024 |

### RFs estendidos (pós-RF-004) — fase 2b ✅

| ID | Resultado Final | Status | Teste de aceite |
|----|----------------|--------|-----------------|
| RF-004b | Categoria física (moto/carro/van/caminhão/carreta) | ✅ Validado | Cadastrar com categoria; ícone/cor na lista |
| RF-004c | Veículo legado sem categoria → completar cadastro | ✅ Validado | Toque abre edição bloqueante |
| RF-003b | Swipe to Action (editar/excluir) + efeito descoberta | ✅ Validado | Deslizar → Editar/Excluir; animação ao entrar/trocar aba |
| RF-003c | Editar veículo existente | ✅ Validado | Swipe editar ou ícone na tela detalhe |

### RFs estendidos — upload

| ID | Resultado Final | Status | Teste de aceite |
|----|----------------|--------|-----------------|
| RF-006b | Upload NF em abastecimentos (múltiplos) | ✅ Validado | Várias NFs > salvar > detalhe/edition listam e abrem cada anexo |
| RF-007b | Upload NF + garantia em manutenções (múltiplos) | ✅ Validado | Várias NFs/garantias > detalhe > abrir anexos individualmente |
| RF-010b | Upload foto de perfil | ✅ Validado | Perfil > Enviar foto > avatar atualiza; JPG/PNG até 2 MB |
| RF-011 | Múltiplos anexos por registro (NF/garantia) | ✅ Validado | Até 5 anexos; câmera e galeria/arquivo; produção `bytes-techus.com.br` |

### Produto financeiro (FIN — doc SaaS)

| ID | Resultado Final | Status | Teste de aceite |
|----|----------------|--------|-----------------|
| FIN-001 | Categorias de despesa por veículo (nome + ícone, seed padrão) | ✅ Validado | Detalhe veículo → categorias → 6 sugeridas + CRUD |
| FIN-002 | Despesa genérica (categoria, data, valor, km, descrição) | ✅ Validado | Aba Despesas → registrar → listar → editar/excluir; dashboard rentabilidade |
| FIN-003 | Anexos em despesa (até 5 comprovantes, câmera/galeria) | ⏳ Aguardando validação | Form/detalhe despesa → anexar → abrir → remover → excluir despesa limpa anexos |

---

## ⚙️ Implementações (IMP)

| ID | Descrição | Arquivo(s) | RF servido |
|----|-----------|------------|------------|
| IMP-001 | Config URL API | `lib/config/api_config.dart` | RF-001+ |
| IMP-002 | Auth POST login | `lib/services/auth_service.dart` | RF-001 |
| IMP-003 | Token JWT SharedPreferences | `lib/services/token_storage.dart` | RF-001 |
| IMP-004 | ApiClient (GET/POST/PUT/DELETE + Bearer) | `lib/services/api_client.dart` | Todos |
| IMP-005 | Dashboard service + fallback 404 | `lib/services/dashboard_service.dart` | RF-002 |
| IMP-006 | Veículos service (listar/criar/atualizar/excluir) | `lib/services/veiculos_service.dart` | RF-003, RF-004 |
| IMP-007 | VeiculosProvider | `lib/providers/veiculos_provider.dart` | RF-003, RF-004 |
| IMP-008 | CadastroVeiculoScreen | `lib/screens/cadastro_veiculo_screen.dart` | RF-004 |
| IMP-009 | VeiculoDetalheScreen (abas + resumo) | `lib/screens/veiculo_detalhe_screen.dart` | RF-005 |
| IMP-015 | VeiculoModulosService + models abas | `lib/services/veiculo_modulos_service.dart`, `lib/models/*` | RF-005 |
| IMP-016 | Abastecimentos CRUD mobile | `lib/services/abastecimentos_service.dart`, `form_abastecimento_screen.dart` | RF-006 |
| IMP-017 | Validação centralizada + testes | `lib/validacao/*`, `test/validacao/*` | RF-004, RF-006, RF-001 |
| IMP-018 | Locale pt_BR + atalho Dashboard | `app_localizacao.dart`, `navegacao_provider.dart`, `botao_ir_dashboard.dart` | UX global |
| IMP-019 | Manutenções CRUD mobile | `manutencoes_service.dart`, `tipos_manutencao_service.dart`, `form_manutencao_screen.dart` | RF-007 |
| IMP-020 | Alertas CRUD mobile + reset | `alertas_service.dart`, `form_alerta_screen.dart` | RF-008 |
| IMP-021 | Notificações alertas (shade + badge + central + background) | `notificacoes_alerta_service.dart`, `central_alertas_screen.dart`, `alertas_provider.dart`, `alertas_background.dart` | RF-008 |
| IMP-022 | Turnos de trabalho CRUD mobile | `periodos_trabalho_service.dart`, `form_iniciar/finalizar/editar_periodo_screen.dart`, `periodo_turno_aberto_screen.dart` | RF-009 |
| IMP-023 | Ganhos (receitas) por plataforma no turno | `receitas_service.dart`, `plataformas_service.dart`, `form_receita_screen.dart` | RF-009 |
| IMP-010 | PerfilTabScreen (dados, senha, plataformas, tipos, logout) | `perfil_tab_screen.dart`, `perfil_service.dart` | RF-010 |
| IMP-024 | CRUD plataformas/tipos no perfil mobile | `plataformas_service.dart`, `tipos_manutencao_service.dart` | RF-010 |
| IMP-025 | Upload multipart (NF, garantia, foto) + múltiplos anexos | `api_client.dart`, `seletor_arquivo.dart`, `upload_anexos_sequencial.dart`, `secao_anexos_formulario.dart`, telas detalhe/form | RF-006b, RF-007b, RF-010b, RF-011 |
| IMP-026 | Compressão de imagens na galeria/arquivo (paridade câmera) | `comprimir_imagem_anexo.dart`, `seletor_arquivo.dart` | RF-006b, RF-007b, RF-011 |
| FIN-IMP-001 | Categorias despesa API + tela | `categorias_despesa_service.dart`, `categorias_despesa_screen.dart` | FIN-001 |
| FIN-IMP-002 | Despesas CRUD API + aba no veículo | `despesas_service.dart`, `form_despesa_screen.dart`, `veiculo_detalhe_screen.dart` | FIN-002 |
| FIN-IMP-003 | Anexos em despesa (multipart + SecaoAnexos) | `entidade_tipo=despesa`, `form_despesa_screen.dart`, `detalhe_despesa_screen.dart` | FIN-003, RF-011 |
| IMP-011 | MainShell (Bottom Bar + FAB) | `lib/screens/main_shell.dart` | RF-002, RF-003 |
| IMP-012 | CategoriaVeiculo enum + visual | `lib/models/categoria_veiculo.dart` | RF-004b |
| IMP-013 | EditarVeiculoScreen | `lib/screens/editar_veiculo_screen.dart` | RF-003c, RF-004c |
| IMP-014 | VeiculoSwipeTile (slidable + descoberta) | `lib/screens/widgets/veiculo_swipe_tile.dart` | RF-003b |

---

## Histórico de validações

| Data | ID | Quem validou | Observação |
|------|-----|--------------|------------|
| — | RF-001 | Diogo | Login JWT |
| — | RF-002 | Diogo | Dashboard + Bottom Bar + FAB |
| — | RF-003 | Diogo | Lista veículos trabalho |
| — | RF-004 | Diogo | Cadastro; depois placa obrigatória |
| 30/05/2026 | RF-003b | Diogo | Swipe editar/excluir + efeito descoberta ao trocar abas |
| 30/05/2026 | RF-003c | Diogo | Editar via swipe ou botão no detalhe |
| 30/05/2026 | RF-004b | Diogo | Categoria no cadastro + ícones/cores na lista |
| 30/05/2026 | RF-004c | Diogo | Veículo legado → edição bloqueante |
| 30/05/2026 | RF-005 | Diogo | Gestão: resumo + 4 abas, pull-to-refresh, editar, destaque abas |
| 30/05/2026 | RF-006 | Diogo | CRUD abastecimentos + validação inputs + pt-BR + atalho Dashboard |
| 30/05/2026 | RF-007 | Diogo | CRUD manutenções (sem upload — RF-007b futuro) |
| 30/05/2026 | RF-008 | Diogo | CRUD alertas + antecedência + badge/central/notificações + ciclos reset/km |
| 30/05/2026 | RF-009 | Diogo | Turnos iniciar/finalizar + ganhos por plataforma + editar/excluir + km/alertas |
| 30/05/2026 | RF-010 | Diogo | Perfil: dados, senha, plataformas, tipos manutenção, logout |
| 31/05/2026 | RF-006b | Diogo | Múltiplas NFs abastecimento; detalhe e editar listam todos os anexos |
| 31/05/2026 | RF-007b | Diogo | Múltiplas NFs/garantias manutenção; abrir anexos no detalhe |
| 31/05/2026 | RF-010b | Diogo | Foto de perfil via galeria |
| 31/05/2026 | RF-011 | Diogo | Múltiplos anexos (máx. 5); upload sequencial; API produção OK; compressão galeria = câmera |
| 01/06/2026 | FIN-001 | Diogo | Categorias por veículo + seed padrão |
| 01/06/2026 | FIN-002 | Diogo | CRUD despesas na aba Despesas; itens 1–5 do checklist (incl. rentabilidade) |

**Escopo mobile principal:** RF-001 a RF-010 ✅ — concluído e validado.

**Upload e anexos:** RF-006b, RF-007b, RF-010b, RF-011 ✅ — validados.
