extends Node2D

@export var pool_itens: Array[ItemData] = []
@export var intervalo: float = 12.0
@export var max_itens_proximos: int = 2
@export var raio_verificacao: float = 80.0

const ITEM_SCENE = preload("res://scenes/item.tscn")

var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= intervalo:
		_timer = 0.0
		_tentar_spawnar()

func _tentar_spawnar() -> void:
	if pool_itens.is_empty():
		return

	var proximos = 0
	for item in get_tree().get_nodes_in_group("item_chao"):
		if global_position.distance_to(item.global_position) <= raio_verificacao:
			proximos += 1

	if proximos >= max_itens_proximos:
		return

	var dados = pool_itens[randi() % pool_itens.size()]
	var novo = ITEM_SCENE.instantiate()
	get_parent().add_child(novo)
	novo.global_position = global_position + Vector2(randf_range(-24, 24), randf_range(-24, 24))
	novo.dados = dados

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(1.0, 0.8, 0.0, 0.8))
	draw_arc(Vector2.ZERO, raio_verificacao, 0, TAU, 32, Color(1.0, 0.8, 0.0, 0.3), 1.0)
