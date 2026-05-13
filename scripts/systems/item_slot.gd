## Carga disponivel na area de descarga do caminhao de suprimentos.
## Compatibilidade com a interacao do jogador:
## possui a propriedade `dados` e o metodo `coletar()`.
extends Node2D

var dados: ItemData = null

const METADE := 20.0


func _ready() -> void:
	var area := Area2D.new()
	area.collision_layer = 2
	area.collision_mask = 0
	add_child(area)

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(METADE * 2.0, METADE * 2.0)
	shape.shape = rect
	area.add_child(shape)


func _draw() -> void:
	if dados == null:
		return

	var fundo := dados.cor
	var sombra := Color(0.03, 0.025, 0.02, 0.35)
	draw_rect(Rect2(-METADE + 3.0, -METADE + 4.0, METADE * 2.0, METADE * 2.0), sombra)
	draw_rect(Rect2(-METADE, -METADE, METADE * 2.0, METADE * 2.0), fundo)
	draw_rect(Rect2(-METADE, -METADE, METADE * 2.0, METADE * 2.0), Color(1.0, 0.95, 0.84), false, 1.5)

	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-METADE + 2.0, 2.0), dados.nome.left(10),
		HORIZONTAL_ALIGNMENT_CENTER, METADE * 2.0 - 4.0, 8, Color.WHITE)

	var cat_cor: Color
	match dados.categoria:
		0: cat_cor = Color(0.96, 0.18, 0.18)
		1: cat_cor = Color(1.0, 0.74, 0.12)
		2: cat_cor = Color(0.22, 0.88, 0.42)
		_: cat_cor = Color.GRAY
	draw_rect(Rect2(-METADE, METADE - 7.0, METADE * 2.0, 7.0), cat_cor)
	draw_line(Vector2(-METADE + 6.0, -METADE + 7.0), Vector2(METADE - 6.0, -METADE + 7.0),
		Color(1.0, 1.0, 1.0, 0.25), 1.0)


## Chamado pelo jogador ao interagir.
func coletar() -> ItemData:
	queue_free()
	return dados
