# Ribeirinho Express - Plano de Revitalizacao Jogavel

## Diagnostico atual

O jogo ja possui um loop funcional: entrar no deposito, coletar mercadorias, lidar com peso, atravessar o mapa, evitar poças e NPCs, organizar itens no barco, completar pedidos, pontuar e vencer antes do tempo acabar.

O problema principal nao e ausencia de sistemas. O problema e que muitos sistemas agem sem suficiente leitura para o jogador. A experiencia fica menos viva porque o jogo comunica pouco estado, risco, progresso, motivo de falha e recompensa.

## Loop real atual

1. Ler pedido ativo no HUD ou na doca.
2. Entrar na casa/deposito.
3. Coletar itens iniciais ou gerados pelos spawners.
4. Gerenciar limite de carga e perda de velocidade.
5. Sair para a rota ate a doca.
6. Evitar poças, patrulheiro e ladrao.
7. Entrar na area da doca.
8. Posicionar itens no grid do barco.
9. Completar pedido automaticamente quando os itens necessarios estao no grid.
10. Receber pontos e novo pedido.
11. Vencer ao atingir a meta ou perder por tempo.

## Objetivo de design

Transformar o loop existente em uma experiencia mais legivel, pressionada e recompensadora, sem trocar a arquitetura central.

O foco e:

- clareza: o jogador sabe o que esta carregando, quanto pesa e quanto falta para vencer;
- feedback: o jogo explica sucesso, erro, roubo, limite de carga e grid invalido;
- risco visivel: ladrão e patrulheiro devem ser entendidos antes de punirem;
- recompensa: entregas precisam parecer eventos, nao apenas uma limpeza silenciosa do grid;
- profundidade: pedidos futuros devem explorar mais o grid e a rota.

## Pacote 1 - Legibilidade imediata

Implementar agora:

- HUD com meta de pontos.
- HUD com inventario carregado.
- HUD com carga em pontos e massa.
- Mensagens temporarias no HUD.
- Mensagens para maos cheias, carga pesada demais, item colocado, item roubado e entrega concluida.
- Motivo de falha ao tentar posicionar no grid.
- Alerta visual do ladrao quando detecta o jogador.

Resultado esperado: o jogador entende o estado da partida a cada segundo.

## Pacote 2 - Ritmo da entrega

Proximo passo recomendado:

- Manter a entrega automatica por enquanto, mas dar feedback mais forte.
- Depois, considerar uma acao de confirmar entrega na doca.
- Mostrar resumo rapido: pedido, pontos, bonus e proximo pedido.
- Dar uma animacao curta no barco/docas.

Resultado esperado: completar pedido vira um momento reconhecivel.

## Pacote 3 - Profundidade do grid

Proximo passo recomendado:

- Criar pedidos com 3 ou 4 itens.
- Criar itens com formatos nao retangulares.
- Usar mais itens frageis em combinacao com pesados.
- Dar bonus por ocupacao eficiente.
- Penalizar itens quebrados ou extras.

Resultado esperado: o grid deixa de ser apenas um lugar de descarregar item e passa a ser puzzle.

## Pacote 4 - Rotas e risco

Proximo passo recomendado:

- Comunicar raio de deteccao do ladrao.
- Comunicar rota do patrulheiro.
- Balancear mapa com caminho curto perigoso e caminho longo seguro.
- Fazer poças e NPCs influenciarem escolhas de carga: levar muito peso aumenta risco de ser pego.

Resultado esperado: atravessar o mapa vira decisao, nao deslocamento.

## Pacote 5 - Progressao

Proximo passo recomendado:

- Criar `LevelData` com tempo, meta, pedidos, spawners, NPCs e layout.
- Fazer uma fase tutorial sem ladrao.
- Introduzir mecanicas em ordem: coleta, peso, grid, fragil, patrulheiro, ladrao.
- Salvar estrelas por fase.

Resultado esperado: o jogo ganha campanha e curva de aprendizado.

## Implementacao desta etapa

Esta etapa implementa o Pacote 1:

- extensao do HUD;
- mensagens temporarias;
- atualizacao de inventario/carga;
- feedbacks em player, grid e doca;
- motivo de bloqueio no grid;
- alerta visual do ladrao.

Essas mudancas sao pequenas, mas atacam diretamente a sensacao de jogo "morto": elas fazem os sistemas existentes aparecerem.
