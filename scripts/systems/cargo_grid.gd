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
var item_to_sprite: Dictionary = {}

# Referências aos nós de background para reconfiguração
var _bg_blur: ColorRect = null
var _bg_lines: Node2D = null

@onready var preview_sprite: Sprite2D = $PreviewSprite
@onready var container_itens: Node2D = $PlacedItems

func _ready() -> void:
	grid = GridData.new(largura, altura)
	grid.item_quebrado.connect(_on_item_quebrado)
	grid.item_caiu.connect(_on_item_caiu)
	visible = false
	preview_sprite.visible = false
	_setup_background()

# ─── Configuração dinâmica (GridConfig) ──────────────────────────────────────

func configurar_grid(config: GridConfig) -> void:
	largura = config.largura
	altura  = config.altura

	grid = GridData.new(largura, altura)
	grid.item_quebrado.connect(_on_item_quebrado)
	grid.item_caiu.connect(_on_item_caiu)
	grid.bloquear_celulas(config.celulas_bloqueadas)

	# Limpar itens visuais existentes
	for child in container_itens.get_children():
		child.queue_free()
	item_to_sprite.clear()

	# Ajustar background sem recriar os nós
	var w := largura * tamanho_celula
	var h := altura  * tamanho_celula
	if _bg_blur:
		_bg_blur.size = Vector2(w, h)
	if _bg_lines:
		_bg_lines.queue_redraw()

	# Escalar para caber numa área visual máxima de 200×160 px
	var escala_x := 200.0 / w
	var escala_y := 160.0 / h
	scale = Vector2.ONE * min(escala_x, escala_y)

# ─── Progresso do pedido (para checkmarks no balão do barco) ─────────────────

func obter_itens_entregues(pedido: OrderData) -> Array[ItemData]:
	var entregues: Array[ItemData] = []
	if pedido == null:
		return entregues

	var itens_no_grid: Array = []
	for x in range(grid.largura):
		for y in range(grid.altura):
			var item = grid.celulas[x][y]
			if item != null and not item in itens_no_grid:
				itens_no_grid.append(item)

	var ja_contados: Array = []
	for item_pedido in pedido.itens_necessarios:
		for item in itens_no_grid:
			if item.nome == item_pedido.nome and not item in ja_contados:
				entregues.append(item_pedido)
				ja_contados.append(item)
				break
	return entregues

# ─── Sinais do GridData ───────────────────────────────────────────────────────

func _on_item_quebrado(item_data: ItemData) -> void:
	if item_to_sprite.has(item_data):
		var sprite = item_to_sprite[item_data]
		sprite.queue_free()
		item_to_sprite.erase(item_data)
	_mostrar_mensagem("%s quebrou no empilhamento." % item_data.nome, "erro", 2.0)

func _on_item_caiu(item_data: ItemData, nova_pos: Vector2i) -> void:
	if item_to_sprite.has(item_data):
		var sprite = item_to_sprite[item_data]
		var destino = Vector2(nova_pos.x * tamanho_celula, nova_pos.y * tamanho_celula)
		var tween = create_tween()
		tween.tween_property(sprite, "position", destino, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

# ─── Loop principal ───────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	var player_na_doca := _player_esta_na_doca(player)
	visible = player_na_doca
	if not player_na_doca:
		preview_sprite.visible = false
		return

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
		if Input.is_action_just_pressed("interact"):
			_mostrar_mensagem(grid.get_motivo_bloqueio(item_em_preview, grid_pos, formato), "erro")

func _colocar_item_no_grid(player, grid_pos, formato, escala_final: Vector2) -> void:
	var item_data = player.itens_carregados.pop_back()

	var visual = Sprite2D.new()
	visual.texture = preview_sprite.texture
	visual.scale = escala_final
	visual.centered = false
	visual.modulate = item_data.cor
	visual.position = Vector2(grid_pos.x * tamanho_celula, grid_pos.y * tamanho_celula)
	container_itens.add_child(visual)

	item_to_sprite[item_data] = visual
	grid.colocar_item(item_data, grid_pos, formato)

	player._atualizar_estado()
	player._atualizar_visual_itens()

	_mostrar_mensagem("%s colocado no barco." % item_data.nome, "info", 1.4)
	_on_item_colocado()

func _on_item_colocado() -> void:
	var pai = get_parent()
	if not pai:
		return
	if pai.has_method("_atualizar_ui_com_progresso"):
		pai._atualizar_ui_com_progresso()
	if pai.has_method("verificar_pedido"):
		pai.verificar_pedido()

# ─── Verificação de pedido ────────────────────────────────────────────────────

func verificar_entrega_por_pedido(pedido: OrderData) -> bool:
	if pedido == null:
		return false

	var entregues = obter_itens_entregues(pedido)
	return entregues.size() >= pedido.itens_necessarios.size()

func _mostrar_mensagem(texto: String, tipo: String = "info", duracao: float = 2.0) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("mostrar_mensagem"):
		hud.mostrar_mensagem(texto, tipo, duracao)

func _limpar_grid() -> void:
	for child in container_itens.get_children():
		child.queue_free()
	item_to_sprite.clear()
	grid = GridData.new(largura, altura)
	grid.item_quebrado.connect(_on_item_quebrado)
	grid.item_caiu.connect(_on_item_caiu)

func _player_esta_na_doca(player: Node2D) -> bool:
	# Se este grid pertence a um Barco, checar proximidade a ESTE barco
	var barco := get_parent() as Boat
	if barco != null:
		if barco.state != Boat.State.DOCKED:
			return false
		return player.global_position.distance_to(barco.global_position) <= distancia_interacao
	# Fallback: CargoGrid standalone
	for node in get_tree().get_nodes_in_group("doca"):
		if node.has_method("contem_posicao_global") and node.contem_posicao_global(player.global_position):
			return true
	return false

# ─── Background (grid visual) ─────────────────────────────────────────────────

func _setup_background() -> void:
	var w := largura * tamanho_celula
	var h := altura  * tamanho_celula

	var bbc := BackBufferCopy.new()
	bbc.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(bbc)
	move_child(bbc, 0)

	var blur_bg := ColorRect.new()
	blur_bg.position = Vector2.ZERO
	blur_bg.size = Vector2(w, h)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/grid_blur.gdshader")
	blur_bg.material = mat
	add_child(blur_bg)
	move_child(blur_bg, 1)
	_bg_blur = blur_bg

	var grid_lines := Node2D.new()
	add_child(grid_lines)
	move_child(grid_lines, 2)
	_bg_lines = grid_lines

	grid_lines.draw.connect(func():
		var lw := largura * tamanho_celula
		var lh := altura  * tamanho_celula
		# Células bloqueadas
		for bc in grid.celulas_bloqueadas:
			grid_lines.draw_rect(
				Rect2(bc.x * tamanho_celula, bc.y * tamanho_celula, tamanho_celula, tamanho_celula),
				Color(0, 0, 0, 0.55)
			)
		# Linhas verticais
		for x in range(largura + 1):
			grid_lines.draw_line(
				Vector2(x * tamanho_celula, 0),
				Vector2(x * tamanho_celula, lh),
				Color(1, 1, 1, 0.45), 1.2, true # Espessura 1.2 e antialiasing ligado
			)
		# Linhas horizontais
		for y in range(altura + 1):
			grid_lines.draw_line(
				Vector2(0, y * tamanho_celula),
				Vector2(lw, y * tamanho_celula),
				Color(1, 1, 1, 0.45), 1.2, true # Espessura 1.2 e antialiasing ligado
			)
	)
