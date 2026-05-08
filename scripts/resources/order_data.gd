class_name OrderData
extends Resource

@export var nome: String = "Pedido"
@export var itens_necessarios: Array[ItemData] = []
@export var recompensa_pontos: int = 100
## Segundos que o barco aguarda antes de partir sem recompensa
@export_range(15.0, 120.0, 1.0) var tempo_limite: float = 45.0
