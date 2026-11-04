# Restauración puntual de cola — v013

Base: la hoja detallada enviada por el usuario (Source/referencia_usuario.png). Se restauran píxeles de las puntas de cola copiándolos de su última referencia (Source/referencia_cola_original.png). No se usa ninguna regeneración para el resultado final ni se cambian mano, orejas, cabeza, bufanda o cuerpo fuera de la máscara.

Wolf_Run_cola_restaurada.png es el máster a resolución original. VALIDACION.json verifica cero píxeles cambiados fuera de Source/mascara_cola.png. Es la referencia principal para comprobar que se ha conservado el resto del dibujo.

Sprites/ contiene ocho PNG RGBA 384×384 con una escala y desplazamiento comunes; run_atlas.png es 3072×384. Godot/Wolf_Run.tres: ocho cuadros, 20 FPS, bucle. Las copias de juego son reescaladas; la garantía de igualdad exacta fuera de la cola corresponde al máster, no a la comparación con otras exportaciones previas.

Previews/hoja_detalle.png muestra el máster sobre crema. Previews/run_detalle.apng conserva color RGBA y textura mejor que el GIF de paleta limitada. run.gif es solo una vista rápida y puede perder grano fino.

El pincel sigue ausente de la carrera y se materializará únicamente al atacar. No se modificaron characters/, art/, código, Git ni entregas anteriores. El recurso no se importó al proyecto principal.

Source/prepare_tail.py y tail_edit_target.png corresponden a una prueba previa de recorte que no se utilizó en la restauración final. El resultado final procede exclusivamente de restore_tail.py y de las dos referencias originales del usuario.
