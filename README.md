# Simulação de Comportamento de Formigas em NetLogo

Este projeto é um modelo de simulação baseado em agentes, desenvolvido na plataforma NetLogo. O objetivo principal é analisar os comportamentos de formigas na procura e coleta de alimentos para seu ninho, e como as condições ambientais e a interação com outras colônias afetam suas estratégias.

## Descrição Geral

O modelo simula um ambiente com fontes de alimento (grama e terra) que se regeneram com o tempo. As formigas (agentes) têm o objetivo de explorar este ambiente, encontrar comida, e transportá-la de volta para o ninho. A eficiência dessa coleta de alimento impacta diretamente na capacidade do formigueiro de gerar novas formigas. A simulação permite explorar diferentes cenários, como a ausência de comunicação química (feromônios), a cooperação dentro de uma única colônia e a competição entre duas colônias rivais.

## Como Funciona

O comportamento geral do modelo emerge a partir de um conjunto de regras simples seguidas pelos agentes (formigas) e pelo ambiente (terreno).

#### Formigas (Agentes)
- **Energia:** Cada formiga possui uma quantidade de energia que é consumida ao se movimentar. Se a energia de uma formiga chegar a zero, ela morre. As formigas podem ganhar energia ao coletar comida.
- **Movimento:**
    - Se uma formiga **não está carregando comida**, ela procura por alimento. Sua primeira prioridade é mover-se em direção a uma fonte de comida adjacente. Caso não haja comida por perto, ela procurará por rastros de feromônio deixados por outras formigas e os seguirá. Se nenhum dos dois estiver presente, ela se moverá aleatoriamente.
    - Se uma formiga **está carregando comida**, seu único objetivo é retornar ao ninho para depositar o alimento.
- **Coleta e Depósito:** Ao encontrar um terreno com comida suficiente, a formiga coleta uma porção, o que a faz entrar no modo "carregando comida". Ao chegar no ninho, ela deposita o alimento, que é convertido em energia para o formigueiro (`energia-ninho`).
- **Reprodução:** Quando um formigueiro acumula energia suficiente (acima de 20), ele a consome para gerar 5 novas formigas.
- **Combate:** No modo de competição, se formigas de ninhos diferentes se encontram no mesmo local, elas batalham. A formiga com menos energia morre.

#### Ambiente e Ninhos
- **Terreno:** O mundo é composto por terrenos (patches). Eles podem ser férteis (cor verde ou marrom), contendo comida, ou inférteis (marrom escuro), sem comida. A comida nos terrenos férteis se regenera com o tempo a uma taxa definida por seletores na interface.
- **Ninhos:** São terrenos especiais (`é-ninho?` = true) que servem como base para as formigas e onde o alimento é armazenado.
- **Feromônios:** Quando uma formiga carregando comida passa por um terreno, ela deixa um rastro de feromônio. A força desse feromônio diminui com o tempo, eventualmente desaparecendo se não for reforçado.

## Modelos de Simulação

A simulação pode ser executada em três modos diferentes, selecionáveis na interface:

1.  **`no-feromones`**: Um cenário base onde as formigas não deixam rastros de feromônio. A busca por comida depende apenas da exploração aleatória e da detecção de alimento próximo.
2.  **`feromones-no-competition`**: Neste modo, há apenas uma colônia de formigas que utiliza feromônios para comunicar a localização de fontes de alimento, otimizando a coleta.
3.  **`feromones-with-competition`**: Duas colônias rivais (cinza e preta) competem pelos mesmos recursos. Ambas usam feromônios, mas também entram em conflito direto quando se encontram.

## Como Usar a Simulação

A interface do modelo permite controlar diversos parâmetros e observar os resultados em tempo real.

#### Controles Principais
- **`setup`**: Botão para inicializar a simulação, criando o terreno e as formigas de acordo com os parâmetros definidos.
- **`go`**: Inicia ou continua a simulação passo a passo.
- **`model-version`**: Seletor para escolher um dos três modos de simulação descritos acima.

#### Seletores (Sliders)
- **`formigas`**: Define o número inicial de formigas no início da simulação.
- **`velocidade-formigas`**: Controla a velocidade de movimento das formigas.
- **`velocidade-crescimento-terra` / `velocidade-crescimento-grama`**: Ajustam a taxa de regeneração de comida nos terrenos de terra e grama, respectivamente.
- **`valor-feromonio`**: Determina a força inicial do rastro de feromônio deixado por uma formiga.

#### Outros Elementos
- **`show-energy?`**: Um interruptor que, quando ativado, exibe o valor de energia atual de cada formiga como um rótulo.
- **Monitores**: Exibem a contagem total de formigas e a contagem para cada colônia (`formigas-1` e `formigas-2`).
- **Gráficos**:
    - **Grama x Terra**: Plota a quantidade de terrenos de cada tipo ao longo do tempo.
    - **Alimento Formigueiro 1 / Formigueiro 2**: Mostra a evolução da energia armazenada em cada ninho.

## Agentes e Suas Propriedades

#### Propriedades das Formigas (Turtles)
- `energia`: Nível de energia da formiga.
- `carregando-comida?`: Estado booleano (verdadeiro/falso) que indica se a formiga está transportando alimento.
- `id-formigueiro`: Identificador do ninho ao qual a formiga pertence (1 ou 2).

#### Propriedades do Terreno (Patches)
- `comida`: Quantidade de alimento disponível no terreno.
- `é-ninho?`: Estado booleano que indica se o terreno é um formigueiro.
- `possui-feromonio?`: Estado booleano que indica a presença de feromônio.
- `forca-feromonio`: Nível de intensidade do feromônio no terreno.
- `energia-ninho`: Quantidade de energia (alimento) armazenada se o terreno for um ninho.
