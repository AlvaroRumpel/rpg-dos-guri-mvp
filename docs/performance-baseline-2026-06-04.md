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

## Trace pos-segunda rodada

Arquivo analisado:

```text
C:\Users\alvar\Downloads\Trace-20260604T223509.json
```

Comparacao com `Trace-20260604T185714.json`:

- Pior long task: `519 ms` -> `368 ms`.
- Long tasks acima de `300 ms`: `56` -> `10`.
- Pior interacao Chrome: `690 ms` -> `488 ms`.
- Interacoes acima de `300 ms`: `49` -> `7`.
- Pior evento de teclado: `459 ms` -> `96 ms`.
- Sends Google/Firestore: `29` -> `17`.
- Long `GPUTask` somado: `17.9 s` -> `13.3 s`.

Observacao:

- O total bruto de long tasks `>=50 ms` subiu no trace novo, mas o trace tambem tem mais eventos/interacoes. O indicador mais relevante foi a queda forte nos piores travamentos.
- Screenshots dos piores intervalos indicaram gargalos remanescentes em landing/PIN, entrada no mestre, cards de ficha e formulario de ficha com varias secoes/dropdowns abertos.
- Firestore/rede nao parece ser o gargalo principal nesta etapa.

Proxima rodada sugerida, se ainda houver travamento perceptivel:

- Card mobile/listas com montagem mais leve, mantendo visual.
- Formulario de ficha com politica mobile para reduzir secoes pesadas simultaneamente abertas.
- Mais isolamento de pintura na landing/PIN se o trace continuar apontando esse fluxo.
