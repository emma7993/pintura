# Carrera v010 — mano del fondo visible

Variante de v009: vuelve a verse el brazo izquierdo del fondo, pequeño y separado del torso. El brazo derecho delantero sigue recto y casi fijo. Se mantiene la disposición del pincel cruzado detrás del cuerpo, argolla atrás y punta hacia delante y abajo, la zancada corta, el ojo blanco abierto y la bufanda roja plana de grafito.

Sprites/: ocho composiciones RGBA 384×384. run_atlas.png: 3072×384. Offset común (−192,−352). Layers/body/ y Layers/brush_carry/ comparten origen; dibujar pincel y después cuerpo. La capa de pincel es rígida e idéntica en todos los cuadros.

Godot/Wolf_Run.tres: run en bucle a 20 FPS (0.4 s/ciclo). Recursos por capa y alternativa Wolf_Run_16fps.tres para 0.5 s/ciclo. Mantener las capas sincronizadas. El project.godot es una vista independiente, no sustituye el arte del juego principal.

Previews/run.gif: ritmo recomendado. run_16fps.gif: alternativa pausada. run_slow.gif y contact.png: revisión de las ocho poses. VALIDACION.json registra dimensiones, bordes transparentes, unicidad y alineación del ojo; estas mediciones no certifican por sí mismas la continuidad artística. Los apoyos dibujados varían unos pocos píxeles respecto al suelo lógico y=352; ver body_bounds.

Source conserva el original, el prompt de edición integrada y el exportador. Se aplica una escala común y registro por el ojo; no se reconstruyen extremidades por piezas. Pincel canónico reutilizado de Wolf_Pincel_v003.

La propuesta de combinar claridad de poses con transiciones más suaves está en DIRECCION_MOVIMIENTO.md. Es trabajo futuro para coordinar con Claude; no se han generado esas animaciones adicionales ni modificado la física.

No se tocaron characters/, art/, el código del juego, versiones anteriores ni Git.

Comprobado con Godot 4.7.2: los cinco SpriteFrames y la escena independiente cargan, con ocho cuadros por recurso y cadencias de 16/20 FPS. Los logs de Source conservan avisos del sandbox sobre certificados y preferencias del editor; los recursos de arte cargaron correctamente.
