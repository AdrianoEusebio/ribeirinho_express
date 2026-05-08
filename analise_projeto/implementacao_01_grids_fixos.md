# 🧊 Implementação 01: Sistema de Grids Fixos (Configurados)

## Descrição
Para garantir o balanceamento, usaremos grids pré-definidos (ex: 3x3, 5x5, 8x10, ou formatos em "L"). Todos os barcos visualmente terão o mesmo tamanho de sprite, mas o espaço interno (grid) será sorteado a partir de uma lista de configurações criadas por nós.

## Passos Detalhados para Implementação

### 1. Criar Resource `GridConfig.gd`
- **Arquivo**: `res://scripts/resources/grid_config.gd`
- **Atributos**:
    - `export var id_grid: String`: Identificador único.
    - `export var largura: int`: Número de colunas.
    - `export var altura: int`: Número de linhas.
    - `export var celulas_bloqueadas: Array[Vector2i]`: Coordenadas que não podem receber itens (buracos).
    - `export var max_itens_recomendados: int`: Sugestão para o sistema de pedidos.

### 2. Modificar o Gerenciamento no `Dock.gd`
- Adicionar um array exportado: `@export var grid_pool: Array[GridConfig] = []`.
- Na função `_spawn_boat(index: int)`:
    - Sortear um grid: `var config = grid_pool[randi() % grid_pool.size()]`.
    - Passar a config para o barco: `new_boat.setup(p, index, config)`.

### 3. Ajustar `Boat.gd`
- Modificar a função `setup(p, index, config: GridConfig)`.
- Chamar `cargo_grid.configurar_grid(config)`.

### 4. Lógica de Escalonamento em `CargoGrid.gd`
- Criar a função `configurar_grid(config: GridConfig)`:
    - Atualizar `largura` e `altura` locais.
    - **Cálculo de Escala**: Definir uma área visual máxima (ex: 200x160 pixels).
    - `var escala_x = max_visual_w / (largura * tamanho_celula_base)`
    - `var escala_y = max_visual_h / (altura * tamanho_celula_base)`
    - `self.scale = Vector2.ONE * min(escala_x, escala_y)` (Garante que caiba mantendo a proporção).
    - Reinicializar o `GridData` com as novas dimensões e bloquear as células de `config.celulas_bloqueadas`.

### 5. Integração com Pedidos
- No `OrderManager.gd` ou na lógica do `Dock`, ao gerar o pedido para um barco, usar `config.max_itens_recomendados` para definir o `size()` do array de itens do pedido.
