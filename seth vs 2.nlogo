breed [lego-robots lego-robot]
breed [lego-robotsac lego-robotac]

lego-robots-own [ultrasound bump ultrasoundr closest-wall]
lego-robotsac-own [ultrasoundac bump]

turtles-own
[
  nearby-classmates         ;; agentset of turtles within some specified radius
]

to setup
  clear-all 
  set-default-shape lego-robots "car top"
  set-default-shape lego-robotsac "car top"
  draw-world
  if blue-car = true [create-lego-robots 1 [set color blue set size 4 setxy -17 13 set heading 90 update-sensors-blue]]
  if green-car = true [create-lego-robotsac 1 [set color green set size 4 setxy -17 -13 set heading 90 update-sensors-green]]
  reset-ticks
end

to draw-world
  ask patches with[
    (pxcor >= min-pxcor + 4 and pxcor <= min-pxcor + 6) or 
    (pxcor <= max-pxcor - 4 and pxcor >= max-pxcor - 6) or
    (pycor >= min-pycor + 4 and pycor <= min-pycor + 6) or 
    (pycor <= max-pycor - 4 and pycor >= max-pycor - 6)
  ]
  [set pcolor yellow]

  ask patches with 
  [abs pxcor = max-pxcor or abs pycor = max-pycor]
  [ set pcolor red ]
  
  if extra-wall = true [ask patches with [(pxcor >= 0) and (pxcor <= 2) and (pycor >= (max-pycor - 8))]
  [set pcolor red]]
end

to go-forward
  if [pcolor] of patch-ahead 1 != red
    [rotate 0 fd .1]
end

to rotate [angle]
  rt random-normal angle motor-noise 
end

to update-sensors-blue
  update-bump-sensor-blue
  update-ultrasound-blue
end

to update-sensors-green
  update-bump-sensor-green
  update-ultrasound-green
end
 
to update-bump-sensor-blue
  let dist 1
  let found false
  while [not found and dist < 5] 
    [       
      ifelse [pcolor] of patch-ahead dist = red
        
          [set found true set bump true]
        
        [set bump false]        
      set dist dist + 1
    ]
end

to update-bump-sensor-green
  let dist 1
  let found false
  while [not found and dist < 5] 
    [       
      ifelse [pcolor] of patch-ahead dist = red
         
          [set found true set bump true]
        
        [set bump false]        
      set dist dist + 1
    ]
end


to detect-car
  set nearby-classmates other turtles in-radius 4
     if any? nearby-classmates
     [jump 3]
end

to update-ultrasound-blue
  let dist 1
  let found false
  let angle heading + 90 - 90 * int((heading + 45) / 90)
    while [not found] 
    [
      let p patch-left-and-ahead angle dist
      if [pcolor] of p = red [
        set found true 
        set closest-wall 1
        ifelse moving-average?
          [set ultrasound ((4 * ultrasound) + random-normal (distance p) ultrasound-noise) / 5 ]
          [set ultrasound random-normal (distance p) ultrasound-noise ]]
      set dist dist + 1
    ] 
    if Bi-directional-sensor = true
    [
      let distr 1
      let foundr false
      let angle2 heading + 270 - 90 * int((heading + 45) / 90)
         while [not found] 
           [
            let p patch-left-and-ahead angle2 distr
            if [pcolor] of p = red [
               set foundr true 
                 ifelse moving-average?
                 [set ultrasoundr ((4 * ultrasoundr) + random-normal (distance p) ultrasound-noise) / 5 ]
                 [set ultrasoundr random-normal (distance p) ultrasound-noise ]]
            set dist dist + 1
          
           ] 
       if ultrasoundr > ultrasound[set ultrasound ultrasoundr set closest-wall 2]
    ]    
    
    if car-detection = true [detect-car]   
end

to update-ultrasound-green
  let dist 1
  let found false
  let angle heading + 270 - 90 * int((heading + 45) / 90)
    while [not found] 
    [
      let p patch-left-and-ahead angle dist
      if [pcolor] of p = red [
        set found true 
        ifelse moving-average?
          [set ultrasoundac ((4 * ultrasoundac) + random-normal (distance p) ultrasound-noise) / 5 ]
          [set ultrasoundac random-normal (distance p) ultrasound-noise ]]
      set dist dist + 1
    ] 
    if car-detection = true [detect-car]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;VIRTUAL ROBOT CONTROL SECTION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code to control the robot -  only actuator primitives (rotate and go-forward) and sensor values are used

to turnaway-after-bump-blue
  update-sensors-blue
  ifelse bump
    [rt 90]  
    [go-forward]
end

to turnaway-after-bump-green
  update-sensors-green
  ifelse bump
    [lt 90]  
    [go-forward]
end



to edge
  ask lego-robots[
    let distance-to-side ultrasound
    turnaway-after-bump-blue
    ifelse closest-wall = 1
    [
    let new-distance-to-side ultrasound
    if (new-distance-to-side > 4) and (new-distance-to-side > distance-to-side) 
    [rotate -0.5]                                                             
    if (new-distance-to-side < 6) and (new-distance-to-side < distance-to-side) 
    [rotate 0.5]
    ]
    [
    let new-distance-to-side ultrasound
    if (new-distance-to-side > 4) and (new-distance-to-side > distance-to-side) 
    [rotate 0.5]                                                             
    if (new-distance-to-side < 6) and (new-distance-to-side < distance-to-side) 
    [rotate -0.5]
    ]
    
    if ultrasound > 9 [fd 2 lt 90 fd 6]
       
    update-plot-blue
  ]
  
  ask lego-robotsac[
    let distance-to-side ultrasoundac
    turnaway-after-bump-green
    let new-distance-to-side ultrasoundac
    if (new-distance-to-side > 4) and (new-distance-to-side > distance-to-side) 
    [rotate 0.5]                                                             
    if (new-distance-to-side < 6) and (new-distance-to-side < distance-to-side) 
    [rotate -0.5]
    if new-distance-to-side > 9 [fd 2 rt 90 fd 6]
       
    update-plot-green
  ]
  tick
end
  
to update-plot-blue
  set-current-plot "Ultrasound"
  set-current-plot-pen "distance"
  plot [ultrasound] of lego-robot 0         ; plot xcor -- there's only one robot, so its id must be 0
  if ticks > 1000                           ; don't change the range until we've plotted all the way across once 
  [set-plot-x-range (ticks - 1000) ticks]   ; scroll the range of the plot so only the last 200 ticks are visible
end

to update-plot-green
  set-current-plot "Ultrasoundac"
  set-current-plot-pen "distance"
  ifelse blue-car = true [plot [ultrasoundac] of lego-robotac 1]         ; plot xcor -- there's only one robot, so its id must be 0
  [plot [ultrasoundac] of lego-robotac 0]
  if ticks > 1000                           ; don't change the range until we've plotted all the way across once 
  [set-plot-x-range (ticks - 1000) ticks]   ; scroll the range of the plot so only the last 200 ticks are visible
end
@#$#@#$#@
GRAPHICS-WINDOW
220
10
711
522
18
18
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
-18
18
-18
18
0
0
1
ticks
30.0

BUTTON
67
10
133
43
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

SLIDER
17
464
189
497
motor-noise
motor-noise
0
1
0.2
.1
1
NIL
HORIZONTAL

BUTTON
9
45
209
78
NIL
turnaway-after-bump-blue
T
1
T
TURTLE
NIL
NIL
NIL
NIL
1

SLIDER
17
430
189
463
ultrasound-noise
ultrasound-noise
0
2
0.2
.1
1
NIL
HORIZONTAL

BUTTON
69
118
132
151
NIL
edge
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
56
157
144
190
NIL
pendown
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL
1

PLOT
718
10
1119
277
Ultrasound
time
Distance
0.0
1000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""
"distance" 1.0 0 -16777216 true "" ""

SWITCH
21
394
185
427
moving-average?
moving-average?
1
1
-1000

BUTTON
4
81
213
114
NIL
turnaway-after-bump-green
T
1
T
TURTLE
NIL
NIL
NIL
NIL
1

SWITCH
40
322
169
355
car-detection
car-detection
1
1
-1000

SWITCH
41
282
152
315
extra-wall
extra-wall
0
1
-1000

SWITCH
41
245
151
278
green-car
green-car
1
1
-1000

SWITCH
42
208
151
241
blue-car
blue-car
0
1
-1000

TEXTBOX
172
212
230
240
Task 1, 3, 4, 5
11
0.0
1

TEXTBOX
172
256
221
284
Task 2, 4
11
0.0
1

TEXTBOX
173
293
222
321
Task 3
11
0.0
1

TEXTBOX
173
331
211
349
Task 4
11
0.0
1

PLOT
719
277
1119
493
Ultrasoundac
time
Distance
0.0
1000.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""
"distance" 1.0 0 -16777216 true "" ""

SWITCH
21
360
166
393
Bi-directional-sensor
Bi-directional-sensor
0
1
-1000

TEXTBOX
173
369
210
387
Task 5
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 true 210 165 195 165
Line -7500403 true 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
