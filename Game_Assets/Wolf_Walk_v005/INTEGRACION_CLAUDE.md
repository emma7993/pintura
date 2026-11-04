# Lobo v005 — entrega para Claude

Fecha: 2026-11-02. Esta entrega está únicamente en `Game_Assets/Wolf_Walk_v005/`. No se ha copiado a characters ni se ha conectado al controlador. No se hizo commit ni push.

## Recursos de ejecución

| Archivo | Especificación |
| --- | --- |
| `SpriteSheets/walk_v005.png` | PNG RGBA 3072×256, 12 columnas, 1 fila |
| `SpriteSheets/idle_v005.png` | PNG RGBA 256×256, pose erguida estática |
| `SpriteSheets/look_around_v005.png` | PNG RGBA 1536×256, 6 columnas, 1 fila |
| `Godot/Wolf.tres` | SpriteFrames: walk 12 cuadros/12 FPS/loop; idle 1 cuadro; look_around 6 cuadros/sin loop |
| `Individual_Frames/` | Los 19 cuadros PNG sueltos |
| `Previews/walk.gif` | Ciclo completo de 1250 ms: 0.8 ciclos/s, 12 cuadros |
| `Previews/walk_contact_test.gif` | Mismo ciclo con marcas de suelo desplazándose a la velocidad de la zancada para revisar el apoyo |
| `Previews/look_around.gif` | Mirada de 1 s; la preview GIF repite para inspección |

Todos los PNG de juego tienen celdas 256×256, transparencia real y suelo visible en y=238. AnimatedSprite2D centrado: offset=(0,-110). La pelvis del montaje está en x=128. Misma escala y piezas fijas durante todo el ciclo; no hay normalización de tamaño por cuadro. Las capturas GIF usan un fondo claro y línea de suelo solo para revisar; esos elementos no están en los PNG.

## Zancada medida

**88 px por paso, 176 px por ciclo en los PNG finales**. Dos pasos alternados, contactos principales en cuadros 1 y 7. El montaje continuo usa 87.5 px/paso y 175 px/ciclo; la diferencia de 1 px/ciclo al medir el raster procede del muestreo y del centro de la huella de píxeles.

Se midió el centro del apoyo visible con alfa ≥128 en las dos últimas filas de la silueta, no la punta de la rodilla ni el extremo de una pierna en vuelo. Tabla de apoyo de cada pie durante sus seis intervalos; la séptima muestra es el despegue en el contacto del pie contrario:

| Muestra | Pie derecho: cuadro | Pie izquierdo: cuadro | Centro de apoyo X medido | Retroceso desde anterior |
| --- | --- | --- | --- | --- |
| 1 | 1 | 7 | 171.5 | — |
| 2 | 2 | 8 | 156.5 | 15.0 |
| 3 | 3 | 9 | 142.0 | 14.5 |
| 4 | 4 | 10 | 127.5 | 14.5 |
| 5 | 5 | 11 | 113.0 | 14.5 |
| 6 | 6 | 12 | 98.5 | 14.5 |
| 7 | 7, pie trasero | 1 del ciclo siguiente, pie trasero | 83.5 | 15.0 |

La trayectoria del montaje retrocede exactamente 14.583333 px/cuadro durante el apoyo. En el raster los centros visibles avanzan 14.5–15 px. No se rota el pie apoyado; conserva una suela plana. La elevación del pie en vuelo es de 16 px como máximo, con balanceo del cuerpo de 0.8 px. La apertura máxima entre centros de apoyo es 88 px.

Mediciones completas: `Source/qa_metrics.json`. Trayectorias de producción: `Source/rig_landmarks.json`. **No usar `POSE_TARGETS.json` como si fuera una medición del arte**: es la guía inicial de objetivos.

## Ritmo y velocidad del personaje

El recurso cumple 12 cuadros a 12 FPS. Eso equivale a 1 ciclo/s con speed_scale=1. Para el ritmo solicitado de 0.8 ciclos/s, usar speed_scale=0.8: 9.6 cuadros/s efectivos y ciclo de 1.25 s. La preview independiente ya usa ese valor.

Para coordinar movimiento y apoyo:

```text
velocidad_mundo ≈ zancada_en_atlas × escala_horizontal_global × ciclos_por_segundo
```

Con 176 px/ciclo medidos y 0.8 ciclos/s: 140.8 px/s a escala 1; 84.48 px/s a escala 0.60. La trayectoria continua ideal del montaje da 140 y 84 px/s respectivamente. Como punto de partida para evitar patinaje, la constante analítica 175 se puede usar en la fórmula y contrastar con el raster medido 176 en escenario.

Si se mantiene otra velocidad del controlador, ajustar el ritmo con `ciclos/s = abs(velocidad_x)/(zancada*abs(escala_global_x))`. Como el recurso base tiene 1 ciclo/s, ese valor coincide con speed_scale. No conservar una fórmula de reproducción calibrada para la zancada de v004 sin volver a medirla.

Esto es información para la integración; no se ha cambiado la velocidad ni el código del juego. La ausencia de deslizamiento en juego depende también de la escala por profundidad, velocidad física, interpolación y ajustes del controlador.

## Reposo y mirada

Idle y mirada usan el mismo torso, pelvis, brazos, cabeza neutra y texturas del montaje de caminata. Se conserva postura erguida, perfil derecho, brazos recogidos y bufanda hacia atrás. En reposo la punta de la bufanda cae un poco más, siempre detrás del hombro.

La mirada mueve únicamente la cabeza: neutra, pequeño gesto de orejas, giro, vigilancia atrás, retorno y neutra. Las seis fases duran 120, 120, 160, 380, 120 y 100 ms. Las duraciones se expresan en Wolf.tres como pesos a 6 FPS. El cuadro 1 y el 6 son **idénticos píxel por píxel a idle**. Las piernas, torso y cola quedan fijos durante la mirada. Conservar la política del controlador de mirar solo al estar quieto y cancelar al moverse.

Una pose estática no puede coincidir con los pies de todas las fases de la caminata. Para una parada especialmente suave, Claude puede implementar una transición visual de aproximadamente 80–120 ms o llevar los pies hacia la pose de reposo. Eso queda fuera de los assets y no se ha implementado. La nueva postura elimina el cambio erguido→encogido de v003, pero no constituye por sí sola una transición de pies perfecta desde cualquier fase.

## Integrar después de revisión

1. Revisar GIF, planchas y la preview independiente antes de sustituir recursos aprobados.
2. Cuando corresponda, copiar juntos `Godot/Wolf.tres` y `SpriteSheets/` a una nueva ruta de characters, manteniendo su estructura relativa. No apuntar el juego a Game_Assets: esa biblioteca tiene .gdignore.
3. Conectar al contrato actual, revisar ritmo/velocidad con la zancada anterior y comprobar giro, apoyo, cancelación de mirada y escala por profundidad.
4. Source, References, scripts de producción y project.godot son archivos de autoría; no hacen falta para ejecutar el personaje ni deben sustituir los controladores.

## Cómo se produjo

Los primeros intentos de generar las 12 fases completas no mantuvieron el apoyo uniforme. Se conservaron como `Source/walk_draft_01.png` y `walk_draft_02.png`; **no son los atlas finales**.

La entrega usa recortes raster dibujados mediante image_gen, con su textura artesanal y contornos grises. `Source/parts_original.png` y `headparts_original.png` son las salidas originales intactas; los prompts completos están al lado. Un montaje independiente en Godot mueve y deforma esas texturas raster para fijar los apoyos y cerrar el ciclo. No son sustitutos vectoriales del lobo. Los scripts de producción viven exclusivamente dentro de esta carpeta y no forman parte del juego.

El montaje final mantiene una escala fija para las piezas y una única escala de render durante todos los cuadros de las tres animaciones. La cola y la bufanda usan funciones periódicas; un cuadro virtual 13, generado aparte solo para QA, coincide exactamente con el 1. No se incluye ese cuadro duplicado en walk.

Para reproducir la producción dentro de este proyecto independiente: ejecutar `Source/prepare.gd` y `Source/prepare_heads.gd` con Godot; después `Source/render_walk.gd` con render gráfico OpenGL; ejecutar `Source/build_resource.py` y `Source/qa_and_previews.py` con Python y Pillow/Numpy. El render final sobrescribe los cuadros provisionales creados durante prepare. `look_draft_packing_metrics.json` describe únicamente ese borrador, no el atlas final. Los scripts no requieren leer ni escribir el juego principal.

La autoría es un montaje de recortes texturizados, con menos variación de dibujo entre fases que las propuestas generadas una a una. Requiere aceptación visual del usuario; la precisión del apoyo no equivale a aprobación artística. Referencias de v004 conservadas en References.

## Comprobaciones

Godot 4.7.2: importación, carga de Wolf.tres, regiones del atlas y ejecución de preview comprobadas. `Godot/Verify.gd`: PASS. `Source/qa_and_previews.py`: PASS para suelo, márgenes, desplazamientos, cierre y coincidencia de endpoints de mirada. El GIF de walk tiene 12 cuadros y dura 1250 ms.

Las ejecuciones headless emitieron el aviso de certificados y el editor restringido no pudo guardar preferencias en AppData. El render de sprites con OpenGL terminó correctamente. No se afirma que este paquete ya esté integrado o probado dentro del controlador del juego.
