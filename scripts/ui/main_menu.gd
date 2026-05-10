extends Control

## Script do Menu Principal (Implementation 10)
## Gerencia o fluxo inicial de jogo e configurações.

@onready var btn_play: Button = $VBoxContainer/BtnPlay
@onready var btn_settings: Button = $VBoxContainer/BtnSettings
@onready var btn_quit: Button = $VBoxContainer/BtnQuit

func _ready() -> void:
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
