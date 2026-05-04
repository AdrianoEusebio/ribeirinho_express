extends CharacterBody2D

const SPEED_BASE: float = 300.0
const SPEED_MINIMA: float = 80.0
const FATOR_PESO: float = 5.0

const ITEM_SCENE = preload("res://scenes/item.tscn")

# Regras de Carga
const LIMITE_ITENS: int = 3
const LIMITE_PONTOS: int = 30
const INTERVALO_PISCA_ATORDOADO: float = 0.12
const ALPHA_PISCA_ATORDOADO: float = 0.35
const COR_SETA_DOCA: Color = Color(0.7, 0.9, 1.0, 0.55)

var last_direction: Vector2 = Vector2.RIGHT

## --- Inventário Multi-Itens ---
var itens_carregados: Array[ItemData] = []
var estado: int = Enums.EstadoJogador.VAZIO

## --- Modificadores externos ---
var _pocas_ativas: int = 0
var modificador_velocidade: float = 1.0
var _tempo_pisca_atordoado: float = 0.0
var _pisca_atordoado_apagado: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var item_visual_container: Node2D = $ItemVisual # Mudei para Node2D para empilhar


func _ready() -> void:
	add_to_group("player") # Permite que outros sistemas achem o player
	_atualizar_visual_itens()


func _physics_process(delta: float) -> void:
	_processar_pisca_atordoado(delta)
	process_movement()
	process_interaction()
	move_and_slide()
	z_index = int(global_position.y)
	queue_redraw()


# ----------------------------------
# Interação (Pegar / Soltar Itens)
# ----------------------------------
func process_interaction() -> void:
	# PEGAR ITEM (E)
	if Input.is_action_just_pressed("interact"):
		if itens_carregados.size() >= LIMITE_ITENS:
			print("Mãos cheias!")
			return

		var areas = hitbox.get_overlapping_areas()
		for area in areas:
			var pai = area.get_parent()
			if pai.has_method("coletar"):
				var dados_do_chao = pai.dados # Espia os dados sem coletar ainda
				if _pode_carregar(dados_do_chao):
					var item_coletado = pai.coletar().duplicate()
					itens_carregados.append(item_coletado)
					_atualizar_estado()
					_atualizar_visual_itens()
					break
				else:
					print("Muito pesado ou volumoso para o que já carrego!")
	
	# SOLTAR ITEM (Q) - Solta o último item pego
	if Input.is_action_just_pressed("drop_item"):
		if itens_carregados.size() > 0:
			_soltar_item()

func _pode_carregar(novo_item: ItemData) -> bool:
	# Regra 1: Max 3 itens (já checado no interaction)
	
	# Calcular pontos atuais
	var pontos_atuais = 0
	for item in itens_carregados:
		pontos_atuais += _get_pontos_item(item)
	
	# Somar novo item
	var novos_pontos = pontos_atuais + _get_pontos_item(novo_item)
	
	return novos_pontos <= LIMITE_PONTOS

func _get_pontos_item(item: ItemData) -> int:
	match item.categoria:
		Enums.Categoria.PESADO: return 30
		Enums.Categoria.MEDIO:  return 11
		Enums.Categoria.FRAGIL: return 8
		_: return 10

func _soltar_item() -> void:
	var item_para_soltar = itens_carregados.pop_back()
	
	var novo_item = ITEM_SCENE.instantiate()
	var container_itens := get_tree().current_scene.get_node_or_null("Itens")
	if container_itens:
		container_itens.add_child(novo_item)
	else:
		get_parent().add_child(novo_item)
	novo_item.global_position = global_position + (last_direction * 40)
	novo_item.dados = item_para_soltar
	
	_atualizar_estado()
	_atualizar_visual_itens()

func _atualizar_estado() -> void:
	if itens_carregados.size() == 0:
		estado = Enums.EstadoJogador.VAZIO
	else:
		# Se tiver qualquer item, está carregando
		estado = Enums.EstadoJogador.CARREGANDO
		# Verificação de "LENTO" pode ser baseada na massa total ou pontos
		if _calcular_massa_total() > 40.0:
			estado = Enums.EstadoJogador.LENTO

func _atualizar_visual_itens() -> void:
	if item_visual_container == null: return
	
	# Limpar visual anterior
	for child in item_visual_container.get_children():
		child.queue_free()
	
	# Criar novos sprites empilhados
	var offset_y = 0
	for item in itens_carregados:
		var s = Sprite2D.new()
		if item.icone:
			s.texture = item.icone
			s.modulate = Color.WHITE
		else:
			s.texture = preload("res://icon.svg")
			s.modulate = item.cor
			s.scale = Vector2(0.2, 0.2)
		
		s.position.y = offset_y
		item_visual_container.add_child(s)
		offset_y -= 15 # Aumentei um pouco o espaço da pilha


# ----------------------------------
# Movimentos do Boneco + animação
# ----------------------------------
func entrar_poca() -> void:
	_pocas_ativas += 1
	modificador_velocidade = 0.35

func sair_poca() -> void:
	_pocas_ativas = max(0, _pocas_ativas - 1)
	if _pocas_ativas == 0:
		modificador_velocidade = 1.0

func atordoar(duracao: float) -> void:
	if estado == Enums.EstadoJogador.ATORDOADO:
		return
	estado = Enums.EstadoJogador.ATORDOADO
	_iniciar_pisca_atordoado()
	await get_tree().create_timer(duracao).timeout
	estado = Enums.EstadoJogador.VAZIO
	_atualizar_estado()
	_parar_pisca_atordoado()

func _iniciar_pisca_atordoado() -> void:
	_tempo_pisca_atordoado = 0.0
	_pisca_atordoado_apagado = false
	modulate = Color.WHITE

func _processar_pisca_atordoado(delta: float) -> void:
	if estado != Enums.EstadoJogador.ATORDOADO:
		if _pisca_atordoado_apagado or modulate != Color.WHITE:
			_parar_pisca_atordoado()
		return

	_tempo_pisca_atordoado -= delta
	if _tempo_pisca_atordoado > 0.0:
		return

	_tempo_pisca_atordoado = INTERVALO_PISCA_ATORDOADO
	_pisca_atordoado_apagado = not _pisca_atordoado_apagado
	modulate = Color(1.0, 1.0, 1.0, ALPHA_PISCA_ATORDOADO if _pisca_atordoado_apagado else 1.0)

func _parar_pisca_atordoado() -> void:
	_tempo_pisca_atordoado = 0.0
	_pisca_atordoado_apagado = false
	modulate = Color.WHITE

func mostrar_indicador_roubo() -> void:
	var label := Label.new()
	label.text = "ROUBADO!"
	label.add_theme_color_override("font_color", Color(1.0, 0.15, 0.15))
	label.add_theme_font_size_override("font_size", 16)
	label.z_index = 150
	label.position = Vector2(-30, -60)
	add_child(label)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50.0, 1.2)
	tween.tween_property(label, "modulate:a", 0.0, 1.2)
	tween.chain().tween_callback(label.queue_free)

func process_movement() -> void:
	if estado == Enums.EstadoJogador.ATORDOADO:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = direction * _calcular_velocidade()
		last_direction = direction
	else:
		velocity = Vector2.ZERO
	
	process_animation(last_direction)


func process_animation(direction: Vector2) -> void:
	if velocity != Vector2.ZERO:
		play_animation("run", direction)
	else:
		play_animation("idle", direction)


func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")


# ----------------------------------
# Velocidade dinâmica
# ----------------------------------
func _calcular_velocidade() -> float:
	var massa_total: float = _calcular_massa_total()
	if massa_total == 0:
		return SPEED_BASE
	
	var vel: float = SPEED_BASE - (massa_total * FATOR_PESO)
	return max(vel, SPEED_MINIMA) * modificador_velocidade

func _calcular_massa_total() -> float:
	var total = 0.0
	for item in itens_carregados:
		total += item.massa
	return total


func _draw() -> void:
	var doca: Dock = _get_doca_alvo()
	if not doca or doca.contem_posicao_global(global_position):
		return

	var destino_global: Vector2 = doca.centro_global()
	var direcao := (to_local(destino_global) - to_local(global_position)).normalized()
	if direcao == Vector2.ZERO:
		return

	var centro := Vector2(0, -24)
	var perpendicular := direcao.orthogonal()
	var ponta := centro + direcao * 3.5
	var base := centro - direcao * 2.5
	var asa_esquerda := base + perpendicular * 1.7
	var asa_direita := base - perpendicular * 1.7

	draw_line(centro - direcao * 4.7, base, COR_SETA_DOCA, 0.8)
	draw_colored_polygon(PackedVector2Array([ponta, asa_esquerda, asa_direita]), COR_SETA_DOCA)


func _get_doca_alvo() -> Dock:
	var doca_mais_proxima: Dock = null
	var menor_distancia := INF
	for node in get_tree().get_nodes_in_group("doca"):
		var doca := node as Dock
		if not doca:
			continue
		var distancia := global_position.distance_to(doca.centro_global())
		if distancia < menor_distancia:
			menor_distancia = distancia
			doca_mais_proxima = doca
	return doca_mais_proxima
