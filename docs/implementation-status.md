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
- Colecoes vazias do Firestore nao re-seedam personagens indevidamente.
- Finalizar combate marca o combate como inativo no Firestore.
- Arquivos base de Firebase Hosting e Firestore Rules criados.
- `flutter analyze` validado sem issues.
- `flutter build web` validado com sucesso.
- Deploy Firebase Hosting publicado em `https://rpgdosguri.web.app`.

## Parcialmente implementado

- Poderes/magias/itens oficiais: ficam locais em assets JSON; ainda nao ha persistencia global no Firestore.
- Mesa/codigo: criacao/entrada por codigo existe, mas ainda falta validacao manual em dispositivos reais.
- Equipamentos oficiais: a UI usa selecao oficial, mas fichas antigas com texto livre sao normalizadas quando editadas/carregadas.

## Fora do MVP local atual

- Validacao manual de persistencia Firestore em duas janelas/dispositivos.
- Validacao manual de tempo real entre celulares.
- Deploy Firebase Hosting.
- Cache local.
- Android build.
- Importacao/exportacao por usuario.
- Sincronizacao automatica com Obsidian em runtime.

## Proximas implementacoes recomendadas

1. Testar fluxo mestre + jogador em duas janelas.
2. Testar URL publicada em celulares reais.
3. Revisar dados importados do vault apos uso em mesa.
4. Decidir se bibliotecas oficiais devem migrar para Firestore.
5. Melhorar cache local de ultima ficha visualizada.
