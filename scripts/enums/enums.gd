## Enums globais do jogo.
## Registrado como Autoload para acesso global.
extends Node

enum Categoria {
	PESADO,
	MEDIO,
	FRAGIL
}

enum EstadoJogador {
	VAZIO,        ## Sem carga — velocidade normal
	CARREGANDO,   ## Carregando item(ns) — velocidade reduzida
	LENTO,        ## Carga pesada demais — velocidade mínima
	ATORDOADO     ## Sofreu obstáculo — sem controle temporário
}
