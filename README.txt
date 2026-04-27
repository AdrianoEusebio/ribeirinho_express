# 📄 Ribeirinho Express — Arquitetura (Godot)

## 1. Arquitetura Geral

### Engine:

- Godot Engine (GDScript)

### Paradigma:

- **Composição baseada em Nodes**
- **Scenes reutilizáveis**

---

## 2. Sistema de Itens

### Cena base: `Item.tscn`

```
Node2D
 ├── Sprite2D
 ├── CollisionShape2D
 ├── ItemData (Resource)
```

---

### 📦 ItemData (Resource)

```
class_name ItemData
extends Resource

@export var massa: float
@export var tamanho: Vector2i
@export var categoria: int
@export var formato: Array
```

---

### 🎯 Categorias

```
enum Categoria {
    PESADO,
    MEDIO,
    FRAGIL
}
```

---

## 3. Sistema de Inventário

👉 NÃO usa slot A/B

Usa:

```
var itens_carregados: Array[ItemData]
var capacidade_max: int
```

---

## 4. Jogador (State Machine)

### Estados:

```
enum Estado {
    VAZIO,
    CARREGANDO,
    LENTO,
    ATORDOADO
}
```

---

## 5. Velocidade

velocidadefinal=velocidadebase−(massatotal⋅k)velocidade_{final} = velocidade_{base} - (massa_{total} \cdot k)velocidadefinal=velocidadebase−(massatotal⋅k)

---

## 6. Sistema de Grid (Tetris)

### Cena: `CargoGrid.tscn`

```
Node2D
 ├── TileMap (visual)
 ├── GridLogic (script)
```

---

### Regras de encaixe

```
func pode_colocar(item, pos):
    if item.categoria == PESADO:
        return esta_no_chao(pos)

    if item.categoria == FRAGIL:
        return suporte_valido_fragil(pos)

    return true
```

---

## 7. Sistema de Entrega

### Veículo = Grid vivo

```
Vehicle.tscn
 ├── CargoGrid
 ├── Pedido (Resource)
```

---

## 8. Pedido (Sistema de Missão)

```
class_name Pedido
extends Resource

@export var minimo_itens: int
@export var bonus_pesados: int
@export var bonus_combo: bool
```

---

## 9. Sistema de IA (Ladrão)

Estados:

- IDLE
- PERSEGUIR
- ROUBAR
- FUGIR

---

## 10. Obstáculos

- Poça → reduz atrito
- Graxa → deslize
- Ladrão → remove item

---

# 📚 O QUE TU PRECISA ESTUDAR (no Godot)

Procura exatamente esses termos:

### 🔥 FUNDAMENTAL

- "Godot Nodes and Scenes"
- "Godot Resource tutorial"
- "Godot State Machine player"
- "Godot TileMap grid system"

---

### 🎯 INTERMEDIÁRIO

- "Godot inventory system"
- "Godot drag and drop UI"
- "Godot AI state machine"

---

### 🧠 AVANÇADO

- "Godot data-driven design"
- "Godot reusable scenes"
- "Godot signals tutorial"

---

# 🚀 Melhor caminho pra começar (ordem REAL)

1. Player movement (CharacterBody2D)
2. Sistema de pegar item
3. Inventário simples (array)
4. Grid básico
5. Colocar item no grid
6. Regras (pesado/frágil)
7. IA ladrão
8. Pontuação

---

# 💡 Dica final (importante)

Tu pensou em:

> "fazer sistema global de itens antes dos sprites"
> 

👉 Isso é EXATAMENTE o certo

Mas no Godot faz assim:

- usa **Resource (ItemData)**
- não cria tudo hardcoded
