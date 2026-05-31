# Checklist Manual de QA

Use este roteiro antes de uma sessao real.

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
