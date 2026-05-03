extends Node2D

@export var tempo_total: float = 120.0
@export var pontuacao_vitoria: int = 500

var tempo_restante: float
var pontuacao: int = 0
var jogo_ativo: bool = true

@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	tempo_restante = tempo_total
	hud.atualizar_tempo(tempo_restante)
	hud.atualizar_pontuacao(pontuacao)

	for doca in get_tree().get_nodes_in_group("doca"):
		doca.pedido_entregue.connect(_on_pedido_entregue)

	_atualizar_hud_pedidos()

func _process(delta: float) -> void:
	if not jogo_ativo:
		return
	tempo_restante -= delta
	hud.atualizar_tempo(maxf(tempo_restante, 0.0))
	if tempo_restante <= 0.0:
		_fim_de_jogo()

func _on_pedido_entregue(pontos: int) -> void:
	pontuacao += pontos
	hud.atualizar_pontuacao(pontuacao)
	_atualizar_hud_pedidos()
	if pontuacao >= pontuacao_vitoria:
		_vitoria()

func _atualizar_hud_pedidos() -> void:
	var texto = ""
	for doca in get_tree().get_nodes_in_group("doca"):
		for boat in doca.boats:
			if boat != null and boat.pedido != null:
				texto += boat.pedido.nome + " (Barco %d):\n" % (boat.spot_index + 1)
				for item in boat.pedido.itens_necessarios:
					texto += "  - " + item.nome + "\n"
	if texto.is_empty():
		hud.atualizar_pedidos("Aguardando barcos...")
	else:
		hud.atualizar_pedidos(texto)

func _vitoria() -> void:
	jogo_ativo = false
	hud.mostrar_resultado(pontuacao, true)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)

func _fim_de_jogo() -> void:
	jogo_ativo = false
	hud.mostrar_resultado(pontuacao, false)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
