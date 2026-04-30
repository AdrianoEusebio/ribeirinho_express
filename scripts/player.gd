extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var last_direction: Vector2 = Vector2.RIGHT
var hitbox_offset: Vector2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	hitbox_offset = hitbox.position

func _physics_process(_delta: float) -> void:
	process_movement()
	process_animation(last_direction)
	move_and_slide()
	
	
# ----------------------------------
# Movimentos do Bonecos + animação
# ----------------------------------
func process_movement() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else:
		velocity = direction * Vector2.ZERO
	
	process_animation(last_direction)

func process_animation(direction) -> void:
	if velocity != Vector2.ZERO:
		play_animation("run", direction)
	else:
		play_animation("idle", direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play( prefix + "_right")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	
	
# ----------------------------------
# Hitbox
# ----------------------------------

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match  last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)
		
		
		
		
		
		
		
		
		
