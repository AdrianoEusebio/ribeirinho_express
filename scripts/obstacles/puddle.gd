extends Node2D

@export var raio: float = 45.0

var _player_dentro: bool = false

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var dentro = global_position.distance_to(player.global_position) <= raio
	if dentro and not _player_dentro:
		_player_dentro = true
		player.entrar_poca()
	elif not dentro and _player_dentro:
		_player_dentro = false
		player.sair_poca()

func _draw() -> void:
	draw_circle(Vector2.ZERO, raio, Color(0.15, 0.45, 1.0, 0.45))
	draw_arc(Vector2.ZERO, raio, 0, TAU, 40, Color(0.3, 0.6, 1.0, 0.7), 2.0)
