# Carrera v011 — proporción del brazo y acabado del combo

Variante de Wolf_Run_v010, tomando como referencia de dibujo el combo aprobado Wolf_Combo_v001/Concepto_01. El brazo derecho delantero se acorta: la mano termina junto a la cintura, en lugar de caer sobre el muslo. Se mantiene una muñeca alineada, mano pequeña casi fija y brazo izquierdo del fondo visible. Se conservan ocho poses, el pincel cruzado detrás del cuerpo, ojo blanco abierto, cabeza pequeña y bufanda roja plana.

La nueva entrega modifica el dibujo del brazo y el acabado; no añade una simulación de movimiento ni sustituye código. La continuidad del ciclo se revisa con las vistas normal/lenta, no se deduce solo del número de cuadros. La cola y bufanda siguen las fases del ciclo; no tienen simulación independiente en esta entrega.

## Uso

- Sprites/run_01.png a run_08.png: RGBA 384×384, composición lista con pincel.
- run_atlas.png: atlas horizontal 3072×384.
- Layers/body/ y Layers/brush_carry/: mismo origen; dibujar pincel y después cuerpo.
- Godot/Wolf_Run.tres: run en bucle a 20 FPS, 0.4 segundos por ciclo. Alternativa Wolf_Run_16fps.tres, 0.5 segundos por ciclo. Recursos independientes por capa.
- Offset común (−192,−352). Escala única y traslación de cada cuadro completo por el punto del ojo; no normalizar por la caja opaca de cada pose.

El pincel usa la misma pieza rígida canónica y disposición diagonal de v010. Las coordenadas grip_xy en VALIDACION.json son el pivote técnico de colocación de esa pieza, no un contacto nuevo de la mano medido para ataques.

## Revisión

Previews/run.gif: vista recomendada. run_16fps.gif: cadencia pausada. run_slow.gif: revisión de las ocho fases. contact.png: hoja completa. comparacion_brazo.png muestra v010 frente a v011 a la misma escala y con las cabezas registradas.

Abrir project.godot de esta carpeta para la escena independiente. Game_Assets sigue excluido de la importación del juego principal; no cambia la animación al pulsar F5 allí.

VALIDACION.json registra tamaños, ocho composiciones distintas, bordes transparentes y posición del ojo. Los contornos de los apoyos pueden variar unos pocos píxeles respecto al suelo lógico y=352; ver body_bounds. Estas métricas no certifican por sí solas la fluidez artística ni la sincronización con la velocidad del jugador.

Source conserva original seleccionado, prompts y exportador. Se utilizó la herramienta integrada de generación/edición; el exportador registra y compone assets, sin reconstruir extremidades por piezas. No se modificaron characters/, art/, código, Git ni versiones anteriores.

Comprobado en Godot 4.7.2: cargan los cinco recursos de ocho cuadros, cadencias de 20/16 FPS y escena independiente. Los logs de Source conservan avisos del sandbox sobre certificados y preferencias del editor, sin fallos de carga de los recursos de arte.
