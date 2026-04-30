extends CanvasLayer

@onready var label_tempo: Label = $Painel/VBox/LabelTempo
@onready var label_pontuacao: Label = $Painel/VBox/LabelPontuacao
@onready var label_pedidos: Label = $Painel/VBox/LabelPedidos
@onready var botao_reiniciar: Button = $Painel/VBox/BotaoReiniciar

func atualizar_tempo(segundos: float) -> void:
	var mins := int(segundos) / 60
	var secs := int(segundos) % 60
	label_tempo.text = "Tempo: %02d:%02d" % [mins, secs]

func atualizar_pontuacao(pts: int) -> void:
	label_pontuacao.text = "Pontuacao: %d" % pts

func atualizar_pedidos(texto: String) -> void:
	label_pedidos.text = texto

func mostrar_resultado(pontuacao_final: int, vitoria: bool) -> void:
	label_tempo.text = "VITORIA!" if vitoria else "Tempo: 00:00"
	if vitoria:
		label_pedidos.text = "Entregues com sucesso!\n%d pts" % pontuacao_final
	else:
		label_pedidos.text = "Tempo esgotado!\n%d pts" % pontuacao_final
	botao_reiniciar.visible = true
	botao_reiniciar.pressed.connect(func(): get_tree().reload_current_scene())
