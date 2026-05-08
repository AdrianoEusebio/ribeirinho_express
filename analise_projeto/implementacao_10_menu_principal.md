# 🎮 Implementação 10: Menu Principal e Fluxo de Navegação

## Descrição
Criar a porta de entrada para o jogador e o fluxo entre as diferentes telas do jogo.

## Passos para Implementação

### 1. Cena `MainMenu.tscn`
- Fundo animado (barco passando ao longe).
- Botões: Jogar, Configurações, Créditos, Sair.

### 2. Painel de Configurações
- Sliders de volume (Geral, Música, SFX).
- Botão para alternar entre tela cheia e modo janela.

### 3. Fluxo de Transição
- Usar um `CanvasLayer` global para fazer transições suaves (fade to black) entre o Menu e o Jogo.
- Implementar o "Menu de Pausa" dentro da cena de gameplay.

### 4. Tutorial Simples
- Uma tela opcional de "Como Jogar" mostrando os comandos (WASD, E para pegar, R para rodar).
