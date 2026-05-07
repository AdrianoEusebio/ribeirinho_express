# 🗺️ Implementação 13: Expansão do Mapa

## Descrição
O mapa atual será expandido para o dobro do tamanho original (aproximadamente 5120x2880 pixels). Isso permitirá mais áreas de estoque, rotas de patrulha mais longas e uma navegação de barcos mais espaçosa.

## Passos para Implementação

### 1. Atualizar Background e Limites
- **Background**: Substituir ou estender o sprite de `background.png` para cobrir a nova área. Caso usemos `TileMap`, expandir as camadas de desenho.
- **Câmera**: Atualizar os limites da `Camera2D` no `Player.tscn`:
    - `limit_right = 5120`
    - `limit_bottom = 2880`

### 2. Reposicionamento de Elementos
- **Docas**: Mover as docas para a nova extremidade inferior do mapa ou criar novos pontos de atracagem.
- **Zonas de Spawn**: Mover os geradores de itens para áreas mais distantes das docas, aumentando o percurso do jogador.
- **Paredes de Colisão**: Estender as barreiras invisíveis para cercar todo o novo perímetro do mapa.

### 3. Distribuição de Obstáculos e Itens
- Adicionar mais poças d'água, NPCs de patrulha e bandidos para preencher o espaço vazio criado.
- Criar "atalhos" ou caminhos alternativos que o jogador possa usar para evitar áreas perigosas.

### 4. Performance (Culling)
- Garantir que objetos fora da tela não processem lógica pesada.
- Usar `VisibleOnScreenNotifier2D` em NPCs e Itens se necessário para otimizar a renderização no mapa maior.
