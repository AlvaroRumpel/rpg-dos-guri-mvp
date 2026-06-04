# Checklist Manual de QA

Use este roteiro antes de uma sessao real.

## Rodada 2026-06-04 - Biblioteca, Combate, Notas, Historia e NPCs

- [ ] 1. Biblioteca: abrir itens, equipamentos e monstros e confirmar campos uteis como Como funciona, Poder/Efeito, Historia, Aparencia, Uso em cena, Recompensas e Fonte quando houver conteudo.
- [ ] 2. Combate: adicionar monstro oficial, clicar no card e confirmar modal completo do monstro.
- [ ] 3. Combate: adicionar participante customizado e clicar no card; confirmar resumo basico sem erro.
- [ ] 4. Combate: clicar em jogador e confirmar resumo da ficha com vida, defesa, raca, classe, armas, acessorios, inventario, status e poderes.
- [ ] 5. Combate: confirmar que todos os poderes do jogador aparecem como usado/disponivel.
- [ ] 6. Ficha: editar ficha sem acessorios e salvar; confirmar que `Anel da Sorte` nao e preenchido automaticamente.
- [ ] 7. Ficha: escolher acessorios manualmente, salvar e reabrir; confirmar que so os escolhidos aparecem.
- [ ] 8. Jogador: alternar entre arma principal e secundaria e conferir dano; se secundaria for escudo, conferir bonus de defesa em vez de dano.
- [ ] 9. Jogador: criar, editar e excluir notas; confirmar ordenacao por data mais recente.
- [ ] 10. Jogador: pesquisar nas proprias notas por titulo e corpo.
- [ ] 11. Mestre: criar, editar e excluir notas; confirmar ordenacao por data mais recente.
- [ ] 12. Mestre: pesquisar nas notas do mestre.
- [ ] 13. Mestre/Historia: criar, editar, remover e reordenar pontos-chave/ideias.
- [ ] 14. Mestre/Historia: pesquisar pontos por titulo, descricao e status.
- [ ] 15. Mestre/NPCs: criar, editar, abrir detalhes e excluir NPC customizado com nome, raca, ocupacao, aparencia, descricao, personalidade, objetivo, vinculo e observacoes.
- [ ] 16. Links: em nota/ideia, escrever `@NomeDoJogador` e `@NomeDoNPC`; clicar nos links e confirmar abertura do resumo correto.
- [ ] 17. Links duplicados: quando jogador e NPC tiverem mesmo nome, confirmar que `@nome` abre primeiro o jogador ativo.
- [ ] 18. Persistencia: recarregar a pagina e confirmar que notas, historia, NPCs, links textuais e combate persistem.
- [ ] 19. Responsividade: repetir os fluxos principais em largura compacta e expandida sem overflow.

Deploy somente se todos os itens acima forem aprovados, alem de `flutter analyze`, `flutter build web`, `git diff --check` e code review sem bloqueadores.

## Rodada pos-QA - Combate, mencoes e reordenacao

- [ ] 1. Combate: no card de cada jogador, alternar arma principal/secundaria pelo botao do proprio card.
- [ ] 2. Combate: confirmar que o card mostra arma atual, dano ou bonus de escudo, atributo e propriedades.
- [ ] 3. Combate: recarregar a pagina e confirmar que a arma ativa escolhida continua igual para a mesa.
- [ ] 4. Jogador/Notas: criar nota com `@Nome`; confirmar que aparece como texto comum, sem sugestao e sem link clicavel.
- [ ] 5. Mestre/Notas: digitar `@` e parte do nome; confirmar sugestoes de jogadores e NPCs.
- [ ] 6. Mestre/Notas: selecionar uma sugestao e confirmar insercao de `@NomeExato`.
- [ ] 7. Mestre/Historia: repetir autocomplete de `@` no campo de descricao da ideia.
- [ ] 8. Mestre/Historia: arrastar ideias para reordenar e confirmar persistencia apos recarregar.
- [ ] 9. Mestre/Historia: com busca ativa, confirmar que a lista filtrada nao permite drag.
- [ ] 10. Mestre/NPCs: confirmar que raca e ocupacao sao dropdowns e que valores antigos/customizados continuam selecionaveis.

## Sincronizacao

- Abrir a mesma mesa em duas janelas com `?mesa=GURI-1234`.
- Em uma janela, entrar como mestre com PIN; na outra, entrar como jogador.
- Solicitar entrada de um jogador e aprovar no painel do mestre.
- Editar vida/status pelo mestre e confirmar atualizacao na ficha do jogador.
- Iniciar combate, avancar rodada e confirmar atualizacao no jogador.
- Solicitar uso de poder pelo jogador, aprovar no mestre e confirmar que o poder ficou usado.
- Finalizar combate e confirmar reset apenas dos poderes por combate.

## Fichas

- Arquivar uma ficha e confirmar que ela some da landing, companhia ativa e novo combate.
- Restaurar a ficha no arquivo do mestre.
- Usar reset por sessao e por descanso longo, confirmando que apenas os limites corretos mudam.

## Mobile e PWA

- Testar landing, mestre, jogador e combate em largura compacta de celular.
- Confirmar que dialogos de ficha, inventario, status e monstro nao geram overflow.
- Copiar link da mesa e abrir em outro dispositivo.
- Instalar como PWA, fechar e reabrir; confirmar retorno para a ultima mesa.

## Privacidade de mesa

- Conferir que jogador nao ve vida de monstros.
- Tentar entrar como mestre com PIN errado e confirmar bloqueio.
- Lembrar: o PIN e uma barreira domestica, nao autenticacao forte.
