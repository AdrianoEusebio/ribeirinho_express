# 💦 Implementação 04: Sistema de Queda (Poça d'água)

## Descrição
Adicionar uma camada de risco ambiental. Se o jogador passar por uma poça d'água enquanto carrega itens, ele terá uma chance de escorregar, caindo e derrubando toda a carga no chão.

## Passos Detalhados para Implementação

### 1. Criar Objeto `Puddle` (Poça)
- **Cena**: `res://scenes/obstacles/puddle.tscn`
- **Componentes**: `Area2D` + `Sprite2D`.
- **Lógica**: Quando o Player entra, emitir sinal ou chamar `player.entrar_poca()`.

### 2. Lógica de Queda no `Player.gd`
- **Animações de Queda**: Usar as animações `stumble_1`, `stumble_2`, `stumble_3` e `stumble_4` presentes no `player.tscn`.
- **Função `escorregar()`**:
    1. Mudar `estado = Enums.EstadoJogador.ATORDOADO`.
    2. **Sequência de Animação**:
        - Tocar `stumble_1` -> `stumble_2` -> `stumble_3` -> `stumble_4` em sequência rápida (ou sortear uma para impacto imediato).
    3. **Dispersão de Itens**:
        - Para cada `item_data` em `itens_carregados`:
            - Instanciar `Item.tscn`.
            - `global_position = player.global_position`.
            - Aplicar um `Tween` para lançar o item em uma direção aleatória (360°) a uma distância de 40-80 pixels, simulando o espalhamento da queda.
    4. **Controle de Performance**: Antes de criar o item físico, verificar `get_tree().get_nodes_in_group("itens_no_chao").size() < 30`.
    5. Limpar `itens_carregados` e chamar `_atualizar_visual_itens()`.

### 3. Detecção de Risco (Probabilidade)
- Adicionar uma variável `chance_queda: float = 0.05` (5%).
- No `_physics_process`, se o jogador estiver em uma poça (`_pocas_ativas > 0`) E se movendo (`velocity.length() > 0`) E carregando itens:
    - A cada 0.5 segundos, rodar `if randf() < chance_queda: escorregar()`.

### 4. Feedback Visual e Sonoro
- **Som**: Efeito de "chapinhar" na água e som de impacto de madeira/caixas caindo.
- **Partículas**: Criar um `CPUParticles2D` de gotas de água azuladas que emitem quando o jogador "pisa" na poça.
