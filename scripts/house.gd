extends Node2D

enum EstadoFoco { FORA, ENTRANDO, DENTRO, SAINDO }

@export var tamanho_mundo: Vector2 = Vector2(2560, 1440)
@export_range(0.0, 1.0, 0.01) var opacidade_mundo: float = 0.55
@export_range(0.0, 1.0, 0.01) var opacidade_casa_fora_focada: float = 0.12
@export var duracao_transicao: float = 0.35
@export var z_foco: int = 60
@export var z_casa_fora: int = 1
@export var z_casa_dentro: int = 0
@export var z_itens_fora: int = 0
@export var z_spawners_fora: int = 0
@export var itens_container_path: NodePath = ^"../Itens"
@export var spawners_container_path: NodePath = ^"../Spawners"
@export var npcs_container_path: NodePath = ^"../NPCs"

var _tween: Tween
var _player_dentro: Node2D
var _itens_container: Node2D
var _spawners_container: Node2D
var _npcs_container: Node2D
var _estado_foco: EstadoFoco = EstadoFoco.FORA
var _alpha_original_area_interior: Dictionary = {}

@onready var dimmer: ColorRect = $Dimmer
@onready var casa_fora: Sprite2D = $CasaFora
@onready var casa_dentro: Sprite2D = $CasaDentro
@onready var area_interior: Area2D = $AreaInterior
@onready var area_interior_shape: CollisionShape2D = $AreaInterior/CollisionShape2D
@onready var paredes_dentro: Node2D = $ParedesDentro
@onready var paredes_fora: Node2D = $ParedesFora


func _ready() -> void:
	_itens_container = get_node_or_null(itens_container_path)
	_spawners_container = get_node_or_null(spawners_container_path)
	_npcs_container = get_node_or_null(npcs_container_path)

	dimmer.size = tamanho_mundo
	dimmer.global_position = Vector2.ZERO
	dimmer.color = Color(0.0, 0.0, 0.0, 0.0)

	# Calcula o z_index da fachada baseado no Y-mundo da base da casa
	var rect := area_interior_shape.shape as RectangleShape2D
	if rect:
		var scale_y := absf(area_interior_shape.global_transform.get_scale().y)
		var base_y := area_interior_shape.global_position.y + rect.size.y * 0.5 * scale_y
		z_casa_fora = int(base_y)

	casa_fora.modulate = Color.WHITE
	casa_dentro.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_aplicar_estado_fora()

	area_interior.body_entered.connect(_on_area_interior_body_entered)
	area_interior.body_exited.connect(_on_area_interior_body_exited)


func _process(_delta: float) -> void:
	if dimmer.visible:
		dimmer.global_position = Vector2.ZERO
	if _estado_foco == EstadoFoco.FORA:
		_ocultar_nos_area_interior_imediato()
	elif _estado_foco == EstadoFoco.DENTRO:
		_mostrar_novos_nos_area_interior()


func _on_area_interior_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	_player_dentro = body
	_estado_foco = EstadoFoco.ENTRANDO
	body.z_index = z_foco + 3
	casa_dentro.z_index = z_foco + 1
	casa_fora.z_index = z_foco + 1
	if _itens_container:
		_itens_container.z_index = z_foco + 2
	if _spawners_container:
		_spawners_container.z_index = z_foco + 2
	_set_collision_enabled(paredes_fora, false)
	_set_collision_enabled(paredes_dentro, true)
	_ocultar_npcs_externos()
	_animar_foco(true)


func _on_area_interior_body_exited(body: Node2D) -> void:
	if body != _player_dentro:
		return

	_estado_foco = EstadoFoco.SAINDO
	_set_collision_enabled(paredes_fora, true)
	_set_collision_enabled(paredes_dentro, false)
	_player_dentro = null
	_animar_foco(false)


func _animar_foco(ativo: bool) -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)

	_tween.tween_property(dimmer, "color:a", opacidade_mundo if ativo else 0.0, duracao_transicao)
	_tween.tween_property(casa_fora, "modulate:a", opacidade_casa_fora_focada if ativo else 1.0, duracao_transicao)
	_tween.tween_property(casa_dentro, "modulate:a", 1.0 if ativo else 0.0, duracao_transicao)
	var nos_area_interior := _preparar_nos_area_interior_para_transicao(ativo)
	for node in nos_area_interior:
		_tween.tween_property(node, "modulate:a", _get_alpha_original(node) if ativo else 0.0, duracao_transicao)
	if ativo:
		_tween.finished.connect(_finalizar_estado_dentro)
	else:
		_tween.finished.connect(_aplicar_estado_fora)


func _aplicar_estado_fora() -> void:
	_mostrar_todos_npcs()
	_estado_foco = EstadoFoco.FORA
	casa_fora.z_index = z_casa_fora
	casa_dentro.z_index = z_casa_dentro
	if _itens_container:
		_itens_container.z_index = z_itens_fora
	if _spawners_container:
		_spawners_container.z_index = z_spawners_fora
	_ocultar_nos_area_interior_imediato()
	_set_collision_enabled(paredes_fora, true)
	_set_collision_enabled(paredes_dentro, false)


func _finalizar_estado_dentro() -> void:
	_estado_foco = EstadoFoco.DENTRO
	_mostrar_novos_nos_area_interior()


func _set_collision_enabled(node: Node, enabled: bool) -> void:
	for child in node.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", not enabled)
		_set_collision_enabled(child, enabled)


func _preparar_nos_area_interior_para_transicao(entrando: bool) -> Array[CanvasItem]:
	var nodes := _coletar_nos_area_interior()
	for node in nodes:
		_registrar_alpha_original(node)
		node.visible = true
		if entrando:
			_set_alpha(node, 0.0)
	return nodes


func _ocultar_nos_area_interior_imediato() -> void:
	for node in _coletar_nos_area_interior():
		_registrar_alpha_original(node)
		node.visible = false
		_set_alpha(node, _get_alpha_original(node))


func _mostrar_novos_nos_area_interior() -> void:
	for node in _coletar_nos_area_interior():
		_registrar_alpha_original(node)
		node.visible = true
		_set_alpha(node, _get_alpha_original(node))


func _coletar_nos_area_interior() -> Array[CanvasItem]:
	var nodes: Array[CanvasItem] = []
	_coletar_filhos_na_area(_itens_container, nodes)
	_coletar_filhos_na_area(_spawners_container, nodes)
	return nodes


func _coletar_filhos_na_area(container: Node2D, nodes: Array[CanvasItem]) -> void:
	if not container:
		return

	for child in container.get_children():
		var node_2d := child as Node2D
		var canvas_item := child as CanvasItem
		if node_2d and canvas_item and _esta_na_area_interior(node_2d) and not nodes.has(canvas_item):
			nodes.append(canvas_item)


func _registrar_alpha_original(node: CanvasItem) -> void:
	if not _alpha_original_area_interior.has(node):
		_alpha_original_area_interior[node] = node.modulate.a


func _get_alpha_original(node: CanvasItem) -> float:
	if not _alpha_original_area_interior.has(node):
		return 1.0
	return _alpha_original_area_interior[node]


func _set_alpha(node: CanvasItem, alpha: float) -> void:
	var color := node.modulate
	color.a = alpha
	node.modulate = color


func _ocultar_npcs_externos() -> void:
	if not _npcs_container:
		return
	for npc in _npcs_container.get_children():
		var node_2d := npc as Node2D
		if node_2d:
			node_2d.visible = _esta_na_area_interior(node_2d)


func _mostrar_todos_npcs() -> void:
	if not _npcs_container:
		return
	for npc in _npcs_container.get_children():
		var node_2d := npc as Node2D
		if node_2d:
			node_2d.visible = true


func _esta_na_area_interior(node: Node2D) -> bool:
	var rectangle := area_interior_shape.shape as RectangleShape2D
	if not rectangle:
		return false

	var local_position := area_interior_shape.global_transform.affine_inverse() * node.global_position
	var half_size := rectangle.size * 0.5
	return absf(local_position.x) <= half_size.x and absf(local_position.y) <= half_size.y
