# 🧩 Implementação 03: Anexar Grid ao Barco

## Descrição
O `CargoGrid` deve ser uma parte integrante do `Boat.tscn`, funcionando como um componente modular. Ele gerencia sua própria lógica de encaixe, mas responde ao ciclo de vida e estado do Barco.

## Passos Detalhados para Implementação

### 1. Estrutura da Cena `Boat.tscn`
- Adicionar o nó `CargoGrid` como filho direto de `Boat`.
- **Posicionamento**: O `CargoGrid` deve estar centralizado visualmente sobre o deck do sprite do barco.
- **Configuração Inicial**: O `CargoGrid` inicia com `visible = false` e `set_process(false)` para economizar performance enquanto o barco navega.

### 2. Ciclo de Vida do Grid no `Boat.gd`
- **Ao chegar (`on_docked`)**:
    - `cargo_grid.visible = true`
    - `cargo_grid.set_process(true)`
    - `cargo_grid.configurar_grid(config_sorteada)` (Ver Implementação 01).
- **Ao partir (`on_leaving`)**:
    - `cargo_grid.visible = false`
    - `cargo_grid.set_process(false)`
    - Emitir sinal de que o grid não está mais disponível para o jogador.

### 3. Lógica de Detecção do Jogador (`CargoGrid.gd`)
- O `CargoGrid` não deve procurar o jogador globalmente o tempo todo.
- **Detecção por Proximidade**:
    - No `_process`, checar a distância entre o `global_position` do Barco e o `global_position` do Player.
    - `if distance_to_player < 200.0 and boat.state == DOCKED:`
        - Habilitar o modo de "Preview" do item que o jogador está segurando.
- **Input de Mouse**:
    - Usar `_unhandled_input` ou checar `is_action_pressed` apenas se `visible == true`.

### 4. Isolamento e Limpeza
- Cada instância de Barco tem seu próprio objeto `GridData` instanciado dentro do seu `CargoGrid`.
- **Limpeza**: Quando o barco chama `queue_free()`, o `GridData` e todos os sprites de itens carregados nele são deletados automaticamente por serem filhos do Barco, evitando vazamento de memória.
