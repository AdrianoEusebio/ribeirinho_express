class_name Dock
extends Node2D

signal pedido_entregue(pontos: int)

@export var pool_pedidos: Array[OrderData] = []
@export var cor: Color = Color(0.2, 0.5, 0.9)
@export var largura_dock: float = 100.0
@export var altura_dock: float = 60.0

var pedido: OrderData = null

@onready var label_pedido: Label = $LabelPedido

func _ready() -> void:
	add_to_group("doca")
	_proximo_pedido()

func _proximo_pedido() -> void:
	if pool_pedidos.is_empty():
		pedido = null
	else:
		var disponiveis = pool_pedidos.filter(func(p): return p != pedido)
		if disponiveis.is_empty():
			disponiveis = pool_pedidos
		pedido = disponiveis[randi() % disponiveis.size()]
	_atualizar_label()

func _atualizar_label() -> void:
	if pedido == null:
		label_pedido.text = "[Doca livre]"
		return
	var texto = pedido.nome + ":\n"
	for item in pedido.itens_necessarios:
		texto += "- " + item.nome + "\n"
	label_pedido.text = texto

func verificar_entrega_por_grid(grid_data: GridData) -> bool:
	if pedido == null:
		return false

	var itens_no_grid: Array = []
	for x in range(grid_data.largura):
		for y in range(grid_data.altura):
			var item = grid_data.celulas[x][y]
			if item != null and not item in itens_no_grid:
				itens_no_grid.append(item)

	var itens_encontrados: Array = []
	for item_pedido in pedido.itens_necessarios:
		var encontrado = false
		for item in itens_no_grid:
			if item.nome == item_pedido.nome and not item in itens_encontrados:
				itens_encontrados.append(item)
				encontrado = true
				break
		if not encontrado:
			return false

	var pontos = pedido.recompensa_pontos
	_mostrar_feedback(pontos)
	pedido = null
	_proximo_pedido()
	pedido_entregue.emit(pontos)
	return true

func _mostrar_feedback(pontos: int) -> void:
	var label = Label.new()
	label.text = "+%d pts!" % pontos
	label.position = Vector2(largura_dock / 2.0 - 30.0, -20.0)
	add_child(label)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 60.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	tween.chain().tween_callback(label.queue_free)

func _draw() -> void:
	draw_rect(Rect2(0, 0, largura_dock, altura_dock), cor)
	draw_rect(Rect2(0, 0, largura_dock, altura_dock), Color.WHITE, false, 2.0)
