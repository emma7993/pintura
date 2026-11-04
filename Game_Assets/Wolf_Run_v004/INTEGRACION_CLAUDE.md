# Carrera con pincel en la mano retrasada

Variante independiente: 8 cuadros de carrera, perfil derecho, brazos bajos hacia atrás. El pincel está en el puño izquierdo retrasado. No sustituye archivos de versiones anteriores.

- `Sprites/run_01.png` a `run_08.png`: composición lista con punta de color.
- `Atlases/run.png`: atlas horizontal RGBA 3072×384, celdas 384×384.
- `Layers/`: cuerpo completo, mango y tres estados de punta alineados.
- Orden: brush_base, tip_color/dry/ink, body. La mano tapa el mango.
- Origen común: offset (−192,−352). No recentrar capas por transparencia.
- `Godot/Wolf_Run.tres`: run, 8 cuadros, 16 FPS, bucle. Los otros recursos contienen capas separadas.
- `brush_contacts.json`: puño y punta por cuadro; esta carrera no pinta.
- `Previews/run.gif` y `run_contact.png`: revisión visual sobre crema.
- `Source/`: original generado, prompt y script reproducible. Pincel reutilizado de Wolf_Pincel_v003.

El suelo lógico es y=352. Esta variante requiere revisión en movimiento en el juego; no se ha medido una velocidad de avance compatible con la zancada. La altura se ha ajustado a 216 px por pose completa. No se modificaron characters/, art/, programación ni Git.
