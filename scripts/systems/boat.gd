class_name Boat
extends Node2D

signal boat_finished(boat)
signal boat_timeout(boat)

enum State { ARRIVING, DOCKED, LEAVING }

@onready var sprite: Sprite2D = $Sprite2D
@onready var cargo_grid: Node2D = $CargoGrid
@onready var label_pedido: Label = $LabelPedido

var state: State = State.ARRIVING
var pedido: OrderData = null
var spot_index: int = 0

var _tempo_restante: float = 0.0
var _tempo_limite: float = 0.0

const BAR_W  := 100.0
const BAR_H  := 7.0
const BAR_Y  := -80.0

const ZONE_RADIUS     := 250.0
const ZONE_FILL       := Color(0.45, 0.82, 1.0, 0.07)
const ZONE_BORDER     := Color(0.45, 0.82, 1.0, 0.55)

func _ready() -> void:
	sprite.frame = randi() % sprite.vframes
	if cargo_grid:
		cargo_grid.visible = false
		cargo_grid.set_process(false)
	_atualizar_ui()

func _process(delta: float) -> void:
	if state != State.DOCKED:
		return
	queue_redraw()
	if _tempo_limite <= 0.0:
		return
	_tempo_restante -= delta
	if _tempo_restante <= 0.0:
		_tempo_limite = 0.0
		boat_timeout.emit(self)
		partir()

func setup(p: OrderData, index: int, config: GridConfig = null) -> void:
	pedido = p
	spot_index = index
	if pedido:
		_tempo_limite   = pedido.tempo_limite
		_tempo_restante = _tempo_limite
	if config and cargo_grid.has_method("configurar_grid"):
		cargo_grid.configurar_grid(config)
	_atualizar_ui()

func chegar(destino: Vector2) -> void:
	state = State.ARRIVING
	global_position = destino + Vector2(1200, 0)
	
	# Partículas de rastro (opcional se o nó existir)
	var rastro = get_node_or_null("RastroParticulas")
	if rastro: rastro.emitting = true

	var tween = create_tween()
	tween.tween_property(self, "global_position", destino, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Bobbing (balanço suave)
	var bob_tween = create_tween().set_loops()
	bob_tween.tween_property(sprite, "position:y", 4.0, 1.2).as_relative().set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(sprite, "position:y", -4.0, 1.2).as_relative().set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	state = State.DOCKED
	if rastro: rastro.emitting = false
	if cargo_grid:
		cargo_grid.visible = true
		cargo_grid.set_process(true)
	queue_redraw()

func partir() -> void:
	if state == State.LEAVING:
		return
	state = State.LEAVING
	
	if cargo_grid:
		cargo_grid.visible = false
		cargo_grid.set_process(false)
	
	var rastro = get_node_or_null("RastroParticulas")
	if rastro: rastro.emitting = true
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(-1200, 0), 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()

# ─── UI ──────────────────────────────────────────────────────────────────────

func _atualizar_ui() -> void:
	if not is_inside_tree() or label_pedido == null:
		return
	if pedido == null:
		label_pedido.text = ""
		return
	var texto = pedido.nome + ":\n"
	for item in pedido.itens_necessarios:
		texto += "- " + item.nome + "\n"
	label_pedido.text = texto

## Atualiza o balão com checkmarks conforme itens são colocados no grid.
func _atualizar_ui_com_progresso() -> void:
	if not is_inside_tree() or label_pedido == null or pedido == null:
		return
	var entregues = cargo_grid.obter_itens_entregues(pedido)
	var nomes_entregues: Array[String] = []
	for e in entregues:
		nomes_entregues.append(e.nome)

	var texto = pedido.nome + ":\n"
	for item_pedido in pedido.itens_necessarios:
		var ok = item_pedido.nome in nomes_entregues
		texto += ("✓ " if ok else "- ") + item_pedido.nome + "\n"
	label_pedido.text = texto

# ─── Verificação de pedido ────────────────────────────────────────────────────

func get_timer_pct() -> float:
	if _tempo_limite <= 0.0:
		return 1.0
	return clampf(_tempo_restante / _tempo_limite, 0.0, 1.0)

func verificar_pedido() -> bool:
	if state != State.DOCKED or pedido == null:
		return false
	if cargo_grid.verificar_entrega_por_pedido(pedido):
		boat_finished.emit(self)
		partir()
		return true
	return false

# ─── Barra de tempo ───────────────────────────────────────────────────────────

func _draw() -> void:
	if state != State.DOCKED:
		return
	# Activation zone
	var r := ZONE_RADIUS
	draw_rect(Rect2(-r, -r, r * 2.0, r * 2.0), ZONE_FILL)
	draw_dashed_line(Vector2(-r, -r), Vector2(r, -r),  ZONE_BORDER, 1.5, 14.0)
	draw_dashed_line(Vector2(r, -r),  Vector2(r, r),   ZONE_BORDER, 1.5, 14.0)
	draw_dashed_line(Vector2(r, r),   Vector2(-r, r),  ZONE_BORDER, 1.5, 14.0)
	draw_dashed_line(Vector2(-r, r),  Vector2(-r, -r), ZONE_BORDER, 1.5, 14.0)
	# Timer bar
	if _tempo_limite <= 0.0:
		return
	var pct := clampf(_tempo_restante / _tempo_limite, 0.0, 1.0)
	var bx  := -BAR_W / 2.0
	draw_rect(Rect2(bx, BAR_Y, BAR_W, BAR_H), Color(0.15, 0.15, 0.15, 0.85))
	if pct > 0.0:
		var cor: Color
		if   pct > 0.5:  cor = Color(0.2,  0.85, 0.3)
		elif pct > 0.25: cor = Color(1.0,  0.75, 0.1)
		else:            cor = Color(0.95, 0.2,  0.2)
		draw_rect(Rect2(bx, BAR_Y, BAR_W * pct, BAR_H), cor)
	draw_rect(Rect2(bx, BAR_Y, BAR_W, BAR_H), Color(0.6, 0.6, 0.6, 0.7), false, 1.0)
