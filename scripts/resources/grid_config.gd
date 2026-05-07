## Configuração de um grid de barco.
## Criar via editor: botão direito → New Resource → GridConfig
class_name GridConfig
extends Resource

@export var id_grid: String = "padrao"
@export var largura: int = 5
@export var altura: int = 4
## Células que não aceitam itens (buracos na estrutura do barco)
@export var celulas_bloqueadas: Array[Vector2i] = []
## Usado pelo OrderManager para gerar pedidos proporcionais ao espaço
@export var max_itens_recomendados: int = 8
