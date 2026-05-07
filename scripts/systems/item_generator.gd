## Gerador contínuo de itens com esteira e fila de espera visual.
##
## - Gera 1 item aleatório a cada 2 segundos.
## - O item anima-se pela esteira até o primeiro slot livre.
## - Máximo 6 itens na fila; gerador pausa quando a fila está cheia.
## - Retoma automaticamente quando o jogador coleta um item.
extends Node2D

const TODOS_ITENS := [
	preload("res://resources/itens/caixa_media.tres"),
	preload("res://resources/itens/caixa_pequena.tres"),
	preload("res://resources/itens/geladeira.tres"),
	preload("res://resources/itens/medicamento.tres"),
	preload("res://resources/itens/saco_graos.tres"),
]
const ITEM_SLOT_SCRIPT := preload("res://scripts/systems/item_slot.gd")

const MAX_FILA       := 6
const INTERVALO      := 5.0   # segundos entre gerações
const DURACAO_TRANSIT := 0.55 # segundos do item percorrer a esteira

# ── Layout (pixels locais) ──
const GEN_W    := 50
const GEN_H    := 50
const BELT_W   := 180
const BELT_H   := 18
const SLOT_SZ  := 44
const SLOT_GAP := 6

# ── Posições calculadas no _ready ──
var _gen_centro: Vector2
var _belt_inicio: Vector2
var _belt_fim: Vector2
var _slots_pos: Array[Vector2] = []

# ── Estado ──
var _slot_nodes: Array          = []   # [MAX_FILA] — Node2D ItemSlot ou null
var _em_transito: bool          = false
var _transito_dados: ItemData   = null
var _transito_slot: int         = -1
var _transito_pos: Vector2      = Vector2.ZERO
var _transito_destino: Vector2  = Vector2.ZERO
var _transito_t: float          = 0.0

@onready var _timer: Timer     = $Timer
@onready var _container: Node2D = $Container


func _ready() -> void:
	_calcular_layout()
	_slot_nodes.resize(MAX_FILA)
	_slot_nodes.fill(null)

	_timer.wait_time = INTERVALO
	_timer.one_shot  = false
	_timer.timeout.connect(_ao_tempo)
	_timer.start()


func _calcular_layout() -> void:
	_gen_centro  = Vector2(GEN_W / 2.0, GEN_H / 2.0)
	_belt_inicio = Vector2(GEN_W + 2.0, GEN_H / 2.0)
	_belt_fim    = Vector2(GEN_W + 2.0 + BELT_W, GEN_H / 2.0)

	_slots_pos.clear()
	for i in MAX_FILA:
		var x := _belt_fim.x + SLOT_GAP + i * (SLOT_SZ + SLOT_GAP) + SLOT_SZ / 2.0
		_slots_pos.append(Vector2(x, GEN_H / 2.0))


# ── Process ────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_verificar_slots_liberados()

	if _em_transito:
		_transito_t += delta / DURACAO_TRANSIT
		var t := _ease(_transito_t)
		_transito_pos = _gen_centro.lerp(_transito_destino, t)
		queue_redraw()
		if _transito_t >= 1.0:
			_finalizar_transito()


func _ease(t: float) -> float:
	t = clamp(t, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t) # smoothstep


# ── Gestão de slots ────────────────────────────────────────────────────────────

func _verificar_slots_liberados() -> void:
	var mudou := false

	for i in MAX_FILA:
		if _slot_nodes[i] != null and not is_instance_valid(_slot_nodes[i]):
			_slot_nodes[i] = null
			mudou = true

	if mudou:
		queue_redraw()
		if not _em_transito and _timer.is_stopped():
			_timer.start()


func _tem_slot_livre() -> bool:
	for node in _slot_nodes:
		if node == null or not is_instance_valid(node):
			return true
	return false


func _primeiro_slot_livre() -> int:
	for i in MAX_FILA:
		if _slot_nodes[i] == null or not is_instance_valid(_slot_nodes[i]):
			return i
	return -1


# ── Geração ────────────────────────────────────────────────────────────────────

func _ao_tempo() -> void:
	if _em_transito:
		return
	var slot := _primeiro_slot_livre()
	if slot == -1:
		_timer.stop()
		return
	_iniciar_transito(slot)


func _iniciar_transito(slot_idx: int) -> void:
	_transito_dados   = TODOS_ITENS[randi() % TODOS_ITENS.size()].duplicate()
	_transito_slot    = slot_idx
	_transito_destino = _slots_pos[slot_idx]
	_transito_pos     = _gen_centro
	_transito_t       = 0.0
	_em_transito      = true
	_timer.stop()
	queue_redraw()


func _finalizar_transito() -> void:
	_em_transito = false

	var slot_idx := _transito_slot
	# Se o slot alvo foi liberado por outro motivo, procura qualquer um livre
	if slot_idx == -1 or (_slot_nodes[slot_idx] != null and is_instance_valid(_slot_nodes[slot_idx])):
		slot_idx = _primeiro_slot_livre()

	if slot_idx >= 0:
		var nodo := Node2D.new()
		nodo.set_script(ITEM_SLOT_SCRIPT)
		nodo.position = _slots_pos[slot_idx]
		_container.add_child(nodo)
		nodo.dados = _transito_dados
		nodo.queue_redraw()
		_slot_nodes[slot_idx] = nodo

	_transito_dados = null
	_transito_slot  = -1
	queue_redraw()

	if _tem_slot_livre():
		_timer.start()


# ── Desenho ────────────────────────────────────────────────────────────────────

func _draw() -> void:
	var font := ThemeDB.fallback_font

	# ── Caixa do gerador ──
	var cor_gen := Color(0.18, 0.60, 1.0) if not _em_transito else Color(0.35, 0.80, 1.0)
	draw_rect(Rect2(0, 0, GEN_W, GEN_H), cor_gen)
	draw_rect(Rect2(0, 0, GEN_W, GEN_H), Color.WHITE, false, 2.0)

	# ── Esteira ──
	var belt_y := GEN_H / 2.0 - BELT_H / 2.0
	draw_rect(Rect2(_belt_inicio.x, belt_y, BELT_W, BELT_H), Color(0.26, 0.20, 0.14))
	for i in range(0, BELT_W, 20):
		var x := _belt_inicio.x + float(i)
		draw_line(Vector2(x, belt_y + 2), Vector2(x + 10, belt_y + BELT_H - 2), Color(0.44, 0.36, 0.25), 2)
	draw_rect(Rect2(_belt_inicio.x, belt_y, BELT_W, BELT_H), Color(0.5, 0.42, 0.32), false, 1.0)

	# ── Fundo dos slots ──
	for i in MAX_FILA:
		var center := _slots_pos[i]
		var half   := SLOT_SZ / 2.0
		var rect   := Rect2(center.x - half, center.y - half, SLOT_SZ, SLOT_SZ)
		var cheio  := _slot_nodes[i] != null and is_instance_valid(_slot_nodes[i])
		draw_rect(rect, Color(0.14, 0.14, 0.14) if not cheio else Color(0.20, 0.20, 0.20))
		draw_rect(rect, Color(0.52, 0.52, 0.52), false, 1.5)
		if not cheio:
			draw_string(font, Vector2(center.x - 4, center.y + 5), str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, 10, 10, Color(0.38, 0.38, 0.38))

	# ── Item em trânsito ──
	if _em_transito and _transito_dados:
		var half := 15.0
		draw_rect(Rect2(_transito_pos.x - half, _transito_pos.y - half, half * 2, half * 2), _transito_dados.cor)
		draw_rect(Rect2(_transito_pos.x - half, _transito_pos.y - half, half * 2, half * 2), Color.WHITE, false, 1.5)
		draw_string(font, Vector2(_transito_pos.x - 13, _transito_pos.y + 4),
			_transito_dados.nome.left(5), HORIZONTAL_ALIGNMENT_LEFT, 28, 8, Color.WHITE)

	# ── Aviso "FILA CHEIA" ──
	if not _tem_slot_livre() and not _em_transito:
		var cx := _belt_inicio.x + BELT_W / 2.0 - 33
		draw_string(font, Vector2(cx, belt_y - 5), "FILA CHEIA",
			HORIZONTAL_ALIGNMENT_LEFT, 80, 10, Color(1.0, 0.35, 0.35))
