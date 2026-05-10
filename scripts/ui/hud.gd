extends CanvasLayer

@onready var label_tempo: Label      = $Painel/VBox/LabelTempo
@onready var label_pontuacao: Label  = $Painel/VBox/LabelPontuacao
@onready var label_pedidos: Label    = $Painel/VBox/LabelPedidos
@onready var botao_reiniciar: Button = $Painel/VBox/BotaoReiniciar

var _label_countdown: Label = null
var _shake_timer: float = 0.0
var _shake_ativo: bool = false
var _tempo_atual: float = 999.0

var _painel_pedidos: PanelContainer = null
var _vbox_pedidos: VBoxContainer = null

func _ready() -> void:
	_criar_label_countdown()
	_estilizar_painel_principal()
	_criar_painel_pedidos()

func _process(delta: float) -> void:
	if not _shake_ativo:
		return
	_shake_timer += delta * 12.0
	label_tempo.position.x = sin(_shake_timer * 2.1) * 3.0
	label_tempo.position.y = sin(_shake_timer * 3.3) * 2.0

# ─── Estilo do painel principal ───────────────────────────────────────────────

func _estilizar_painel_principal() -> void:
	var painel: Panel = $Painel
	painel.add_theme_stylebox_override("panel", _criar_stylebox())

	label_tempo.add_theme_font_size_override("font_size", 30)
	label_tempo.add_theme_color_override("font_color", Color.WHITE)
	label_pontuacao.add_theme_font_size_override("font_size", 14)
	label_pontuacao.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	label_pedidos.visible = false

func _criar_stylebox() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.04, 0.07, 0.14, 0.90)
	s.border_width_left   = 2
	s.border_width_right  = 2
	s.border_width_top    = 2
	s.border_width_bottom = 2
	s.border_color = Color(0.35, 0.65, 1.0, 0.75)
	s.corner_radius_top_left     = 10
	s.corner_radius_top_right    = 10
	s.corner_radius_bottom_left  = 10
	s.corner_radius_bottom_right = 10
	s.content_margin_left   = 14
	s.content_margin_right  = 14
	s.content_margin_top    = 12
	s.content_margin_bottom = 12
	return s

# ─── Painel de pedidos (direita) ──────────────────────────────────────────────

func _criar_painel_pedidos() -> void:
	_painel_pedidos = PanelContainer.new()
	_painel_pedidos.add_theme_stylebox_override("panel", _criar_stylebox())

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 6)
	_painel_pedidos.add_child(outer)

	var titulo := Label.new()
	titulo.text = "Pedidos Ativos"
	titulo.add_theme_font_size_override("font_size", 13)
	titulo.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0))
	outer.add_child(titulo)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.35, 0.65, 1.0, 0.4))
	outer.add_child(sep)

	_vbox_pedidos = VBoxContainer.new()
	_vbox_pedidos.add_theme_constant_override("separation", 4)
	outer.add_child(_vbox_pedidos)

	add_child(_painel_pedidos)

	var vp := get_viewport().get_visible_rect().size
	_painel_pedidos.position = Vector2(vp.x - 235, vp.y / 2.0 - 80)

# ─── Atualização dos pedidos com barras de tempo ──────────────────────────────

func atualizar_pedidos_barcos(barcos: Array) -> void:
	if not _vbox_pedidos:
		return
	for child in _vbox_pedidos.get_children():
		child.queue_free()

	if barcos.is_empty():
		var lbl := Label.new()
		lbl.text = "Aguardando barcos..."
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.55, 0.65, 0.75))
		_vbox_pedidos.add_child(lbl)
		return

	for boat in barcos:
		var pedido = boat.pedido
		var pct: float = boat.get_timer_pct() if boat.has_method("get_timer_pct") else 1.0

		var header := Label.new()
		header.text = "%s (Barco %d)" % [pedido.nome, boat.spot_index + 1]
		header.add_theme_font_size_override("font_size", 12)
		header.add_theme_color_override("font_color", Color(0.65, 0.88, 1.0))
		_vbox_pedidos.add_child(header)

		_vbox_pedidos.add_child(_criar_barra_tempo(pct))

		var entregues = boat.cargo_grid.obter_itens_entregues(pedido)
		var nomes_entregues: Array[String] = []
		for e in entregues:
			nomes_entregues.append(e.nome)

		for item in pedido.itens_necessarios:
			var ok = item.nome in nomes_entregues
			# Se o item está ok, removemos da lista de nomes_entregues para o próximo duplicado não herdar o OK por erro
			if ok:
				var idx = nomes_entregues.find(item.nome)
				nomes_entregues.remove_at(idx)

			var item_lbl := Label.new()
			item_lbl.text = (" [OK] " if ok else "  - ") + item.nome
			item_lbl.add_theme_font_size_override("font_size", 11)
			if ok:
				item_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
			else:
				item_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
			_vbox_pedidos.add_child(item_lbl)

		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 5)
		_vbox_pedidos.add_child(spacer)

func _criar_barra_tempo(pct: float) -> Control:
	var cont := Control.new()
	cont.custom_minimum_size = Vector2(195, 7)

	var bg := ColorRect.new()
	bg.color = Color(0.18, 0.18, 0.18, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	cont.add_child(bg)

	if pct > 0.0:
		var fg := ColorRect.new()
		if pct > 0.5:
			fg.color = Color(0.2, 0.85, 0.3)
		elif pct > 0.25:
			fg.color = Color(1.0, 0.75, 0.1)
		else:
			fg.color = Color(0.95, 0.2, 0.2)
		fg.anchor_left   = 0.0
		fg.anchor_right  = pct
		fg.anchor_top    = 0.0
		fg.anchor_bottom = 1.0
		cont.add_child(fg)

	return cont

# ─── Countdown ────────────────────────────────────────────────────────────────

func _criar_label_countdown() -> void:
	_label_countdown = Label.new()
	_label_countdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_countdown.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_label_countdown.add_theme_font_size_override("font_size", 96)
	_label_countdown.add_theme_color_override("font_color", Color.WHITE)
	_label_countdown.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_label_countdown.add_theme_constant_override("shadow_offset_x", 3)
	_label_countdown.add_theme_constant_override("shadow_offset_y", 3)
	_label_countdown.size = Vector2(300, 160)
	_label_countdown.visible = false
	_label_countdown.z_index = 200
	add_child(_label_countdown)
	_posicionar_countdown()

func _posicionar_countdown() -> void:
	if not _label_countdown:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_label_countdown.position = vp / 2.0 - _label_countdown.size / 2.0

func mostrar_countdown(numero: int) -> void:
	if not _label_countdown:
		return
	_posicionar_countdown()
	if numero == 0:
		_label_countdown.text = "VAI!"
		_label_countdown.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		_label_countdown.text = str(numero)
		_label_countdown.add_theme_color_override("font_color", Color.WHITE)
	_label_countdown.visible = true
	_label_countdown.scale = Vector2(1.8, 1.8)
	var tween := create_tween()
	tween.tween_property(_label_countdown, "scale", Vector2(1.0, 1.0), 0.35) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func ocultar_countdown() -> void:
	if _label_countdown:
		_label_countdown.visible = false

# ─── Timer ────────────────────────────────────────────────────────────────────

func atualizar_tempo(segundos: float) -> void:
	_tempo_atual = segundos
	var mins := int(segundos) / 60
	var secs := int(segundos) % 60
	label_tempo.text = "%02d:%02d" % [mins, secs]

	if segundos <= 15.0:
		label_tempo.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		_shake_ativo = true
	elif segundos <= 60.0:
		label_tempo.add_theme_color_override("font_color", Color(1.0, 0.78, 0.1))
		_shake_ativo = false
		label_tempo.position = Vector2.ZERO
	else:
		label_tempo.add_theme_color_override("font_color", Color.WHITE)
		_shake_ativo = false
		label_tempo.position = Vector2.ZERO

# ─── Pontuação ────────────────────────────────────────────────────────────────

func atualizar_pontuacao(pts: int) -> void:
	label_pontuacao.text = "Pontuacao: %d" % pts
	label_pontuacao.scale = Vector2(1.25, 1.25)
	var tween := create_tween()
	tween.tween_property(label_pontuacao, "scale", Vector2(1.0, 1.0), 0.25) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

# ─── Resultado ────────────────────────────────────────────────────────────────

func mostrar_resultado(pontuacao_final: int, vitoria: bool) -> void:
	label_tempo.text = "VITÓRIA!" if vitoria else "00:00"
	_shake_ativo = false
	label_tempo.position = Vector2.ZERO
	label_tempo.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4) if vitoria else Color(1.0, 0.3, 0.3))

	if _vbox_pedidos:
		for child in _vbox_pedidos.get_children():
			child.queue_free()
		var lbl := Label.new()
		lbl.text = ("Entregues com sucesso!\n%d pts" if vitoria else "Tempo esgotado!\n%d pts") % pontuacao_final
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4) if vitoria else Color(1.0, 0.4, 0.4))
		_vbox_pedidos.add_child(lbl)

	botao_reiniciar.visible = true
	botao_reiniciar.pressed.connect(func(): get_tree().reload_current_scene(), CONNECT_ONE_SHOT)
