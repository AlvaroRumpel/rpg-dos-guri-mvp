# Status de Implementacao do MVP

Este documento compara `docs/specification.md` com o estado atual do app Flutter.

## Implementado no MVP local

- Tema visual "pergaminho fantasia" centralizado em `RpgTheme`.
- Cores padronizadas para estados: ativo, inconsciente, derrotado e morto.
- Barras de vida com cor por faixa de risco.
- Dialog de configuracao de mesa com nome e codigo local.
- Geracao de codigo local `GURI-0000`.
- Entrada sem login.
- Entrada como mestre.
- Solicitacao de entrada por jogador.
- Aprovacao de jogador pelo mestre.
- Criacao de ficha inicial apos aprovacao.
- Edicao de ficha fora de combate.
- Edicao emergencial de ficha pelo mestre.
- Atributos e pericias editaveis.
- Bloqueio de atributo acima de +6.
- Bloqueio de pericia acima de +3.
- Vida maxima calculada por `10 + Vigor`.
- Defesa calculada por armadura + escudo.
- Limite de 2 campos de acessorio especial.
- Moedas.
- Combate ativo.
- Rodada manual.
- Adicionar jogadores ausentes ao combate.
- Adicionar monstros a partir da biblioteca.
- Editar vida, defesa e dano sugerido do monstro ao adicionar.
- Adicionar NPC aliado, NPC neutro, NPC inimigo ou objeto relevante.
- Aplicar dano manual.
- Aplicar cura manual.
- Vida trava em 0.
- Cura nao passa da vida maxima.
- Ao chegar a 0, participante fica inconsciente.
- Estados manuais: ativo, inconsciente, derrotado, morto.
- Status com nome, tipo, descricao, duracao e visibilidade para jogador.
- Remocao de status.
- Uso de consumivel pelo mestre com valor rolado manualmente.
- Reducao de quantidade de consumivel.
- Log informativo de acoes.
- Reset de poderes por combate ao finalizar combate.
- Reset manual de poderes por sessao e por descanso longo.
- Fila persistida de pedidos de uso de poder/magia para aprovacao do mestre.
- Arquivamento e restauracao de fichas pelo mestre.
- Jogador ve combate sem vida de monstros.
- Importador oficial do vault em `tools/import_official_vault.dart`.
- Assets JSON oficiais em `assets/data/official/`.
- Biblioteca oficial carregada por `OfficialLibraryRepository`.
- Biblioteca oficial de racas, classes, progressao, magias, rituais, poderes, equipamentos, itens, kits e monstros.
- Ficha com selecao oficial de raca, classe, arma, secundario/escudo, armadura e ate 2 acessorios.
- Editor de inventario para adicionar item oficial da biblioteca, ajustar quantidade e remover item.
- Progressao guiada local ate nivel 10.
- Mago escolhe magia simples/forte conforme o novo nivel.
- Contratos de repositories preparados para Firestore.
- Inicializacao Firebase no app com fallback local.
- Repositories Firestore e mappers criados para mesa, fichas, combate e logs.
- Sincronizacao Firestore conectada ao controller atual.
- Pendencias de aprovacao persistidas no documento da mesa.
- Entrada/criacao de mesa por codigo na tela inicial.
- Deep link de mesa por `?mesa=GURI-1234`.
- Cache local de ultima mesa e ultima ficha selecionada.
- PIN domestico de mestre, salvo como hash local por mesa.
- Colecoes vazias do Firestore nao re-seedam personagens indevidamente.
- Finalizar combate marca o combate como inativo no Firestore.
- Arquivos base de Firebase Hosting e Firestore Rules criados.
- Notas do jogador, notas do mestre, historia e NPCs customizados.
- Mencoes por `@nome` nos campos do mestre, com jogador ativo priorizado antes de NPC homonimo.
- Card de combate com arma ativa por participante e persistencia da escolha.
- `flutter analyze` validado sem issues.
- `flutter build web` validado com sucesso.
- Deploy Firebase Hosting publicado em `https://rpgdosguri.web.app`.
- QA manual em celulares reais e instalacao PWA reportados como concluidos em 2026-06-04.
- Rodada inicial de performance publicada em Hosting, com instrumentacao debug-only, reducao de rebuilds por Provider e cache de listas filtradas.
- Segunda rodada de performance publicada em Hosting, removendo blur real de modais, adicionando secoes lazy no formulario de ficha e isolando pintura de landing/cards.

## Parcialmente implementado

- Poderes/magias/itens oficiais: decisao atual e manter somente assets JSON, sem CRUD Firestore.
- Mesa/codigo: criacao/entrada por codigo existe e ja teve validacao manual em dispositivos reais.
- Equipamentos oficiais: a UI usa selecao oficial, mas fichas antigas com texto livre sao normalizadas quando editadas/carregadas.
- PIN de mestre: barreira domestica contra acesso casual; nao e autenticacao forte contra usuario malicioso.
- Performance: duas rodadas aplicadas; ainda precisa comparacao manual pos-deploy com Chrome Performance/DevTools e mobile real.

## Fora do MVP local atual

- Android build.
- Importacao/exportacao por usuario.
- Sincronizacao automatica com Obsidian em runtime.
- Profiling manual detalhado de long tasks e quedas de frame em mobile/web desktop.

## Proximas implementacoes recomendadas

1. Repetir cenarios de `docs/performance-baseline-2026-06-04.md` em mobile real e Chrome Performance.
2. Comparar o novo trace contra `Trace-20260604T185714.json`, especialmente landing, PIN, cards e formulario de ficha.
3. Se ainda houver travas perceptiveis, tratar card mobile/listas grandes na proxima rodada sem simplificar identidade visual.
4. Revisar dados importados do vault apos uso em mesa.
5. Manter Android build, importacao/exportacao, Obsidian runtime e autenticacao forte fora da fila imediata.
