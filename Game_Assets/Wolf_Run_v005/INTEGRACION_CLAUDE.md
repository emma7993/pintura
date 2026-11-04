# Carrera v005 — ojos abiertos y manos originales

Ocho cuadros mirando a la derecha: ojos blancos ovalados abiertos en todos los cuadros, manos negras pequeñas y alargadas con dedos en punta, brazos bajos y retrasados. Pincel en la mano izquierda retrasada.

Sprites/: ocho composiciones RGBA listas con punta de color. Atlases/run.png: 3072×384, ocho celdas de 384×384. Origen común (−192,−352). Godot/Wolf_Run.tres: run a 16 FPS en bucle.

Layers/: cuerpo sin pincel, mango y tres estados de punta. Dibujar mango, punta elegida y cuerpo, en ese orden. brush_contacts.json guarda las coordenadas del agarre y punta. La carrera no pinta.

Previews/run.gif y run_contact.png permiten revisar el ciclo. Source/ conserva el original, prompt y script de empaquetado. Generado con la herramienta integrada de imágenes, usando la carrera v004 y los originales del usuario como referencias de identidad y manos.

Se conservó la versión anterior. No se modificaron characters/, art/, programación ni Git. La continuidad y el ajuste de velocidad requieren revisión de Claude dentro del juego; esta entrega es arte para revisión del usuario.
