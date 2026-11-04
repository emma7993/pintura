# Caminata v004 suavizada — v005 revisión 03

## Alcance vigente

La última instrucción del usuario sustituye la petición de ampliar la zancada: **solo aumentar de 8 a 12 fases para una caminata lenta más suave, conservando el dibujo y proporciones de v004**. No se aplica mano gris, no se alarga el paso y no se reconstruye el cuerpo por piezas. No usar el montaje rechazado de la raíz de v005 ni la propuesta de mano gris de Revision_02.

Entrega nueva en `Game_Assets/Wolf_Walk_v005/Revision_03/`. No se copió a characters, no se modificó código del juego ni se hizo commit/push. La versión activa del juego se conserva.

## Archivos

- `SpriteSheets/walk_v005_r03.png`: RGBA 3072×256, 12 celdas 256×256, alfa real, suelo en y=238.
- `Godot/Wolf.tres`: animación **walk únicamente**, 12 cuadros, 12 FPS base, loop.
- `Individual_Frames/walk/`: doce PNG completos.
- `Previews/walk.gif`: 12 cuadros, 1250 ms por ciclo, 0.8 ciclos/s.
- `Previews/walk_contact.png`: plancha de revisión con claves originales identificadas.
- `References/`: los ocho cuadros v004 sin modificar.
- `Source/`: cuatro originales image_gen de dos intermedios cada uno, sus prompts exactos, empaquetador y métricas.

Abrir `project.godot` de esta carpeta y F5 para la preview independiente. Espacio pausa; flechas permiten revisar cada cuadro. El proyecto principal no apunta a esta entrega.

## Qué se conservó

Los cuadros finales 1,4,7,10 son idénticos píxel por píxel a los cuadros v004 1,3,5,7. Los otros ocho son dibujos completos generados como intermedios a partir de las poses vecinas de v004. No se separaron patas, torso, cabeza o brazos, ni se deformaron articulaciones por código.

Se muestrea el ciclo de ocho fases en doce posiciones: 0,2/3,4/3,2,8/3,10/3,4,14/3,16/3,6,20/3,22/3. La última pareja se dibujó usando v004 7→8→1 para preparar el retorno al principio. Las fracciones son la guía temporal de generación; no son una certificación de interpolación geométrica exacta.

El empaquetado recorta cada figura completa, aplica un factor de escala común por plancha de dos dibujos y registra cuerpo/suelo. No normaliza cada figura por separado ni modifica la anatomía. La calibración de las fuentes de distinta resolución se registra en `Source/packing_metrics.json`. Los cuatro cuadros originales no se reescalaron ni desplazaron.

## Integración después de revisión

Copiar el atlas a una nueva ruta versionada del personaje y **sustituir solo la animación walk** en el SpriteFrames activo. Este Wolf.tres es una muestra con walk; no reemplazar a ciegas un recurso que también contenga idle y look_around. Esa sustitución borraría las otras animaciones. Idle y mirada no forman parte de esta revisión.

AnimatedSprite2D centrado conserva offset=(0,-110). A 12 FPS base, speed_scale=0.8 produce 0.8 ciclos/s, equivalentes a 9.6 cuadros/s efectivos. La preview ya usa ese valor. Claude mantiene el control de velocidad física y reproducción.

## Límites y QA

El objetivo vigente es preservar v004 y suavizar sus fases; no se mantienen las cifras de 175–176 px/ciclo de la propuesta rechazada. Tampoco se certifica aquí velocidad constante del pie, zancada ampliada ni ausencia de deslizamiento en el controlador. Esas medidas no deben copiarse de la documentación anterior.

Verificado: 12 dibujos distintos, atlas RGBA 3072×256, suelo y=238, margen transparente sin personaje recortado y cuatro claves originales idénticas. El GIF contiene los 12 cuadros y dura 1250 ms. Importación y carga del recurso en Godot 4.7.2 comprobadas. Métricas en `Source/qa_metrics.json`.

Plancha inspeccionada para proporciones, piernas completas, manos negras y bufanda. Persisten pequeñas variaciones de trazo y forma propias de los intermedios generados. La fluidez percibida y el empalme12→1 requieren la revisión artística del usuario en el GIF y después en escenario; no se declara aprobación visual definitiva.

No hay un rig nuevo ni ajustes de los controladores dentro de esta entrega. Los scripts incluidos son de empaquetado y preview del paquete independiente.
