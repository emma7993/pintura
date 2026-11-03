# Pedido para ChatGPT/Codex — Wolf_Pincel_v003 (pincel largo y fino, guardado en la espalda)

Copiar desde aquí:

---

Necesito una entrega nueva del lobo de Pintura: **Game_Assets/Wolf_Pincel_v003/**. Cambia el pincel y el conjunto de acciones. El personaje se conserva igual: lobo negro de contorno gris claro, bufanda roja, cola gris, ojos blancos entrecerrados, mismo estilo y grosor de línea, alto de pie ~216 px.

Referencia de género: metroidvania 2D de acción precisa, con poses muy legibles, anticipación corta, golpe en 1–2 cuadros y recuperación rápida. **Todo el diseño, las poses y los cuadros deben ser originales**; no calcar ni reproducir sprites de otros juegos.

## 1. El pincel
- **Proporción:** largo y muy fino, como una aguja o un estoque. Longitud ≈ **100 % de la altura del lobo** (~215 px). Mango delgado (6–8 px), virola metálica corta, punta de pincel redondo fino y una pequeña argolla al final del mango.
- **Guardado:** cuando no se usa, va **en la espalda, en diagonal**, casi oculto detrás del cuerpo y la bufanda. Solo asoman la argolla por un hombro y la punta por debajo de la cola o de la cadera.
- **Al actuar:** el lobo lo saca de la espalda en el primer cuadro de cada acción, lo usa y lo devuelve a la espalda en los últimos. Caminar, correr y saltar se hacen con el pincel guardado y las **manos encogidas al pecho**, como en Wolf_Walk_v005 Revision_03.

## 2. Animaciones (celdas RGBA **384×384**, suelo en **y=352**, lobo centrado en **x=192**, mirando a la derecha)

| Animación | Cuadros | Bucle | Notas |
|---|---:|---|---|
| idle | 6 | sí | Respiración suave; pincel en la espalda. |
| walk | 12 | sí | Manos al pecho. Cabeza estable (±2 px entre cuadros). Zancada ~145 px por ciclo. |
| run | 8 | sí | Inclinado adelante. Cabeza estable (±3 px). Zancada ~300 px por ciclo. |
| jump_start, jump_up, fall, land | 2, 2, 2, 2 | no, sí, sí, no | Pincel guardado. |
| dash | 6 | no | Impulso horizontal corto, cuerpo estirado. |
| wall_slide | 4 | sí | Pegado a una pared, resbalando. |
| wall_jump | 4 | no | Se impulsa desde la pared. |
| slash_side | 7 | no | Saca el pincel y da un tajo horizontal delante. Cuadros 3–4 = golpe/pintura. |
| slash_up | 7 | no | Tajo hacia arriba. Cuadros 3–4 = golpe/pintura. |
| slash_down | 6 | no | En el aire, estocada hacia abajo para rebotar sobre enemigos. Cuadros 2–4 = golpe. |
| paint_rise | 8 | no | Pincelada diagonal ascendente: punta en el suelo delante y sube recta a ~60° hacia arriba y atrás. Cuadros 4–6 pintan. |
| paint_up | 8 | no | Trazo vertical para pintar una puerta. Cuadros 4–6 pintan. |
| dip | 6 | no | Moja la punta en un lago de tinta (en el suelo, delante). Cuadros 4–5 cargan tinta. |
| hurt | 3 | no | Recibe un golpe. |
| death | 8 | no | Cae y se deshace en trazos de grafito. |

## 3. Capas
- `body/`: el lobo completo, sin pincel.
- `brush_back/`: el pincel guardado (se dibuja **detrás** del cuerpo). Vacío en los cuadros en que está en la mano.
- `brush_base/`: mango y virola cuando está en la mano.
- `tip_color/`, `tip_dry/`, `tip_ink/`: las tres puntas alineadas (también en brush_back, para que se vea si está seco o cargado).
- `smear/`: estela del golpe en los cuadros de impacto, como una pincelada blanca en escala de grises que el juego tiñe del color o de la tinta que lleve el pincel.
- Mismo origen para todas las capas (offset −192,−352), sin recentrar. Cuadros numerados desde 01 y atlas horizontales.

## 4. Datos y verificación
- `brush_contacts.json` / `.csv` (mismo esquema que antes: grip_xy, angle_degrees_clockwise, tip_xy, contact_by_state_xy, paints, receives_ink), más **`hitbox`** [x,y,w,h] en los cuadros de golpe.
- `Godot/` con SpriteFrames por capa, `Previews/` con GIF y hojas de contacto, `INTEGRACION_CLAUDE.md`, `Source/`.
- `VALIDACION.json`: suelo y=352 en todos los cuadros apoyados; alto 216 ±3 en idle, walk y run; temblor de la cabeza entre cuadros en walk y run; que el reposo y los cuadros de pies juntos de walk tengan la cabeza en la misma posición.
- No tocar characters/, art/, el código ni git.

---
