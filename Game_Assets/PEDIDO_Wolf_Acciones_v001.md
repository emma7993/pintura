# Pedido: Wolf_Acciones_v001 — acciones con el modelo aprobado

El lobo ya tiene aprobados el reposo, la caminata, la carrera v027 y el salto v004. Las demás animaciones siguen
siendo de entregas viejas y se nota al jugar: son de otro tamaño y otro dibujo. Medido por Claude el 12 nov 2026
(masa del cuerpo en px de celda; la carrera v027 mide 7088):

| Animación en el juego | Masa | Problema |
|---|---|---|
| Combo de 3 golpes y tajo arriba (`Wolf_Combo_v001`) | 8800–9750 | 13–17 % más grande, carbón más claro (50 contra 37), bufanda pálida y con patrón, contorno más grueso |
| Dash (`Wolf_Pincel_v003`) | 9411 | 15 % más grande, ojo entrecerrado y casi el doble de grande, bufanda 55 % más grande |
| Resbalar y saltar de la pared | 8900–9500 | 13–15 % más grande, ojo entrecerrado y grande |
| Tajo hacia abajo (pogo) | 5883 | 9 % más chico, ojo entrecerrado |
| Daño y muerte | ~7100 | tamaño correcto, pero con el ojo entrecerrado y el contorno grueso del modelo viejo |

Por ahora el juego las iguala de tamaño por código (`ESCALAS` en `lobo_sprite.gd`), pero el dibujo sigue siendo
distinto. Este pedido es para redibujarlas. Leer antes `Game_Assets/GUIA_LOBITO.md`.

## Método (el que funcionó)
Personaje COMPLETO en una sola hoja por animación, con `Wolf_Run_v027` y `Wolf_Salto_v004` adjuntos como
referencia de modelo. Sin collages. Después, solo ediciones puntuales sobre la misma hoja. Un pedido por
animación, en este orden de prioridad; no pasar a la siguiente hasta que Emma apruebe la anterior.

## Se conserva en todas (igual que la carrera v027)
Mismo tamaño y masa del cuerpo (7088 ± 5 %), cabeza chica, **ojo blanco pequeño, redondo y abierto** (~40 px²;
puede cerrarse en el instante del golpe o del daño), orejas con triángulo gris, contorno gris fino completo,
carbón RGB 32–41 con grano suave, bufanda roja ~RGB 153,50,47 de 1250–1750 px² sin patrón, cola grande con
punta gris clara, brazos delgados que terminan en punta. El pincel solo aparece en los ataques.

## Animaciones (384x384, pies en (192,352), mirando a la derecha)
1. **Combo** — `attack_01` (corte ascendente), `attack_02` (barrido horizontal), `attack_03` (remate hacia
   abajo): 4 cuadros cada uno a 16 fps (anticipación, golpe, golpe extendido, recuperación). Mismas poses y
   mismo alcance del pincel que `Wolf_Combo_v001`; cambia solo el modelo del lobo. La tinta del trazo, negra.
2. **Tajo hacia arriba** — `attack_up`, 4 cuadros: arco vertical sobre la cabeza (hoy reutiliza `attack_01`).
3. **Dash** — 3 cuadros en bucle a 18 fps: cuerpo horizontal y estirado, bufanda y cola en línea hacia atrás.
4. **Tajo hacia abajo** — `slash_down`, 6 cuadros a 18 fps, en el aire: estocada vertical con el pincel bajo los pies.
5. **Pared** — `wall_slide` (4 cuadros en bucle, agarrado mirando hacia afuera) y `wall_jump` (4 cuadros, impulso).
6. **Daño y muerte** — `hurt` (3 cuadros) y `death` (8 cuadros), mismas poses que `Wolf_Pincel_v003`.

## Entrega
`Game_Assets/Wolf_Acciones_v001/Sprites/<animación>/01..NN.png`, un GIF por animación, una lámina junto a la
carrera v027 y el salto v004, e `INTEGRACION_CLAUDE.md`. En los ataques, indicar por cuadro el rectángulo que
ocupa el trazo de tinta (zona de golpe).
