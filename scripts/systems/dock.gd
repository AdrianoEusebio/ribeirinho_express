class_name Dock
extends Node2D

signal pedido_entregue(pontos: int)

@export var pool_pedidos: Array[OrderData] = []
@export var boat_scene: PackedScene = preload("res://scenes/boat.tscn")

@export var spot_positions: Array[Vector2] = [
	Vector2(200, 100),
	Vector2(500, 100),
	Vector2(800, 100)
]

var boats: Array[Node2D] = [null, null, null]

func _ready() -> void:
	add_to_group("doca")
	# Pequeno atraso para começar a spawnar barcos
	await get_tree().create_timer(1.0).timeout
	_check_and_spawn_boats()

func _check_and_spawn_boats() -> void:
	for i in range(3):
		if boats[i] == null:
			_spawn_boat(i)

func _spawn_boat(index: int) -> void:
	var new_boat = boat_scene.instantiate()
	add_child(new_boat)
	boats[index] = new_boat
	
	var p = _get_random_pedido()
	new_boat.setup(p, index)
	new_boat.boat_finished.connect(_on_boat_finished)
	
	# Faz o barco chegar na posição do spot
	# Como o barco é filho da Doca, a posição é relativa ou global?
	# Vamos usar global_position para garantir.
	var target_pos = global_position + spot_positions[index]
	new_boat.chegar(target_pos)

func _get_random_pedido() -> OrderData:
	if pool_pedidos.is_empty(): return null
	return pool_pedidos[randi() % pool_pedidos.size()]

func _on_boat_finished(boat) -> void:
	pedido_entregue.emit(boat.pedido.recompensa_pontos)
	var index = boat.spot_index
	boats[index] = null
	# Espera um pouco e spawna outro
	await get_tree().create_timer(3.0).timeout
	_check_and_spawn_boats()

func contem_posicao_global(posicao: Vector2) -> bool:
	# Agora a doca é uma área que engloba todos os spots
	# Vamos definir um retângulo grande o suficiente ou checar proximidade dos barcos
	for boat in boats:
		if boat != null and boat.state == boat.State.DOCKED:
			var rect = Rect2(boat.global_position - Vector2(100, 100), Vector2(300, 200))
			if rect.has_point(posicao):
				return true
	return false

func centro_global() -> Vector2:
	# Retorna o centro do spot mais próximo do player talvez?
	# Por enquanto retorna o centro da doca
	return global_position + Vector2(500, 100)

# Removidos métodos de desenho antigos que não fazem mais sentido
# ou podem ser adaptados para os spots.
