# Lobo v003 — caminata y alerta ocasional

Abrir Godot_Preview/project.godot en Godot 4 y ejecutar con F6 la escena Wolf/Godot/Preview.tscn, o ejecutar el proyecto con F5. La demo camina en el sitio y se detiene para mirar cada 7–14 segundos. Flechas: control manual; espacio: alternar demo. En manual, el lobo mira solo al estar quieto y cancela inmediatamente al moverse. La demo no incluye audio: la actuación sugiere que escuchó algo.

Para el proyecto existente: copiar 01_Characters/Wolf dentro de Game_Assets/Wolf_v003 y abrir Godot/Preview.tscn con F6. Mantener las carpetas juntas para las referencias relativas. El script Wolf.gd acepta animate(delta, speed01, vel_x, air, vy); la conexión al controlador existente debe realizarse en el proyecto antes de sustituir el personaje. No se modificó el controlador de pintura.

Destino permanente solicitado: C:\Users\Immix\Documents\NPM Game\pintura\Game_Assets. Esta entrega está en outputs; no se instaló allí por restricciones de escritura.

Caminata: 8 cuadros, 8 FPS. Alerta: 6 cuadros, 0.99 segundos sin loop. Reposo: pose estática. Todas las celdas son PNG RGBA de 256×256. Punto de suelo y=238; offset=(0,-110) con centered activado.

Esta v003 sustituye la propuesta v002 dentro de este paquete. Es una versión funcional comprobada en un proyecto aislado; la aceptación visual y la integración definitiva en el juego siguen pendientes. No confundir la ejecución correcta con aprobación artística.
