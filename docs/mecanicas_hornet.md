# Mecánicas de Hornet medidas del video (referencia del lobo)

Fuente: grabación de Emma de Silksong (4 nov 2026, 640x416, ~60 fps, 48 s de juego). Medido por Claude el
12 nov 2026 siguiendo a Hornet cuadro por cuadro (capa roja y máscara blanca) y a la cámara (flujo óptico de
la franja del suelo, corregido x0.963 porque el primer plano se mueve más rápido que el plano de juego).

Escala: Hornet mide 71 px de cuernos a pies en el video; el lobo, 130 px en el juego. **Factor x1.83.**
Error estimado de las cifras: ±4 %.

| Movimiento | Hornet (px del video) | Lobo (x1.83) | En `player.gd` |
|---|---|---|---|
| Carrera | 184 px/s; arranca, frena y gira en ≤ 0.05 s | 337 px/s | `RUN_SPEED` 340 |
| Dash | ~605 px/s durante 0.13 s, luego frena; 133 px en 0.25 s | 243 px en 0.25 s | `DASH_SPEED` 1100, `DASH_TIME` 0.14, `DASH_BRAKE` |
| Sprint (dash mantenido) | 386 px/s (2.1 veces la carrera), cuerpo muy inclinado, nube de polvo | 707 px/s | `SPRINT_MULT` 2.1 |
| Giro en sprint | derrapa ~0.35 s hasta parar y arranca ~0.30 s (0.65 s en total) | igual | `SPRINT_BRAKE` 2000, `SPRINT_ACCEL` 2400 |
| Salto completo | sube a 390 px/s constantes ~0.18 s, frena a ~1560 px/s², cima a 0.44 s y 117–122 px (1.7 cuerpos), cae a ~1150 px/s²; 0.92 s en el aire | 214–223 px | `JUMP_VELOCITY` −715, `JUMP_HOLD` 0.16, `RISE_GRAVITY` 2850, `FALL_GRAVITY` 2100 |
| Brinco (toque) | 32–47 px, 0.29–0.38 s; al soltar, deja de subir casi en seco | 59–87 px | `JUMP_MIN` 0.08, `JUMP_CUT` 0 |
| Control en el aire | misma velocidad que la carrera, cambio de dirección inmediato | igual | `AIR_ACCEL` |
| Salto en sprint | misma altura (126 px) y tiempo (0.95 s); sale a ~1.15 veces el sprint y va perdiendo hasta ~270 px/s; 325 px de largo; **voltereta** justo después de la cima | 595 px de largo | `SPRINT_JUMP_BOOST`, `SPRINT_AIR_END`, `SPRINT_AIR_DRAG`, `LoboSprite.voltereta()` |
| Aterrizaje | se agacha ~0.07 s (solo visual); puede saltar de inmediato | igual | rebote visual `LAND_BOUNCE` |
| Tajo de lado | uno cada ~0.30 s; el arco se ve ~0.10 s y alcanza ~1 cuerpo al frente; se puede dar en el aire | igual | `ATTACK_COOLDOWN` 0.28 |
| Tajo hacia arriba | en el aire, arco vertical sobre la cabeza (~0.10 s) | igual | `attack_up` |

No aparecen en el video (se dejan como estaban, escalados): rebote del tajo hacia abajo (pogo), salto de
pared y caída máxima (en el video no llega al tope; al final de una caída larga iba a ~590 px/s).

Cámara en el video: Hornet queda casi fija en pantalla al correr (la cámara la sigue sin retraso apreciable
y se adelanta ~25 px hacia donde mira); en un salto la cámara sube ~27 px (un 22 % de la altura del salto) y
vuelve.

## Lo que falta de arte para que se vea como Hornet
El sprint, el derrape y la voltereta usan por ahora poses existentes (carrera v027 inclinada, pose de
aterrizaje y pose de la cima girando). Pedido: `Game_Assets/PEDIDO_Wolf_Sprint_v001.md`.

## Cómo repetir la medición
`herramientas/prueba_salto.gd` y `herramientas/prueba_sprint.gd` comprueban las cifras del lobo contra esta
tabla; `herramientas/captura_sprint.gd` saca la tira de cuadros del dash, sprint, salto en sprint y derrape.
