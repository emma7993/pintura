# Pedido para ChatGPT/Codex — Wolf_Varita_v002 (pincel como varita grande)

Copiar desde aquí:

---

Necesito una nueva entrega del lobo de Pintura: **Game_Assets/Wolf_Varita_v002/**. Reemplaza a Wolf_Pincel_v001 en cómo sostiene el pincel. Conserva todo lo demás del personaje: lobo negro de contorno gris claro, bufanda roja, cola gris, ojos blancos entrecerrados, estilo y grosor de línea de Wolf_Pincel_v001 / Wolf_Walk_v005 Revision_03, y la misma escala (alto del lobo ~216 px dentro de la celda).

## 1. Cómo sostiene el pincel (lo principal)
- El pincel se sostiene **como una varita mágica grande o un báculo corto**, no como una lanza horizontal.
- Va en **una sola mano**, la delantera, tomado por el tercio inferior del mango.
- El pincel mide ~75–85 % de la altura del lobo.
- En reposo y al caminar, la punta apunta **hacia arriba y adelante, unos 60–70° sobre la horizontal**, por encima de la cabeza y por delante del hocico.
- La otra mano queda libre, junto al pecho o balanceándose.
- El pincel nunca tapa la cara ni la bufanda.

## 2. Animaciones (celdas RGBA 256×256, suelo en y=238, lobo mirando a la derecha)

| Animación | Cuadros | Notas |
|---|---:|---|
| idle | 6 | Sin pincel. Respiración suave en bucle (hombros y bufanda), misma postura erguida. |
| idle_varita | 6 | Con varita, en bucle; la punta oscila apenas. |
| walk | 12 | Sin pincel. **Torso estable**: el centro del cuerpo no se desplaza más de ±2 px entre cuadros (en v005 los cuadros 2 y 8 están corridos ~8 px y la caminata se ve trabada). Zancada ~145 px por ciclo. Ciclo cerrado. |
| walk_varita | 12 | Igual que walk, con la varita en alto y un leve vaivén. |
| run / run_varita | 8 | Carrera clara: cuerpo inclinado adelante, zancada ~290 px por ciclo, torso estable ±3 px. |
| jump_up / jump_up_varita | 2 + 2 | Despegue (2 cuadros) y subida en bucle (2 cuadros). |
| fall / fall_varita | 2 | Caída en bucle. |
| land / land_varita | 2 | Aterrizaje: flexión de rodillas y vuelta a la postura. |
| paint_slash | 8 | **Estocada diagonal**: la varita baja de arriba-atrás a abajo-adelante, trazando una línea recta a ~60° (de arriba a la derecha hacia el suelo, delante del lobo). Cuadros 4–6 = contacto que pinta. |
| paint_up | 8 | Trazo vertical hacia arriba, para pintar una puerta. Cuadros 4–6 pintan. |
| dip | 6 | Baja la punta hasta el suelo para mojarla en un lago de tinta. Cuadros 4–5 cargan tinta. |

## 3. Capas y formato (igual que Wolf_Pincel_v001)
- Por animación: `body/` (lobo completo, sin pincel), `brush_base/` (mango y virola) y `tip_color/`, `tip_dry/`, `tip_ink/` (las tres puntas ya alineadas).
- Orden de dibujo: mango, punta, cuerpo. La mano que sostiene debe quedar **por delante** del mango.
- Mismo origen para todas las capas (offset −128,−238), sin recentrar por área opaca.
- Cuadros numerados desde 01 y atlas horizontales.
- `brush_contacts.json` / `.csv` con el mismo esquema: `grip_xy`, `angle_degrees_clockwise`, `tip_xy`, `contact_by_state_xy` (color, dry, ink), `paints`, `receives_ink`, para cada cuadro de cada animación con varita.
- `Godot/` con los SpriteFrames, `Previews/` con GIF y hojas de contacto, `VALIDACION.json` (suelo, sin recortes, desplazamiento máximo del torso por cuadro) e `INTEGRACION_CLAUDE.md`.
- No tocar characters/, art/, el código ni git.

## 4. Verificación que necesito en VALIDACION.json
- Desplazamiento horizontal del centro del cuerpo cuadro a cuadro en walk, walk_varita, run y run_varita (máximo ±2–3 px).
- Altura del lobo por animación (todas ~216 px ±3) para que no crezca ni se encoja al cambiar de animación.
- Que el cuadro de reposo y los cuadros de pies juntos de la caminata tengan la misma posición del cuerpo, para que al soltar la tecla no parezca que da un paso atrás.

---
