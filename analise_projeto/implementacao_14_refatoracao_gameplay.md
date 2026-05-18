# 🔄 Implementação 14: Refatoração do Sistema de Itens, Missões e Gameplay

## Descrição
Refatoração profunda das regras de game loop, pontuação, grids visuais de carga e persistência local de scores para implementar uma dinâmica arcade baseada em Score Attack com metas progressivas e ranking local.

## Detalhes de Implementação

### 1. Escala do Grid de Carga
- **Proporção**: Redução do grid padrão de 6x4 para **3 colunas** por **5 linhas** (3x5).
- **Arquivos**:
  - `res://scenes/cargo_grid.tscn`: Parâmetros de `largura = 3` e `altura = 5`.
  - `res://scripts/systems/cargo_grid.gd`: `@export var largura: int = 3` e `@export var altura: int = 5`.

### 2. Fluxo e Entrega do Barco
- **Entrega Automática**: Assim que as exigências do pedido forem totalmente atendidas dentro do grid de carga, o barco deve acionar `confirmar_entrega()` imediatamente, partindo da doca e creditando os pontos base (300 pts) mais bônus de velocidade.
- **Sinalização**: O player não precisa mais estar fisicamente próximo ao barco nem pressionar a tecla "E" para efetuar a entrega após o grid estar pronto.

### 3. Sistema de Pontuação Parcial (Timeout)
- Toda vez que o tempo limite do barco atracado esgotar sem que o pedido seja concluído, o barco partirá e o jogador receberá pontos parciais com base nos itens corretos já colocados no grid.
- **Fórmula de Cálculo**:
  $$\text{pontos} = \max\left(0, \text{int}\left(200.0 \times \frac{M}{N}\right) - 100\right)$$
  - $N$: Número de itens exigidos pela missão.
  - $M$: Número de itens corretos inseridos no grid.
- Se o jogador colocou pelo menos metade dos itens necessários, ele receberá uma fração de pontos (máximo de 200 pontos com penalidade de -100). Caso não tenha itens válidos ou quantidade insuficiente, ganha 0 pontos.

### 4. Game Loop Adaptativo de 5 Minutos
- **Tempo Inicial**: Ajustado para 300 segundos (5 minutos) em `main.gd`.
- **Meta de Pontuação**:
  - Meta inicial configurada para 900 pontos.
  - Ao bater a meta de pontuação (`pontuacao >= meta`), o jogo **não encerra**. Em vez disso:
    - A meta de pontuação é acrescida em **+600 pontos**.
    - O cronômetro do jogo ganha **+30 segundos** de bônus acumulativos.
    - O HUD é atualizado com a nova meta e o novo tempo, mantendo a gameplay contínua até o tempo se esgotar completamente.

### 5. Tela de Game Over e Registro de Rankings
- Quando o tempo total do jogo esgota (`tempo_restante <= 0`), a partida entra no estado `ENCERRADO` e exibe um painel de **Game Over** contendo:
  - Label "GAME OVER" estilizado.
  - Caixa de texto (`LineEdit`) de 3 caracteres para o jogador inserir suas iniciais.
  - Três botões interativos:
    1. **Registrar Pontos**: Valida as iniciais e insere o score no ranking de Top 10.
    2. **Jogar Novamente**: Recarrega a cena de gameplay.
    3. **Ir para o Menu**: Retorna para a tela de Menu Principal.
- **Salvamento**: Os registros são persistidos em formato JSON no arquivo seguro `user://scores.json`.

### 6. Painel de Ranking no Menu Principal
- No `MainMenu.tscn`, é adicionado um novo botão **RANKING**.
- Ao clicar, exibe um painel elegante centralizado contendo a tabela com as 10 melhores pontuações salvas (Posição, Nome e Pontuação) com fonte mono/pixelada, e um botão "Voltar".
