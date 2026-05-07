# 🔊 Implementação 08: Áudio e Música

## Descrição
O áudio deve reforçar a imersão na temática amazônica e fornecer feedback tátil para cada ação mecânica do jogo. Abaixo está a lista completa de assets sonoros necessários para uma versão completa.

## Passos Detalhados para Implementação

### 1. Sistema de Áudio (Autoload `SoundManager.gd`)
- Criar um nó `AudioStreamPlayer` para música e um pool de `AudioStreamPlayer` para SFX (permitindo sons sobrepostos).
- Métodos: `play_sfx(id)`, `play_music(id)`, `stop_all_sfx()`.

### 2. Lista Completa de Efeitos Sonoros (SFX)

#### 👣 Jogador e Movimentação
- `step_wood`: Passo seco em madeira (trapiche).
- `step_mud`: Som úmido de passo na lama/terra.
- `player_slip`: Som de escorregão rápido seguido de `player_fall`.
- `player_fall`: Som de corpo caindo no chão (baque surdo).
- `item_pickup`: Som de madeira batendo levemente ao pegar uma caixa.
- `item_drop`: Som de objeto sendo colocado no chão.

#### 📦 Interação com Grid (Barco)
- `grid_hover`: Som sutil de "clique" ao passar o item sobre as células do grid.
- `grid_place_success`: Som de "encaixe" satisfatório (tipo um 'clack' de madeira encaixando perfeitamente).
- `grid_place_error`: Som curto de erro (buzzer grave) se tentar colocar em local inválido.
- `grid_rotate`: Som de objeto girando ou deslizando.
- `item_break`: Som de madeira lascando ou vidro quebrando (para itens frágeis).

#### 🛶 Ambiente e Entidades
- `boat_engine_loop`: Som de motor de rabeta constante (grave e rítmico).
- `boat_horn`: Buzina de barco a vapor para chegada/partida.
- `water_splash`: Som de água espirrando (poças ou barco cortando o rio).
- `bandit_laugh`: Risada sarcástica ou resmungo quando o ladrão rouba algo.
- `npc_mumble`: Resmungo rítmico estilo Undertale para diálogos.

#### 📺 Interface e Sistema
- `ui_button_hover`: Som metálico ou de clique leve.
- `ui_button_click`: Som de confirmação.
- `countdown_tick`: Som de relógio mecânico (tic-tac).
- `timer_alarm`: Som de aviso urgente (apito de barco rápido) nos últimos 10s.
- `victory_jingle`: Fanfarra curta com flauta amazônica ao terminar a fase com sucesso.

### 3. Trilha Sonora (Música)
- `bgm_gameplay_calm`: Carimbó/Beiradão instrumental com percussão leve e violão.
- `bgm_gameplay_tense`: Versão da mesma música com BPM acelerado e mais batidas de tambor para o final da partida.
- `bgm_menu`: Melodia suave com sons de natureza ao fundo (pássaros, água).

### 4. Configuração de Mixagem
- Criar 3 barramentos (Buses) no Godot: `Master`, `Music` e `SFX`.
- Aplicar um leve efeito de Reverb no bus `SFX` para sons que acontecem no porto aberto.
