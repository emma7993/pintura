# Salto v004

Cinco poses de Wolf_Salto_Estudio_v003, a escala y registro originales. Los PNG RGBA miden 384×384 y conservan el origen en (192, 352). El orden es impulso, ascenso, cima, caída y aterrizaje.

La referencia de identidad para todo el juego es Wolf_Pincel_v003, en Animations/idle/body y Animations/walk/body. El ojo se mantiene entrecerrado al caminar y abierto en carrera, ascenso, cima y caída. Impulso y aterrizaje admiten una expresión de esfuerzo. En esta entrega los ojos provienen de v003.

El carbón se ajustó a la mediana medida de RGB (35, 34, 34). El grano de luminancia del interior se acerca al de reposo y caminado, con sigma entre 1.22 y 1.26 frente a 1.27 en la referencia. La cola se tomó del reposo a escala 1:1. Se recortó el empalme con el cuerpo y se rotó para cada pose. La edición generativa se usó para probar el encaje. La entrega usa el dibujo original de la cola.

Previews/comparacion.png muestra los originales y el salto a la misma escala. Previews/salto.gif conserva la trayectoria de revisión de v003. VALIDACION.json registra las mediciones. El arte está listo para revisión e integración.

## Aprobación

Aprobado por el usuario el 2026-11-06 como modelo definitivo de salto para pruebas junto con carrera v027 y caminado original. Las cinco fuentes necesarias para reconstruirlo están incluidas en Source/Originales_Estudio_v003; no requiere descargar las versiones de estudio descartadas. Claude se encarga de la integración.
