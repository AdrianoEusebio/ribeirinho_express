## Caminhao de suprimentos que abastece o porto com cargas coletaveis.
##
## - Descarrega uma carga por ciclo no primeiro slot livre.
## - Prioriza itens pedidos pelos barcos ativos.
## - Pausa quando a area de descarga esta cheia.
## - Retoma automaticamente quando o jogador coleta uma carga.
extends Node2D

const TODOS_ITENS := [
	preload("res://resources/itens/caixa_media.tres"),
	preload("res://resources/itens/caixa_pequena.tres"),
	preload("res://resources/itens/geladeira.tres"),
	preload("res://resources/itens/medicamento.tres"),
	preload("res://resources/itens/saco_graos.tres"),
	# Novos Itens - Pesados
	preload("res://resources/itens/maquina_lavar.tres"),
	preload("res://resources/itens/sofa.tres"),
	preload("res://resources/itens/armario.tres"),
	preload("res://resources/itens/botijao_gas.tres"),
	preload("res://resources/itens/roda_caminhao.tres"),
	# Novos Itens - Médios
	preload("res://resources/itens/microondas.tres"),
	preload("res://resources/itens/televisao.tres"),
	preload("res://resources/itens/cesta_acai.tres"),
	preload("res://resources/itens/caixa_isopor.tres"),
	preload("res://resources/itens/caixa_suprimentos.tres"),
	# Novos Itens - Frágeis
	preload("res://resources/itens/abajur.tres"),
	preload("res://resources/itens/radio_pilha.tres"),
	preload("res://resources/itens/caixa_copos.tres"),
	preload("res://resources/itens/vaso_planta.tres"),
	preload("res://resources/itens/cesta_ovos.tres"),
]
const ITEM_SLOT_SCRIPT := preload("res://scripts/systems/item_slot.gd")

@export var max_slots: int = 6
@export var intervalo_remessa: float = 5.0
@export var peso_item_pedido: int = 8
@export var peso_item_extra: int = 1
@export var max_duplicatas_base: int = 2

const TRUCK_W := 108.0
const TRUCK_H := 48.0
const CAB_W := 34.0
const SLOT_SZ := 44.0
const SLOT_GAP := 8.0
const DOCK_W := 350.0
const DOCK_H := 72.0

var _slot_nodes: Array = []
var _slots_pos: Array[Vector2] = []
var _acabou_de_descarregar: float = 0.0

@onready var _timer: Timer = $Timer
@onready var _container: Node2D = $Container


var _sprite_esteira: Sprite2D
var _esteira_timer: float = 0.0

func _ready() -> void:
	max_slots = max(1, max_slots)
	_garantir_slots_prontos()

	# Configurar Sprite da Esteira Animada
	_sprite_esteira = Sprite2D.new()
	_sprite_esteira.texture = load("res://assets/assets/conveyorbelt605x60.webp")
	_sprite_esteira.region_enabled = true
	# 600x238 total -> 4 frames de ~59.5px altura
	_sprite_esteira.region_rect = Rect2(0, 0, 600, 59)
	_sprite_esteira.centered = false
	_sprite_esteira.position = Vector2(TRUCK_W + 22.0, 10.0)
	# Escala para a largura da doca (350 / 600)
	_sprite_esteira.scale = Vector2(DOCK_W / 600.0, 1.0)
	add_child(_sprite_esteira)
	move_child(_sprite_esteira, 0)

	_timer.wait_time = intervalo_remessa
	_timer.one_shot = true
	_timer.timeout.connect(_ao_tempo_remessa)
	_timer.start()
	queue_redraw()


func _process(delta: float) -> void:
	_verificar_slots_liberados()
	
	# Animação da Esteira
	if _sprite_esteira:
		_esteira_timer += delta * 10.0 # Velocidade da animação
		var frame := int(_esteira_timer) % 4
		_sprite_esteira.region_rect.position.y = frame * (238.0 / 4.0)

	if _acabou_de_descarregar > 0.0:
		_acabou_de_descarregar = maxf(0.0, _acabou_de_descarregar - delta)
		queue_redraw()


func _calcular_layout() -> void:
	_slots_pos.clear()
	var inicio_x := TRUCK_W + 36.0
	var y := TRUCK_H / 2.0
	for i in max_slots:
		var x := inicio_x + i * (SLOT_SZ + SLOT_GAP) + SLOT_SZ / 2.0
		_slots_pos.append(Vector2(x, y))


func _garantir_slots_prontos() -> void:
	max_slots = max(1, max_slots)
	if _slots_pos.size() != max_slots:
		_calcular_layout()
	if _slot_nodes.size() != max_slots:
		_slot_nodes.resize(max_slots)


func _verificar_slots_liberados() -> void:
	_garantir_slots_prontos()
	var mudou := false

	for i in max_slots:
		var node = _slot_nodes[i]
		if node != null:
			# Verifica se o nodo ainda é válido E não está agendado para deleção
			if not is_instance_valid(node) or node.is_queued_for_deletion():
				_slot_nodes[i] = null
				mudou = true

	if mudou:
		queue_redraw()
		# Garante que o gerador retome se houver espaço e o timer estiver parado
		if _tem_slot_livre() and _timer != null and _timer.is_stopped():
			_timer.start()


func _tem_slot_livre() -> bool:
	return _primeiro_slot_livre() != -1


func _primeiro_slot_livre() -> int:
	_garantir_slots_prontos()
	for i in max_slots:
		var node = _slot_nodes[i]
		if node == null or not is_instance_valid(node) or node.is_queued_for_deletion():
			return i
	return -1


func _ao_tempo_remessa() -> void:
	_garantir_slots_prontos()
	var slot_idx := _primeiro_slot_livre()
	if slot_idx == -1:
		queue_redraw()
		return

	_descarregar_item(slot_idx)

	if _tem_slot_livre():
		if _timer != null:
			_timer.start()
	else:
		queue_redraw()


func _descarregar_item(slot_idx: int) -> void:
	var dados := _escolher_item()
	if dados == null:
		return

	var nodo := Node2D.new()
	nodo.set_script(ITEM_SLOT_SCRIPT)
	nodo.position = _slots_pos[slot_idx]
	_container.add_child(nodo)
	nodo.dados = dados
	nodo.queue_redraw()
	_slot_nodes[slot_idx] = nodo

	_acabou_de_descarregar = 0.22
	queue_redraw()


func _escolher_item() -> ItemData:
	var pedidos_ativos := _contar_itens_pedidos_ativos()
	var visiveis := _contar_itens_visiveis()
	var entradas: Array = []
	var peso_total := 0

	for item in TODOS_ITENS:
		var nome: String = item.nome
		var pedidos: int = pedidos_ativos.get(nome, 0)
		var quantidade_visivel: int = visiveis.get(nome, 0)
		var limite_visivel: int = max(max_duplicatas_base, pedidos)

		var peso := peso_item_extra
		if pedidos > 0:
			peso = peso_item_pedido * pedidos

		if quantidade_visivel >= limite_visivel:
			peso = 0
		elif quantidade_visivel > 0:
			peso = maxi(1, peso - quantidade_visivel * 2)

		if peso > 0:
			entradas.append({"item": item, "peso": peso})
			peso_total += peso

	if entradas.is_empty():
		for item in TODOS_ITENS:
			entradas.append({"item": item, "peso": 1})
			peso_total += 1

	var rolagem := randi_range(1, peso_total)
	var acumulado := 0
	for entrada in entradas:
		acumulado += entrada["peso"]
		if rolagem <= acumulado:
			return entrada["item"].duplicate()

	return TODOS_ITENS[0].duplicate()


func _contar_itens_visiveis() -> Dictionary:
	var contagem := {}
	for node in _slot_nodes:
		if node != null and is_instance_valid(node) and node.dados != null:
			var nome: String = node.dados.nome
			contagem[nome] = contagem.get(nome, 0) + 1
	return contagem


func _contar_itens_pedidos_ativos() -> Dictionary:
	var contagem := {}
	for doca in get_tree().get_nodes_in_group("doca"):
		var barcos = doca.get("boats")
		if not (barcos is Array):
			continue
		for boat in barcos:
			if boat == null or not is_instance_valid(boat):
				continue
			if boat.pedido == null:
				continue
			for item in boat.pedido.itens_necessarios:
				if item == null:
					continue
				contagem[item.nome] = contagem.get(item.nome, 0) + 1
	return contagem


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var descarga_cheia := not _tem_slot_livre()

	_desenhar_caminhao(font)
	# _desenhar_area_descarga(font, descarga_cheia)
	_desenhar_slots(font)

	if descarga_cheia:
		draw_string(font, Vector2(TRUCK_W + 130.0, -8.0), "SEM ESPACO",
			HORIZONTAL_ALIGNMENT_CENTER, 120, 11, Color(1.0, 0.42, 0.28))


func _desenhar_caminhao(font: Font) -> void:
	var brilho := 0.08 if _acabou_de_descarregar > 0.0 else 0.0
	var carroceria := Color(0.78 + brilho, 0.32 + brilho, 0.18 + brilho)
	var cabine := Color(0.18, 0.56 + brilho, 0.78 + brilho)
	var sombra := Color(0.05, 0.04, 0.035, 0.32)

	draw_rect(Rect2(5.0, TRUCK_H - 1.0, TRUCK_W + 10.0, 8.0), sombra)
	draw_rect(Rect2(0.0, 7.0, TRUCK_W - CAB_W, 31.0), carroceria)
	draw_rect(Rect2(TRUCK_W - CAB_W, 14.0, CAB_W, 24.0), cabine)
	draw_rect(Rect2(TRUCK_W - CAB_W + 5.0, 18.0, 14.0, 9.0), Color(0.75, 0.92, 1.0))
	draw_rect(Rect2(0.0, 7.0, TRUCK_W - CAB_W, 31.0), Color(0.95, 0.78, 0.45), false, 1.5)
	draw_rect(Rect2(TRUCK_W - CAB_W, 14.0, CAB_W, 24.0), Color(0.9, 0.95, 1.0), false, 1.5)
	draw_circle(Vector2(21.0, 42.0), 8.0, Color(0.08, 0.08, 0.08))
	draw_circle(Vector2(84.0, 42.0), 8.0, Color(0.08, 0.08, 0.08))
	draw_circle(Vector2(21.0, 42.0), 3.3, Color(0.55, 0.55, 0.55))
	draw_circle(Vector2(84.0, 42.0), 3.3, Color(0.55, 0.55, 0.55))
	draw_string(font, Vector2(10.0, 28.0), "SUPRIMENTOS",
		HORIZONTAL_ALIGNMENT_CENTER, 70, 8, Color(1.0, 0.93, 0.72))


func _desenhar_area_descarga(font: Font, cheia: bool) -> void:
	var origem := Vector2(TRUCK_W + 22.0, 4.0)
	var cor_base := Color(0.34, 0.24, 0.14)
	var cor_linha := Color(0.62, 0.46, 0.26)
	if cheia:
		cor_linha = Color(1.0, 0.46, 0.28)

	draw_rect(Rect2(origem.x, origem.y, DOCK_W, DOCK_H - 22.0), Color(0.13, 0.11, 0.09, 0.72))
	draw_rect(Rect2(origem.x, origem.y + DOCK_H - 24.0, DOCK_W, 14.0), cor_base)
	for i in range(0, int(DOCK_W), 28):
		var x := origem.x + i
		draw_line(Vector2(x, origem.y + DOCK_H - 23.0), Vector2(x + 18.0, origem.y + DOCK_H - 11.0), cor_linha, 1.5)
	draw_rect(Rect2(origem.x, origem.y + DOCK_H - 24.0, DOCK_W, 14.0), cor_linha, false, 1.0)
	draw_string(font, Vector2(origem.x + 8.0, origem.y + 11.0), "CARGAS",
		HORIZONTAL_ALIGNMENT_LEFT, 70, 10, Color(0.84, 0.9, 0.86))


func _desenhar_slots(font: Font) -> void:
	for i in max_slots:
		var center := _slots_pos[i]
		var half := SLOT_SZ / 2.0
		var rect := Rect2(center.x - half, center.y - half, SLOT_SZ, SLOT_SZ)
		var cheio := _slot_nodes[i] != null and is_instance_valid(_slot_nodes[i])
		var fundo := Color(0.16, 0.13, 0.1) if not cheio else Color(0.22, 0.18, 0.13)

		draw_rect(rect, fundo)
		draw_rect(rect, Color(0.56, 0.42, 0.26), false, 1.5)
		if not cheio:
			draw_string(font, Vector2(center.x - 9.0, center.y + 4.0), str(i + 1),
				HORIZONTAL_ALIGNMENT_CENTER, 18, 10, Color(0.46, 0.38, 0.29))
