# 🔄 Implementação 06: Game Loop (Tempo e Dificuldade)

## Descrição
Gerenciar o ciclo de vida da partida: desde a contagem regressiva inicial até a tela de resultados final, controlando o tempo, a pontuação e a progressão de dificuldade.

## Passos Detalhados para Implementação

### 1. Criar `GameManager.gd` (Autoload)
- **Estados**: `STARTING`, `PLAYING`, `ENDED`.
- **Variáveis Globais**:
    - `pontuacao: int = 0`
    - `tempo_restante: float = 180.0` (3:00 min)
    - `is_frozen: bool = true`
- **Sinais**: `score_changed(new_score)`, `timer_changed(new_time)`, `game_started`, `game_finished`.

### 2. Contagem Regressiva Inicial (Get Ready)
- Ao carregar a cena principal:
    1. Definir `is_frozen = true` (ou `get_tree().paused = true`, mas cuidado com a UI).
    2. Mostrar um Label gigante no centro da tela: "3... 2... 1... VAI!".
    3. Usar um `Timer` ou `Tween` para atualizar o texto a cada 1 segundo.
    4. Ao final dos 3 segundos:
        - Ocultar o Label.
        - Definir `is_frozen = false`.
        - Emitir o sinal `game_started`.
        - Começar o cronômetro oficial de 3 minutos.

### 3. Sistema de Tempo e Pontuação
- **Cronômetro**: No `_process`, decrementar `tempo_restante` apenas se `not is_frozen`.
- **Pontuação Adaptativa**:
    - Ao entregar um barco: `pontos_base * (tempo_restante_do_barco / tempo_total_do_barco)`.
    - Se o barco for entregue muito rápido, adicionar um `bonus_combo`.
- **Dificuldade**: A cada 1000 pontos, reduzir o intervalo de spawn de novos barcos e aumentar a chance de spawn de bandidos.

### 4. Ciclo de Barcos (Overcooked Style)
- O `GameManager` monitora os spots de barcos.
- Se um spot está vazio e `not is_frozen`, disparar o spawn de um novo barco após um delay aleatório.
- Se um barco atinge o timeout de espera, chamar `boat.partir()` sem processar recompensa.

### 5. Finalização e Resultados
- Quando `tempo_restante <= 0`:
    1. Definir `is_frozen = true`.
    2. Parar todas as IAs (ladrões e NPCs).
    3. Instanciar a `ResultScreen.tscn`.
    4. Mostrar: Recorde Local, Pontos Atuais e Estrelas (1 a 3 baseadas na meta).
