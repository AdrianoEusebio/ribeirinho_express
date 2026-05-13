extends Control

## Script do Menu Principal (Implementation 10)
## Gerencia o fluxo inicial de jogo e configurações.

@onready var btn_play: Button = $VBoxContainer/BtnPlay
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var btn_quit: Button = $VBoxContainer/BtnQuit
@onready var title_label: Label = $Title

func _ready() -> void:
	var font_title = load("res://assets/assets/04b_30/04B_30__.TTF")
	if font_title:
		title_label.add_theme_font_override("font", font_title)
		title_label.add_theme_font_size_override("font_size", 64)
	
	var font_btns = load("res://assets/assets/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf")
	var botoes = [btn_play, btn_settings, btn_quit]
	for btn in botoes:
		if btn and font_btns:
			btn.add_theme_font_override("font", font_btns)
			btn.add_theme_font_size_override("font_size", 22) # Ajuste para legibilidade
	
	if btn_play:
		btn_play.pressed.connect(_on_play_pressed)
	if btn_settings:
		btn_settings.pressed.connect(_on_settings_pressed)
	if btn_quit:
		btn_quit.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	# Transição para a cena principal
	# Em um projeto real, aqui teríamos uma animação de fade
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	# Placeholder para painel de configurações
	print("Abrir configurações: Volume, Tela Cheia...")
