# 🖥️ Implementação 07: Melhoria de UI/HUD

## Descrição
A interface deve fornecer informações críticas em tempo real sem obstruir a visão da ação. O foco é a legibilidade e o feedback imediato de progresso.

## Passos Detalhados para Implementação

### 1. Elementos do HUD Superior
- **Timer (Cronômetro)**:
    - Node: `Label` (ou `RichTextLabel` para efeitos).
    - Lógica: Conectar ao sinal `timer_changed` do `GameManager`.
    - **Feedback Visual**: 
        - > 60s: Branco.
        - < 60s: Amarelo e pulsa levemente.
        - < 15s: Vermelho e vibra (shake) a cada segundo.
- **Score (Pontuação)**:
    - Lógica: Conectar ao sinal `score_changed`.
    - **Efeito**: Usar `Tween` para aumentar o tamanho do Label momentaneamente (escala 1.2x) e voltar ao normal sempre que os pontos aumentarem.

### 2. Painel de Pedidos (Acima dos Barcos)
- Em vez de uma lista lateral estática, usar **Balões de Pensamento** ou **Flutuantes** que acompanham o barco.
- **Componentes**: 
    - `HBoxContainer` com instâncias de um pequeno `Scene` de Ícone de Item.
- **Lógica de Checkmark**:
    - Cada ícone no balão tem um sub-nó de Checkmark (verde).
    - Quando o `CargoGrid` detecta um item correto, ele emite um sinal que ativa o checkmark correspondente no balão do barco.

### 3. Barra de Carga (Player Feedback)
- **Node**: `ProgressBar` posicionado logo acima da cabeça do jogador.
- **Lógica**: 
    - `value = (massa_total / limite_massa) * 100`.
    - Mudar a cor da barra: Azul (leve), Laranja (pesado), Vermelho (limite/lento).

### 4. Seta Indicadora de Direção
- **Descrição**: Uma pequena seta que gira ao redor do jogador apontando para o barco com o pedido mais antigo (urgente).
- **Lógica**: 
    - A seta aponta para o `global_position` do barco.
    - Fica visível apenas se o jogador estiver carregando itens e estiver fora da área da doca.

### 5. Estética e Tipografia
- **Fontes**: Usar fontes de estilo "Stencil" ou "Lettering de Barco" (típicas da Amazônia).
- **Texturas**: Aplicar um `NinePatchRect` com textura de palha trançada ou madeira pintada para o fundo dos painéis de pedidos.
