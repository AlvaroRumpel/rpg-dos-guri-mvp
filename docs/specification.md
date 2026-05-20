# Especificacao do Projeto - RPG dos Guri

## 1. Resumo

O RPG dos Guri e um web app/PWA em Flutter para auxiliar uma mesa pequena de RPG medieval/fantasia com regras leves. O app nao substitui o mestre, nao rola dados e nao decide acertos. Ele controla apenas estado de jogo: fichas, vida, combate, poderes usados, consumiveis, status, monstros e progressao basica.

Regra central do produto:

```txt
Toda automacao deve economizar contagem, nao decisao.
```

## 2. Objetivos do MVP

O MVP deve permitir:

- Mestre criar ou acessar uma mesa.
- Jogadores entrarem por link/codigo, sem conta.
- Jogadores solicitarem entrada.
- Mestre aprovar jogadores.
- Jogadores criarem ou editarem suas fichas apos aprovacao.
- Mestre iniciar combate.
- Mestre adicionar jogadores e monstros ao combate.
- Mestre controlar vida, cura, dano, status e estado dos participantes.
- Jogadores consultarem suas fichas no celular.
- Jogadores solicitarem uso de poderes ou itens na vida real; mestre confirma no app.
- Mestre finalizar combate e resetar usos por combate.
- Mestre subir personagens de nivel.

## 3. Fora do Escopo

Nao implementar no MVP:

- Rolagem automatica de dados.
- Decisao automatica de acerto.
- Aplicacao automatica de dano a partir de rolagem.
- Tabuleiro, mapa, grid ou tokens.
- Controle rigido de turno.
- Iniciativa obrigatoria.
- Chat interno.
- Gerador de encontros.
- Gerador de tesouro.
- Loja automatica.
- Exportacao para Obsidian.
- Importacao de arquivos.
- Campanhas completas.
- VTT.
- Autenticacao com email, Google ou senha.
- Sincronizacao offline complexa.

## 4. Usuarios

### 4.1 Mestre

O mestre deve conseguir:

- Entrar como mestre pelo link da mesa.
- Ver jogadores e solicitacoes pendentes.
- Aprovar jogadores.
- Criar fichas manualmente, se necessario.
- Editar informacoes emergencialmente.
- Iniciar e finalizar combate.
- Controlar rodada atual.
- Adicionar monstros da biblioteca.
- Controlar vida de jogadores, monstros, NPCs e objetos.
- Aplicar dano manual.
- Aplicar cura manual.
- Adicionar status.
- Alterar estado manual: ativo, inconsciente, derrotado ou morto.
- Subir personagem de nivel.
- Ver log informativo de acoes.

### 4.2 Jogador

O jogador deve conseguir:

- Entrar por link/codigo.
- Solicitar entrada na mesa.
- Acessar ficha apos aprovacao.
- Ver vida atual, vida maxima e defesa.
- Ver atributos e pericias.
- Ver poderes, magias e itens.
- Solicitar uso de poder/magia.
- Consultar itens consumiveis.
- Editar ficha fora de combate.

Durante combate, o jogador nao deve editar a ficha livremente.

## 5. Fluxos Principais

### 5.1 Entrada na Mesa

1. Usuario abre o app.
2. App mostra codigo da mesa.
3. Usuario escolhe:
   - Entrar como mestre.
   - Escolher ficha aprovada.
   - Solicitar entrada como jogador.

### 5.2 Solicitacao de Jogador

1. Jogador informa nome.
2. App registra solicitacao pendente.
3. Mestre ve solicitacao.
4. Mestre aprova.
5. App cria ficha inicial para o jogador.
6. Jogador passa a conseguir escolher a ficha.

### 5.3 Criacao/Edicao de Ficha

Campos basicos:

- Nome.
- Raca.
- Classe.
- Nivel.
- Conceito.
- Atributos.
- Pericias.
- Vida atual.
- Vida maxima calculada.
- Defesa calculada.
- Arma principal.
- Item secundario ou escudo.
- Armadura.
- Acessorios.
- Poderes e magias.
- Inventario.
- Moedas.
- Status.

Regras:

- Vida maxima = `10 + Vigor`.
- Ao mudar Vigor, muda somente vida maxima.
- Defesa e calculada por armadura + escudo.
- Acessorios especiais: limite de 2.
- Atributo nao pode passar de +6.
- Pericia nao pode passar de +3.

### 5.4 Combate

O combate deve ser simples e manual:

- Combate ativo.
- Rodada atual.
- Participantes.
- Status dos participantes.
- Acoes rapidas.
- Finalizar combate.

Nao ha ordem rigida de turno.

### 5.5 Participantes de Combate

Um participante pode ser:

- Jogador.
- Monstro.
- NPC aliado.
- NPC neutro.
- NPC inimigo.
- Objeto relevante.

Qualquer efeito pode mirar qualquer participante. O app nao restringe cura a aliados nem dano a inimigos.

### 5.6 Aplicar Dano

1. Mestre seleciona alvo.
2. Mestre informa dano final.
3. App reduz vida atual.
4. Vida nao fica negativa.
5. Se vida chega a 0, app marca como inconsciente.

### 5.7 Aplicar Cura

1. Mestre seleciona alvo.
2. Mestre informa cura final.
3. App aumenta vida atual.
4. Cura nao passa da vida maxima.
5. Se alvo estava inconsciente e recebe cura, volta para ativo.

### 5.8 Status e Condicoes

Status sao labels manuais. O app nao aplica automaticamente vantagem, desvantagem, bonus ou penalidade.

Campos:

- Nome.
- Tipo.
- Descricao.
- Duracao opcional.
- Visivel para jogador.

Tipos sugeridos:

- Condicao.
- Bonus.
- Penalidade.
- Vantagem.
- Desvantagem.
- Narrativo.

Exemplos:

- Caido.
- Cego.
- Preso.
- Protegido.
- Abencoado.
- Envenenado.

### 5.9 Poderes e Magias

Campos:

- Nome.
- Tipo.
- Descricao curta.
- Teste sugerido.
- Dano, cura ou efeito.
- Limite de uso.
- Status de uso.

Limites:

- Livre.
- Uma vez por combate.
- Uma vez por sessao.
- Uma vez por descanso longo.

Regra:

- Magias fortes sao uma vez por combate.
- Ao finalizar combate, resetar usos por combate.
- Nao resetar usos por sessao ou descanso longo.

### 5.10 Consumiveis

Consumiveis possuem quantidade.

Exemplo:

```txt
Pocao de Cura Simples x2
Efeito: 1d6 + 2 de Vida
```

Fluxo desejado:

1. Jogador pede para usar item na vida real.
2. Mestre solicita a rolagem fisica, se houver.
3. Valor rolado e informado manualmente.
4. App soma bonus fixo.
5. Mestre escolhe alvo.
6. App aplica efeito.
7. Quantidade reduz em 1.

## 6. Regras do Sistema RPG

Fonte oficial: vault `E:\Obsidian\RPG dos Guri`.

Regras ja incorporadas:

- Vida maxima inicial: `10 + Vigor`.
- Dano de armas nao soma atributo por padrao.
- Dano de magias nao soma atributo por padrao.
- Ao chegar a 0 de Vida, personagem cai inconsciente.
- Defesa:
  - Sem armadura: 10.
  - Armadura leve: 11.
  - Armadura media: 12.
  - Armadura pesada: 13.
  - Escudo: +1.
- Defesa maxima inicial recomendada: 14.
- Mago usa apenas 1 magia forte por combate.
- Personagens vao do nivel 1 ao 10.
- Nao ha XP numerico; progressao e por marcos.
- Nenhum atributo pode passar de +6.
- Nenhuma pericia pode passar de +3.

## 7. Biblioteca Inicial

### 7.1 Racas

- Humano.
- Elfo.
- Anao.
- Orc.

### 7.2 Classes

- Guerreiro.
- Ladino.
- Mago.
- Clerigo.

### 7.3 Itens

- Pocao de Cura Simples.
- Tocha.
- Corda.
- Kit de curandeiro simples.

### 7.4 Monstros

- Rato de Porao Gigante.
- Morcego Faminto.
- Goblin Covarde.
- Goblin Saqueador.
- Esqueleto Estalado.
- Esqueleto Armado.
- Bandido Simples.
- Cultista Iniciante.

## 8. Monstros

Campos da ficha de monstro:

- Nome.
- Categoria.
- Defesa.
- Vida padrao.
- Ataque sugerido.
- Dano sugerido.
- Movimento.
- Instinto.
- Habilidade especial.
- Descricao curta.

Ao adicionar multiplos monstros:

```txt
Goblin Covarde
Quantidade: 4

Resultado:
- Goblin Covarde 1
- Goblin Covarde 2
- Goblin Covarde 3
- Goblin Covarde 4
```

Cada monstro tem vida individual no MVP.

## 9. Progressao

Progressao faz parte do MVP.

Fluxo:

1. Mestre escolhe personagem.
2. Mestre aciona subir nivel.
3. App mostra novo nivel.
4. App adiciona habilidade conforme classe.
5. Se houver escolha, mestre/jogador escolhe opcao.
6. App valida limites.
7. App salva evolucao.

Regras:

- Mestre decide quando sobe de nivel.
- Mago escolhe magia simples de lista global.
- Habilidades por classe vem de tabela oficial.
- Bloquear atributo acima de +6.
- Bloquear pericia acima de +3.

## 10. Dados e Modelos

### 10.1 Enumeracoes

- `UserRole`: landing, master, player.
- `ParticipantType`: player, monster, npcAlly, npcNeutral, npcEnemy, object.
- `UsageLimit`: free, combat, session, longRest.
- `DefeatedState`: active, unconscious, defeated, dead.

### 10.2 Modelos Principais

- `RpgTable`.
- `CharacterSheet`.
- `PowerEntry`.
- `InventoryItem`.
- `StatusEntry`.
- `MonsterTemplate`.
- `CombatParticipant`.
- `CombatState`.

### 10.3 Estado Atual

O MVP atual usa estado local em memoria:

- `RpgSessionController`.
- `provider`.
- Dados seedados.

Esse estado sera substituido por Firestore na etapa online.

## 11. Firebase e Persistencia

Backend alvo:

- Firebase Hosting.
- Cloud Firestore.
- Sem login visivel.

Modelo sugerido:

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

Bibliotecas:

```txt
libraries/rpg-dos-guri/monsters/{monsterId}
libraries/rpg-dos-guri/items/{itemId}
libraries/rpg-dos-guri/powers/{powerId}
libraries/rpg-dos-guri/spells/{spellId}
libraries/rpg-dos-guri/classes/{classId}
```

## 12. Telas

### 12.1 Entrada

Mostra:

- Nome/codigo da mesa.
- Botao entrar como mestre.
- Lista de fichas aprovadas.
- Botao solicitar entrada.

### 12.2 Mestre

Mostra:

- Acoes principais.
- Solicitacoes pendentes.
- Combate ativo.
- Participantes.
- Fichas.
- Log informativo.

### 12.3 Jogador

Mostra:

- Ficha.
- Vida atual/maxima.
- Defesa.
- Poderes e magias.
- Itens.
- Status.
- Botao editar ficha fora de combate.

### 12.4 Combate

Mostra:

- Rodada.
- Jogadores.
- Monstros/NPCs/objetos.
- Vida.
- Defesa.
- Status.
- Estado manual.
- Acoes de dano, cura e status.

## 13. Requisitos de UX

- Interface mobile-first.
- Poucas telas.
- Acoes do mestre devem ser rapidas.
- Jogador deve consultar ficha no celular com pouca friccao.
- Vida de monstros nao deve ser visivel aos jogadores.
- Labels e status devem ser visuais e faceis de lembrar.
- Evitar formularios longos durante combate.
- Priorizar clareza sobre decoracao.
- Tema deve misturar fantasia medieval discreta com utilidade.

## 14. Requisitos Tecnicos

- Flutter Web primeiro.
- Android depois.
- Material 3.
- Provider para estado local inicial.
- Firebase no proximo passo.
- Porta padrao VS Code: `5173`.
- Launch principal: `RPG dos Guri - Edge`.

## 15. Comandos de Desenvolvimento

```powershell
cd F:\_geral\Projetos\rpg-dos-guri-mvp
flutter pub get
flutter run -d edge --web-port 5173
```

Configuracao Firebase futura:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

## 16. Roadmap

### MVP Local

- Estrutura Flutter.
- Telas principais.
- Estado local.
- Fluxos mestre/jogador.
- Controle manual de combate.
- Documentacao.

### MVP Online

- Configurar Firebase.
- Criar repositories Firestore.
- Trocar estado local por streams.
- Persistir mesa, fichas e combate.
- Publicar no Firebase Hosting.

### MVP 1.5

- Progressao guiada completa por classe.
- Biblioteca global completa de magias, poderes e itens.
- Historico melhor de consumiveis.
- Regras de validacao de ficha mais completas.
- Cache local de ultima ficha salva.

### Futuro

- Android build.
- Melhorias visuais.
- Agrupamento opcional de monstros.
- Auditoria simples de acoes.
- Regras Firestore mais restritivas, se houver necessidade.
