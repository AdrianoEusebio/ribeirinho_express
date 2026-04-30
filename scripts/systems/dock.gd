class_name Dock
extends Node2D

signal pedido_entregue(pontos: int)

@export var pool_pedidos: Array[OrderData] = []
@export var cor: Color = Color(0.2, 0.5, 0.9)
@export var largura_dock: float = 100.0
@export var altura_dock: float = 60.0
@export var margem_ativacao: float = 6.0
@export var opacidade_fundo: float = 0.28
@export var opacidade_pulso_min: float = 0.35
@export var opacidade_pulso_max: float = 0.8
@export var velocidade_pulso: float = 1.6
@export var tamanho_tracejado: float = 10.0
@export var intervalo_tracejado: float = 6.0

var pedido: OrderData = null
var _tempo_pulso: float = 0.0

@onready var label_pedido: Label = $LabelPedido

func _ready() -> void:
	add_to_group("doca")
	_proximo_pedido()

func _process(delta: float) -> void:
	_tempo_pulso += delta
	queue_redraw()

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

func contem_posicao_global(posicao: Vector2) -> bool:
	var rect := Rect2(global_position, Vector2(largura_dock, altura_dock)).grow(margem_ativacao)
	return rect.has_point(posicao)

func player_esta_na_area() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	return player != null and contem_posicao_global(player.global_position)

func centro_global() -> Vector2:
	return global_position + Vector2(largura_dock, altura_dock) * 0.5

func _draw() -> void:
	var rect := Rect2(0, 0, largura_dock, altura_dock)
	var fundo := cor
	fundo.a = opacidade_fundo
	draw_rect(rect, fundo)

	var pulso := (sin(_tempo_pulso * TAU * velocidade_pulso) + 1.0) * 0.5
	var alpha := lerpf(opacidade_pulso_min, opacidade_pulso_max, pulso)
	var cor_borda := cor.lerp(Color.WHITE, 0.35)
	cor_borda.a = alpha
	_desenhar_borda_tracejada(rect, cor_borda, 2.0)

func _desenhar_borda_tracejada(rect: Rect2, cor_linha: Color, largura: float) -> void:
	var pontos := [
		rect.position,
		rect.position + Vector2(rect.size.x, 0),
		rect.position + rect.size,
		rect.position + Vector2(0, rect.size.y),
	]

	for index in range(pontos.size()):
		_desenhar_linha_tracejada(pontos[index], pontos[(index + 1) % pontos.size()], cor_linha, largura)

func _desenhar_linha_tracejada(inicio: Vector2, fim: Vector2, cor_linha: Color, largura: float) -> void:
	var vetor := fim - inicio
	var comprimento := vetor.length()
	if comprimento <= 0.0:
		return

	var direcao := vetor / comprimento
	var distancia := 0.0
	while distancia < comprimento:
		var fim_tracejo := minf(distancia + tamanho_tracejado, comprimento)
		draw_line(inicio + direcao * distancia, inicio + direcao * fim_tracejo, cor_linha, largura)
		distancia += tamanho_tracejado + intervalo_tracejado
