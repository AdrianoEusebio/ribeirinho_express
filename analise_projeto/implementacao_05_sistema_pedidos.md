# 📋 Implementação 05: Sistema de Pedidos (Orders)

## Descrição
O sistema de pedidos gera listas de itens que o jogador deve carregar no barco. É crucial que o sistema apenas peça itens que **existem** no pool de recursos do jogo, para que o desafio seja completável.

## Passos Detalhados para Implementação

### 1. Estrutura do `OrderData.gd`
- **Resource**: `res://scripts/resources/order_data.gd`
- **Atributos**:
    - `export var itens_exigidos: Array[ItemData]`: Lista exata de objetos `ItemData` que o jogador deve colocar no grid.
    - `export var recompensa_pontos: int`: Base de pontos pela entrega.
    - `export var tempo_limite_barco: float`: Tempo que o barco esperará no spot (ex: 60s).

### 2. Gerador Dinâmico (`OrderManager.gd`)
- O `OrderManager` deve ter acesso a um **Pool de Itens Disponíveis** (uma pasta com todos os `.tres` de itens ou uma lista preenchida no inspetor).
- **Lógica de Geração**:
    1. Receber o `GridConfig` do barco sorteado.
    2. Determinar a `quantidade` de itens baseada na capacidade do grid (ex: `grid.largura * grid.altura / 4`).
    3. **Sorteio**: Selecionar aleatoriamente N itens do **Pool de Itens Disponíveis**.
    4. Criar uma nova instância de `OrderData` preenchida com esses itens e passar para o `Boat.setup()`.

### 3. Validação de Entrega no `CargoGrid.gd`
- Criar a função `verificar_pedido(pedido: OrderData) -> bool`:
    - Percorrer `pedido.itens_exigidos`.
    - Para cada item exigido, verificar se existe um item correspondente (pelo `id` ou `nome`) dentro do `GridData.celulas`.
    - **Contagem**: Se o pedido pede 2 "Cestas de Açaí", o grid deve conter pelo menos 2 instâncias diferentes desse item.
    - Retornar `true` apenas se todos os requisitos forem satisfeitos.

### 4. Feedback e Conclusão
- **Interface**: Ao colocar um item no barco que faz parte do pedido, o HUD ou o balão do barco deve marcar aquele item como "OK" (ex: mudar cor para verde ou adicionar um checkmark).
- **Finalização**: Assim que `verificar_pedido()` retornar `true`, o barco deve disparar um sinal de sucesso, o `GameManager` soma os pontos, e o barco chama `partir()`.
