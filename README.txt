Documentação Técnica: Ribeirinho Express (Projeto Uninorte)
1. Visão Geral e Arquitetura do Sistema
O projeto utiliza uma abordagem de Prototipagem por Blocos (Greyboxing). A lógica de jogo é separada da estética para permitir iterações rápidas e escalabilidade regional.
• 
Perspectiva: 2D Top-Down (Ortogonal).

• Grid Base: $32 \times 32$ pixels (unidade lógica de movimento e colisão).
• Motor: GameMaker / GML (GameMaker Language).
2. Ciclo de Vida do Ativo: obj_carga_pai
Para garantir a independência de texturas, todas as cargas herdam de um objeto pai com as seguintes variáveis de instância:VariávelTipoFunçãomassaRealPeso do item (fator de redução de velocidade).grid_w / grid_hIntDimensões do objeto em unidades de grid.is_fragileBoolDefine se o item quebra em colisões acima de v_limit.id_formaArrayMatriz binária para o mini-game de Tetris.
3. Máquina de Estados do Jogador (obj_jogador)
O jogador opera sob uma lógica de estados para gerenciar animações de "mãos levantadas" e restrições de movimento.
• Estados: ESTADO.VAZIO, ESTADO.CARREGANDO, ESTADO.LENTO, ESTADO.ATORDOADO.
• Slots de Inventário:
    ◦ Slot_A: Primário (base da pilha).
    ◦ Slot_B: Secundário (topo da pilha - apenas se Slot_A for $1 \times 1$).
4. Cronograma de Desenvolvimento (Sprints de 10 dias)
Sprint 1: Core Engine & Física Base
Implementação da movimentação fluida e colisão de ambiente.
• Variável Crítica: move_spd = base_spd - (massa_total * penalidade).
• Sistema de Snap: Alinhamento automático da carga ao centro do jogador ao coletar.
Sprint 2: Lógica de Missão (Logística)
Criação do sistema de demandas e validação.
• Pedido: Objeto JSON contendo {tipo_id, quantidade, destino_id}.
• UI: Display dinâmico de lista de pedidos ativa.
Sprint 3: O Sistema de Caos (Dynamic Obstacles)
Implementação de ameaças externas que afetam os atributos do jogador.
• Poças: Modificam o atrito do chão, gerando deslize.
• Ladrões (NPC): IA de perseguição simples que aciona o estado ATORDOADO no player.
Sprint 4: Estética e Level Design
Conversão dos protótipos em arte final (Porto e Armazém).
• Mapas: Construção via Tilemaps usando o grid de 32px.
• Feedback: Partículas de poeira e efeitos sonoros de impacto.
5. Regras de Empilhamento e Dimensionamento
A escala define a dificuldade de navegação nos corredores do armazém.
• Itens Grandes (> 1x1): Exemplo: Sofá ($3 \times 1$). Bloqueia o empilhamento. O jogador só carrega um.
• Itens Pequenos (1x1): Exemplo: Caixa. Permite empilhamento máximo de 2 unidades.
• Escala do Mundo:
    ◦ Jogador: $32 \times 48$ px (ocupa 1.5 grid vertical).
    ◦ Corredores: Mínimo de $64$ px (2 grids) para permitir rotação de itens grandes.
6. Lógica de Velocidade Dinâmica (Fórmula IA)
Para facilitar o ajuste de dificuldade (balanceamento), utilizamos a seguinte equação para o cálculo de frame:$$velocidade\_final = velocidade\_base - (massa\_total \times 0.5)$$Nota para IA: Se massa_total >= capacidade_max, o estado do jogador muda para parado ou sobrecarga.