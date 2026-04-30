extends CharacterBody2D

enum Estado { PATRULHA, PERSEGUINDO, FUGINDO }

@export var velocidade: float = 110.0
@export var raio_deteccao: float = 220.0
@export var raio_roubo: float = 25.0
@export var duracao_fuga: float = 3.5

var _estado: Estado = Estado.PATRULHA
var _timer_fuga: float = 0.0
var _pos_inicial: Vector2
var _cooldown_roubo: float = 0.0

func _ready() -> void:
	_pos_inicial = global_position

func _physics_process(delta: float) -> void:
	_cooldown_roubo -= delta
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	match _estado:
		Estado.PATRULHA:
			_mover_para(_pos_inicial, velocidade * 0.4)
			if dist <= raio_deteccao and player.itens_carregados.size() > 0:
				_estado = Estado.PERSEGUINDO

		Estado.PERSEGUINDO:
			if player.itens_carregados.is_empty():
				_estado = Estado.PATRULHA
			elif dist <= raio_roubo and _cooldown_roubo <= 0:
				_roubar(player)
			elif dist > raio_deteccao * 1.4:
				_estado = Estado.PATRULHA
			else:
				_mover_para(player.global_position, velocidade)

		Estado.FUGINDO:
			_timer_fuga -= delta
			var dir_fuga = (global_position - player.global_position).normalized()
			velocity = dir_fuga * velocidade * 1.2
			if _timer_fuga <= 0:
				_estado = Estado.PATRULHA

	move_and_slide()

func _mover_para(alvo: Vector2, vel: float) -> void:
	var dir = alvo - global_position
	if dir.length() > 5.0:
		velocity = dir.normalized() * vel
	else:
		velocity = Vector2.ZERO

func _roubar(player) -> void:
	if player.itens_carregados.is_empty():
		return
	player.itens_carregados.pop_back()
	player._atualizar_estado()
	player._atualizar_visual_itens()
	_estado = Estado.FUGINDO
	_timer_fuga = duracao_fuga
	_cooldown_roubo = duracao_fuga + 1.0
	print("Ladrao roubou um item!")

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.8, 0.1, 0.1))
	draw_arc(Vector2.ZERO, raio_deteccao / 4.0, 0, TAU, 24, Color(0.8, 0.1, 0.1, 0.25), 1.5)
