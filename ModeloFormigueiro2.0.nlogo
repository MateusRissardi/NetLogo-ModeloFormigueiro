;  UILIZADA PARA VERIFICAR A QAUNTIDADE DE COMIDA ARMAZENADA EM UM TERRENO E SE O TERRENO É O FORMIGUEIRO OU NÃO
patches-own [comida é-ninho? possui-feromonio? forca-feromonio energia-ninho]

;  UTILIZADA PARA VERIFICAR A ENERGIA DAS FORMIGAS E SE ELAS ESTÃO CARREGANDO ALIMENTO
turtles-own [energia carregando-comida? id-formigueiro]

;  UTILIZADA PARA VERIFICAR O QUANTO DE ALIMENTO O FORMIGUEIRO POSSUI

;  PROCEDIMENTO SETUP. TEM FUNÇÃO DE COMEÇAR A SIMULAÇÃO E DE CRIAR AS FORMIGAS
to setup
  clear-all
  gerar-terreno
  if model-version = "feromones-with-competition"[
    create-turtles formigas / 2[
      set shape "bug"
      set color gray
      set energia 1 + random 100
      set carregando-comida? false
      setxy 12 - random 8 12 - random 8
      set id-formigueiro 1
    ]
    create-turtles formigas / 2[
      set shape "bug"
      set color black
      set energia 1 + random 100
      set carregando-comida? false
      setxy -12 + random 8 -12 + random 8
      set id-formigueiro 2
    ]
  ]
  if model-version = "feromones-no-competition"[
    create-turtles formigas[
      set shape "bug"
      set color black
      set energia 1 + random 100
      set carregando-comida? false
      setxy -5 + random 10 -5 + random 10
    ]
  ]
  if model-version = "no-feromones"[
    create-turtles formigas[
      set shape "bug"
      set color black
      set energia 1 + random 100
      set carregando-comida? false
      setxy -5 + random 10 -5 + random 10
    ]
  ]
  reset-ticks
end

;  PROCEDIMENTO GO, ELE DEFINE A VELOCIDADE DE CRESCIMENTO DE ALIMENTO DO TERRENO, ATIVA OS PROCEDIMENTOS DAS FORMIGAS E VERIFICA SE O USUÁRIO QUER VER A ENERGIA DAS FORMIGAS
to go
  ask patches[
    ifelse pcolor != brown - 2 [
    if comida < 5  and not é-ninho? [ set pcolor brown set comida comida + velocidade-crescimento-terra]
    if comida > 5 and comida < 15 and not é-ninho? [ set pcolor green  set comida comida + velocidade-crescimento-grama]
    ]
    [ set pcolor brown - 2 ]

   ]
  ask turtles [
    movimentar-formiga
    verificar-comida
    enfrentar-rival
    nascer-formiga
  ]
  ask turtles [
   ifelse show-energy? [set label energia]
    [set label ""]
  ]
  if model-version != "no-feromones"[
    ask patches[
      gerar-feromonios
    ]
  ]

  tick
end
;  PROCEDIMENTO GERAR-FEROMONIOS, TEM A FUNÇÃO VERFICIAR SE UM DETERMINADO PATCH POSSUI ALGUMA FORMIGA QUE ESTÁ CARREGANDO COMIDA NO MOMENTO, CASO FOR VERDADEIRO ELA IRÁ DEPOSITAR UM FEROMÔNIO EM CIMA DO TERRENO
;  COM O INTUITO DE AVISAR PARA AS OUTRAS FORMIGAS SOBRE UMA NOVA FONTE DE COMIDA ENCONTRADA

to gerar-feromonios
  ifelse any? turtles-here with [carregando-comida?][
    set possui-feromonio? true
    set forca-feromonio valor-feromonio
    ]
  [ ifelse forca-feromonio > 0 [ set forca-feromonio forca-feromonio - 0.5 ][ set possui-feromonio? false set forca-feromonio 0 ]]

end

;  PROCEDIMENTO PARA GERAÇÃO DE TERRENO, NELE É GERADO AS GRAMAS, AS TERRAS, AS TERRAS INFÉRTEIS E O FORMIGUEIRO
to gerar-terreno
  ask patches [
    set pcolor green
    set é-ninho? false
    set comida 5 + random 45
    set possui-feromonio? false
  ]
  ask patches [
    if random 100 > 40 [
      set pcolor brown
      set comida 5 + random -10
    ]
  ]
  ask patches [
    if random 100 > 80 [
      set pcolor brown - 2
      set comida 0
    ]
  ]
  if model-version = "feromones-with-competition" [
    ask patch 5 5 [
      set pcolor brown + 2
      set é-ninho? true
      set comida 0
      set energia-ninho 0
    ]
    ask patch -5 -5 [
      set pcolor brown + 2
      set é-ninho? true
      set comida 0
      set energia-ninho 0
    ]
  ]
  if model-version = "feromones-no-competition"[
    ask patch 0 0 [
      set pcolor brown + 2
      set é-ninho? true
      set comida 0
      set energia-ninho 0
    ]
  ]

  if model-version = "no-feromones"[
    ask patch 0 0 [
      set pcolor brown + 2
      set é-ninho? true
      set comida 0
      set energia-ninho 0
    ]
  ]


end

;  PROCEDIMENTO DE MOVIMENTO DAS FORMIGAS, VALIDA SE A FORMIGA TEM ENERGIA PARA ANDAR, CASO NÃO IVER ELA MORRE, CASO TIVER ELA VERIFICA SE ELA ESTÁ CARREGANDO
;  COMIDA, CASO ESTIVER CARREGANDO ELA VAI IR EM DIREÇÃO AO NINHO, CASO NÃO ELA VAI PROCURAR SE HÁ ALGUM FEROMÔNIO EM SUA VIZINHANÇA, CASO
;  TIVER E NÃO TIVER MUITAS FORMIGAS SEGUINDO ELA IRÁ SEGUIR O RASTRO, CASO NÃO PROCURAR ALEATORIAMENTE POR COMIDA
to movimentar-formiga
  let quantidadeFormigas count turtles-on neighbors
  let patches-com-alimento neighbors with [ comida > 5 ]
  let patches-com-feromonio neighbors with [ possui-feromonio? ]
  if energia < 1 [die]
  ifelse carregando-comida?[
    if model-version = "feromones-with-competition"[
      if id-formigueiro = 1[face patch 5 5 forward velocidade-formigas set energia energia - 0.75 ] if id-formigueiro = 2 [face patch -5 -5 forward velocidade-formigas set energia energia - 0.75] ]
    if model-version = "feromones-no-competition"[
      face patch 0 0 forward velocidade-formigas set energia energia - 0.75
    ]
    if model-version = "no-feromones"[
      face patch 0 0 forward velocidade-formigas set energia energia - 0.75
    ]
  ]
  [
    ifelse any? patches-com-alimento
    [ face one-of patches-com-alimento forward velocidade-formigas + 0.2 set energia energia - 0.25 ]
    [ ifelse any? patches-com-feromonio and  quantidadeFormigas < 5
      [ face one-of patches-com-feromonio forward velocidade-formigas + 0.2 set energia energia - 0.25]
      [ right 30 - random 30 forward velocidade-formigas + 0.2 set energia energia - 0.25 ]
    ]
  ]
end

;  PROCEDIMENTO ENFRENTAR-RIVAL, TEM COMO OBJETIVO VERIFICAR SE HÁ POSSUI DUAS OU MAIS FORMIGAS QUE
;  PERTENCEM A UM FORMIGUEIRO DIFERENTE, CASO ISSO FOR VERDADEIRO ELAS IRÃO BATALHAR, A GANHADORA
;  SERÁ A QUE POSSUIR MAIS ENERGIA, RESULTANDO ASSIM NA MORTE DA FORMIGA PERDEDORA

to enfrentar-rival
  if any? turtles-here with [id-formigueiro != [id-formigueiro] of myself] and any? turtles-here with [energia > [energia] of myself] [
    die
  ]
end

;  PROCEDIMENTO DE VERIFICAR COMIDA, NELE ELE VERIFICA TODA A QUESTÃO DE COMIDA DA FORMIGA/FORMIGUEIRO. ELA VERIFICA SE A FORMIGA COM COMIDA ESTÁ EM CIMA DO FORMIGUEIRO, E
;  TAMBÉM SE ELA ESTÁ EM CIMA DE UMA GRAMA ENQUANTO NÃO CARREGA NENHUM TIPO DE ALIMENTO
to verificar-comida
  if carregando-comida? and [ é-ninho? ] of patch-here[
    set carregando-comida? false
    set energia-ninho energia-ninho + 1
  ]
  if not carregando-comida?[
    if comida >= 5[
      set carregando-comida? true
      set energia energia + 15
      set comida comida - 5
    ]
  ]
end

;  PROCEDIMENTO DE NASCER FORMIGAS, CASO O FORMIGUEIRO ALCANCE UMA CERTA QUANTIA DE ALIMENTO ELA IRÁ GERAR NOVAS FORMIGAS
to nascer-formiga
  if energia-ninho > 20 and [é-ninho?] of patch-here[
    hatch 5 [
      set shape "bug"
      set energia 1 + random 100
      set carregando-comida? false
      if id-formigueiro = 1 [setxy 5 5 set color gray]
      if id-formigueiro = 2 [setxy -5 -5 set color black]
    ]
    set energia-ninho 0
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
232
10
669
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
60.0

BUTTON
4
55
67
88
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
79
55
142
88
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
7
300
141
333
show-energy?
show-energy?
1
1
-1000

MONITOR
8
341
98
386
formigas-total
count turtles
17
1
11

SLIDER
5
98
224
131
formigas
formigas
1
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
6
140
224
173
velocidade-formigas
velocidade-formigas
0.1
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
6
179
224
212
velocidade-crescimento-terra
velocidade-crescimento-terra
0.001
0.01
0.0025
0.0001
1
NIL
HORIZONTAL

SLIDER
6
223
225
256
velocidade-crescimento-grama
velocidade-crescimento-grama
0.01
0.1
0.03
0.01
1
NIL
HORIZONTAL

PLOT
688
15
888
165
Grama x Terra
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"grama" 1.0 0 -14439633 true "" "plot count patches with [ pcolor = green ]"
"terra" 1.0 0 -5207188 true "" "plot count patches with [ pcolor = brown ]"

CHOOSER
3
10
224
55
model-version
model-version
"no-feromones" "feromones-no-competition" "feromones-with-competition"
2

SLIDER
7
263
224
296
valor-feromonio
valor-feromonio
1
50
15.0
1
1
NIL
HORIZONTAL

MONITOR
8
390
80
435
formigas-1
count turtles with [id-formigueiro = 1]
17
1
11

MONITOR
86
390
158
435
formigas-2
count turtles with [id-formigueiro = 2]
17
1
11

PLOT
696
180
1086
431
Alimento Formigueiro 1  Formigueiro 2
NIL
NIL
0.0
25.0
0.0
25.0
true
true
"" ""
PENS
"Formigueiro 2" 1.0 0 -16777216 true "" "if model-version = \"feromones-with-competition\" [\nplot [ energia-ninho ] of patch -5 -5\n]"
"Formigueiro 1" 1.0 0 -7500403 true "" "if model-version = \"feromones-with-competition\" [\nplot [ energia-ninho ] of patch 5 5\n]\nif model-version = \"feromones-no-competition\"\n or model-version = \"no-feromones\"\n [\n plot [energia-ninho] of patch 0 0\n ]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
