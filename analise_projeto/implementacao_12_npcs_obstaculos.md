# 💂‍♂️ Implementação 12: NPCs Obstáculos (Antigos Guardas)

## Descrição
Os "Guardas" agora atuarão como NPCs de patrulha que servem como obstáculos físicos. Em vez de atordoar o jogador com uma tela de pause ou algo similar, eles apenas causarão uma repulsão física (knockback), dificultando a movimentação e podendo empurrar o jogador para poças d'água.

## Passos para Implementação

### 1. Refatorar IA de Patrulha (`NPCPatrol.gd`)
- Manter a patrulha básica (ida e volta ou caminhos definidos).
- Aumentar a variedade de NPCs (usar diferentes frames de spritesheet).
- Remover a chamada de `player.atordoar()`.

### 2. Mecânica de Repulsão (Knockback)
- Quando o NPC colidir com o jogador:
    - Calcular o vetor de direção oposta: `direcao_repulsao = (posicao_player - posicao_npc).normalized()`.
    - Aplicar uma força instantânea ao `velocity` do jogador.
    - O jogador deve entrar em um estado curto de "descontrole" (0.2s) onde não aceita comandos de input, apenas processa a inércia da batida.

### 3. Melhoria na IA
- **Deteção Visual**: Se o jogador estiver muito perto na frente do NPC, o NPC pode acelerar levemente para tentar "atropelar" o jogador.
- **Sons**: Adicionar um som de "esbarrão" ou resmungo do NPC ao colidir.

### 4. Distribuição no Mapa
- Posicionar múltiplos NPCs em rotas estratégicas que cruzam o caminho entre o estoque de itens e os barcos.
- Criar NPCs que ficam parados "conversando" e bloqueando caminhos estreitos, forçando o jogador a dar a volta.
