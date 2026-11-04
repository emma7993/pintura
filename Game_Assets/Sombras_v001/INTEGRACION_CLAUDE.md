# Sombras v001 — Nivel 1: Camino

Entrega de arte original, 2026-11-03. **No está integrada en el juego.** No se tocaron characters/, art/, código del juego ni Git. Los scripts de esta carpeta solo producen o revisan arte de forma independiente.

## Manos y anclas

PNG RGBA de 256×512, numerados desde 01. Atlas horizontales sin separación. Rutas `Manos/A/<animacion>/`, `Manos/B/...`, `Manos/C/...`. Se conserva una escala de objeto común para todas las animaciones de cada diseño; las poses de emerger no se normalizan a la altura de la mano completa.

| Diseño | Carácter | Ancla local (x,y) | Alto al emerger |
|---|---|---|---:|
| A | delgada, larga, dedos y filamentos nerviosos | (128,480) | 380 px |
| B | pesada, base gruesa y garras | **(64,480)** | 348 px |
| C | pequeña y rápida | (128,480) | 310 px |

**B tiene el ancla más a la izquierda** para que el zarpazo grueso quepa sin cortar sus garras. Aplicar offset negativo de la ancla correspondiente, no usar (-128,-480) para todas. No recentrar los cuadros por área opaca. Las tres miran a la derecha y mantienen la misma base en el suelo.

| Animación, para A/B/C | Cuadros | FPS | Bucle |
|---|---:|---:|---|
| emerge | 8 | 12 | no |
| reach | 8 | 10 | sí |
| grab | 6 | 14 | no |
| sink | 6 | 12 | no |
| dissolve | 8 | 12 | no |

Los atlas de emerge/reach/dissolve son 2048×512; grab/sink, 1536×512. `reach` usa cinco poses dibujadas en ida/vuelta: 1,2,3,4,5,4,3,2; así el siguiente cuadro 1 cierra el tanteo sin un reinicio de pose. `sink` vuelve por seis fases de emerge. Los originales completos de ocho poses de reach se conservan en Source.

`grab` golpea únicamente en **cuadros 3 y 4** (índices desde 1; en Godot serían 2 y 3). `hand_contacts.json` y `.csv` incluyen el contacto activo y los extremos de los dedos por cuadro de reach/grab. Coordenadas locales de la celda, +x derecha, +y abajo. `primary_tip_xy` y `contact_xy` son el borde más adelantado de la silueta, útil como punto de golpe. `fingertips_xy` son candidatos medidos en extremos del contorno, no articulaciones de un esqueleto: en una garra curvada el extremo delantero puede no coincidir con la punta anatómica. Revisar `Previews/*_contacts_QA.png` antes de asignar un hitbox fino a cada dedo; no usar todos esos puntos como daño automático.

## Charco común separado

`Manos/Puddle/01..08.png`: 384×96; atlas `puddle_loop_atlas.png`, 3072×96. 8 FPS en bucle, periodo 1 s. El alfa y el borde exterior son idénticos en todos los cuadros; los brillos y las burbujas tienen variación periódica.

La ancla real del charco se registra en `VALIDACION.json` como `puddle_anchor_xy`. Colocarla en la misma posición mundial que la ancla de cada mano. Esto mantiene el pie común sin necesidad de incluir el charco en los PNG de brazo. El preview ya hace esta composición.

En dissolve los fragmentos se borran y el último cuadro del brazo es transparente; desaparece su contacto visible con el suelo, pero **el charco sigue separado y conserva el suelo en y=480**. El JSON informa tanto el ancla lógica como el último píxel visible de cada cuadro, sin presentar el cuadro vacío como si tuviera pies.

## Bruma

| Recurso | Ruta | Tamaño/cuadros | FPS | Bucle |
|---|---|---|---:|---|
| front_loop | Bruma/Front/ | 512×1024, 8 | 8 | sí |
| body | Bruma/body.png | 512×1024, 1 | 1 | textura repetible |
| wisps 01–06 | Bruma/Wisps/01..06/ | 128×128, 6 cada uno | 10 | no |
| eyes 01–03 | Bruma/Eyes/01..03/ | 128×64, 4 cada par | 6 | sí |
| recoil | Bruma/Recoil/ | 512×1024, 6 | 12 | no |

Atlas horizontales: front_loop 4096×1024, recoil 3072×1024, cada wisp 768×128 y cada par de ojos 512×64. Los ojos siguen abierto/medio/cerrado/medio, con la misma ubicación dentro de la celda. Los jirones avanzan y se disipan; su último cuadro es transparente. `master.png` en las carpetas de wisps es la textura fuente, no un séptimo cuadro.

El lado izquierdo del frente es negro opaco y coincide exactamente en RGBA con el borde de body. Rellenar hacia la izquierda con body repetido en horizontal y vertical; el frente queda a la derecha del relleno. La velocidad de avance de la pared es movimiento del nodo, no del atlas. El frente tiene remolinos periódicos y jirones en su borde derecho. No escalar cada cuadro por separado.

`body.png` tiene costura de **0 niveles de diferencia RGBA** entre izquierda/derecha y arriba/abajo, verificada al píxel. Se preparó con reflexión y transición suave de borde sobre una textura original generada; no hay un borde gris brillante que revele el mosaico. Se incluye una vista de repetición para revisión.

Al tocar color, reproducir recoil y hacer retroceder el grupo bruma+relleno desde código. El recoil se desgarra y reduce su densidad; no tiene que seguir empalmando opaco con un relleno inmóvil al final. Coordinar la opacidad/posición del relleno con ese retroceso. La recuperación a front_loop y las colisiones quedan a cargo de Claude.

## Godot y vistas previas

`Godot/Sombras_Manos.tres`: A_emerge, A_reach, A_grab, A_sink, A_dissolve y equivalentes B/C, más puddle_loop. `Godot/Sombras_Bruma.tres`: front_loop, body, wisp_01..06, eyes_01..03, recoil. Los recursos usan rutas relativas y respetan mayúsculas para Windows/Mac.

Abrir el `project.godot` de esta carpeta como **proyecto independiente** de arte y ejecutar `Godot/Preview.tscn` con F5/F6. Se ven las tres manos junto al lobo y la bruma sobre el bosque de grafito. Teclas 1–5: emerge/reach/grab/sink/dissolve; R: recoil; F: volver al frente en bucle. No quitar el `.gdignore` de Game_Assets ni esperar un cambio en el F5 del juego principal.

`Previews/` incluye GIF y hojas de contacto de cada animación sobre crema (`*_crema`) y sobre Camino (`*_camino`). Los fondos, el lobo de referencia, números y marcas de QA no forman parte de los PNG del enemigo. Los GIF redondean los tiempos a centésimas; los FPS exactos están en SpriteFrames y en el JSON.

## Validación y originales

`VALIDACION.json` registra tamaños, conteos, FPS, bucles, anclas y el último píxel visible por cuadro. Manos emerge/reach/grab/sink: suelo medido y=480 en todos los cuadros. Disolución: ancla de suelo conservada, con fragmentos que se elevan y final vacío según se explicó. Front y charco tienen un cuadro virtual de cierre idéntico al primero (`closure_test.png`, no añadirlo como cuadro extra). Reach se cierra por la secuencia de ida/vuelta; ojos por la repetición del medio parpadeo.

La entrega contiene **116 cuadros de manos/charco y 63 de bruma**, 179 en total, además de atlas y fuentes. Los diseños y poses se generaron con image_gen integrado; las animaciones de humo, borrado, charco y retroceso se rasterizaron a partir de esas texturas mediante un render offline de Godot. No se integraron shaders en el juego.

`Source/` conserva originales sin retocar, prompts y scripts de empaquetado/render/validación. `References/` conserva las referencias de estilo y los diseños maduros A/B/C. La ilustración generada puede tener pequeñas variaciones de dedos y contorno; los ojos del dorso y la textura mantienen la identidad del diseño. No borrar fuentes al integrar.


Godot 4.7.2: importación, carga de todos los SpriteFrames y captura del preview comprobadas sin errores de recursos o scripts. El modo headless restringido emitió avisos del almacén de certificados y preferencias de Windows; la revisión gráfica se renderizó correctamente.
