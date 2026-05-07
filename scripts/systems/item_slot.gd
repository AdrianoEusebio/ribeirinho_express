## Item aguardando coleta em um slot da esteira geradora.
## Compatível com o sistema de interação do jogador (mesma interface que item.gd):
## tem propriedade `dados` e método `coletar()`.
extends Node2D

var dados: ItemData = null

const METADE := 20.0

func _ready() -> void:
	# Area2D para ser detectada pelo Hitbox do jogador (collision_layer = 2, igual item.tscn)
	var area := Area2D.new()
	area.collision_layer = 2
	area.collision_mask = 0
	add_child(area)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(METADE * 2, METADE * 2)
	shape.shape = rect
	area.add_child(shape)

func _draw() -> void:
	if dados == null:
		return

	# Fundo colorido com a cor do item
	draw_rect(Rect2(-METADE, -METADE, METADE * 2, METADE * 2), dados.cor)
	draw_rect(Rect2(-METADE, -METADE, METADE * 2, METADE * 2), Color.WHITE, false, 1.5)

	# Nome do item (centralizado)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-METADE, 3), dados.nome, HORIZONTAL_ALIGNMENT_CENTER, METADE * 2, 9, Color.WHITE)

	# Faixa de categoria na base do slot
	var cat_cor: Color
	match dados.categoria:
		0: cat_cor = Color(1.0, 0.3, 0.3)  # PESADO — vermelho
		1: cat_cor = Color(1.0, 0.75, 0.1) # MEDIO  — amarelo
		2: cat_cor = Color(0.3, 1.0, 0.45) # FRAGIL — verde
		_: cat_cor = Color.GRAY
	draw_rect(Rect2(-METADE, METADE - 7, METADE * 2, 7), cat_cor)

## Chamado pelo jogador ao interagir (compatível com item.gd).
func coletar() -> ItemData:
	queue_free()
	return dados
