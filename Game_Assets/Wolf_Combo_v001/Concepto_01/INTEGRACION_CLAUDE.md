# Combo de pincel — Concepto 01

Primera propuesta de diseño de tres ataques enlazados. No sustituye los sprites del juego: son cuatro poses clave por golpe y una animática para revisar dirección, alcance y silueta.

1. **Corte ascendente:** desenvaine desde atrás; el pincel se alarga al subir en diagonal y deja un trazo negro hacia delante y arriba.
2. **Barrido horizontal:** enlaza desde la posición alta y barre a la derecha. La tinta sigue la punta; el mango se mantiene fino.
3. **Remate descendente:** levanta el pincel y lo baja en diagonal hasta tocar el suelo delante del lobo. Cierra con salpicadura y recogida del pincel.

Objetivo: pincel propio de madera negra, argolla, virola corta y cerdas finas; pasa de unos 215 px guardado a unos 310 px durante el golpe. Aumenta el largo, no el grosor. Estas cifras son objetivos del diseño y requieren ajuste/medición en la fase de producción. El personaje conserva su cabeza, manos pequeñas, bufanda roja plana y cola gris.

## Revisar

`Previews/diseno_combo.png` muestra las doce poses sobre crema. `combo_animatic.gif` propone un ritmo de lectura; `combo_lento.gif` permite examinarlas. Los GIF individuales separan cada golpe. La animática cambia entre poses clave y no pretende representar todavía el movimiento fluido final.

`Poses/attack_01..03/` conserva los cuadros de concepto RGBA de 512×512. Atlas de cuatro poses por ataque: 2048×512. Se dejaron márgenes adicionales para el arma alargada y la pintura; no cambiar el origen ni copiar estos cuadros a la carrera de 384×384. Ancla propuesta (256,448), pendiente de registro final de cada apoyo. Se empaqueta con escala común, sin normalizar cada personaje por su área opaca.

## Producción posterior

Una vez elegido el diseño: resolver los enlaces entre los tres golpes, conservar escala de cabeza/torso, fijar los apoyos y dibujar las fases intermedias necesarias. Entregar cuerpo, pincel base, punta y estela de tinta en capas independientes. La longitud extendida del pincel necesita su propio parámetro/curva; no estirar el cuerpo ni el grosor del arma. Medir agarre, punta, cuadros activos e hitboxes después de cerrar el dibujo; no usar las manchas negras de esta lámina directamente como hitbox.

Esta entrega no incluye capas independientes, animación final, SpriteFrames ni contactos/hitboxes de producción. El negro está integrado en las poses para juzgar el diseño. Los cuadros de impacto deberían tener una lectura breve y clara; la pausa, los enlaces y el desplazamiento se ajustarán con Claude dentro del juego.

Source conserva el original intacto, prompt y exportador. Imágenes generadas con la herramienta integrada a partir del lobo de Wolf_Run_v010. Las capturas del usuario son referencia de intención (arma fina que se alarga y continuidad de ataques), no sprites calcados ni elementos extraídos de otro juego.

No se modificaron characters/, art/, código, Git ni entregas anteriores.
