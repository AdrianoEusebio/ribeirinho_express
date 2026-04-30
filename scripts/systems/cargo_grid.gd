## Componente visual do Grid (Barco).
## Gerencia entrada de mouse, visualização e interação com o jogador.
extends Node2D

@export var largura: int = 5
@export var altura: int = 4
@export var tamanho_celula: int = 40

@export var distancia_interacao: float = 250.0

var grid: GridData
var item_em_preview: ItemData = null
var rotacao_atual: int = 0 
var item_to_sprite: Dictionary = {} # Mapeia ItemData -> Sprite2D

@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var container_itens: Node2D = $PlacedItems

func _ready() -> void:
	grid = GridData.new(largura, altura)
	grid.item_quebrado.connect(_on_item_quebrado)
	grid.item_caiu.connect(_on_item_caiu)
	preview_sprite.visible = false

func _on_item_quebrado(item_data: ItemData) -> void:
	if item_to_sprite.has(item_data):
		var sprite = item_to_sprite[item_data]
		sprite.queue_free()
		item_to_sprite.erase(item_data)

func _on_item_caiu(item_data: ItemData, nova_pos: Vector2i) -> void:
	if item_to_sprite.has(item_data):
		var sprite = item_to_sprite[item_data]
		var destino = Vector2(nova_pos.x * tamanho_celula, nova_pos.y * tamanho_celula)
		var tween = create_tween()
		tween.tween_property(sprite, "position", destino, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	# CALCULAR DISTÂNCIA AO CENTRO DO GRID
	var centro_grid = global_position + Vector2(largura * tamanho_celula, altura * tamanho_celula) / 2
	var distancia = player.global_position.distance_to(centro_grid)
	
	if distancia <= distancia_interacao and player.itens_carregados.size() > 0:
		_processar_preview(player)
	else:
		preview_sprite.visible = false

func _processar_preview(player) -> void:
	var mouse_pos = get_local_mouse_position()
	var grid_pos = Vector2i(floor(mouse_pos.x / tamanho_celula), floor(mouse_pos.y / tamanho_celula))
	
	item_em_preview = player.itens_carregados.back()
	
	if Input.is_action_just_pressed("rotate_item"):
		rotacao_atual = (rotacao_atual + 1) % 4
	
	var formato = item_em_preview.obter_formato_rotacionado(rotacao_atual)
	
	preview_sprite.visible = true
	preview_sprite.position = Vector2(grid_pos.x * tamanho_celula, grid_pos.y * tamanho_celula)
	
	if item_em_preview.icone:
		preview_sprite.texture = item_em_preview.icone
		preview_sprite.modulate = Color(1, 1, 1, 0.5)
	else:
		preview_sprite.texture = preload("res://icon.svg")
		preview_sprite.modulate = item_em_preview.cor
		preview_sprite.modulate.a = 0.5
	
	var tex_size = preview_sprite.texture.get_size()
	var eh_vertical = (rotacao_atual % 2 == 1)
	var tam_visual_x = item_em_preview.tamanho.y if eh_vertical else item_em_preview.tamanho.x
	var tam_visual_y = item_em_preview.tamanho.x if eh_vertical else item_em_preview.tamanho.y
	
	var escala_x = (tam_visual_x * tamanho_celula) / tex_size.x
	var escala_y = (tam_visual_y * tamanho_celula) / tex_size.y
	preview_sprite.scale = Vector2(escala_x, escala_y)
	
	if grid.pode_colocar(item_em_preview, grid_pos, formato):
		preview_sprite.modulate.r *= 0.5
		preview_sprite.modulate.b *= 0.5
		preview_sprite.modulate.g = 1.0
		
		if Input.is_action_just_pressed("interact"):
			_colocar_item_no_grid(player, grid_pos, formato, Vector2(escala_x, escala_y))
	else:
		preview_sprite.modulate = Color(1, 0, 0, 0.5)

func _colocar_item_no_grid(player, grid_pos, formato, escala_final: Vector2) -> void:
	var item_data = player.itens_carregados.pop_back()
	
	# Criar o visual permanente
	var visual = Sprite2D.new()
	visual.texture = preview_sprite.texture
	visual.scale = escala_final
	visual.centered = false
	visual.modulate = item_data.cor
	visual.position = Vector2(grid_pos.x * tamanho_celula, grid_pos.y * tamanho_celula)
	container_itens.add_child(visual)
	
	# Guardar no dicionário ANTES de colocar no grid (para o sinal de queda funcionar)
	item_to_sprite[item_data] = visual
	
	grid.colocar_item(item_data, grid_pos, formato)

	player._atualizar_estado()
	player._atualizar_visual_itens()

	print("Item colocado no barco! Ocupação: %.1f%%" % grid.calcular_ocupacao())

	for doca in get_tree().get_nodes_in_group("doca"):
		if doca.verificar_entrega_por_grid(grid):
			_limpar_grid()
			break

func _limpar_grid() -> void:
	for child in container_itens.get_children():
		child.queue_free()
	item_to_sprite.clear()
	grid = GridData.new(largura, altura)
	grid.item_quebrado.connect(_on_item_quebrado)
	grid.item_caiu.connect(_on_item_caiu)

func _draw() -> void:
	# Desenha as linhas do grid para ajudar a ver
	for x in range(largura + 1):
		draw_line(Vector2(x * tamanho_celula, 0), Vector2(x * tamanho_celula, altura * tamanho_celula), Color.WHITE, 1.0)
	for y in range(altura + 1):
		draw_line(Vector2(0, y * tamanho_celula), Vector2(largura * tamanho_celula, y * tamanho_celula), Color.WHITE, 1.0)
