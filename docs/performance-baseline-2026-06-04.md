# Performance Baseline - 2026-06-04

## Alvo

- URL publicada: `https://rpgdosguri.web.app`
- Foco da rodada: lentidao de interacao em mobile e web desktop.

## Medicao automatizada disponivel nesta sessao

- Requisicao HTTP inicial para a URL publicada.
- Antes da rodada: HTTP `200`, `931 ms`.
- Depois do deploy final: HTTP `200`, `698 ms`.
- Depois da segunda rodada visual/performance: HTTP `200`, `1036 ms`.
- Tamanho do HTML inicial: `1603 bytes`.

## Limites desta medicao

- O Browser plugin nao disponibilizou ferramenta de navegacao/performance nesta sessao.
- Long tasks, quedas de frame e Timeline do Chrome precisam ser conferidos manualmente no Chrome Performance/DevTools.
- Mobile real precisa repetir os cenarios abaixo apos o deploy da rodada.

## Cenarios para comparar antes/depois

- Entrar como mestre.
- Trocar abas do mestre.
- Abrir biblioteca e alternar abas internas.
- Buscar na biblioteca.
- Abrir modal grande de biblioteca/inventario/ficha.
- Alternar arma no combate.
- Aplicar dano/cura e mudar rodada.
- Criar/editar nota, ponto de historia e NPC.
- Entrar como jogador e trocar abas.

## Marcadores de Timeline adicionados

- `rpg.official_library.load`
- `rpg.firestore.remote_apply`
- `rpg.firestore.persist_changes`
- `rpg.master.tab_change`
- `rpg.player.tab_change`
- `rpg.library.tab_change`
- `rpg.library.search`
- `rpg.library.build`
- `rpg.dialog.open`

## Otimizacoes aplicadas

- Instrumentacao de Timeline fora de release para biblioteca, Firestore, dialogs, busca e troca de abas.
- Cache de personagens ativos/arquivados no controller.
- Troca de `context.watch` amplo por `context.select`/`context.read` em landing, mestre, jogador e editor de inventario.
- Cache de listas filtradas em notas do jogador, notas do mestre, historia e NPCs.
- Deploy de Hosting publicado apos `flutter analyze`, `flutter test`, `flutter build web` e `git diff --check`.

## Segunda rodada aplicada em 2026-06-04

- Removido blur real (`BackdropFilter`) de `RpgModal`.
- Painel de modal isolado com `RepaintBoundary`.
- Criado `RpgExpandableFormSection`, mantendo visual de painel fantasia e montando conteudo da secao apenas quando expandida.
- `_showCharacterForm` passou a abrir por padrao apenas Identidade e Combate.
- Secoes Atributos, Pericias, Acessorios e Grimorio do mago ficam lazy.
- Grimorio do mago abre automaticamente ao trocar ficha evoluida para classe Mago.
- `DropdownMenuItem` estaveis do formulario de ficha sao pre-calculados fora do `StatefulBuilder`.
- Landing e `CharacterCard` receberam `RepaintBoundary` em blocos pesados, sem simplificacao visual.
- Deploy Hosting publicado na versao `projects/880074034144/sites/rpgdosguri/versions/cb11766f9d762b42`.
