extends CharacterBody2D

const SPRITESHEET: Texture2D = preload("res://assets/images/npc/patrulheiro.png")
const FRAME_SIZE := Vector2i(32, 32)
const FRAME_COUNT := 6
const IDLE_RIGHT_ROW := 1
const RUN_RIGHT_ROW  := 4
const IDLE_ANIMATION := "idle_right"
const RUN_ANIMATION  := "run_right"

@export var velocidade: float = 45.0
@export var raio_passeio: float = 250.0
@export var raio_colisao: float = 15.0
@export var forca_knockback: float = 180.0

var _pos_inicial: Vector2
var _destino: Vector2
var _timer_destino: float = 0.0
var _cooldown_colisao: float = 0.0
var _cooldown_reescolha: float = 0.0
var _flip_h: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_pos_inicial = global_position
	_destino = global_position
	_configurar_animacoes()
	_escolher_destino()

func _physics_process(delta: float) -> void:
	z_index = int(global_position.y)
	_cooldown_colisao  -= delta
	_cooldown_reescolha -= delta
	_timer_destino -= delta

	var dist := global_position.distance_to(_destino)
	if dist < 12.0 or _timer_destino <= 0.0:
		velocity = Vector2.ZERO
		animated_sprite_2d.flip_h = _flip_h
		animated_sprite_2d.play(IDLE_ANIMATION)
		if _timer_destino <= 0.0:
			_escolher_destino()
	else:
		var dir := (_destino - global_position).normalized()
		_flip_h = dir.x < 0.0
		
		# Deteção Visual e Aceleração (Implementation 12)
		var vel_atual = velocidade
		var player = get_tree().get_first_node_in_group("player")
		if player and global_position.distance_to(player.global_position) < 160.0:
			var dir_ao_player = (player.global_position - global_position).normalized()
			if dir_ao_player.dot(dir) > 0.7: # Player na frente
				vel_atual *= 2.4 # Acelera para empurrar
		
		velocity = dir * vel_atual
		animated_sprite_2d.flip_h = _flip_h
		animated_sprite_2d.play(RUN_ANIMATION)

	move_and_slide()

	# Re-pick destination when hitting a wall
	if _cooldown_reescolha <= 0.0:
		for i in range(get_slide_collision_count()):
			if not get_slide_collision(i).get_collider().is_in_group("player"):
				_escolher_destino()
				_cooldown_reescolha = 1.2
				break

	_checar_colisao_player()

func _escolher_destino() -> void:
	var angulo := randf() * TAU
	var dist := randf_range(60.0, raio_passeio)
	_destino = _pos_inicial + Vector2(cos(angulo), sin(angulo)) * dist
	_timer_destino = randf_range(3.0, 7.0)

func _configurar_animacoes() -> void:
	var frames := SpriteFrames.new()

	frames.add_animation(IDLE_ANIMATION)
	frames.set_animation_loop(IDLE_ANIMATION, true)
	frames.set_animation_speed(IDLE_ANIMATION, 5.0)
	for frame_index in FRAME_COUNT:
		frames.add_frame(IDLE_ANIMATION, _criar_frame(IDLE_RIGHT_ROW, frame_index))

	frames.add_animation(RUN_ANIMATION)
	frames.set_animation_loop(RUN_ANIMATION, true)
	frames.set_animation_speed(RUN_ANIMATION, 6.0)
	for frame_index in FRAME_COUNT:
		frames.add_frame(RUN_ANIMATION, _criar_frame(RUN_RIGHT_ROW, frame_index))

	if frames.has_animation("default"):
		frames.remove_animation("default")
	animated_sprite_2d.sprite_frames = frames

func _criar_frame(row: int, column: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = SPRITESHEET
	frame.region = Rect2(column * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return frame

func _checar_colisao_player() -> void:
	if _cooldown_colisao > 0:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	if global_position.distance_to(player.global_position) <= raio_colisao * 4:
		var direcao_repulsao: Vector2 = (player.global_position - global_position).normalized()
		player.aplicar_knockback(direcao_repulsao, forca_knockback)
		_cooldown_colisao = 0.6
