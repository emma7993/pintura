# Lobito — salto y caída v001

Cinco poses mirando a la derecha, con el diseño de referencia de Wolf_Run_v013: lobo negro con grano de grafito, contorno gris, ojo blanco abierto, bufanda roja plana y punta de cola gris. Sin pincel ni arma visible.

## Rutas

| Acción | Cuadro | Archivo |
|---|---|---|
| Salto | Impulso | Animations/jump/01_impulso.png |
| Salto | Ascenso | Animations/jump/02_ascenso.png |
| Salto | Cima | Animations/jump/03_cima.png |
| Caída | Cayendo | Animations/fall/01_cayendo.png |
| Caída | Aterrizaje con rebote | Animations/fall/02_aterrizaje_rebote.png |

PNG RGBA 384×384, offset común (−192,−352), ancla de pies (192,352). Escala común: las flexiones reducen naturalmente la altura de la silueta; no se agranda cada pose para llenar la celda. Impulso y aterrizaje se registran en y=352. El salto vertical del jugador corresponde a la física del juego, no debe deducirse de la posición de la imagen dentro del atlas.

Atlases/jump.png: 1152×384 (tres celdas). Atlases/fall.png: 768×384 (dos celdas). Atlases/jump_fall.png: 1920×384 (cinco celdas en el orden anterior). ASSETS.json contiene rutas, nombres de estado, dimensiones y mapeo de cuadros para retomar el trabajo.

## Estados preparados para Godot

Godot/Wolf_Jump_Fall.tres incluye las secuencias `jump` (tres cuadros) y `fall_and_land` (dos), sin bucle, para revisar el orden solicitado. Incluye también estados de una pose para integración por condiciones: `jump_start`, `jump_up`, `jump_apex`, `fall` y `land`.

- Impulso al despegar; pasar a ascenso mientras la velocidad vertical sea negativa.
- Cima cerca del cambio de signo de velocidad vertical; no mantenerla indefinidamente en mitad de una caída.
- `fall` mantiene únicamente la pose cayendo mientras el lobo esté en el aire.
- `land` se activa al confirmar contacto con el suelo. **No reproducir caída y aterrizaje en bucle mientras siga en el aire.**

La quinta pose representa la compresión elástica del aterrizaje. Con solo ese dibujo, el rebote temporal se obtiene con un pequeño desplazamiento visual del sprite y retorno (por ejemplo, 4–6 px durante unos 0.15–0.20 s), manteniendo la colisión en el suelo. No es un salto automático ni un sexto sprite. Son valores iniciales de diseño para probar con Claude, no ajustes ya instalados.

La bufanda se retrasa hacia abajo en el ascenso, flota hacia atrás en la cima y se levanta hacia atrás al caer/aterrizar. Revisar los enlaces con la carrera antes de integrar.

## Previews y fuentes

Previews/hoja_poses.png muestra los cinco dibujos. salto_caida.gif y .apng muestran una trayectoria ilustrativa, con un rebote visual usando la quinta pose; esa trayectoria está solo en la vista previa. timeline.json describe esa demostración. poses.gif permite revisar los dibujos sin trayectoria. El APNG conserva mejor la textura que el GIF.

Source conserva la lámina original, corrección localizada de caída, prompts y exportador. Se utilizó la herramienta integrada de imágenes; los scripts solo registran, empaquetan y preparan vistas previas. VALIDACION.json comprueba cinco imágenes distintas, tamaños, bordes y suelo de las poses apoyadas. La anatomía y los enlaces requieren revisión visual; no se afirma identidad píxel a píxel con la carrera al tratarse de poses nuevas.

No se modificaron characters/, art/, código del juego, Git ni entregas anteriores. El recurso está preparado para que Claude lo copie y conecte posteriormente; Game_Assets sigue fuera de la importación del juego principal.
