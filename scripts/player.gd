extends CharacterBody2D

const SPEED_BASE: float = 300.0
const SPEED_MINIMA: float = 80.0
const FATOR_PESO: float = 5.0

const ITEM_SCENE = preload("res://scenes/item.tscn")

# Regras de Carga
const LIMITE_ITENS: int = 3
const LIMITE_PONTOS: int = 30

var last_direction: Vector2 = Vector2.RIGHT
var hitbox_offset: Vector2

## --- Inventário Multi-Itens ---
var itens_carregados: Array[ItemData] = []
var estado: int = Enums.EstadoJogador.VAZIO

## --- Modificadores externos ---
var _pocas_ativas: int = 0
var modificador_velocidade: float = 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var item_visual_container: Node2D = $ItemVisual # Mudei para Node2D para empilhar


func _ready() -> void:
	add_to_group("player") # Permite que outros sistemas achem o player
	hitbox_offset = hitbox.position
	_atualizar_visual_itens()


func _physics_process(_delta: float) -> void:
	process_movement()
	process_interaction()
	move_and_slide()


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
	await get_tree().create_timer(duracao).timeout
	estado = Enums.EstadoJogador.VAZIO
	_atualizar_estado()

func process_movement() -> void:
	if estado == Enums.EstadoJogador.ATORDOADO:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = direction * _calcular_velocidade()
		last_direction = direction
		update_hitbox_offset()
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


# ----------------------------------
# Hitbox
# ----------------------------------
func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)
