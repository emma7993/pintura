# Lobo v005

Caminata erguida de 12 cuadros, dos pasos por ciclo, bufanda roja hacia atrás y brazos recogidos. Incluye idle de un cuadro y mirada de seis, con la misma postura base.

**Medición final: 88 px/paso y 176 px/ciclo.** Apoyos de 14.5–15 px por cuadro en los PNG. Atlas RGBA de caminata 3072×256, celdas 256×256 y suelo y=238. Wolf.tres contiene walk a 12 FPS en bucle; para 0.8 ciclos/s usar speed_scale=0.8.

- Recurso: `Godot/Wolf.tres`.
- Atlas: `SpriteSheets/`.
- Cuadros sueltos: `Individual_Frames/`.
- GIF a 0.8 ciclos/s: `Previews/walk.gif`.
- Originales, prompts y montaje reproducible: `Source/`.
- Instrucciones y mediciones: `INTEGRACION_CLAUDE.md`.

Abrir este project.godot como proyecto independiente y pulsar F5. Espacio pausa la caminata; flechas inspeccionan los cuadros. Solo es una preview de arte; el juego principal continúa con sus recursos activos.

Esta versión usa piezas raster generadas y montaje controlado para fijar la velocidad de los pies. Los borradores de doce poses generadas independientemente se conservaron como fuente, pero no se usan en el atlas final. La calidad artística queda sujeta a revisión.

No se ha copiado nada a characters ni se ha modificado el código del juego. No se hizo commit o push.
