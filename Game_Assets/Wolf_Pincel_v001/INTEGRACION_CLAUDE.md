# Wolf Pincel v001 — entrega de arte

Fecha: 2026-11-02. Arte candidato para revisión visual; no está integrado en el juego ni publicado en GitHub. No sustituye las animaciones activas. No usar las exportaciones antiguas de v005 rechazadas.

## Archivos y capas

Cada animación está en `Animations/<nombre>/`. Cuadros individuales RGBA de 256×256, numerados desde 01. Atlas horizontales sin separación. `body/` contiene el lobo completo sin arma; `brush_base/` contiene mango y virola; `tip_color/`, `tip_dry/` y `tip_ink/` contienen las tres puntas ya transformadas y alineadas. `brush/` es mango + punta seca como alternativa. No superponer `brush/` y `brush_base/` a la vez.

Orden usado en las vistas previas: mango, punta elegida, cuerpo. Las manos negras del cuerpo ocultan el mango. Todos los sprites deben compartir origen, escala, frame y flip. No centrar cada capa según su área opaca. Usar esquina superior izquierda de celda, o el mismo offset (-128,-238) para colocar el suelo en el origen del personaje.

| Animación | Cuadros | Atlas por capa | FPS sugeridos | Bucle |
|---|---:|---|---:|---|
| idle_pincel | 1 | 256×256 | 10 | sí |
| walk_pincel | 12 | 3072×256 | 12 × speed_scale 0.8 | sí |
| run | 8 | 2048×256, solo body | 16 | sí |
| run_pincel | 8 | 2048×256 | 16 | sí |
| paint_slash | 8 | 2048×256 | 10 | no |
| paint_up | 8 | 2048×256 | 10 | no |
| dip | 6 | 1536×256 | 10 | no |

`run` es la versión sin arma. `run_pincel` tiene otro dibujo completo de carrera y sus capas de arma. 51 cuadros de cuerpo en total. Suelo de registro y=238, comprobado con alfa >16. Una escala uniforme por secuencia nueva; únicamente recorte y desplazamiento de figuras completas. No se deformaron ni reconstruyeron patas, torso o cola por piezas. El nuevo idle es erguido y mantiene la bufanda detrás.

`walk_pincel/body` conserva exactamente los píxeles de `Wolf_Walk_v005/Revision_03/Individual_Frames/walk`. No se amplió la zancada: se mantiene la de esa revisión, aproximadamente 132 px/ciclo según la medición previa del proyecto; no usar 175 px/ciclo. La velocidad de desplazamiento debe calibrarse visualmente con Claude: esta entrega no certifica apoyo del pie a velocidad constante. 12 FPS con speed_scale=0.8 produce 9.6 cuadros/s, 0.8 ciclos/s y 1.25 s/ciclo. El GIF usa ese tiempo; el recurso guarda 12 FPS.

## Punta y eventos

`brush_contacts.json` y `brush_contacts.csv` son las tablas completas, cuadro por cuadro, con coordenadas locales de celda (origen arriba izquierda, +x derecha, +y abajo). `tip_xy` es la punta geométrica; `contact_by_state_xy` mide el extremo visible de cada punta rasterizada. Usar el contacto del estado activo para la máscara. Ángulos positivos giran hacia abajo.

- `paint_slash`: pinta únicamente en cuadros **4, 5 y 6**.
- `paint_up`: pinta únicamente en cuadros **4, 5 y 6**.
- `dip`: recibe tinta en cuadros **4 y 5**; no pinta el mundo.
- Idle, caminata y carreras: no emiten pintura.
- Una punta seca nunca pinta, aunque se reproduzca el tajo. La disponibilidad de una sola carga y el retroceso de sombras son responsabilidad del código de Claude.

Hay 43 registros con arma y 8 sin arma. No hay punta fuera de la celda ni capas cortadas por sus bordes. Para el dip, posicionar la boca del tintero en el contacto de los cuadros 4–5; la boca del tintero del otro paquete está aproximadamente en (128,133) dentro de su propia celda de 256×256.

## Límites visuales que requieren revisión

El agarre se colocó a mano sobre las manoplas dibujadas; no hay un rig ni certificación de anatomía o continuidad subpíxel. Las secuencias nuevas son dibujos completos generados y pueden variar ligeramente cabeza, manos y bufanda entre cuadros. Revisar los GIF y hojas de contacto antes de integrar. La carrera está registrada al mismo suelo incluso en las poses recogidas; no incorpora desplazamiento vertical del nodo ni física de salto. `paint_up`, `paint_slash` y `dip` recuperan la pose al acabar mediante el sistema de animación de Claude; no prometer una transición idéntica al píxel hacia el idle.

## Recursos y revisión independiente

`Godot/Wolf_body.tres`, `Wolf_brush_base.tres`, `Wolf_brush.tres` y los tres `Wolf_tip_*.tres` contienen SpriteFrames sincronizables. Las rutas son relativas y respetan mayúsculas para Windows/Mac.

Abrir **este** `project.godot` como proyecto independiente en Godot 4.7.2 y pulsar F6 sobre `Godot/Preview.tscn`, o F5 en este proyecto de arte. Flechas cambian animación, 1/2/3 cambian punta, Espacio repite. El `.gdignore` de Game_Assets sigue intacto; el F5 del juego principal no usa estos recursos.

`Source/` conserva originales de generación sin retocar, prompts y scripts de empaquetado. `References/` conserva los 12 cuadros de caminata usados. El arte se produjo con image_gen integrado; el empaquetado aplica transformaciones rígidas al pincel, no al cuerpo por partes. `Previews/` contiene GIF y hojas de contacto. `VALIDACION.json` documenta los checks de tamaños, suelo, ausencia de clipping y conservación de caminata.

Importación y arranque de preview comprobados en Godot 4.7.2 sin errores de recursos o scripts. El entorno restringido emitió avisos de certificados y escritura de preferencias de usuario, ajenos al arte. No se copió nada a characters/ o art/, no se editó código del juego ni se hizo commit/push.

## Tabla de punta geométrica por cuadro

Coordenadas de contacto nominal; el JSON incluye también el extremo visible de cada estado. Todos los índices empiezan en 1.

| Animación | Cuadro | Punta x | Punta y | Pinta con carga | Recarga |
|---|---:|---:|---:|---|---|
| idle_pincel | 1 | 215.36 | 114.41 | no | no |
| walk_pincel | 1 | 226.52 | 123.36 | no | no |
| walk_pincel | 2 | 226.66 | 124.32 | no | no |
| walk_pincel | 3 | 226.79 | 125.27 | no | no |
| walk_pincel | 4 | 226.52 | 123.36 | no | no |
| walk_pincel | 5 | 226.66 | 124.32 | no | no |
| walk_pincel | 6 | 226.79 | 125.27 | no | no |
| walk_pincel | 7 | 226.52 | 123.36 | no | no |
| walk_pincel | 8 | 226.66 | 124.32 | no | no |
| walk_pincel | 9 | 226.79 | 125.27 | no | no |
| walk_pincel | 10 | 226.52 | 123.36 | no | no |
| walk_pincel | 11 | 226.66 | 124.32 | no | no |
| walk_pincel | 12 | 226.79 | 125.27 | no | no |
| run_pincel | 1 | 224.79 | 118.58 | no | no |
| run_pincel | 2 | 224.99 | 120.52 | no | no |
| run_pincel | 3 | 225.19 | 122.47 | no | no |
| run_pincel | 4 | 224.79 | 119.58 | no | no |
| run_pincel | 5 | 224.99 | 119.52 | no | no |
| run_pincel | 6 | 225.19 | 121.47 | no | no |
| run_pincel | 7 | 224.79 | 120.58 | no | no |
| run_pincel | 8 | 224.99 | 120.52 | no | no |
| paint_slash | 1 | 231.36 | 133.41 | no | no |
| paint_slash | 2 | 163.66 | 72.78 | no | no |
| paint_slash | 3 | 213.66 | 86.78 | no | no |
| paint_slash | 4 | 245.87 | 127.12 | sí | no |
| paint_slash | 5 | 252.2 | 145.0 | sí | no |
| paint_slash | 6 | 250.32 | 167.29 | sí | no |
| paint_slash | 7 | 244.2 | 148.0 | no | no |
| paint_slash | 8 | 229.8 | 107.4 | no | no |
| paint_up | 1 | 228.8 | 162.6 | no | no |
| paint_up | 2 | 227.32 | 173.29 | no | no |
| paint_up | 3 | 236.2 | 162.0 | no | no |
| paint_up | 4 | 234.29 | 92.52 | sí | no |
| paint_up | 5 | 198.59 | 57.64 | sí | no |
| paint_up | 6 | 158.12 | 47.13 | sí | no |
| paint_up | 7 | 190.59 | 61.64 | no | no |
| paint_up | 8 | 229.8 | 112.4 | no | no |
| dip | 1 | 231.36 | 116.41 | no | no |
| dip | 2 | 230.2 | 146.0 | no | no |
| dip | 3 | 221.22 | 196.66 | no | no |
| dip | 4 | 195.88 | 225.87 | no | sí |
| dip | 5 | 204.6 | 207.8 | no | sí |
| dip | 6 | 233.36 | 113.41 | no | no |
