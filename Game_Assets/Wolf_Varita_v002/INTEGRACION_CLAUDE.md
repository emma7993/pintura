# Wolf Varita v002 — Pintura

Entrega de arte del 2026-11-03. Sustituye conceptualmente el agarre de Wolf_Pincel_v001. No se instaló en el juego, no se modificaron characters/, art/, código ni Git. La entrega anterior queda intacta.

## Formato y capas

18 animaciones, 98 cuadros de cuerpo. PNG RGBA 256×256; atlas horizontales sin margen entre celdas. Cada animación está en `Animations/<nombre>/body/01.png...`. Las que llevan varita añaden `brush_base/`, `tip_color/`, `tip_dry/` y `tip_ink/`, todos con el mismo origen y numeración. Los atlas de cada capa están junto a esas carpetas.

**Offset común: (-128,-238).** No recentrar por área opaca ni aplicar una escala diferente a las capas. Orden: mango, punta activa, cuerpo. La mano delantera queda sobre el mango y la otra mano queda libre junto al pecho. El cuerpo es idéntico entre cada pareja con/sin varita para evitar saltos al cambiar de estado. Sin varita conserva la mano adelantada libre, no se dibujó otro torso.

El pincel mide 176.17 px, el 81.56 % del alto de pie de 216 px. Agarre dentro del tercio inferior en todos los cuadros. Reposo y locomoción: aproximadamente 68° sobre la horizontal, vaivén menor de un grado, punta por encima de las orejas y delante del hocico. Ninguna capa del arma toca el borde de la celda. El cuerpo se compone encima, por lo que la varita no se dibuja sobre cara o bufanda.

## Animaciones

| Nombre | Cuadros | FPS del recurso | Bucle |
|---|---:|---:|---|
| idle / idle_varita | 6 cada una | 6 | sí |
| walk / walk_varita | 12 cada una | 12 | sí |
| run / run_varita | 8 cada una | 16 | sí |
| jump_start / jump_start_varita | 2 cada una | 10 | no |
| jump_up / jump_up_varita | 2 cada una | 10 | sí |
| fall / fall_varita | 2 cada una | 10 | sí |
| land / land_varita | 2 cada una | 10 | no |
| paint_rise | 8 | 10 | no |
| paint_slash | 8 | 10 | no |
| paint_up | 8 | 10 | no |
| dip | 6 | 10 | no |

`jump_start` es el despegue de 2 cuadros del pedido; después pasa a `jump_up`, subida en bucle de 2 cuadros. Fall y land son estados separados. La traslación del personaje y la gravedad las programa Claude; no están incorporadas en los PNG.

Para caminar a 0.8 ciclos/s: 12 FPS × speed_scale 0.8 = 9.6 cuadros/s; ciclo de 1.25 s. El GIF de caminata usa ese tiempo. El cálculo de apertura de los pies da **146 px/ciclo** para walk y **311 px/ciclo** para run. La carrera está aproximadamente un 7 % por encima del objetivo de 290. Son estimaciones de dos pasos a partir de la máxima separación de centros de los pies, no una certificación de velocidad constante del apoyo. Ajustar velocidad de mundo y de animación después de revisar la sensación en juego.

## Pintura y contactos

`brush_contacts.json` conserva el esquema grip_xy, angle_degrees_clockwise, tip_xy, contact_by_state_xy/color/dry/ink, paints y receives_ink. Añade longitud del pincel, fracción de agarre y punto objetivo. Hay 64 registros con arma. El CSV contiene lo mismo en columnas.

Coordenadas desde arriba izquierda de la celda; +y hacia abajo. Ángulos negativos apuntan arriba. `tip_xy` es el extremo geométrico y `contact_by_state_xy` mide el extremo raster visible de cada punta; usar este último para estampar pintura. Puntas seca/color/tinta comparten mango y transformaciones.

- **paint_rise**: cuadros 1–3 preparan la punta baja; 4–6 pintan por una recta ascendente hacia atrás. Puntos geométricos: (239,236), (215,194.431), (119,28.154). Dirección en pantalla -120°, es decir 60° hacia arriba y atrás. Cuadros 7–8 recuperan la varita alta.
- **paint_slash**: cuadros 4–6 recorren esa misma recta en sentido descendente, +60°. El contacto es el reverso exacto de rise, con preparación/recuperación propias de la secuencia.
- **paint_up**: cuadros 4–6 pintan en x=233, y=236 → 125 → 24, vertical ascendente.
- **dip**: cuadros 4–5 reciben tinta en el suelo, aproximadamente (235,238); no pintan el escenario.
- Los otros estados no pintan. Una punta seca tampoco debe pintar durante un cuadro activo; inventario y cargas corresponden a Claude.

El trazo debe interpolarse entre contactos; no basta con estampar un punto por cuadro si la punta recorre muchos píxeles. Los contactos de subida están alineados, pero su separación temporal no es uniforme: hay aceleración en el gesto.

## Escala, estabilidad y validación

`VALIDACION.json` incluye los valores por cuadro de altura y centro del torso, sus diferencias entre cuadros, la comparación de idle con los cuadros 4 y 10 de walk, y las trayectorias de contacto. `Previews/*_torso_QA.png` muestra en cian el núcleo segmentado y en rojo su centro horizontal, para auditar la medición. El núcleo excluye bufanda roja, borde gris y cola; no es el centro del bounding box de toda la silueta.

El registro horizontal de walk y run queda a menos de ±0.5 px del centro medio; la variación entre cuadros también queda por debajo de los límites solicitados. Idle y los cuadros de pies juntos de walk comparten posición del torso dentro de 2 px en x y 3 px en y.

Reposo, caminata, carrera y gestos de pintura se registraron a 216 px de silueta. Se escalaron figuras completas de forma uniforme, nunca se reconstruyeron patas, torso o cola por piezas. `Source/body_registration.json` conserva todas las escalas y traslaciones aplicadas; el dibujo generado puede tener pequeñas variaciones internas de proporción y textura, que requieren revisión artística.

**Excepción acordada con el usuario:** salto y aterrizaje conservan una escala común de cabeza/torso; la flexión cambia naturalmente la altura de la silueta. En esos estados se informa la altura real y no se fuerza el check de 216±3. El suelo sigue siendo la referencia de celda y=238, no un desplazamiento físico del nodo.

## Godot y conservación

`Godot/Wolf_body.tres`, `Wolf_brush_base.tres` y `Wolf_tip_color/dry/ink.tres` contienen SpriteFrames con las mismas animaciones y cuadros sincronizables. Para revisión, abrir **este** `project.godot` independiente y ejecutar `Godot/Preview.tscn`. Flechas cambian animación, 1/2/3 cambian punta y Espacio repite. Se abre en paint_rise, el gesto prioritario. El `.gdignore` de Game_Assets sigue intacto: el F5 del juego principal no activa esta entrega.

`Source/` conserva los originales sin tocar y los prompts usados con image_gen integrado, además de los scripts de recorte, registro, capas, atlas, GIF y medición. `References/` conserva la identidad, la caminata anterior y el pincel fuente. No borrar esos archivos al integrar. `Previews/` contiene GIF y hojas de contacto para cada animación.


Godot 4.7.2: importación, carga de todos los SpriteFrames y captura del preview comprobadas sin errores de recursos o scripts. El modo headless restringido emitió avisos del almacén de certificados y preferencias de Windows; la revisión gráfica se renderizó correctamente.
