# ✅ Decisões de Design e Novas Ideias

## 🎯 Decisões Definidas

### Nível de Complexidade e Game Loop
1.  **Tempo de Partida**: Definido inicialmente como **3:00 minutos**. O sistema será flexível para ajustes futuros.
2.  **Sistema de Entrega (Estilo Overcooked)**: Não há tela de "Game Over" por erros. O foco é entregar o máximo possível.
3.  **Partida de Barcos**: Se o jogador demorar, a recompensa diminui. Se demorar demais, o barco parte para dar lugar a outro.
4.  **Limite de Itens no Chão**: Para evitar sobrecarga (performance), haverá um limite de **30 itens dropados** simultaneamente no mapa.

### Mecânicas de Movimento e Combate
5.  **Colisão com Bandidos**:
    *   **Com Itens**: O jogador é roubado e o ladrão foge.
    *   **Sem Itens**: O jogador sofre um "repulsão" (efeito trampolim).
6.  **NPCs de Patrulha (Obstáculos)**: Ao encostar, o jogador é empurrado para trás na direção oposta, sem atordoamento longo, apenas perda de controle momentânea.
7.  **Sem Sprint**: A velocidade será controlada apenas pelo peso e modificadores (poças/power-ups).

### Detalhes do Grid
7.  **Itens Irregulares**: Confirmado. Teremos formatos variados (L, T, etc.) para todos os tipos de itens.
8.  **Pesados**: Mantida a regra de apenas no "chão" do barco.

### IA do Ladrão
9.  **Dificuldade Adaptativa**: A quantidade de bandidos aumenta conforme o jogador performa bem (mais pontos em menos tempo = mais perigo).
10. **Recuperação de Itens**: *Sugestão aprovada:* O jogador poderá recuperar o item se nocautear o bandido com o Bastão ou alcançá-lo.

---

## 🌟 Quadro de Features Atualizado

### 🎮 Gameplay e Mecânicas
*   **Evento de Temporal**: Adiciona poças aleatórias e reduz visibilidade.
*   **Bastão (Power-up)**: Usado para nocautear bandidos ou recuperar itens roubados.
*   **Carrinho de Mão (Power-up)**: Permite carregar mais de 3 itens (independente do peso) por tempo limitado.

### 🌍 Imersão e Áudio
*   **Diálogos Undertale-style**: Balões de fala com bips rítmicos representando as vozes. NPCs e Bandidos terão "vozes" diferentes.
*   **Modo Noturno (Hard Mode)**: Ciclo dia/noite com uso de lanterna, dificultando a visão de poças e bandidos.

pensar: melhorar os sprites existentes

correção: sistema de selecionar itens ta esteira. Caso exista mais de 2 itens do mesmo tipo(2 cadeiras),  esteira diminui a porcentagem de chance daquele item vir, a esteira tmb é influenciadad pelas missões, caso venha 2 missões com 3 items iguais, a esteira tem que aumentar a porcentagem de chance de vim  o item.

refatoração: o sistema vai se comportar de outra maneira. Atualmente ele funciona como uma especie de arcade baseado em entregar e juntar uma pontuação em um periodo de tempo. Preciso que o sistema tenha uma proressão de dificuldade durante a perda de tempo(aumentar o spawn de bandidos e npc e velocidade em que os barcos vão embora), porem, preciso vamos implementar um sistema de melhoria de atributos do jogador e outros pontos de melhoria(Igual o megbonk).

correção: melhorar o desing do hud do jogo, adicionar sprites talvez.

meg-feature: multiplayer coo-op.

### 🏆 Social e Progresso
*   **Leaderboard Local**: Ranking dos melhores scores salvo no PC.
*   **Loja de Upgrades**: Planejada para o futuro (melhorias de velocidade, carga, etc.).

### 🗺️ Estrutura do Mapa
*   **Tamanho Dobrado**: O mapa será expandido para o dobro do tamanho (aprox. 5120x2880), permitindo mais exploração, rotas de patrulha longas e spawn de itens distantes das docas.
