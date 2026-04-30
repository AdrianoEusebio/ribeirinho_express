## Script que controla o item físico no cenário.
extends Node2D

## Dados do item vinculados a esta instância.
## Arraste um arquivo .tres da pasta resources/itens para este campo no Inspector.
@export var dados: ItemData:
	set(novo_valor):
		dados = novo_valor.duplicate() if novo_valor else null
		if is_inside_tree():
			_atualizar_visual()

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label_nome: Label = $LabelNome # Para debug visual se não tivermos sprite

func _ready() -> void:
	add_to_group("item_chao")
	_atualizar_visual()

## Atualiza a aparência do item baseado nos dados atribuídos.
func _atualizar_visual() -> void:
	if dados == null:
		return
	
	if dados.icone:
		sprite_2d.texture = dados.icone
		sprite_2d.modulate = Color.WHITE
		label_nome.visible = false
	else:
		# Fallback para teste: ícone do Godot pintado com a cor do item
		sprite_2d.texture = preload("res://icon.svg")
		sprite_2d.modulate = dados.cor
		sprite_2d.scale = Vector2(0.25, 0.25) # Tamanho base no chão
		label_nome.text = dados.nome
		label_nome.visible = true

## Chamado quando o jogador coleta o item.
func coletar() -> ItemData:
	# Aqui podemos adicionar um efeito de som ou partícula no futuro
	queue_free() # Remove o item do chão
	return dados
