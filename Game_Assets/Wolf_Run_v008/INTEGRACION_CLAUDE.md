# Wolf Run v008 — 16 cuadros y pincel guardado

Entrega exclusivamente de carrera, basada en la estética aprobada de Wolf_Run_v007. Mano delantera casi quieta junto a la cadera, pincel guardado en diagonal detrás de cuerpo y bufanda, ojos abiertos pequeños, zancada corta y bufanda roja plana con textura de grafito. No contiene ataques nuevos ni cambia cuándo se equipa el pincel en el juego.

## Archivos y reproducción

- `Sprites/run_01.png` a `run_16.png`: composiciones RGBA listas para usar.
- `run_atlas.png`: atlas horizontal 6144×384, 16 celdas de 384×384.
- `Layers/body/`: lobo sin pincel. `Layers/brush_back/`: pincel guardado. Las capas comparten origen; dibujar `brush_back` y después `body`.
- `Godot/Wolf_Run.tres`: animación `run`, 16 cuadros, 32 FPS, bucle. Los recursos `Wolf_Run_body.tres` y `Wolf_Run_brush_back.tres` contienen las capas independientes.
- Offset común (−192,−352). No recentrar por la caja opaca de cada cuadro. Se aplicó una sola escala para todo el ciclo y traslaciones del cuadro completo para estabilizar el ojo/cabeza.

32 FPS conserva el ciclo de medio segundo de v007 (8 cuadros a 16 FPS). No reproducir estos 16 cuadros a 16 FPS salvo que se quiera ralentizar la carrera a un ciclo por segundo. La velocidad de traslación del jugador no se ha calculado a partir de estos dibujos.

El pincel se reutiliza del diseño de Wolf_Pincel_v003, con proyección más corta al quedar guardado. Su posición detrás del personaje es fija; la silueta y la cola ocultan distintas partes según la fase. Ninguna mano lo sostiene durante `run`. Claude puede ocultar la capa `brush_back` al comenzar un ataque y usar el pincel de esa animación.

## Revisión

`Previews/run.gif`: ciclo de 500 ms (30/40 ms por cuadro debido a la precisión del GIF). `run.apng`: vista de mayor precisión temporal. `run_slow.gif` y `hands_slow.gif`: revisión lenta del ciclo y del brazo; las hojas `contact.png` y `hands_contact.png` muestran todos los cuadros.

Abrir el `project.godot` de esta carpeta para la vista independiente en Godot. `Game_Assets/.gdignore` sigue excluyendo esta biblioteca del juego principal, por lo que F5 en el juego no cambia su animación actual.

`VALIDACION.json` contiene dimensiones, unicidad de archivos, margen transparente y posición del ojo por cuadro. El rango total medido del punto del ojo es menor de 1 px por eje. Esto no mide por sí solo la deformación de la mano o la continuidad de las piernas. El suelo lógico es y=352; el contorno dibujado de algunos apoyos varía unos pocos píxeles, detallados en `body_bounds`, y las fases de vuelo quedan más altas. No se declara una validación física perfecta de los apoyos.

Godot 4.7.2 importó las texturas y cargó los tres SpriteFrames y la escena de vista previa. El validador comprobó 16 cuadros de 384×384 a 32 FPS en cada recurso. El log conserva una advertencia del entorno sobre el almacén de certificados; no hubo fallos de carga de los recursos de arte. Ver `Source/godot_validation.log`.

`Source/original.png` conserva la primera propuesta de 16 cuadros; `body_original.png` es el cuerpo seleccionado tras quitar el pincel dibujado. `prompts.txt` registra ambas instrucciones de generación integrada. `export.py` empaqueta, registra y compone el pincel canónico; no reconstruye las extremidades por piezas.

No se han modificado versiones anteriores, characters/, art/, el código del juego ni Git. Esta entrega queda para revisión visual e integración por Claude.
