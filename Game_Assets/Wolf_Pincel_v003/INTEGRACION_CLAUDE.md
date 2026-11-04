# Wolf Pincel v003 — Pintura

Entrega de arte, 2026-11-03. Especificación vigente: pincel fino guardado en la espalda, celdas de 384×384 y nuevo conjunto de acciones. Las versiones anteriores quedan conservadas. No se integró en el juego ni se modificaron characters/, art/, código del juego o Git.

## Archivos, origen y capas

**18 animaciones, 101 cuadros de cuerpo, siete capas por cuadro: 707 PNG individuales.** Todas las celdas son RGBA de 384×384. Numeración desde 01; atlas horizontales sin separación en `Animations/<animacion>/<capa>_atlas.png`.

**Offset común: (-192,-352).** El suelo de referencia es y=352 y el personaje mira a la derecha. No recentrar ningún PNG por su área opaca; las transparencias son parte del registro. Las capas de un cuadro comparten exactamente la celda, escala y origen.

| Capa | Contenido |
|---|---|
| body | lobo completo, sin pincel |
| brush_back | argolla y extremo posterior del pincel guardado; vacío cuando está en la mano |
| brush_base | mango y virola en la mano; vacío cuando está guardado |
| tip_color | punta con restos de color, transformada a su ubicación de mano o espalda |
| tip_dry | misma punta seca, ya alineada |
| tip_ink | misma punta entintada, ya alineada |
| smear | estela blanca/gris transparente, solo en cuadros de impacto/pintura |

Orden usado: **brush_back → brush_base → una punta activa → smear → body**. Así la mano y el cuerpo quedan por delante del mango, y la estela no tapa la cara. No dibujar las tres puntas a la vez. Los PNG vacíos son intencionales y también tienen 384×384.

## Pincel fino y guardado

El original del pincel es nuevo: madera negra, virola corta, cerdas finas de pincel redondo y argolla metálica ovalada. No se calcó ni se utilizó el sprite de aguja de otro juego. El pincel en mano ocupa **215 px de extensión raster** y el mango mide aproximadamente **7 px de grosor**, según alfa>64, dentro del intervalo pedido de 6–8 px.

En la espalda se muestran únicamente los extremos. El tramo central está deliberadamente oculto: no exportar un mango flotando fuera de la silueta. **La vista guardada usa una proyección acortada de 0.53**, unos 114 px entre sus extremos proyectados, para que la argolla coincida con el hombro y la punta con la zona inferior de la cola. Al actuar, la proyección es completa, 215 px. Es una decisión de encuadre/perspectiva del dibujo guardado, no una escala que deba aplicar el juego otra vez. Si se exige también una longitud visible de 215 px estando guardado, hace falta revisar ese encuadre.

El estado de la punta también se ve guardado: elegir tip_color/dry/ink funciona en ambos lugares. `brush_back` contiene la base guardada; **no contiene una punta de color fija**. El JSON indica `weapon_location: back/hand` y `projection_scale` como documentación; las capas ya están renderizadas y no deben transformarse de nuevo.

## Animaciones y tiempo

| Animación | Cuadros | FPS | Bucle | Impacto / pintura / carga (1-based) |
|---|---:|---:|---|---|
| idle | 6 | 6 | sí | — |
| walk | 12 | 12 | sí | — |
| run | 8 | 16 | sí | — |
| jump_start | 2 | 12 | no | — |
| jump_up | 2 | 10 | sí | — |
| fall | 2 | 10 | sí | — |
| land | 2 | 12 | no | — |
| dash | 6 | 24 | no | — |
| wall_slide | 4 | 8 | sí | — |
| wall_jump | 4 | 16 | no | — |
| slash_side | 7 | 20 | no | 3–4: golpe/pintura |
| slash_up | 7 | 20 | no | 3–4: golpe/pintura |
| slash_down | 6 | 20 | no | 2–4: golpe; no pinta |
| paint_rise | 8 | 12 | no | 4–6: pintura |
| paint_up | 8 | 12 | no | 4–6: pintura |
| dip | 6 | 10 | no | 4–5: carga tinta |
| hurt | 3 | 14 | no | — |
| death | 8 | 10 | no | último cuadro totalmente transparente |

Walk conserva las manos al pecho, postura erguida y ojos blancos entrecerrados. Run inclina el cuerpo, mantiene las manos recogidas y hace ondear la bufanda. Se conserva la expresión estrecha pedida en esta especificación; el PDF del usuario se conserva como referencia facial en References, incluida su forma pequeña de ojo abierto para otras variaciones.

El pincel permanece guardado en reposo y locomoción, salto, dash, pared, hurt y death. En slash_side/up/down, paint_rise/up y dip aparece en la mano desde el **cuadro 1**. Regresa a la espalda en los últimos dos cuadros, excepto dip: sigue en la mano hasta cargar en el 5 y vuelve a la espalda en el 6. En death, el pincel cae con la pose y se desvanece junto al cuerpo; no queda un objeto flotando al terminar.

Los tajos side/up duran 0.35 s a 20 FPS y sus dos cuadros de golpe duran 0.1 s en total. Dash dura 0.25 s. Las acciones de pintura son algo más largas para leer la trayectoria. Para caminar a 0.8 ciclos/s, usar speed_scale=0.8 sobre los 12 FPS del recurso: ciclo de 1.25 s. El GIF usa ese tiempo. No confundir el bucle del GIF de revisión con las animaciones de acción, que no tienen bucle en SpriteFrames.

## Contactos, golpe y máscaras

`brush_contacts.json` y `.csv` tienen un registro por cada cuadro, incluidos los guardados. Conservan grip_xy, angle_degrees_clockwise, tip_xy, contact_by_state_xy/color/dry/ink, paints, receives_ink y añaden **hitbox [x,y,w,h]**, hits, weapon_location, grip_role, canonical_grip_x, projection_scale y opacity.

Coordenadas locales desde arriba izquierda de celda, +x derecha, +y abajo. Ángulos positivos giran hacia abajo. Los índices empiezan en **1**; restar uno al usar directamente el frame de AnimatedSprite2D.

`grip_xy` es el agarre de la mano en los cuadros de acción. Cuando está guardado, `grip_role` vale storage_anchor: es el ancla de colocación en la espalda, no una mano. `tip_xy` es el extremo geométrico; `contact_by_state_xy` mide el extremo realmente visible de cada punta raster. El agarre fue colocado sobre las manos dibujadas y puede deslizarse sobre el mango entre poses; no es un rig físico ni hay pivote de mano único para todas las acciones.

- **paint_rise**, cuadros 4–6: punta (340,352) → (310,300.0385) → (190,92.1924). Recta hacia arriba y atrás, dirección en pantalla -120°, equivalente a 60° sobre la horizontal hacia atrás. Los tres primeros cuadros preparan con la punta baja y los últimos recuperan/guardan.
- **paint_up**, cuadros 4–6: x=330 constante, y=352 → 230 → 80.
- **dip**, cuadros 4–5: contacto del extremo cerca de (310,352), en el suelo delante. No pinta.
- **slash_side/up**: golpe y pintura en 3–4, con estela separada. **slash_down**: golpe en 2–4 para rebote aéreo; la velocidad del rebote y sus condiciones las programa Claude.

Los hitbox son rectángulos locales orientativos que cubren el tramo delantero entre agarre y punta, con margen de 12 px y límites dentro de la celda. Se incluyen solo durante los cuadros activos. No usarlos como colisión permanente ni interpretar paints=true como disponibilidad de una carga: punta seca, inventario y consumo de pintura corresponden al código del juego.

Smear está en blanco/escala de grises, con alfa transparente. Teñir únicamente esa capa con la carga activa; no teñir el cuerpo. Para revelar óleo, interpolar estampas a lo largo de la trayectoria entre contactos: una sola estampa por cuadro puede dejar huecos en paint_rise. El movimiento acelera durante la subida; no se afirma velocidad uniforme de la punta.

## Verificación y límites

`VALIDACION.json` registra los tamaños, conteos, alturas, suelo real por cuadro y centro de la cabeza. Idle/walk/run quedan dentro de **216 ±3 px** de alto. Todos los cuadros apoyados medidos terminan en **y=352**. Los cuadros aéreos y la desintegración tienen su ancla lógica en ese mismo origen, aunque la pose o los fragmentos no constituyan un apoyo físico.

La cabeza se mide segmentando el núcleo oscuro conectado de la cabeza, excluyendo contorno gris, bufanda y cola. El informe incluye desviación respecto a la media y diferencia entre vecinos, **incluido el cierre último→primero**. Walk pasa el límite de 2 px y run el de 3 px; idle y los cuadros de pies juntos 4/10 de walk coinciden dentro de 2 px. `Previews/*_head_QA.png` muestra la máscara cian y su centro rojo para auditar el resultado.

Se conserva una figura completa en cada pose; se aplicó registro uniforme del conjunto, sin reconstruir patas, cabeza o torso por piezas. El informe de Source/body_registration.json contiene las escalas por cuadro. La ilustración generada puede variar ligeramente detalles internos de textura y proporción; revisar la actuación en los GIF antes de integrarla.

Las zancadas se estiman sumando la máxima apertura de los grupos de pies en cada medio ciclo (dos pasos). La carrera tiene aperturas diferentes en sus dos apoyos; el informe conserva también el doble de la apertura mayor como estimación conservadora de pasos simétricos. Esa lectura puede perder parte de una fase aérea y **no certifica velocidad constante del pie apoyado**. Los valores obtenidos están en VALIDACION.json; calibrar velocidad de mundo y FPS al integrar, especialmente la carrera. No se aumentó la velocidad del jugador ni se modificó programación.

## Godot, revisión y fuentes

`Godot/` contiene Wolf_body.tres, Wolf_brush_back.tres, Wolf_brush_base.tres, Wolf_tip_color.tres, Wolf_tip_dry.tres, Wolf_tip_ink.tres y Wolf_smear.tres. Todos contienen las mismas 18 animaciones y 101 cuadros para sincronización directa. Las rutas son relativas, con las mismas mayúsculas para Windows y Mac.

Abrir **este project.godot independiente** y ejecutar `Godot/Preview.tscn` con F5/F6. Flechas cambian acción; 1/2/3 seleccionan color/seco/tinta; Espacio repite; H muestra contactos e hitbox. El `.gdignore` de Game_Assets permanece intacto: el F5 del juego principal no activa esta entrega.

`Previews/` contiene GIF, hojas de contacto, versiones del cuerpo solo y QA de cabeza. Los fondos crema y las marcas no forman parte del PNG del personaje. Los GIF redondean tiempos a centésimas; los FPS exactos están en los recursos.

`Source/` conserva los originales sin retocar, prompts de image_gen integrado y scripts de registro, capas, empaquetado y medición. Algunas hojas fuente incluyen una celda de relleno que no se exportó. Los diseños, poses y cuadros son originales; las referencias de otros juegos se utilizaron como indicación de género y no se incorporaron como sprites jugables.


## Resultado final de revisión

Zancada estimada por suma de aperturas: walk **153 px/ciclo**, run **302.5 px/ciclo**, frente a objetivos aproximados de 145/300. Desplazamiento máximo entre centros de cabeza consecutivos, incluido el cierre: walk **0.462 px**, run **2.984 px**.

Godot 4.7.2 importó y cargó los 707 cuadros de las siete capas; el preview gráfico se renderizó correctamente. Los avisos de certificados y preferencias del usuario provienen del entorno headless restringido; no hubo errores de recursos o scripts en la comprobación final.
