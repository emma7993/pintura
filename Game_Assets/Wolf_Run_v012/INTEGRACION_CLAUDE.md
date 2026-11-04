# Carrera v012 — sin pincel y mano alineada

Ocho cuadros de carrera basados en v011. Mano derecha delantera alineada con el antebrazo y balanceo pequeño, conservando el brazo corto y la mano izquierda del fondo visible. Se mantienen personaje, ojo abierto, bufanda roja plana, cola gris y zancada compacta.

**Nueva regla del pincel:** no se ve durante run, ni en la mano ni en la espalda. Aparece al comenzar un ataque y desaparece al finalizar. Esta regla sustituye el transporte cruzado de v009–v011 y el desenvaine/guardado de la primera lámina conceptual del combo. Este paquete no modifica todavía el concepto del combo ni su programación.

Sprites/run_01.png a run_08.png: PNG RGBA 384×384. run_atlas.png: 3072×384. Layers/body/ contiene el mismo lobo sin arma para compatibilidad; no existe capa de pincel en esta entrega. Al integrar, Claude debe evitar superponer la capa de pincel de una versión anterior.

Godot/Wolf_Run.tres y Wolf_Run_body.tres: run en bucle, ocho cuadros, 20 FPS, ciclo de 0.4 segundos. Wolf_Run_16fps.tres: alternativa de 0.5 segundos. Offset común (−192,−352). Una sola escala y registro del cuadro completo por el ojo; no recentrar cada silueta.

Previews/run.gif muestra la cadencia recomendada; run_slow.gif y mano_lenta.gif permiten revisar el ciclo y la muñeca. contact.png y manos_contact.png reúnen los cuadros. El movimiento de mano es dibujado; el prompt propone un balanceo de pocos píxeles, no una trayectoria certificada matemáticamente.

El project.godot de esta carpeta es una vista independiente. El juego principal sigue excluyendo Game_Assets y no cambia al pulsar F5 allí. VALIDACION.json registra tamaños, unicidad, bordes transparentes y alineación del ojo; no certifica por sí solo fluidez o apoyos. Los contornos del suelo dibujado pueden variar unos pocos píxeles respecto a y=352, detallados en body_bounds.

Source conserva el original seleccionado, instrucciones de edición integrada y exportador. No se reconstruyen extremidades por piezas. No se tocaron characters/, art/, código del juego, Git ni versiones anteriores.

El acabado de esta corrección es más limpio y plano que v011; se priorizó conservar la geometría de la muñeca. La prueba adicional de textura reintroducía la mano anterior y fue descartada.

Comprobado en Godot 4.7.2: tres recursos con ocho cuadros, tamaños y cadencias correctos, y escena independiente cargada. Logs en Source; los avisos de certificados y preferencias corresponden al sandbox, sin fallos de carga del arte.
