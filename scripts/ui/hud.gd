extends CanvasLayer

@onready var label_tempo: Label      = $Painel/VBox/LabelTempo
@onready var label_pontuacao: Label  = $Painel/VBox/LabelPontuacao
@onready var label_pedidos: Label    = $Painel/VBox/LabelPedidos
@onready var botao_reiniciar: Button = $Painel/VBox/BotaoReiniciar

var _label_countdown: Label = null
var _label_mensagem: Label = null
var _shake_timer: float = 0.0
var _shake_ativo: bool = false
var _tempo_atual: float = 999.0
var _meta_pontuacao: int = 0
var _mensagem_tween: Tween = null

var _painel_pedidos: PanelContainer = null
var _vbox_pedidos: VBoxContainer = null
var _font_pixel: Font = null

func _ready() -> void:
	add_to_group("hud")
	# Tenta carregar uma fonte pixelada se existir. 
	# Caso contrário, usará a padrão do sistema.
	_font_pixel = load("res://assets/assets/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf") 
	
	_criar_label_countdown()
	_criar_label_mensagem()
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
	
	# Posicionamento dinâmico no canto superior esquerdo (Aumentado para evitar esticamento)
	painel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	painel.offset_left = 20
	painel.offset_top = 20
	painel.offset_right = 350  # Aumentado para 330 de largura
	painel.offset_bottom = 180 # Aumentado para 160 de altura
	
	# Ajusta o VBox interno para respeitar as bordas da imagem
	var vbox: VBoxContainer = $Painel/VBox
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 30
	vbox.offset_top = 35
	vbox.offset_right = -30
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 20) # Aumentado de 10 para dar mais espaço

	label_tempo.add_theme_font_size_override("font_size", 48)
	label_tempo.add_theme_color_override("font_color", Color.WHITE) # Mudado para Branco para contraste
	label_tempo.add_theme_stylebox_override("normal", _criar_bg_tempo())
	label_tempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_tempo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_pixel: label_tempo.add_theme_font_override("font", _font_pixel)
	
	label_pontuacao.add_theme_font_size_override("font_size", 20)
	label_pontuacao.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	label_pontuacao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_pixel: label_pontuacao.add_theme_font_override("font", _font_pixel)
	
	label_pedidos.visible = false

func _criar_bg_tempo() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.1, 0.1, 0.1, 0.9) # Preto fosco
	s.set_corner_radius_all(8) # Bordas arredondadas
	# Padding interno para o texto não encostar nas bordas
	s.content_margin_left = 15
	s.content_margin_right = 15
	s.content_margin_top = 5
	s.content_margin_bottom = 5
	return s

func _criar_stylebox() -> StyleBoxTexture:
	var s := StyleBoxTexture.new()
	var tex = load("res://assets/assets/lista.png")
	if tex:
		s.texture = tex
		# Configura as margens do NinePatch (Aumentado para evitar esticamento nos cantos)
		s.texture_margin_left = 50
		s.texture_margin_right = 50
		s.texture_margin_top = 50
		s.texture_margin_bottom = 50
		# Margens de conteúdo para PanelContainers
		s.content_margin_left = 35
		s.content_margin_right = 35
		s.content_margin_top = 40
		s.content_margin_bottom = 35
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
	titulo.add_theme_font_size_override("font_size", 20) # Aumentado de 14
	titulo.add_theme_color_override("font_color", Color.BLACK)
	if _font_pixel: titulo.add_theme_font_override("font", _font_pixel)
	outer.add_child(titulo)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0, 0, 0, 0.2)) 
	outer.add_child(sep)

	_vbox_pedidos = VBoxContainer.new()
	_vbox_pedidos.add_theme_constant_override("separation", 8) # Aumentado de 4
	outer.add_child(_vbox_pedidos)

	add_child(_painel_pedidos)

	# Posicionamento dinâmico no canto superior direito (Aumentado significativamente)
	_painel_pedidos.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_painel_pedidos.offset_left = -450 # Aumentado de -350 (Largura agora aprox 430px)
	_painel_pedidos.offset_top = 20
	_painel_pedidos.offset_right = -20
	# O offset_bottom será definido automaticamente pelo conteúdo no PanelContainer

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
		var pronto := false
		if boat != null:
			pronto = boat.pedido_pronto
		header.text = "%s (Barco %d)%s" % [pedido.nome, boat.spot_index + 1, " - PRONTO" if pronto else ""]
		header.add_theme_font_size_override("font_size", 16) # Mantido tamanho maior
		
		# Cores: Verde se pronto, Azul se pendente (respeitando contraste)
		if pronto:
			header.add_theme_color_override("font_color", Color(0.0, 0.6, 0.2)) 
		else:
			header.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
			
		if _font_pixel: header.add_theme_font_override("font", _font_pixel)
		_vbox_pedidos.add_child(header)

		_vbox_pedidos.add_child(_criar_barra_tempo(pct))

		var entregues = boat.cargo_grid.obter_itens_entregues(pedido)
		var nomes_entregues: Array[String] = []
		for e in entregues:
			nomes_entregues.append(e.nome)

		for item in pedido.itens_necessarios:
			var ok = item.nome in nomes_entregues
			if ok:
				var idx = nomes_entregues.find(item.nome)
				nomes_entregues.remove_at(idx)

			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 10)
			
			# Checkbox Visual
			var check_rect := TextureRect.new()
			var atlas := AtlasTexture.new()
			atlas.atlas = load("res://assets/assets/checks.png")
			# 72x76 total -> 36x38 cada frame. 
			# Frame 0 (concluido): 0,0. Frame 2 (padrao): 0,38
			var frame_y = 0 if ok else 38
			atlas.region = Rect2(0, frame_y, 36, 38)
			check_rect.texture = atlas
			check_rect.custom_minimum_size = Vector2(20, 20) # Redimensiona para caber na lista
			check_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			check_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			row.add_child(check_rect)

			var item_lbl := Label.new()
			item_lbl.text = item.nome
			item_lbl.add_theme_font_size_override("font_size", 16) # Aumentado um pouco para equilibrar com o check
			if _font_pixel: item_lbl.add_theme_font_override("font", _font_pixel)
			
			if ok:
				item_lbl.add_theme_color_override("font_color", Color(0.0, 0.5, 0.1))
			else:
				item_lbl.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25))
				
			row.add_child(item_lbl)
			_vbox_pedidos.add_child(row)

		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 5)
		_vbox_pedidos.add_child(spacer)

func _criar_barra_tempo(pct: float) -> Control:
	var cont := Control.new()
	cont.custom_minimum_size = Vector2(350, 10) # Aumentado de 250, 8

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
	if _font_pixel: _label_countdown.add_theme_font_override("font", _font_pixel)
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

func _criar_label_mensagem() -> void:
	_label_mensagem = Label.new()
	_label_mensagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_mensagem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label_mensagem.add_theme_font_size_override("font_size", 24)
	_label_mensagem.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_label_mensagem.add_theme_constant_override("shadow_offset_x", 2)
	_label_mensagem.add_theme_constant_override("shadow_offset_y", 2)
	if _font_pixel: _label_mensagem.add_theme_font_override("font", _font_pixel)
	_label_mensagem.size = Vector2(620, 48)
	_label_mensagem.visible = false
	_label_mensagem.z_index = 180
	add_child(_label_mensagem)
	_posicionar_mensagem()

func _posicionar_mensagem() -> void:
	if not _label_mensagem:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	_label_mensagem.position = Vector2(vp.x / 2.0 - _label_mensagem.size.x / 2.0, 96.0)

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

func mostrar_mensagem(texto: String, tipo: String = "info", duracao: float = 2.0) -> void:
	if not _label_mensagem:
		return
	_posicionar_mensagem()
	_label_mensagem.text = texto
	_label_mensagem.visible = true
	_label_mensagem.modulate.a = 1.0
	_label_mensagem.scale = Vector2(1.08, 1.08)
	match tipo:
		"sucesso":
			_label_mensagem.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
		"alerta":
			_label_mensagem.add_theme_color_override("font_color", Color(1.0, 0.78, 0.16))
		"erro":
			_label_mensagem.add_theme_color_override("font_color", Color(1.0, 0.28, 0.25))
		_:
			_label_mensagem.add_theme_color_override("font_color", Color(0.72, 0.9, 1.0))

	if _mensagem_tween:
		_mensagem_tween.kill()
	_mensagem_tween = create_tween()
	_mensagem_tween.tween_property(_label_mensagem, "scale", Vector2.ONE, 0.16)
	_mensagem_tween.tween_interval(duracao)
	_mensagem_tween.tween_property(_label_mensagem, "modulate:a", 0.0, 0.35)
	_mensagem_tween.tween_callback(func(): _label_mensagem.visible = false)

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
	if _meta_pontuacao > 0:
		label_pontuacao.text = "Pontuacao: %d / %d" % [pts, _meta_pontuacao]
	else:
		label_pontuacao.text = "Pontuacao: %d" % pts
	label_pontuacao.scale = Vector2(1.25, 1.25)
	var tween := create_tween()
	tween.tween_property(label_pontuacao, "scale", Vector2(1.0, 1.0), 0.25) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func configurar_meta_pontuacao(meta: int) -> void:
	_meta_pontuacao = meta

# ─── Resultado e Persistência de Rankings ──────────────────────────────────────

func _salvar_score(nome: String, pts: int) -> void:
	var path: String = "user://scores.json"
	var scores: Array = []
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var err = json.parse(content)
			if err == OK and json.data is Array:
				scores = json.data
	
	scores.append({"name": nome.to_upper(), "score": pts, "date": Time.get_date_string_from_system()})
	# Ordenar de forma decrescente pela pontuação
	scores.sort_custom(func(a, b): return b["score"] < a["score"])
	# Manter apenas o Top 10
	if scores.size() > 10:
		scores = scores.slice(0, 10)
		
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scores))

func mostrar_resultado(pontuacao_final: int, vitoria: bool) -> void:
	_shake_ativo = false
	label_tempo.position = Vector2.ZERO
	
	# Criar overlay de tela inteira
	var overlay = ColorRect.new()
	overlay.name = "GameOverOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.04, 0.08, 0.14, 0.85) # Semi-transparente escuro
	overlay.z_index = 500
	add_child(overlay)
	
	# CenterContainer para alinhar
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	
	# PanelContainer para o painel principal
	var panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.2, 0.95)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.35, 0.65, 1.0)
	style.set_corner_radius_all(12)
	style.content_margin_left = 35
	style.content_margin_right = 35
	style.content_margin_top = 35
	style.content_margin_bottom = 35
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	
	# VBoxContainer interno
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)
	
	# Título "GAME OVER"
	var lbl_title = Label.new()
	lbl_title.text = "GAME OVER"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 48)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	if _font_pixel:
		lbl_title.add_theme_font_override("font", _font_pixel)
	vbox.add_child(lbl_title)
	
	# Pontuação Final
	var lbl_score = Label.new()
	lbl_score.text = "Sua Pontuacao: %d pts" % pontuacao_final
	lbl_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_score.add_theme_font_size_override("font_size", 24)
	lbl_score.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2)) # Dourado
	if _font_pixel:
		lbl_score.add_theme_font_override("font", _font_pixel)
	vbox.add_child(lbl_score)
	
	# Separador
	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("color", Color(1, 1, 1, 0.15))
	vbox.add_child(sep1)
	
	# Seção de Iniciais (LineEdit)
	var hbox_input = HBoxContainer.new()
	hbox_input.alignment = HBoxContainer.ALIGNMENT_CENTER
	hbox_input.add_theme_constant_override("separation", 10)
	vbox.add_child(hbox_input)
	
	var lbl_input = Label.new()
	lbl_input.text = "Iniciais (3 letras):"
	lbl_input.add_theme_font_size_override("font_size", 18)
	lbl_input.add_theme_color_override("font_color", Color.WHITE)
	if _font_pixel:
		lbl_input.add_theme_font_override("font", _font_pixel)
	hbox_input.add_child(lbl_input)
	
	var edit_name = LineEdit.new()
	edit_name.max_length = 3
	edit_name.placeholder_text = "AAA"
	edit_name.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit_name.custom_minimum_size = Vector2(90, 40)
	edit_name.add_theme_font_size_override("font_size", 20)
	if _font_pixel:
		edit_name.add_theme_font_override("font", _font_pixel)
	
	# Estilizar LineEdit
	var style_edit = StyleBoxFlat.new()
	style_edit.bg_color = Color(0.04, 0.06, 0.1, 1.0)
	style_edit.border_width_left = 2
	style_edit.border_width_top = 2
	style_edit.border_width_right = 2
	style_edit.border_width_bottom = 2
	style_edit.border_color = Color(0.35, 0.65, 1.0)
	style_edit.set_corner_radius_all(6)
	edit_name.add_theme_stylebox_override("normal", style_edit)
	edit_name.add_theme_stylebox_override("focus", style_edit)
	
	hbox_input.add_child(edit_name)
	
	# Botão Registrar Pontos
	var btn_register = Button.new()
	btn_register.text = "REGISTRAR PONTOS"
	btn_register.custom_minimum_size = Vector2(250, 45)
	btn_register.add_theme_font_size_override("font_size", 16)
	if _font_pixel:
		btn_register.add_theme_font_override("font", _font_pixel)
	vbox.add_child(btn_register)
	
	# Estilo para os botões do Game Over
	var style_btn = StyleBoxFlat.new()
	style_btn.bg_color = Color(0.12, 0.22, 0.35, 1.0)
	style_btn.set_corner_radius_all(8)
	style_btn.content_margin_left = 15
	style_btn.content_margin_right = 15
	
	var style_btn_hover = style_btn.duplicate()
	style_btn_hover.bg_color = Color(0.18, 0.32, 0.5, 1.0)
	
	btn_register.add_theme_stylebox_override("normal", style_btn)
	btn_register.add_theme_stylebox_override("hover", style_btn_hover)
	btn_register.add_theme_stylebox_override("focus", style_btn)
	
	# Sucesso no Registro
	var lbl_success = Label.new()
	lbl_success.text = ""
	lbl_success.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_success.add_theme_font_size_override("font_size", 14)
	lbl_success.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
	if _font_pixel:
		lbl_success.add_theme_font_override("font", _font_pixel)
	lbl_success.visible = false
	vbox.add_child(lbl_success)
	
	# Conexão do botão Registrar
	btn_register.pressed.connect(func():
		var iniciais = edit_name.text.strip_edges().to_upper()
		if iniciais == "":
			iniciais = "AAA"
		_salvar_score(iniciais, pontuacao_final)
		btn_register.disabled = true
		btn_register.text = "REGISTRADO COM SUCESSO!"
		lbl_success.text = "Score salvo para %s!" % iniciais
		lbl_success.visible = true
		edit_name.editable = false
	)
	
	# Separador
	var sep2 = HSeparator.new()
	sep2.add_theme_color_override("color", Color(1, 1, 1, 0.15))
	vbox.add_child(sep2)
	
	# Botão Jogar Novamente
	var btn_retry = Button.new()
	btn_retry.text = "JOGAR NOVAMENTE"
	btn_retry.custom_minimum_size = Vector2(250, 45)
	btn_retry.add_theme_font_size_override("font_size", 16)
	if _font_pixel:
		btn_retry.add_theme_font_override("font", _font_pixel)
	btn_retry.add_theme_stylebox_override("normal", style_btn)
	btn_retry.add_theme_stylebox_override("hover", style_btn_hover)
	btn_retry.add_theme_stylebox_override("focus", style_btn)
	vbox.add_child(btn_retry)
	btn_retry.pressed.connect(func():
		get_tree().reload_current_scene()
	)
	
	# Botão Ir para o Menu
	var btn_menu = Button.new()
	btn_menu.text = "IR PARA O MENU"
	btn_menu.custom_minimum_size = Vector2(250, 45)
	btn_menu.add_theme_font_size_override("font_size", 16)
	if _font_pixel:
		btn_menu.add_theme_font_override("font", _font_pixel)
	
	var style_btn_menu = style_btn.duplicate()
	style_btn_menu.bg_color = Color(0.2, 0.2, 0.2, 1.0)
	var style_btn_menu_hover = style_btn_hover.duplicate()
	style_btn_menu_hover.bg_color = Color(0.3, 0.3, 0.3, 1.0)
	
	btn_menu.add_theme_stylebox_override("normal", style_btn_menu)
	btn_menu.add_theme_stylebox_override("hover", style_btn_menu_hover)
	btn_menu.add_theme_stylebox_override("focus", style_btn_menu)
	vbox.add_child(btn_menu)
	btn_menu.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
	)
