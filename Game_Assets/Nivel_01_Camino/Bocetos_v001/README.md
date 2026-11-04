# Nivel 1 — Camino: bocetos de grafito v001

Selección específica solicitada el 2026-11-02. Un cuadro casi blanco que apenas empieza a dibujarse: líneas difusas, abiertas y monocromas; mucho espacio sin marcar. Las formas vienen de la pintura completa: nubes y sol, acueducto, faro, bosque y orilla.

## Ver el parallax

Abrir este `project.godot` como proyecto independiente en Godot 4.7.2 y pulsar F5. Flechas izquierda/derecha recorren 4200 px de montaje visual. El lobo V4 se incluye solo para comparar escala y legibilidad; esta preview no modifica su controlador ni simula las colisiones del juego.

También hay una copia utilizable dentro del proyecto principal en `art/worlds/camino/nivel_01_bocetos_v001/`. Abrir su `Godot/Preview.tscn` y pulsar F6. `Godot/Environment.tscn` es el montaje reutilizable sin controles ni interfaz de preview. No se cambia automáticamente la escena del juego principal: esta entrega queda preparada para el nivel 1, como solicitaste.

## Carpetas

| Carpeta/archivo | Contenido |
| --- | --- |
| `Fondos/` | Tres PNG RGBA panorámicos independientes, 1774×887 |
| `Modulos/` | 16 PNG RGBA de 256×256 y atlas 1024×1024 |
| `Godot/Environment.tscn` | Montaje de fondo y módulos con Parallax2D |
| `Godot/Preview.tscn` | Cámara móvil y lobo para inspección |
| `Previews/scene_01.png` a `scene_04.png` | Capturas reales de Godot |
| `Source/` | Original de generación, prompts, empaquetador y QA |
| `Referencias/` | Pintura completa, Camino inacabado y brief histórico |
| `inventory.json` | Rutas, dimensiones, encuadre y transparencia de los módulos |

## Capas

| Plano | Contenido | Movimiento horizontal relativo a la cámara | Orden Z |
| --- | --- | --- | --- |
| Base | Blanco roto casi neutro | Fijo en pantalla | CanvasLayer -100 |
| Lejano | `01_cielo_lejano.png`: nubes, disco solar y horizonte sugerido | 0.08 | -70 |
| Medio lejano | `02_acueducto_faro.png`: arcos, faro pequeño y olas | 0.23 | -50 |
| Medio | `03_bosque_orilla.png`: árboles y trazos de ribera | 0.48 | -30 |
| Jugable visual | Suelo y decoración a lápiz | 1.00 | -18 a -7 |
| Cercano | Juncos reutilizados, opacidad baja | 1.10 | 3 |

La velocidad vertical de las capas es 1.0 para seguir el encuadre del suelo. La base es un ColorRect: no se repite una textura de lienzo fuerte que compita con el dibujo. Las tres capas de fondo conservan alfa real entre líneas, sin rectángulos blancos superpuestos. En la preview usan opacidades de 0.30, 0.50 y 0.52; los trazos cercanos usan 0.20.

Los PNG transparentes pueden verse casi negros sobre un visor negro; revisar las capturas sobre blanco para apreciar el lápiz. El cielo es deliberadamente tenue, no una imagen vacía.

## Módulos

Suelo A–D; plataforma corta y larga; puente de tres arcos; pared; árbol izquierdo/derecho; juncos; piedras; lápiz; pedestal; arco de acceso; ancla. Todos son estados de boceto. `ground_d` tiene una subida en su contorno: se entrega, pero no se usa para el tramo horizontal continuo de la preview.

Son piezas de montaje con margen transparente; no se declaran tiles perfectamente conectables. Se pueden solapar o ajustar en el editor. El kit no incluye colisiones automáticas. Los trazos auxiliares y el antialias no deben convertirse en hitboxes.

## Integración para Claude

Instanciar `res://art/worlds/camino/nivel_01_bocetos_v001/Godot/Environment.tscn` dentro de la zona lateral. Configurar `ground_y` y `world_width` según el controlador; los valores iniciales son 600 y 4200. Ocultar los fondos y troncos provisionales al sustituirlos y conservar sus cuerpos de colisión hasta diseñar el mapa. `show_modules=false` permite usar únicamente las tres capas de fondo y montar el terreno de forma independiente.

El lápiz y pedestal de muestra son solo arte. Recogida, estados de restauración, inventario, progresión musical y persistencia corresponden a la integración de Claude. No se crean enemigos definitivos ni se fijan otros mundos.

## Validación y procedencia

Creado con image_gen integrado a partir de la pintura adjunta; prompts exactos en Source. El empaquetador Godot recorta la cuadrícula y redimensiona las celdas, sin dibujar ni reconstruir poses. Los originales se conservan. Los bocetos anteriores permanecen en `Game_Assets/Camino_World_v001/` como exploración; esta carpeta es la selección actual de nivel 1.

Importación y preview ejecutadas en Godot 4.7.2. `Source/verify.gd` comprueba los 16 módulos, alfa, encuadre y movimiento real de las cuatro capas: para 400 px de cámara los desplazamientos fueron -32, -92, -192 y -440 px. Resultado PASS. El grafito ocupa aproximadamente 2.1%, 3.0% y 4.4% de los fondos al medir alfa >0.02. Métricas en `Source/qa_metrics.json`.

Capturas inspeccionadas sobre blanco. Queda pendiente aprobación artística del usuario y revisar uniones de módulos al diseñar salas definitivas. Las capas se repiten aprovechando sus márgenes vacíos; no se afirma continuidad pictórica perfecta en cualquier encuadre.

Los tests headless emitieron un mensaje del entorno sobre el almacén de certificados, y el editor restringido no pudo guardar preferencias en AppData; no hubo errores de recursos o scripts. La captura gráfica con OpenGL se completó correctamente. No se hizo commit ni push.
