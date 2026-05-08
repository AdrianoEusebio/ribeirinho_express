extends Node2D

enum Estado { INICIANDO, JOGANDO, ENCERRADO }

@export var tempo_total: float = 180.0
@export var pontuacao_vitoria: int = 9999  # sem limite por padrão — vence pelo tempo

# Dificuldade adaptativa
@export var thief_scene: PackedScene = preload("res://scenes/thief.tscn")
@export var pontos_por_nivel_dificuldade: int = 300
@export var max_ladroes: int = 4

var _estado: Estado = Estado.INICIANDO
var tempo_restante: float = 0.0
var pontuacao: int = 0
var _nivel_dificuldade: int = 0
var _timer_hud: float = 0.0

@onready var hud: CanvasLayer = $HUD
@onready var _npcs: Node2D  = $NPCs

func _ready() -> void:
	tempo_restante = tempo_total
	hud.atualizar_tempo(tempo_restante)
	hud.atualizar_pontuacao(pontuacao)

	for doca in get_tree().get_nodes_in_group("doca"):
		doca.pedido_entregue.connect(_on_pedido_entregue)
		doca.barco_atracou.connect(_atualizar_hud_pedidos)

	_atualizar_hud_pedidos()
	_iniciar_contagem_regressiva()

# ─── Contagem regressiva ──────────────────────────────────────────────────────

func _iniciar_contagem_regressiva() -> void:
	_set_jogo_congelado(true)

	for n in [3, 2, 1]:
		hud.mostrar_countdown(n)
		await get_tree().create_timer(1.0).timeout

	hud.mostrar_countdown(0)  # "VAI!"
	await get_tree().create_timer(0.8).timeout
	hud.ocultar_countdown()

	_set_jogo_congelado(false)
	_estado = Estado.JOGANDO
	for doca in get_tree().get_nodes_in_group("doca"):
		doca.iniciar()

func _set_jogo_congelado(congelado: bool, incluir_barcos: bool = false) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(not congelado)
	if _npcs:
		for npc in _npcs.get_children():
			npc.set_physics_process(not congelado)
	if incluir_barcos:
		for doca in get_tree().get_nodes_in_group("doca"):
			doca.encerrar()

# ─── Loop principal ───────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _estado != Estado.JOGANDO:
		return
	tempo_restante -= delta
	hud.atualizar_tempo(maxf(tempo_restante, 0.0))
	if tempo_restante <= 0.0:
		_fim_de_jogo()
		return
	# Atualiza pedidos no HUD periodicamente (cobre chegada de novos barcos)
	_timer_hud -= delta
	if _timer_hud <= 0.0:
		_timer_hud = 2.0
		_atualizar_hud_pedidos()

# ─── Pontuação e dificuldade ──────────────────────────────────────────────────

func _on_pedido_entregue(pontos: int) -> void:
	pontuacao += pontos
	hud.atualizar_pontuacao(pontuacao)
	_atualizar_hud_pedidos()
	_checar_dificuldade()
	if pontuacao >= pontuacao_vitoria:
		_vitoria()

func _checar_dificuldade() -> void:
	var novo_nivel := pontuacao / pontos_por_nivel_dificuldade
	if novo_nivel > _nivel_dificuldade:
		_nivel_dificuldade = novo_nivel
		_spawnar_ladrао_extra()

func _spawnar_ladrао_extra() -> void:
	if not thief_scene or not _npcs:
		return
	var ladroes := get_tree().get_nodes_in_group("thief")
	if ladroes.size() >= max_ladroes:
		return
	var novo := thief_scene.instantiate()
	_npcs.add_child(novo)
	var player = get_tree().get_first_node_in_group("player")
	var base: Vector2 = player.global_position if player else Vector2(1280, 720)
	novo.global_position = _encontrar_posicao_spawn(base)

func _encontrar_posicao_spawn(base: Vector2) -> Vector2:
	var space := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.collision_mask = 0xFFFFFFFF
	for _i in range(25):
		var angulo := randf() * TAU
		var dist := randf_range(400, 700)
		var candidato := base + Vector2(cos(angulo), sin(angulo)) * dist
		params.position = candidato
		var resultados := space.intersect_point(params, 8)
		var bloqueado := false
		for r in resultados:
			var col = r.get("collider")
			if col and not (col is CharacterBody2D):
				bloqueado = true
				break
		if not bloqueado:
			return candidato
	# Fallback: usa o próprio base com deslocamento mínimo
	return base + Vector2(randf_range(-150, 150), randf_range(-150, 150))

# ─── HUD de pedidos ───────────────────────────────────────────────────────────

func _atualizar_hud_pedidos() -> void:
	var barcos_ativos: Array = []
	for doca in get_tree().get_nodes_in_group("doca"):
		for boat in doca.boats:
			if boat != null and boat.pedido != null:
				barcos_ativos.append(boat)
	hud.atualizar_pedidos_barcos(barcos_ativos)

# ─── Fim de jogo ──────────────────────────────────────────────────────────────

func _vitoria() -> void:
	_encerrar(true)

func _fim_de_jogo() -> void:
	_encerrar(false)

func _encerrar(vitoria: bool) -> void:
	if _estado == Estado.ENCERRADO:
		return
	_estado = Estado.ENCERRADO
	_set_jogo_congelado(true, true)  # inclui barcos e docas
	hud.mostrar_resultado(pontuacao, vitoria)
