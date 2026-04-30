extends CharacterBody2D

@export var velocidade: float = 70.0
@export var distancia_patrulha: float = 180.0
@export var duracao_atordoamento: float = 1.5
@export var raio_colisao: float = 20.0

var _direcao: float = 1.0
var _percorrido: float = 0.0
var _cooldown_colisao: float = 0.0

func _physics_process(delta: float) -> void:
	_cooldown_colisao -= delta

	velocity = Vector2(_direcao * velocidade, 0)
	_percorrido += velocidade * delta

	if _percorrido >= distancia_patrulha:
		_direcao *= -1
		_percorrido = 0.0

	move_and_slide()
	_checar_colisao_player()

func _checar_colisao_player() -> void:
	if _cooldown_colisao > 0:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	if global_position.distance_to(player.global_position) <= raio_colisao * 4:
		player.atordoar(duracao_atordoamento)
		_cooldown_colisao = duracao_atordoamento + 0.5

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.5, 0.1))
