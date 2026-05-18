extends Control

## Script do Menu Principal (Implementation 10 & 14)
## Gerencia o fluxo inicial de jogo, configurações e ranking geral.

@onready var btn_play: Button = $VBoxContainer/BtnPlay
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var btn_ranking: Button = $VBoxContainer/BtnRanking
@onready var btn_quit: Button = $VBoxContainer/BtnQuit
@onready var title_label: Label = $Title

var _font_pixel: Font = null
var _font_title: Font = null

func _ready() -> void:
	_font_title = load("res://assets/assets/04b_30/04B_30__.TTF")
	if _font_title and title_label:
		title_label.add_theme_font_override("font", _font_title)
		title_label.add_theme_font_size_override("font_size", 64)
	
	_font_pixel = load("res://assets/assets/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf")
	var botoes = [btn_play, btn_settings, btn_ranking, btn_quit]
	for btn in botoes:
		if btn and _font_pixel:
			btn.add_theme_font_override("font", _font_pixel)
			btn.add_theme_font_size_override("font_size", 22) # Ajuste para legibilidade
	
	if btn_play:
		btn_play.pressed.connect(_on_play_pressed)
	if btn_settings:
		btn_settings.pressed.connect(_on_settings_pressed)
	if btn_ranking:
		btn_ranking.pressed.connect(_on_ranking_pressed)
	if btn_quit:
		btn_quit.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	print("Abrir configurações: Volume, Tela Cheia...")

func _on_ranking_pressed() -> void:
	# Criar overlay de tela cheia para o Ranking
	var overlay = ColorRect.new()
	overlay.name = "RankingOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.04, 0.08, 0.14, 0.9)
	add_child(overlay)
	
	# CenterContainer
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	
	# PanelContainer do Ranking
	var panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.2, 0.95)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.35, 0.65, 1.0)
	style.set_corner_radius_all(12)
	style.content_margin_left = 40
	style.content_margin_right = 40
	style.content_margin_top = 35
	style.content_margin_bottom = 35
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	
	# VBoxContainer
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)
	
	# Título do Ranking
	var lbl_title = Label.new()
	lbl_title.text = "RANKING GERAL"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 36)
	lbl_title.add_theme_color_override("font_color", Color(0.35, 0.65, 1.0))
	if _font_title:
		lbl_title.add_theme_font_override("font", _font_title)
	vbox.add_child(lbl_title)
	
	# Separador
	var sep1 = HSeparator.new()
	sep1.add_theme_color_override("color", Color(1, 1, 1, 0.15))
	vbox.add_child(sep1)
	
	# Carregar Scores
	var scores := _carregar_scores()
	
	if scores.is_empty():
		var lbl_empty = Label.new()
		lbl_empty.text = "NENHUM REGISTRO AINDA"
		lbl_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_empty.add_theme_font_size_override("font_size", 18)
		lbl_empty.add_theme_color_override("font_color", Color(0.55, 0.65, 0.75))
		if _font_pixel:
			lbl_empty.add_theme_font_override("font", _font_pixel)
		vbox.add_child(lbl_empty)
	else:
		# GridContainer de Pontuações (3 Colunas: Posição, Iniciais, Score)
		var grid = GridContainer.new()
		grid.columns = 3
		grid.add_theme_constant_override("h_separation", 50)
		grid.add_theme_constant_override("v_separation", 12)
		vbox.add_child(grid)
		
		# Headers
		var headers = ["POS", "JOGADOR", "PONTOS"]
		for header in headers:
			var lbl_h = Label.new()
			lbl_h.text = header
			lbl_h.add_theme_font_size_override("font_size", 16)
			lbl_h.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2)) # Amarelo/Dourado
			if _font_pixel:
				lbl_h.add_theme_font_override("font", _font_pixel)
			grid.add_child(lbl_h)
			
		# Exibir Top 10
		for idx in range(scores.size()):
			var item = scores[idx]
			
			# Posição
			var lbl_pos = Label.new()
			lbl_pos.text = "%02d." % (idx + 1)
			lbl_pos.add_theme_font_size_override("font_size", 16)
			lbl_pos.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45) if idx == 0 else Color.WHITE)
			if _font_pixel:
				lbl_pos.add_theme_font_override("font", _font_pixel)
			grid.add_child(lbl_pos)
			
			# Iniciais
			var lbl_name = Label.new()
			lbl_name.text = str(item.get("name", "AAA"))
			lbl_name.add_theme_font_size_override("font_size", 16)
			lbl_name.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45) if idx == 0 else Color.WHITE)
			if _font_pixel:
				lbl_name.add_theme_font_override("font", _font_pixel)
			grid.add_child(lbl_name)
			
			# Score
			var lbl_score = Label.new()
			lbl_score.text = "%d PTS" % int(item.get("score", 0))
			lbl_score.add_theme_font_size_override("font_size", 16)
			lbl_score.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45) if idx == 0 else Color.WHITE)
			if _font_pixel:
				lbl_score.add_theme_font_override("font", _font_pixel)
			grid.add_child(lbl_score)
			
	# Separador
	var sep2 = HSeparator.new()
	sep2.add_theme_color_override("color", Color(1, 1, 1, 0.15))
	vbox.add_child(sep2)
	
	# Botão Voltar
	var btn_back = Button.new()
	btn_back.text = "VOLTAR AO MENU"
	btn_back.custom_minimum_size = Vector2(200, 45)
	btn_back.add_theme_font_size_override("font_size", 16)
	if _font_pixel:
		btn_back.add_theme_font_override("font", _font_pixel)
	
	# Estilizar botão voltar
	var style_btn = StyleBoxFlat.new()
	style_btn.bg_color = Color(0.12, 0.22, 0.35, 1.0)
	style_btn.set_corner_radius_all(8)
	style_btn.content_margin_left = 15
	style_btn.content_margin_right = 15
	
	var style_btn_hover = style_btn.duplicate()
	style_btn_hover.bg_color = Color(0.18, 0.32, 0.5, 1.0)
	
	btn_back.add_theme_stylebox_override("normal", style_btn)
	btn_back.add_theme_stylebox_override("hover", style_btn_hover)
	btn_back.add_theme_stylebox_override("focus", style_btn)
	
	vbox.add_child(btn_back)
	btn_back.pressed.connect(func():
		overlay.queue_free()
	)

func _carregar_scores() -> Array:
	var path: String = "user://scores.json"
	if not FileAccess.file_exists(path):
		return []
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var err = json.parse(content)
		if err == OK and json.data is Array:
			return json.data
	return []
