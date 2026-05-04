extends Node2D

signal boat_finished(boat)

enum State { ARRIVING, DOCKED, LEAVING }

@onready var sprite: Sprite2D = $Sprite2D
@onready var cargo_grid: Node2D = $CargoGrid
@onready var label_pedido: Label = $LabelPedido

var state: State = State.ARRIVING
var pedido: OrderData = null
var spot_index: int = 0

func _ready() -> void:
	# Escolhe uma cor de barco aleatória
	sprite.frame = randi() % sprite.vframes
	_atualizar_ui()

func setup(p: OrderData, index: int) -> void:
	pedido = p
	spot_index = index
	_atualizar_ui()

func chegar(destino: Vector2) -> void:
	state = State.ARRIVING
	# Começa fora da tela (direita)
	global_position = destino + Vector2(1200, 0)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", destino, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	state = State.DOCKED

func partir() -> void:
	state = State.LEAVING
	var tween = create_tween()
	# Vai embora para a esquerda (continuando em frente)
	tween.tween_property(self, "global_position", global_position + Vector2(-1200, 0), 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()

func _atualizar_ui() -> void:
	if not is_inside_tree() or label_pedido == null: return
	
	if pedido == null:
		label_pedido.text = ""
		return
		
	var texto = pedido.nome + ":\n"
	for item in pedido.itens_necessarios:
		texto += "- " + item.nome + "\n"
	label_pedido.text = texto

func verificar_pedido() -> bool:
	if state != State.DOCKED or pedido == null:
		return false
		
	if cargo_grid.verificar_entrega_por_pedido(pedido):
		boat_finished.emit(self)
		partir()
		return true
	return false
