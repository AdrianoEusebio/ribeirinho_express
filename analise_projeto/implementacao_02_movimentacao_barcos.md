# 🚢 Implementação 02: Movimentação dos Barcos (Chegada e Saída)

## Descrição
Implementar o sistema de navegação dos barcos usando `Tweens` para garantir uma movimentação suave de entrada (pela direita) e saída (pela esquerda), simulando a correnteza do rio.

## Passos Detalhados para Implementação

### 1. Sistema de Coordenadas no `Dock.gd`
- **Spawn (Entrada)**: Definir um `X` fixo fora da tela à direita (ex: `1200`). O `Y` deve ser o mesmo do `spot_position`.
- **Exit (Saída)**: Definir um `X` fixo fora da tela à esquerda (ex: `-400`).
- **Lógica**: Ao chamar `_spawn_boat(index)`, calcular:
    - `pos_inicial = Vector2(1200, spot_positions[index].y)`
    - `pos_doca = spot_positions[index]`
    - `pos_saida = Vector2(-400, spot_positions[index].y)`

### 2. Estados e Transições no `Boat.gd`
- **Função `chegar(destino_global: Vector2)`**:
    - `state = State.ARRIVING`.
    - `global_position = Vector2(1200, destino_global.y)`.
    - Usar `create_tween()`: 
        - `tween.tween_property(self, "global_position", destino_global, 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)`.
        - Adicionar um segundo tween paralelo para um leve "bobbing" (balanço) no eixo Y: `tween.tween_property(sprite, "position:y", 5.0, 0.5).as_relative().set_loops()`.
    - Ao terminar: `state = State.DOCKED`.

- **Função `partir(saida_global: Vector2)`**:
    - `state = State.LEAVING`.
    - `cargo_grid.visible = false`.
    - Usar `create_tween()`:
        - `tween.tween_property(self, "global_position", saida_global, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)`.
    - Ao terminar: `queue_free()`.

### 3. Feedback Visual (Rastro de Água)
- Adicionar um nó `GPUParticles2D` ou `CPUParticles2D` na popa do barco.
- **Configuração**:
    - Emissão ativada apenas se `velocity.length() > 10`.
    - Textura de "bolha" ou "espuma" branca com transparência.
    - Direção oposta ao movimento (direção +X quando o barco vai para -X).

### 4. Gatilhos de Partida
- O barco deve chamar `partir()` em dois cenários:
    1. **Sucesso**: Pedido entregue (chamado após a animação de sucesso).
    2. **Timeout**: O tempo de espera do barco no `GameManager` esgotou (o barco vai embora vazio).
