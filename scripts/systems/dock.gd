class_name Dock
extends Node2D

signal pedido_entregue(pontos: int)
signal barco_atracou

@export var pool_pedidos: Array[OrderData] = []
@export var grid_pool: Array[GridConfig] = []
@export var boat_scene: PackedScene = preload("res://scenes/boat.tscn")

@export var spot_positions: Array[Vector2] = [
	Vector2(350, 0),
	Vector2(850, 0),
	Vector2(1530, 0)
]

# Segundos de espera dependendo do estado do porto
const DELAY_PORTO_VAZIO   := Vector2(1.0, 3.0)
const DELAY_PORTO_OCUPADO := Vector2(6.0, 14.0)

var boats: Array[Node2D]     = [null, null, null]
var _agendados: Array[bool]  = [false, false, false]
var _jogo_ativo: bool        = true

func _ready() -> void:
	add_to_group("doca")

func iniciar() -> void:
	await get_tree().create_timer(1.0).timeout
	_spawn_boat(0)
	_agendar_spawn()

# ─── Spawn escalonado (esquerda → direita) ────────────────────────────────────

func _agendar_spawn() -> void:
	if not _jogo_ativo:
		return
	var slot := _primeiro_slot_livre()
	if slot == -1:
		return
	_agendados[slot] = true
	var delay: float
	if _tem_algum_barco():
		delay = randf_range(DELAY_PORTO_OCUPADO.x, DELAY_PORTO_OCUPADO.y)
	else:
		delay = randf_range(DELAY_PORTO_VAZIO.x, DELAY_PORTO_VAZIO.y)
	_executar_spawn_apos(slot, delay)

func _executar_spawn_apos(slot: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_agendados[slot] = false
	if not _jogo_ativo or boats[slot] != null:
		return
	_spawn_boat(slot)
	_agendar_spawn()  # verifica se há mais slots livres

func _spawn_boat(index: int) -> void:
	var new_boat: Node2D = boat_scene.instantiate()
	add_child(new_boat)
	boats[index] = new_boat

	var p      := _get_random_pedido()
	var config := _get_random_grid_config()
	new_boat.setup(p, index, config)

	new_boat.boat_finished.connect(_on_boat_finished)
	new_boat.boat_timeout.connect(_on_boat_timeout)

	barco_atracou.emit()

	var target_pos := global_position + spot_positions[index]
	new_boat.chegar(target_pos)

# ─── Callbacks de barcos ──────────────────────────────────────────────────────

func _on_boat_finished(boat) -> void:
	pedido_entregue.emit(boat.pedido.recompensa_pontos)
	boats[boat.spot_index] = null
	_agendar_spawn()

func _on_boat_timeout(boat) -> void:
	boats[boat.spot_index] = null
	_agendar_spawn()

# ─── Encerramento do jogo ─────────────────────────────────────────────────────

func encerrar() -> void:
	_jogo_ativo = false
	for boat in boats:
		if boat != null:
			boat.set_process(false)

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _primeiro_slot_livre() -> int:
	for i in range(3):
		if boats[i] == null and not _agendados[i]:
			return i
	return -1

func _tem_algum_barco() -> bool:
	for b in boats:
		if b != null:
			return true
	return false

func _get_random_pedido() -> OrderData:
	if pool_pedidos.is_empty(): return null
	return pool_pedidos[randi() % pool_pedidos.size()]

func _get_random_grid_config() -> GridConfig:
	if grid_pool.is_empty(): return null
	return grid_pool[randi() % grid_pool.size()]

# ─── Consultas externas ───────────────────────────────────────────────────────

func contem_posicao_global(posicao: Vector2) -> bool:
	for boat in boats:
		if boat != null and boat.state == boat.State.DOCKED:
			var rect := Rect2(boat.global_position - Vector2(100, 100), Vector2(300, 200))
			if rect.has_point(posicao):
				return true
	return false

func centro_global() -> Vector2:
	return global_position + Vector2(500, 100)
