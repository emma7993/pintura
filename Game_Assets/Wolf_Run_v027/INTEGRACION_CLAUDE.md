# v027 — proporciones y expresión de carrera

Base visual: v026, cuyo estilo el usuario valoró favorablemente. Referencias adjuntas a una sola edición con image_gen: la hoja `Lobito Saltando.png` proporcionada por el usuario, conservada en Source/Referencia_Salto_Usuario.png, y el PNG nativo del ascenso aprobado de Wolf_Salto_v004.

Se solicitó reducir aproximadamente 10–12% la cabeza como unidad respecto del cuello, mantener su diseño, afinar moderadamente la relación torso/extremidades y cambiar el ojo a una mirada seria, decidida y ligeramente enojada. Se pidió preservar poses, zancada, manos visibles, trazo fino, bufanda y cola de v026. Ese porcentaje describe la instrucción artística, no una garantía de reducción exacta medida. La salida es una edición generativa, no idéntica píxel a píxel a v026. No se modificaron las referencias aprobadas.

La revisión visual incluye cabeza, torso, brazos y piernas contra el salto. La flexión y orientación cambian la silueta proyectada; no se afirma igualdad exacta de longitudes óseas a partir de PNG de poses diferentes. `Source/COMPARACION_PROPORCIONES.json` mide el ancho a la altura del ojo como indicador auxiliar, explícitamente sensible a pose/expresión. La expresión nueva es intencional y reemplaza el ojo redondo de la carrera en esta revisión.

## Archivos de revisión

- `Previews/salto_v026_v027.png`: salto aprobado, carrera anterior y carrera revisada a escala de celda idéntica.
- `Previews/comparacion_modelo.png`: caminado, salto y los ocho cuadros actuales.
- `Previews/run.gif`: ocho cuadros a 20 FPS sobre crema.
- `Previews/sprite_sheet.png`: hoja 4×2 RGBA transparente, 1536×768.
- `Sprites/run/01..08.png`: celdas RGBA 384×384, perfil derecho, origen lógico (192,352).
- `Atlases/run.png`: atlas horizontal; `Godot/Wolf_Run.tres`: SpriteFrames run, 20 FPS y bucle.
- `Source/edicion.png`, `Source/PROMPT.txt`: resultado original e instrucción completa de la edición integrada.
- `Source/export.py`: escala común de la hoja y traslación común, sin normalizar tamaño individualmente.

Se mantienen las limitaciones de revisión técnica: los apoyos rasterizados no coinciden todavía todos exactamente en y=352 (ver VALIDACION.json), y no se ha certificado recorrido uniforme de suela ni avance por ciclo. Aprobación artística del usuario: 2026-11-06. Modelo definitivo elegido para pruebas; Claude realiza la integración y verifica estos detalles técnicos. No se modifica código, characters/, art/ ni Git.

## Aprobación y publicación

El usuario aprobó esta carrera, el salto v004 y el caminado original como modelos definitivos para probarlos en el juego el 2026-11-06. Esta autorización reemplaza el estado previo de revisión artística; no implica que la física o el registro hayan sido validados.
