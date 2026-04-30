# ⛴️ Ribeirinho Express

Jogo de puzzle e logística inspirado na vida nos rios da Amazônia. Organize sua carga, respeite os limites de peso e entregue as mercadorias antes que o tempo acabe!

## 🚀 Status Atual: Core Mechanics Finalizado
O sistema de interação e organização de carga está 100% funcional.

### Funcionalidades Implementadas:
- ✅ **Inventário Dinâmico**: Carregue até 3 itens (Pesados, Médios ou Frágeis) com impacto na velocidade.
- ✅ **Barco com Grid (5x4)**: Sistema de organização por células com suporte a rotação de itens.
- ✅ **Física de Pressão**: Itens Frágeis possuem limite de resistência (2 pontos).
- ✅ **Distribuição de Carga**: O peso dos itens de cima é dividido entre todos os suportes de baixo (Ponteamento).
- ✅ **Gravidade e Destruição**: Itens quebram visualmente e as pilhas superiores caem para preencher o vácuo.
- ✅ **Restrições de Realismo**: Proibido colocar itens no ar e limite de distância para interagir com o barco.

---

## 🎯 Próximos Passos (To-Do)

### 1. Sistema de Pedidos (Orders System)
- Criar um sistema que gera "listas de compras" que o jogador deve coletar e organizar no barco.
- Bônus por organizar os itens de forma eficiente (menos espaço usado).

### 2. Gamificação e UI
- Adicionar um temporizador para as entregas.
- Menu principal e HUD para mostrar a carga atual e o pedido ativo.
- Efeitos sonoros (KABOOM ao quebrar itens, som de impacto ao cair).

### 3. Visual e Ambientação
- Substituir os blocos coloridos por sprites reais (caixas de madeira, cestas de açaí, eletrodomésticos).
- Animar o personagem carregando os itens acima da cabeça.

---

## 🛠️ Tecnologias
- **Engine**: Godot 4.3 (GDScript)
- **Design**: Data-driven com Resources (`ItemData`)
