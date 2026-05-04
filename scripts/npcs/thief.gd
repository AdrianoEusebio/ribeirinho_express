extends CharacterBody2D

enum Estado { PATRULHA, PERSEGUINDO, FUGINDO }

const SPRITESHEET: Texture2D = preload("res://assets/images/npc/ladrao.png")
const FRAME_SIZE := Vector2i(32, 32)
const FRAME_COUNT := 6
const ANIMATIONS := {
	"idle_down": 0,
	"idle_right": 1,
	"idle_up": 2,
	"run_down": 3,
	"run_right": 4,
	"run_up": 5,
}

@export var velocidade: float = 110.0
@export var raio_deteccao: float = 220.0
@export var raio_roubo: float = 48.0
@export var duracao_fuga: float = 3.5

var _estado: Estado = Estado.PATRULHA
var _timer_fuga: float = 0.0
var _pos_inicial: Vector2
var _cooldown_roubo: float = 0.0
var _ultima_direcao: Vector2 = Vector2.DOWN
var _tempo_travado: float = 0.0
var _angulo_desvio: float = 0.0
var _vel_antes: float = 0.0
var _pos_antes: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_pos_inicial = global_position
	_pos_antes = global_position
	_configurar_animacoes()
	_atualizar_animacao()

func _physics_process(delta: float) -> void:
	z_index = int(global_position.y)
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
			elif dist > raio_deteccao * 1.4:
				_estado = Estado.PATRULHA
			else:
				_mover_para(player.global_position, velocidade)

		Estado.FUGINDO:
			_timer_fuga -= delta
			var dir_fuga = (global_position - player.global_position).normalized()
			if _angulo_desvio != 0.0:
				dir_fuga = dir_fuga.rotated(_angulo_desvio)
			velocity = dir_fuga * velocidade * 1.2
			if _timer_fuga <= 0:
				_estado = Estado.PATRULHA

	_vel_antes = velocity.length()
	_pos_antes = global_position
	move_and_slide()
	_checar_travamento(delta)
	_tentar_roubar_por_contato(player)
	_atualizar_animacao()

func _mover_para(alvo: Vector2, vel: float) -> void:
	var dir = alvo - global_position
	if dir.length() > 5.0:
		var dir_norm = dir.normalized()
		if _angulo_desvio != 0.0:
			dir_norm = dir_norm.rotated(_angulo_desvio)
		velocity = dir_norm * vel
	else:
		velocity = Vector2.ZERO
		_tempo_travado = 0.0
		_angulo_desvio = 0.0

func _checar_travamento(delta: float) -> void:
	if _vel_antes < 5.0:
		_tempo_travado = maxf(0.0, _tempo_travado - delta * 2.0)
		if _tempo_travado < 0.05:
			_angulo_desvio = 0.0
		return
	var deslocamento = global_position.distance_to(_pos_antes)
	if deslocamento < _vel_antes * delta * 0.2:
		_tempo_travado += delta
		if _tempo_travado > 0.2 and _angulo_desvio == 0.0:
			_angulo_desvio = PI / 2.0
		elif _tempo_travado > 1.5:
			_angulo_desvio = -_angulo_desvio
			_tempo_travado = 0.3
	else:
		_tempo_travado = maxf(0.0, _tempo_travado - delta * 2.0)
		if _tempo_travado < 0.05:
			_angulo_desvio = 0.0

func _roubar(player) -> void:
	if player.itens_carregados.is_empty():
		return
	player.itens_carregados.pop_back()
	player._atualizar_estado()
	player._atualizar_visual_itens()
	player.mostrar_indicador_roubo()
	_estado = Estado.FUGINDO
	_timer_fuga = duracao_fuga
	_cooldown_roubo = duracao_fuga + 1.0

func _tentar_roubar_por_contato(player) -> void:
	if _estado != Estado.PERSEGUINDO or _cooldown_roubo > 0:
		return
	if player.itens_carregados.is_empty():
		return
	if _encostou_no_player(player):
		_roubar(player)

func _encostou_no_player(player) -> bool:
	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		var collider := collision.get_collider()
		if collider == player:
			return true

	return global_position.distance_to(player.global_position) <= raio_roubo

func _configurar_animacoes() -> void:
	var frames := SpriteFrames.new()
	for animation_name in ANIMATIONS:
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.set_animation_speed(animation_name, 7.0 if animation_name.begins_with("run") else 5.0)
		for frame_index in FRAME_COUNT:
			frames.add_frame(animation_name, _criar_frame(ANIMATIONS[animation_name], frame_index))

	if frames.has_animation("default"):
		frames.remove_animation("default")
	animated_sprite_2d.sprite_frames = frames

func _criar_frame(row: int, column: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = SPRITESHEET
	frame.region = Rect2(column * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return frame

func _atualizar_animacao() -> void:
	if velocity.length() > 0.1:
		_ultima_direcao = velocity.normalized()
		_tocar_animacao("run", _ultima_direcao)
	else:
		_tocar_animacao("idle", _ultima_direcao)

func _tocar_animacao(prefixo: String, direcao: Vector2) -> void:
	if absf(direcao.x) > absf(direcao.y):
		animated_sprite_2d.flip_h = direcao.x < 0.0
		animated_sprite_2d.play(prefixo + "_right")
	elif direcao.y < 0.0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(prefixo + "_up")
	else:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(prefixo + "_down")
