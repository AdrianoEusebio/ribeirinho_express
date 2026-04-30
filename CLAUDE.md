# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Ribeirinho Express** is a Godot 4.6 puzzle/logistics game inspired by Amazonian river transportation. Players organize cargo on a boat grid, respecting weight limits, fragility rules, and gravity physics.

## Running the Game

This is a Godot 4.6 project — no build step required.

- Open the project folder in **Godot Editor 4.6+**
- Press **F5** or click **Play** to run from `res://scenes/main.tscn`
- No external package managers (npm, pip, etc.)

Controls: **WASD** move, **E** interact/pick up, **Q** drop, **R** rotate item in grid

## Architecture

### Autoload / Globals

`scripts/enums/enums.gd` is registered as `Enums` autoload. All game-wide enums live here (`Categoria`, `EstadoJogador`). Reference them as `Enums.Categoria.PESADO` from any script.

### Data-Driven Items (`resources/itens/`)

Items are Godot `Resource` files (`.tres`) backed by `scripts/resources/item_data.gd`. To add a new item type: create a new `.tres` file via the Godot editor (right-click → New Resource → ItemData) — no code changes needed.

Key `ItemData` fields: `massa`, `tamanho` (Vector2i grid size), `categoria` (enum), `formato` (custom cell shape array).

### Cargo Grid — Two-Layer Design

The grid is split into two scripts with distinct responsibilities:

- **`scripts/systems/grid_data.gd`** (pure logic, extends `Object`): grid state, placement validation, pressure physics, gravity simulation. No Node dependencies. All rules live here.
- **`scripts/systems/cargo_grid.gd`** (visual, extends `Node2D`): mouse preview, rotation UI, placing/removing visual item nodes. Delegates all validation to `GridData`.

When modifying grid behavior (placement rules, pressure limits, gravity), edit `grid_data.gd`. When modifying visual feedback or UX, edit `cargo_grid.gd`.

### Pressure Physics (in `grid_data.gd`)

Weight propagates top-to-bottom. Each item's weight is divided equally among the cells directly below it. `FRAGIL` items break if accumulated pressure at any cell exceeds `2.1`. Items above a broken item fall via the gravity system (emits `item_caiu` signal).

### Player Inventory (`scripts/player.gd`)

Capacity uses a **point system**, not just item count:
- Max 3 items AND max 30 points
- PESADO = 30 pts, MEDIO = 11 pts, FRAGIL = 8 pts
- Speed degrades linearly from `SPEED_BASE` (300) to `SPEED_MINIMA` (80) based on carried weight

### Scene Graph

```
main.tscn
├── Player (player.tscn → player.gd, CharacterBody2D)
└── CargoGrid (cargo_grid.tscn → cargo_grid.gd, Node2D)
    └── items container (children are item.tscn instances)
```

Items on the ground are `item.tscn` nodes (Node2D + item.gd). Items in inventory are tracked as `ItemData` resource references only (no scene node).

## Roadmap Context

Core mechanics are complete. The next planned systems (not yet implemented) are:
1. Orders System (delivery missions)
2. Gamification UI (timer, HUD, main menu)
3. Real sprites and animations
