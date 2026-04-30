extends CharacterBody2D

const SPRITESHEET: Texture2D = preload("res://assets/images/npc/patrulheiro.png")
const FRAME_SIZE := Vector2i(32, 32)
const FRAME_COUNT := 6
const RUN_RIGHT_ROW := 4
const RUN_RIGHT_ANIMATION := "run_right"

@export var velocidade: float = 70.0
@export var distancia_patrulha: float = 180.0
@export var duracao_atordoamento: float = 1.5
@export var raio_colisao: float = 15.0

var _direcao: float = 1.0
var _percorrido: float = 0.0
var _cooldown_colisao: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_configurar_animacoes()
	_atualizar_animacao()

func _physics_process(delta: float) -> void:
	_cooldown_colisao -= delta

	velocity = Vector2(_direcao * velocidade, 0)
	_percorrido += velocidade * delta

	if _percorrido >= distancia_patrulha:
		_direcao *= -1
		_percorrido = 0.0
		_atualizar_animacao()

	move_and_slide()
	_checar_colisao_player()

func _configurar_animacoes() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation(RUN_RIGHT_ANIMATION)
	frames.set_animation_loop(RUN_RIGHT_ANIMATION, true)
	frames.set_animation_speed(RUN_RIGHT_ANIMATION, 7.0)
	for frame_index in FRAME_COUNT:
		frames.add_frame(RUN_RIGHT_ANIMATION, _criar_frame(RUN_RIGHT_ROW, frame_index))

	if frames.has_animation("default"):
		frames.remove_animation("default")
	animated_sprite_2d.sprite_frames = frames

func _criar_frame(row: int, column: int) -> AtlasTexture:
	var frame := AtlasTexture.new()
	frame.atlas = SPRITESHEET
	frame.region = Rect2(column * FRAME_SIZE.x, row * FRAME_SIZE.y, FRAME_SIZE.x, FRAME_SIZE.y)
	return frame

func _atualizar_animacao() -> void:
	animated_sprite_2d.flip_h = _direcao < 0.0
	animated_sprite_2d.play(RUN_RIGHT_ANIMATION)

func _checar_colisao_player() -> void:
	if _cooldown_colisao > 0:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	if global_position.distance_to(player.global_position) <= raio_colisao * 4:
		player.atordoar(duracao_atordoamento)
		_cooldown_colisao = duracao_atordoamento + 0.5
