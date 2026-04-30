## Lógica pura do Grid (Tabuleiro do Barco).
class_name GridData
extends Object

signal item_quebrado(item: ItemData)
signal item_caiu(item: ItemData, nova_pos: Vector2i)

var largura: int
var altura: int
var celulas: Array = [] # Array 2D: celulas[x][y]

func _init(l: int, a: int) -> void:
	largura = l
	altura = a
	for x in range(largura):
		var coluna = []
		for y in range(altura):
			coluna.append(null)
		celulas.append(coluna)

func pode_colocar(item: ItemData, pos: Vector2i, formato: Array[Vector2i]) -> bool:
	for celula_relativa in formato:
		var x = pos.x + celula_relativa.x
		var y = pos.y + celula_relativa.y
		if x < 0 or x >= largura or y < 0 or y >= altura: return false
		if celulas[x][y] != null: return false
	
	if item.categoria == Enums.Categoria.PESADO:
		var toca_chao = false
		for celula_relativa in formato:
			if (pos.y + celula_relativa.y) == altura - 1:
				toca_chao = true
				break
		if not toca_chao: return false
	
	# Regra de SUPORTE (Não deixar voar)
	var tem_suporte = false
	for celula_relativa in formato:
		var cx = pos.x + celula_relativa.x
		var cy = pos.y + celula_relativa.y
		if cy == altura - 1 or (cy + 1 < altura and celulas[cx][cy + 1] != null):
			tem_suporte = true
			break
	if not tem_suporte: return false
				
	return true

func colocar_item(item: ItemData, pos: Vector2i, formato: Array[Vector2i]) -> void:
	for celula_relativa in formato:
		var x = pos.x + celula_relativa.x
		var y = pos.y + celula_relativa.y
		celulas[x][y] = item
	_checar_quebra_de_frageis()

func _checar_quebra_de_frageis() -> void:
	var mapa_pressao = _calcular_mapa_de_pressao()
	var itens_para_quebrar = []
	
	for x in range(largura):
		for y in range(altura):
			var item = celulas[x][y]
			if item != null and item.categoria == Enums.Categoria.FRAGIL:
				# Se a pressão em QUALQUER célula do item frágil passar de 2.0
				if mapa_pressao[x][y] > 2.1 and not item in itens_para_quebrar:
					itens_para_quebrar.append(item)
	
	if itens_para_quebrar.size() > 0:
		for item in itens_para_quebrar:
			item_quebrado.emit(item)
			_remover_item_data(item)
		processar_gravidade()

## ALGORITMO DE DISTRIBUIÇÃO DE FORÇA
## Calcula quanto peso cada célula do grid está recebendo de cima.
func _calcular_mapa_de_pressao() -> Array:
	var pressao = []
	for x in range(largura):
		var col = []; col.resize(altura); col.fill(0.0)
		pressao.append(col)
	
	# Processamos do topo para o fundo para acumular o peso vindo de cima
	for y in range(0, altura):
		for x in range(largura):
			var item = celulas[x][y]
			if item == null: continue
			
			# Só processamos o item uma vez (pela sua célula mais ao topo-esquerda)
			if not _eh_topo_esquerda(item, x, y): continue
			
			# 1. Calcular Peso Total deste item (Peso Base + Pressão que ele já recebeu de cima)
			var peso_base = item.tamanho.x * item.tamanho.y
			var pressao_recebida = _get_pressao_sobre_item(item, pressao)
			var peso_total = peso_base + pressao_recebida
			
			# 2. Contar quantos pontos de apoio este item tem embaixo dele
			var apoios = _get_celulas_de_apoio(item)
			if apoios.size() > 0:
				var peso_por_apoio = peso_total / float(apoios.size())
				# 3. Distribuir o peso para as células de apoio
				for a in apoios:
					pressao[a.x][a.y] += peso_por_apoio
					
	return pressao

func _eh_topo_esquerda(item: ItemData, x: int, y: int) -> bool:
	for ix in range(largura):
		for iy in range(altura):
			if celulas[ix][iy] == item:
				return ix == x and iy == y
	return false

func _get_pressao_sobre_item(item: ItemData, mapa_pressao: Array) -> float:
	var total = 0.0
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item:
				total += mapa_pressao[x][y]
	return total

func _get_celulas_de_apoio(item: ItemData) -> Array[Vector2i]:
	var apoios: Array[Vector2i] = []
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item:
				var abaixo = y + 1
				if abaixo < altura:
					# Um apoio é qualquer célula ocupada abaixo ou o próprio chão
					# Mas aqui queremos saber quem RECEBE a pressão, então focamos no item abaixo
					if celulas[x][abaixo] != null and celulas[x][abaixo] != item:
						apoios.append(Vector2i(x, abaixo))
					elif abaixo == altura - 1 and celulas[x][abaixo] == null:
						# O chão também é um apoio, mas não precisamos somar pressão nele para fins de quebra
						pass 
	# Adicionamos um "apoio virtual" se estiver no chão para a conta de divisão fechar
	var total_apoios_reais = apoios.size()
	var encosta_no_chao = false
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item and y == altura - 1:
				encosta_no_chao = true; break
	
	# Se quisermos ser ultra-precisos, retornaríamos todos os pontos de contato.
	# Para o jogo, se o item tem 2 células na base e uma está no ar e outra no item, 
	# a que está no item recebe 100% do peso.
	return apoios

func _remover_item_data(item: ItemData) -> void:
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item: celulas[x][y] = null

func processar_gravidade() -> void:
	var itens_no_grid = []
	for x in range(largura):
		for y in range(altura):
			var item = celulas[x][y]
			if item != null and not item in itens_no_grid: itens_no_grid.append(item)
	
	itens_no_grid.sort_custom(func(a, b): return _get_item_bottom_y(a) > _get_item_bottom_y(b))
	
	var algo_mudou = false
	for item in itens_no_grid:
		var queda = _calcular_queda_maxima(item)
		if queda > 0:
			_mover_item_fisicamente(item, queda)
			algo_mudou = true
	if algo_mudou: processar_gravidade()

func _get_item_bottom_y(item: ItemData) -> int:
	var max_y = -1
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item: max_y = max(max_y, y)
	return max_y

func _calcular_queda_maxima(item: ItemData) -> int:
	var celulas_item = []
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item: celulas_item.append(Vector2i(x, y))
	if celulas_item.is_empty(): return 0
	var distancia = 0
	while true:
		var d_teste = distancia + 1
		var pode_cair = true
		for c in celulas_item:
			var ny = c.y + d_teste
			if ny >= altura or (celulas[c.x][ny] != null and celulas[c.x][ny] != item):
				pode_cair = false; break
		if pode_cair: distancia = d_teste
		else: break
	return distancia

func _mover_item_fisicamente(item: ItemData, distancia: int) -> void:
	var celulas_originais = []
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] == item:
				celulas_originais.append(Vector2i(x, y))
				celulas[x][y] = null
	var nova_pos_ancora = Vector2i(largura, altura)
	for c in celulas_originais:
		var ny = c.y + distancia
		celulas[c.x][ny] = item
		if ny < nova_pos_ancora.y: nova_pos_ancora.y = ny
		if c.x < nova_pos_ancora.x: nova_pos_ancora.x = c.x
	item_caiu.emit(item, nova_pos_ancora)

func calcular_ocupacao() -> float:
	var ocupadas = 0
	for x in range(largura):
		for y in range(altura):
			if celulas[x][y] != null: ocupadas += 1
	return (float(ocupadas) / (largura * altura)) * 100.0
