# 🎨 Implementação 09: Sprites e Artes Restantes

## Descrição
Consolidação do estilo visual "Pixel Art Ribeirinho". Esta implementação visa remover qualquer placeholder e padronizar o tamanho e a paleta de cores dos assets.

## Passos Detalhados para Implementação

### 1. Catálogo de Itens (Sprites de Grid)
Os itens abaixo devem ser criados e categorizados no sistema de `ItemData`. 
Sugerimos o uso de bordas coloridas ou ícones no HUD para identificar a categoria rapidamente.

- **🪨 Pesados (Ocupam 2x2 ou layouts em L/T)**:
    - `geladeira`: Alta e estreita.
    - `maquina_lavar`: Quadrada e pesada.
    - `sofa`: Grande (pode ser 3x2 ou 2x3).
    - `armario`: Ocupa muito espaço vertical.
    - `botijao_gas`: Clássico, redondo e pesado.
    - `roda_carro`: Formato circular no grid (bloqueia cantos).
    - **Sugestão**: `saco_farinha` (Essencial para o tema).

- **📦 Médios (Ocupam 1x2 ou 2x1)**:
    - `microondas`: Retangular pequeno.
    - `tv`: Fina mas larga.
    - `caixa_default`: A famosa "Caixa de Papelão" multiuso.
    - **Sugestão**: `cesta_acai` (Item icônico da região).
    - **Sugestão**: `caixa_isopor` (Comum em transportes fluviais).

- **💎 Fráteis (Ocupam 1x1 - Quebram se caírem)**:
    - `abajur`: Pequeno e delicado.
    - `radio_pilha`: Item retrô ribeirinho.
    - `caixa_copos_vidro`: Som de vidro quebrando ao cair.
    - `vaso_planta`: Requer cuidado no transporte.
    - `caixa_remedios`: Item vital de entrega.
    - **Sugestão**: `cesta_ovos` (Muito frágil).

### 2. Estados de Animação do Player
O `AnimatedSprite2D` do jogador precisa das seguintes sequências (Frames 32x32):
- `idle_carry` / `run_carry`: Mesmos movimentos, mas com os braços elevados e expressão de esforço.
- `stumble` (1 a 4): Frames do jogador perdendo o equilíbrio (já iniciados).
- `knocked_out`: Player no chão com "estrelinhas" ou fumaça na cabeça (usado ao bater no NPC ou cair).
- `victory_pose`: Player comemorando com braços para cima.

### 3. Tileset e Ambiente (Trapiche)
Expandir o `TileMap` para criar profundidade:
- **Camada de Base**: Tábuas de madeira irregulares (trapiche).
- **Camada de Detalhes**: Limo verde nas bordas perto da água, pregos enferrujados, rachaduras na madeira.
- **Objetos de Cena**: Amarradores de barco (ferro), redes de pesca penduradas (semi-transparentes), bancos de madeira.
- **Rio**: Água com animação de fluxo constante e sombras dos barcos.

### 4. Barcos (Visual Único)
Embora todos tenham o mesmo tamanho de colisão (Implementação 01), os sprites devem variar:
- `barco_regional_azul`: Estilo clássico "Leão do Norte".
- `barco_regional_verde`: Com cobertura de palha ou lona.
- `barco_regional_vermelho`: Com dois andares (mesmo que o segundo seja apenas decorativo).
- **Decorações**: Nomes pintados na lateral (ex: "Boto Ligeiro", "Estrela do Mar").
