## Dados de um item do jogo (mercadoria/carga).
## Criar novos itens: botão direito na pasta resources/itens → New Resource → ItemData
@icon("res://icon.svg")
class_name ItemData
extends Resource

## Nome legível do item (ex: "Caixa de Medicamentos")
@export var nome: String = ""

## Sprite do item no mundo e no grid
@export var icone: Texture2D

## Cor para teste visual (caso não tenha sprite)
@export var cor: Color = Color.WHITE

## Peso em kg — afeta a velocidade do jogador ao carregar
@export_range(0.1, 100.0, 0.1) var massa: float = 1.0

## Dimensão do item no grid (largura x altura em células)
@export var tamanho: Vector2i = Vector2i(1, 1)

## Categoria que define as regras de posicionamento no grid
## 0 = PESADO (só no chão), 1 = MEDIO (qualquer lugar), 2 = FRAGIL (sem peso acima)
@export_enum("PESADO", "MEDIO", "FRAGIL") var categoria: int = 1

## Células ocupadas relativas à origem (0,0).
## Ex: peça em L → [(0,0), (0,1), (1,0)]
## Se vazio, será calculado automaticamente como retângulo usando 'tamanho'
@export var formato: Array[Vector2i] = []

## Se true, este item dá bônus de pontuação (medicamentos, alimentos)
@export var eh_essencial: bool = false

## Peso na pontuação — itens mais importantes valem mais
@export_range(1, 10) var prioridade: int = 1

## Descrição curta para a UI (tooltip)
@export_multiline var descricao: String = ""


## Retorna as células que o item ocupa.
## Se 'formato' estiver vazio, gera um retângulo baseado no 'tamanho'.
func obter_formato() -> Array[Vector2i]:
	if formato.size() > 0:
		return formato
	
	# Gerar retângulo automático
	var celulas: Array[Vector2i] = []
	for x in range(tamanho.x):
		for y in range(tamanho.y):
			celulas.append(Vector2i(x, y))
	return celulas


## Retorna o formato rotacionado 90° no sentido horário.
## Chamado quando o jogador pressiona R para rotacionar.
func obter_formato_rotacionado(rotacao: int) -> Array[Vector2i]:
	var celulas := obter_formato()
	var resultado: Array[Vector2i] = []
	
	# Aplicar rotação N vezes (0=0°, 1=90°, 2=180°, 3=270°)
	var rot := rotacao % 4
	for celula in celulas:
		var nova := celula
		for i in range(rot):
			nova = Vector2i(-nova.y, nova.x)
		resultado.append(nova)
	
	# Normalizar para que todas as coordenadas sejam >= 0
	var min_x := 0
	var min_y := 0
	for c in resultado:
		min_x = min(min_x, c.x)
		min_y = min(min_y, c.y)
	
	var normalizado: Array[Vector2i] = []
	for c in resultado:
		normalizado.append(Vector2i(c.x - min_x, c.y - min_y))
	
	return normalizado


## Retorna a categoria como texto legível.
func obter_nome_categoria() -> String:
	match categoria:
		0: return "PESADO"
		1: return "MEDIO"
		2: return "FRAGIL"
		_: return "DESCONHECIDO"
