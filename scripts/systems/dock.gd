class_name Dock
extends Node2D

signal pedido_entregue(pontos: int, boat)
signal barco_atracou

@export var pool_pedidos: Array[OrderData] = []
@export var grid_pool: Array[GridConfig] = []
@export var boat_scene: PackedScene = preload("res://scenes/boat.tscn")

@export var spot_positions: Array[Vector2] = [
	Vector2(350, 0),
	Vector2(850, 0),
	Vector2(1530, 0)
]

# Segundos de espera dependendo do estado do porto
const DELAY_PORTO_VAZIO   := Vector2(1.0, 3.0)
const DELAY_PORTO_OCUPADO := Vector2(6.0, 14.0)

var boats: Array[Node2D]     = [null, null, null]
var _agendados: Array[bool]  = [false, false, false]
var _jogo_ativo: bool        = true
var _tempo_decorrido: float  = 0.0

const TODOS_ITENS_POOL := [
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

func _ready() -> void:
	add_to_group("doca")

func _process(delta: float) -> void:
	if _jogo_ativo:
		_tempo_decorrido += delta

func iniciar() -> void:
	await get_tree().create_timer(1.0).timeout
	_spawn_boat(0)
	_agendar_spawn()

# ─── Spawn escalonado (esquerda → direita) ────────────────────────────────────

func _agendar_spawn() -> void:
	if not _jogo_ativo:
		return
	var slot := _primeiro_slot_livre()
	if slot == -1:
		return
	_agendados[slot] = true
	var delay: float
	if _tem_algum_barco():
		delay = randf_range(DELAY_PORTO_OCUPADO.x, DELAY_PORTO_OCUPADO.y)
	else:
		delay = randf_range(DELAY_PORTO_VAZIO.x, DELAY_PORTO_VAZIO.y)
	delay += 5.0
	delay *= _get_fator_dificuldade()
	_executar_spawn_apos(slot, delay)

func _executar_spawn_apos(slot: int, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_agendados[slot] = false
	if not _jogo_ativo or boats[slot] != null:
		return
	_spawn_boat(slot)
	_agendar_spawn()  # verifica se há mais slots livres

func _spawn_boat(index: int) -> void:
	var new_boat: Node2D = boat_scene.instantiate()
	add_child(new_boat)
	boats[index] = new_boat

	var config := _get_random_grid_config()
	var p      := _get_random_pedido(config.max_itens_recomendados if config else 0)
	new_boat.setup(p, index, config)

	new_boat.boat_finished.connect(_on_boat_finished)
	new_boat.boat_timeout.connect(_on_boat_timeout)

	barco_atracou.emit()
	_mostrar_mensagem("Barco %d chegou com novo pedido." % (index + 1), "info", 1.8)

	var target_pos := global_position + spot_positions[index]
	new_boat.chegar(target_pos)

# ─── Callbacks de barcos ──────────────────────────────────────────────────────

func _on_boat_finished(boat) -> void:
	pedido_entregue.emit(boat.pedido.recompensa_pontos, boat)
	boats[boat.spot_index] = null
	_agendar_spawn()

func _on_boat_timeout(boat) -> void:
	var N: int = boat.pedido.itens_necessarios.size()
	var M: int = boat.cargo_grid.obter_itens_entregues(boat.pedido).size()
	var pontos_parciais := 0
	if N > 0 and M > 0:
		pontos_parciais = max(0, int(200.0 * M / N) - 100)

	if pontos_parciais > 0:
		_mostrar_mensagem("Barco %d perdeu o prazo, mas entregou parciais: +%d pts!" % [boat.spot_index + 1, pontos_parciais], "info", 2.5)
		pedido_entregue.emit(pontos_parciais, boat)
	else:
		_mostrar_mensagem("Barco %d perdeu o prazo sem entregas válidas." % (boat.spot_index + 1), "alerta", 2.0)

	boats[boat.spot_index] = null
	_agendar_spawn()

# ─── Encerramento do jogo ─────────────────────────────────────────────────────

func encerrar() -> void:
	_jogo_ativo = false
	for boat in boats:
		if boat != null:
			boat.set_process(false)

# ─── Helpers ──────────────────────────────────────────────────────────────────

func _primeiro_slot_livre() -> int:
	for i in range(3):
		if boats[i] == null and not _agendados[i]:
			return i
	return -1

func _tem_algum_barco() -> bool:
	for b in boats:
		if b != null:
			return true
	return false

func _get_random_pedido(max_itens: int = 0) -> OrderData:
	if pool_pedidos.is_empty(): return null
	var p = pool_pedidos[randi() % pool_pedidos.size()].duplicate()
	
	# Progressiva a cada 1 minuto de jogo: inicia com 4 itens e aumenta +1 a cada 60 segundos (limite de 10)
	var num_itens: int = min(10, 4 + int(_tempo_decorrido / 60.0))
	
	# Preencher os itens da missão até atingir o num_itens usando o TODOS_ITENS_POOL (garante novos itens nas missões!)
	while p.itens_necessarios.size() < num_itens:
		var item_aleatorio = TODOS_ITENS_POOL[randi() % TODOS_ITENS_POOL.size()]
		p.itens_necessarios.append(item_aleatorio)
		
	if p.itens_necessarios.size() > num_itens:
		p.itens_necessarios = p.itens_necessarios.slice(0, num_itens)
		
	# Aumentar o tempo limite em +25 segundos
	p.tempo_limite += 25.0
	
	# Definir recompensa padrão de 300 pontos por barco
	p.recompensa_pontos = 300
	
	return p

func _get_random_grid_config() -> GridConfig:
	if grid_pool.is_empty(): return null
	return grid_pool[randi() % grid_pool.size()]

func aumentar_dificuldade(nivel: int) -> void:
	_nivel_atual = nivel

var _nivel_atual: int = 0

func _get_fator_dificuldade() -> float:
	return max(0.4, 1.0 - (_nivel_atual * 0.1))

func _mostrar_mensagem(texto: String, tipo: String = "info", duracao: float = 2.0) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("mostrar_mensagem"):
		hud.mostrar_mensagem(texto, tipo, duracao)

# ─── Consultas externas ───────────────────────────────────────────────────────

func contem_posicao_global(posicao: Vector2) -> bool:
	for boat in boats:
		if boat != null and boat.state == boat.State.DOCKED:
			var rect := Rect2(boat.global_position - Vector2(100, 100), Vector2(300, 200))
			if rect.has_point(posicao):
				return true
	return false

func centro_global() -> Vector2:
	return global_position + Vector2(500, 100)
