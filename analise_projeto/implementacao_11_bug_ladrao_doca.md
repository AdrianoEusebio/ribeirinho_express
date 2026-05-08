# 🐛 Implementação 11: BUG - Restrição do Ladrão na Doca

## Descrição
Atualmente, o ladrão pode entrar na área da doca, o que torna o jogo injusto, pois o jogador está focado no puzzle do grid. A área da doca deve ser uma "zona segura" contra roubos físicos.

## Passos para Implementação

### 1. Definir a Área da Doca
- Adicionar um nó `Area2D` chamado `SafeZone` na cena da Doca.
- Configurar o `CollisionLayer` para uma camada específica (ex: Camada 5 - "SafeZones").

### 2. Modificar IA do Ladrão (`Thief.gd`)
- **Zona Segura**: O ladrão não pode entrar na doca enquanto o jogador estiver nela.
- **Lógica de Colisão**:
    - Se o jogador **tem itens**: O ladrão executa o roubo e entra no estado `FUGINDO`.
    - Se o jogador **não tem itens**: O ladrão aplica um "impulso" (knockback) no jogador, jogando-o para trás (efeito trampolim), e continua sua patrulha ou perseguição.
- **Spawn Adaptativo**: O `GameManager` deve instanciar novos bandidos conforme a pontuação do jogador aumenta rapidamente.

### 3. Recuperação de Itens
- Se o jogador alcançar o ladrão no estado `FUGINDO` (ou usar o Power-up Bastão), o item é dropado no chão e o ladrão é atordoado por alguns segundos.

### 4. Feedback Visual
- O ladrão pode fazer um gesto de "frustração" ou "pare" ao chegar na borda da doca.
