# Arquitetura do MVP

## Decisoes

- Stack: Flutter Web primeiro, Android depois.
- Estado: `provider` com `ChangeNotifier`, por ser o menor custo para o MVP.
- Backend alvo: Firebase Cloud Firestore.
- Login: sem autenticacao visivel. A sessao sera acessada por link/codigo.
- Implementacao atual: estado local em memoria para validar fluxo do MVP antes de ligar Firestore.
- Offline: fora do escopo. Pode existir cache basico do navegador no futuro.
- Design: Material 3 com tema medieval discreto e interface utilitaria.

## Estrutura

```txt
lib/
  app/
    rpg_app.dart
  features/
    rpg/
      models/
      state/
      views/
```

Hoje a feature `rpg` esta agrupada para acelerar o MVP. Quando Firebase entrar, o proximo passo natural e separar `data/` com repositories por dominio:

- `TableRepository`
- `CharacterRepository`
- `CombatRepository`
- `LibraryRepository`

## Fonte de regras

O vault `E:\Obsidian\RPG dos Guri` e a fonte oficial das regras, mas nao e dependencia runtime do app. Durante desenvolvimento, `tools/import_official_vault.dart` le os arquivos em `90 Fontes Oficiais` e gera JSONs versionados em `assets/data/official/`.

O Flutter carrega esses assets por `OfficialLibraryRepository`. Firestore continua responsavel apenas por estado de mesa: fichas, combate, pendencias e logs. Bibliotecas oficiais ficam locais no app ate haver necessidade real de edicao pelo banco.

Conteudos gerados:

- racas;
- classes;
- progressao de nivel;
- magias;
- rituais;
- poderes;
- armas, escudos, armaduras e acessorios;
- consumiveis e itens uteis;
- kits iniciais;
- monstros.

Regras ja consideradas:

- Vida maxima: `10 + Vigor`.
- Defesa:
  - Sem armadura: 10
  - Armadura leve: 11
  - Armadura media: 12
  - Armadura pesada: 13
  - Escudo: +1
- Dano de arma e magia nao soma atributo por padrao.
- Magia forte: 1 vez por combate.
- Ao chegar a 0 de Vida, o participante fica inconsciente.
- Dano trava em 0.
- Cura nao passa da Vida maxima.

## Modelo Firestore Sugerido

```txt
tables/{tableId}
  name
  code
  activeCombatId
  updatedAt

tables/{tableId}/characters/{characterId}
  identity
  attributes
  skills
  combat
  equipment
  powers
  inventory
  statuses

tables/{tableId}/combats/{combatId}
  active
  round
  updatedAt

tables/{tableId}/combats/{combatId}/participants/{participantId}
  type
  sourceCharacterId
  name
  currentHp
  maxHp
  defense
  damageSuggestion
  statuses
  defeatedState

tables/{tableId}/actionLogs/{logId}
  message
  createdAt
```

Bibliotecas globais futuras, se a mesa quiser editar regras pelo banco:

```txt
libraries/rpg-dos-guri/monsters/{monsterId}
libraries/rpg-dos-guri/items/{itemId}
libraries/rpg-dos-guri/powers/{powerId}
libraries/rpg-dos-guri/spells/{spellId}
libraries/rpg-dos-guri/classes/{classId}
```

## Proximo Passo Tecnico

1. Validar em sessao real mestre + jogador em dois celulares.
2. Ajustar dados oficiais importados conforme lacunas percebidas na mesa.
3. Decidir se bibliotecas oficiais continuam locais ou migram para Firestore.
