# 🗺️ Ribeirinho Express — Roadmap Técnico

> Roteiro completo dividido em **MVP (Protótipo Jogável)** e **Pós-MVP (Jogo Completo)**.

---

# PARTE 1: MVP — PROTÓTIPO JOGÁVEL

> **Objetivo:** Uma fase jogável onde o jogador pega itens, encaixa no grid do barco, e tenta atingir a meta antes do tempo acabar.

---

## FASE 1 — Fundação de Dados (Semana 1)

### Passo 1.1: Criar `ItemData.gd` (Resource)
- **Arquivo:** `scripts/resources/item_data.gd`
- **O que faz:** Define a estrutura de dados de cada item do jogo
- **Campos:**
  - `nome: String` — ex: "Caixa de Medicamentos"
  - `icone: Texture2D` — sprite do item
  - `massa: float` — peso em kg (afeta velocidade do jogador)
  - `tamanho: Vector2i` — dimensão no grid (ex: 2x1)
  - `categoria: Categoria` — enum: PESADO, MEDIO, FRAGIL
  - `formato: Array[Vector2i]` — células ocupadas relativas à origem
  - `eh_essencial: bool` — medicamentos/alimentos = bônus de pontuação
  - `prioridade: int` — peso na pontuação

### Passo 1.2: Criar Enum de Categorias
- **Arquivo:** `scripts/enums/enums.gd` (Autoload)
- Centralizar o enum `Categoria { PESADO, MEDIO, FRAGIL }`
- Centralizar o enum `EstadoJogador { VAZIO, CARREGANDO, LENTO, ATORDOADO }`

### Passo 1.3: Criar Resources de Teste
- **Pasta:** `resources/itens/`
- Criar 4-5 arquivos `.tres` no editor do Godot:
  - `caixa_pequena.tres` (1x1, MEDIO, 5kg)
  - `caixa_medicamento.tres` (1x1, FRAGIL, 3kg, essencial)
  - `saco_graos.tres` (2x2, PESADO, 20kg)
  - `caixa_media.tres` (2x1, MEDIO, 10kg)
  - `geladeira.tres` (1x3, PESADO, 30kg)

### Entregável da Fase 1:
> Dados dos itens configuráveis pelo editor, sem tocar em código.

---

## FASE 2 — Itens no Mundo (Semana 1-2)

### Passo 2.1: Criar cena `Item.tscn`
```
StaticBody2D (ou Area2D)
 ├── Sprite2D (visual do item)
 ├── CollisionShape2D (detecção)
 └── script: item.gd
```

### Passo 2.2: Script `item.gd`
- **Variável exportada:** `@export var dados: ItemData`
- Na `_ready()`: configurar sprite e collision shape baseado no `dados`
- **Signal:** `item_coletado(item_data)` — emitido quando o jogador pega

### Passo 2.3: Espalhar itens na cena Main
- Instanciar 5-6 itens de teste no cenário
- Cada um com um `ItemData` diferente atribuído pelo editor

### Entregável da Fase 2:
> Itens visíveis no cenário com colisão funcional.

---

## FASE 3 — Sistema de Coleta (Semana 2)

### Passo 3.1: Refatorar `player.gd`
- Remover `JUMP_VELOCITY` (resíduo do template)
- Corrigir `velocity = direction * Vector2.ZERO` → `velocity = Vector2.ZERO`
- Remover chamada duplicada de `process_animation()`
- Adicionar variáveis:
  - `var item_carregado: ItemData = null`
  - `var estado: EstadoJogador = EstadoJogador.VAZIO`

### Passo 3.2: Implementar coleta via Hitbox
- Quando o jogador pressiona `interact` (tecla E):
  - Verificar se a Hitbox (Area2D) está colidindo com algum Item
  - Se sim: guardar referência ao `ItemData`, mudar estado para `CARREGANDO`
  - Mostrar feedback visual (item some do chão, sprite aparece sobre o jogador)

### Passo 3.3: Sistema de velocidade dinâmica
- `velocidade_final = SPEED_BASE - (item_carregado.massa * FATOR_PESO)`
- Se `velocidade_final < SPEED_MINIMA`: estado = `LENTO`

### Entregável da Fase 3:
> Jogador pega itens, fica mais lento, e carrega visualmente.

---

## FASE 4 — Sistema de Grid (Semana 2-3)

### Passo 4.1: Criar `GridData.gd` (lógica pura)
- **Arquivo:** `scripts/systems/grid_data.gd`
- Array 2D (`Array[Array]`) representando o grid
- Cada célula: `null` (vazio) ou referência ao `ItemData`
- Funções:
  - `pode_colocar(item: ItemData, pos: Vector2i) -> bool`
  - `colocar_item(item: ItemData, pos: Vector2i) -> void`
  - `remover_item(pos: Vector2i) -> void`
  - `calcular_ocupacao() -> float` (percentual preenchido)

### Passo 4.2: Regras de posicionamento
- **PESADO:** Só na linha inferior (`pos.y == grid_altura - 1`)
- **FRAGIL:** Verificar se célula acima não tem item PESADO
- **MEDIO:** Sem restrições

### Passo 4.3: Criar cena `CargoGrid.tscn` (visual)
```
Node2D
 ├── GridVisual (script que desenha o grid)
 ├── HighlightCell (indica onde o item vai cair)
 └── PlacedItems (container dos itens já posicionados)
```
- Desenhar grid com `_draw()` ou TileMap
- Mostrar preview do item ao passar o mouse
- Verde = pode colocar, Vermelho = não pode

### Passo 4.4: Interação Mouse + Grid
- Ao clicar no grid com item carregado:
  - Calcular célula baseado na posição do mouse
  - Verificar `pode_colocar()`
  - Se sim: posicionar item, limpar `item_carregado`
- Rotação com botão direito ou tecla R:
  - Rotacionar o `formato` do item 90° (trocar x,y das coordenadas)

### Entregável da Fase 4:
> Grid funcional onde itens são encaixados com regras de categoria.

---

## FASE 5 — Game Loop Básico (Semana 3-4)

### Passo 5.1: Timer / Cronômetro
- Node `Timer` na cena principal
- HUD mostrando tempo restante
- Quando chega a 0: tela de resultado

### Passo 5.2: Sistema de pontuação básico
```
pontuacao = (espacos_usados / espacos_totais) * 1000
          + (itens_essenciais_colocados * 200)
          + (tempo_restante * 5)
```

### Passo 5.3: Tela de resultado
- **Vitória:** Meta atingida (ex: ≥60% do espaço preenchido)
  - Mostrar: pontuação, estrelas (1-3), botão "Próximo Nível"
- **Derrota:** Tempo esgotou sem atingir a meta
  - Mostrar: "Tente novamente", botão "Reiniciar"

### Passo 5.4: Spawner de itens
- Área de "estoque" no cenário com itens aparecendo periodicamente
- Ou esteira fixa com N itens pré-definidos por nível

### Passo 5.5: Cenário mínimo
- Área de chão walkable (TileMap simples)
- Zona de estoque (esquerda)
- Barco com grid (direita)
- Água ao redor (visual)

### Entregável da Fase 5:
> **🎮 MVP COMPLETO — Protótipo jogável com uma fase funcional.**

---

## Resumo do MVP — Estrutura de Pastas Final

```
ribeirinho-express/
├── assets/
│   ├── images/
│   │   ├── player/Player.png
│   │   ├── items/          ← sprites dos itens
│   │   ├── tileset/        ← tiles do cenário
│   │   └── ui/             ← elementos de interface
│   └── audio/              ← sons e música (pode ficar vazio no MVP)
├── resources/
│   └── itens/              ← arquivos .tres de cada item
├── scenes/
│   ├── main.tscn
│   ├── player.tscn
│   ├── item.tscn
│   ├── cargo_grid.tscn
│   └── ui/
│       ├── hud.tscn        ← timer + score
│       └── result_screen.tscn
├── scripts/
│   ├── player.gd
│   ├── item.gd
│   ├── enums/
│   │   └── enums.gd
│   ├── resources/
│   │   └── item_data.gd
│   ├── systems/
│   │   ├── grid_data.gd
│   │   ├── grid_visual.gd
│   │   ├── score_manager.gd
│   │   └── level_manager.gd
│   └── ui/
│       ├── hud.gd
│       └── result_screen.gd
└── project.godot
```

---

# PARTE 2: PÓS-MVP — JOGO COMPLETO

> Tudo abaixo só deve ser feito **depois** que o MVP estiver jogável e divertido.

---

## FASE 6 — Polimento Visual (Semana 4-5)

| Tarefa | Descrição |
| ------ | --------- |
| 6.1 | Criar tileset do porto fluvial (água, madeira, vegetação) |
| 6.2 | Criar tileset do centro de distribuição (concreto, prateleiras) |
| 6.3 | Animações dos itens ao serem colocados no grid (bounce, flash) |
| 6.4 | Partículas: splash de água, poeira ao andar |
| 6.5 | Efeito visual quando o timer entra nos últimos 30s (tela pulsa vermelho) |
| 6.6 | Transições entre telas (fade in/out) |

---

## FASE 7 — Áudio (Semana 5)

| Tarefa | Descrição |
| ------ | --------- |
| 7.1 | Música ambiente do porto (loop) |
| 7.2 | Música do galpão (loop) |
| 7.3 | Aceleração da música nos últimos 30s |
| 7.4 | SFX: pegar item, soltar item, erro, sucesso, buzina do barco |
| 7.5 | AudioManager (Autoload) para gerenciar crossfade |

---

## FASE 8 — Sistema de Níveis (Semana 5-6)

| Tarefa | Descrição |
| ------ | --------- |
| 8.1 | Criar `LevelData.gd` (Resource): grid_size, tempo_limite, itens_disponiveis, meta_minima |
| 8.2 | 5 níveis no porto + 5 no galpão (dificuldade crescente) |
| 8.3 | Tela de seleção de níveis (mapa do rio) |
| 8.4 | Sistema de estrelas (salvar progresso com `ConfigFile` ou `JSON`) |
| 8.5 | Desbloqueio progressivo de níveis |

---

## FASE 9 — Obstáculos e Eventos (Semana 6-7)

| Tarefa | Descrição |
| ------ | --------- |
| 9.1 | **Poça d'água:** Area2D que reduz velocidade do jogador |
| 9.2 | **Graxa:** Area2D que faz o jogador deslizar (impulso na direção) |
| 9.3 | **Ladrão (IA):** State Machine (IDLE → PERSEGUIR → ROUBAR → FUGIR) |
| 9.4 | Ladrão usa NavigationAgent2D para pathfinding |
| 9.5 | Se o ladrão toca o jogador carregando: rouba o item |
| 9.6 | **Chuva:** Evento aleatório que spawna poças extras |

---

## FASE 10 — UI/UX Completa (Semana 7-8)

| Tarefa | Descrição |
| ------ | --------- |
| 10.1 | Menu principal (Jogar, Configurações, Créditos) |
| 10.2 | Tela de configurações (volume, tela cheia) |
| 10.3 | Tutorial interativo (fase 0 com instruções) |
| 10.4 | Tela de pause |
| 10.5 | Tela de créditos |
| 10.6 | Indicadores visuais de categoria no grid (ícones de peso/frágil) |

---

## FASE 11 — Narrativa e Cutscenes (Semana 8-9)

| Tarefa | Descrição |
| ------ | --------- |
| 11.1 | Tela de introdução (contexto amazônico) |
| 11.2 | Diálogos entre níveis (caixa de texto simples) |
| 11.3 | Ilustrações das comunidades recebendo suprimentos |
| 11.4 | Tela final de conclusão da campanha |

---

## FASE 12 — Polimento Final e Build (Semana 9-10)

| Tarefa | Descrição |
| ------ | --------- |
| 12.1 | Balancear dificuldade de todos os níveis |
| 12.2 | Testar em diferentes resoluções |
| 12.3 | Otimizar performance |
| 12.4 | Exportar build para Windows |
| 12.5 | (Opcional) Exportar para Web (HTML5) |
| 12.6 | Criar página no itch.io |

---

# Resumo Visual do Roadmap

```
MVP (4 semanas)                          PÓS-MVP (6 semanas)
─────────────────────────────────        ────────────────────────────────────
F1: Dados       ████                     F6:  Visual      ████████
F2: Itens       ████                     F7:  Áudio       ████
F3: Coleta      ████████                 F8:  Níveis      ████████
F4: Grid        ████████████             F9:  Obstáculos  ████████
F5: Game Loop   ████████████             F10: UI/UX       ████████
                                         F11: Narrativa   ████████
    🎮 PROTÓTIPO JOGÁVEL                 F12: Build       ████
                                             🚀 JOGO COMPLETO
```

---

# Próximo Passo Imediato

> Começar pela **Fase 1, Passo 1.1**: Criar o script `item_data.gd` com a classe `ItemData`.
> É a base de TUDO — sem ele, nenhum outro sistema funciona.
