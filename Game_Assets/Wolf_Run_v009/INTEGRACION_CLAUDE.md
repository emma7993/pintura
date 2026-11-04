# Carrera v009 — brazo recto y pincel cruzado

Ocho poses originales de carrera del lobo, con brazo derecho delantero extendido hacia abajo y atrás, muñeca alineada y mano pequeña casi quieta. El otro brazo queda oculto detrás del torso. Se conservan la cabeza pequeña, ojo blanco abierto, bufanda roja plana con flecos cortos, cola gris y zancada compacta.

El pincel se lleva cruzado detrás del cuerpo y el brazo: argolla atrás a la izquierda, punta hacia delante y abajo. Esta disposición reemplaza el guardado casi vertical de v008. Es el diseño propio del pincel de Wolf_Pincel_v003; no se extrajo ni calcó la aguja o las poses de otro juego. Las capturas del usuario orientan únicamente la lectura de la silueta y del arma.

## Uso

- `Sprites/run_01.png` a `run_08.png`: RGBA 384×384, pincel incluido.
- `run_atlas.png`: 3072×384, ocho celdas horizontales.
- `Layers/body/` y `Layers/brush_carry/`: capas con origen común. Dibujar pincel primero y cuerpo después; la mano y el torso ocultan parte del mango.
- `Godot/Wolf_Run.tres`: run, bucle, **20 FPS**, ciclo de 0.4 segundos. Recursos equivalentes por capa y alternativa `Wolf_Run_16fps.tres` para un ciclo de 0.5 segundos.
- Offset (−192,−352). No normalizar cada silueta por separado. Una sola escala y traslaciones del cuadro completo registran el punto del ojo.

Recomendación artística: comenzar con ocho poses a 20 FPS y ajustar la cadencia a la velocidad real del jugador. Más dibujos solo ayudan cuando los apoyos y el espaciado son coherentes; no conviene aumentar el número para compensar saltos de forma. No se afirma conocer el número de cuadros o los FPS del juego de referencia. La velocidad de avance y el deslizamiento de los pies deben ajustarse dentro del juego.

## Previews y comprobaciones

`Previews/run.gif`: versión recomendada a 20 FPS. `run_16fps.gif`: mismos dibujos, reproducción más pausada. `run_slow.gif`: revisión del ciclo. `contact.png`: las ocho poses. Los APNG de 16 y 20 FPS conservan mejor el detalle que el GIF.

Abrir el `project.godot` de esta carpeta para ver el arte independientemente. El proyecto principal sigue excluyendo Game_Assets con su .gdignore y no cambia al pulsar F5 allí.

`VALIDACION.json` registra tamaños, ocho composiciones distintas, bordes transparentes y el rango del punto del ojo (menor de 1 px por eje). Esa medida no certifica por sí sola la fluidez. El pincel usa exactamente la misma capa rígida en todos los cuadros, sin deformación generada. El suelo lógico sigue en y=352; los contornos dibujados de los apoyos presentan variaciones de pocos píxeles registradas en `body_bounds`; las fases de vuelo quedan más altas.

Godot 4.7.2 importó las texturas y cargó los cinco recursos y la escena independiente. El validador comprobó ocho cuadros por recurso, los tamaños y las cadencias de 16/20 FPS. Los logs de Source conservan advertencias del sandbox sobre certificados y preferencias de usuario; no hubo fallos de carga de estos recursos de arte.

Source conserva el original generado con la herramienta integrada, prompt y exportador. El exportador registra, empaqueta y compone el pincel existente; no reconstruye las extremidades por partes. No se modificaron characters/, art/, el código del juego, versiones anteriores ni Git.
