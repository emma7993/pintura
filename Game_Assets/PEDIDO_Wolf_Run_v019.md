# Pedido: Wolf_Run_v019 — carrera dibujada como el caminado y el salto

=== GUÍA DEL LOBITO (aplica a este y a todos los sprites futuros) ===
Guía completa en Game_Assets/GUIA_LOBITO.md.

LOS DOS DIBUJOS QUE MANDAN
- Caminado original: Wolf_Pincel_v003/Animations/walk/body/01..12.png (y idle/body). Es EL personaje.
- Salto aprobado: Wolf_Salto_v004/Sprites/01..05. Mismo personaje en movimiento, con brazos delgados que
  terminan en punta y ojo abierto.
Todo sprite nuevo debe verse como un cuadro más de esas dos animaciones, hecho por el mismo dibujante.

RASGOS QUE NO CAMBIAN
- Cuerpo delgado pero con volumen, como el caminado: torso con forma, piernas finas con muslo, espinilla y
  pie bien dibujados (grosor de pierna 15–20 px). Ni de alambre ni panzón. Cabeza chica.
- Contorno gris claro y delgado alrededor de TODA la silueta: cabeza, torso, brazos, piernas y pies.
- Orejas con triángulo gris claro; un solo mechón detrás de la cabeza.
- Ojo blanco, pequeño y redondo; abierto desde que corre.
- Bufanda roja (~153,50,47) con pliegues; banda del cuello delgada; al correr ondea HACIA ATRÁS por la
  velocidad, no cuelga hacia abajo como al caminar. Mismo tamaño que en el caminado.
- Cola del original, grande y esponjada, punta gris claro amplia; nace de la cadera y sigue el movimiento.
- Manos en punta como en el salto: sin puños redondos ni mitones.
- Carbón RGB 32–41 con grano fino y suave.

=== PEDIDO v019 ===

QUÉ SALIÓ MAL EN v018 (no repetir)
Se recortaron la cabeza, la bufanda y la cola del caminado y se pegaron sobre un cuerpo dibujado aparte.
Las medidas de la cabeza salieron perfectas, pero el resultado es un collage: el cuerpo no tiene contorno
gris (solo 18–25% del borde, contra 90% en el original), las piernas son de alambre y sin pies, la pierna
de atrás parece una cola, los brazos casi no se ven, la bufanda cuelga como al caminar y la cola queda
suelta. No se ve como el lobo del caminado ni como el del salto.

MÉTODO (el mismo que funcionó con el salto v003/v004)
1. Adjunta a la herramienta de imágenes, como referencias visuales, una hoja con los cuadros del caminado
   original y la hoja del salto v004.
2. Dibuja al personaje COMPLETO (cabeza, bufanda, cola, torso, brazos y piernas juntos) en una sola hoja
   de 4x2 con las ocho poses de carrera. Nada de piezas pegadas.
3. Después, haz ediciones puntuales sobre esa misma hoja solo si hace falta: cola, bufanda, grano y ojo.
4. Antes de entregar, pon la carrera junto al caminado y al salto a la misma escala y confirma a la vista
   que es el mismo personaje y el mismo trazo. Luego mide con herramientas/comparar_lobo.py.

MOVIMIENTO: CARRERA NORMAL (NO SPRINT)
- Torso inclinado hacia adelante unos 15–20°, cabeza adelantada y un poco baja, mirando al frente.
- 01 y 05: la pierna de atrás se estira para empujar y la de adelante apoya un poco delante de la cadera.
  02 y 06: el pie apoyado queda bajo la cadera y la otra rodilla se dobla y viene al frente.
  03 y 07: la rodilla de adelante sube alto y el pie apoyado queda atrás. 04 y 08: vuelo corto.
- Brazos con codo doblado, alternados y opuestos a las piernas: uno adelante a la altura del pecho y el
  otro atrás junto a la cadera, ambos visibles, con la mano en punta.
- Ancho máximo 150–170 px. La cabeza sube y baja 3–5 px de forma pareja.
- Ligero, decidido y en control.

MEDIDAS QUE DEBEN DAR (comparar_lobo.py)
Oreja a ojo 56–68 px · ojo 32–50 px² · bufanda 1250–1550 px² · carbón 31–38 · grano 4.3–5.7 ·
área del cuerpo bajo la bufanda 3800–4600 px² · borde del cuerpo con contorno gris 85% o más.
Las medidas no sustituyen la comparación visual del paso 4.

FORMATO
8 cuadros en bucle a 20 fps, mirando a la derecha. PNG transparente de 384x384, pies en (192,352), misma
escala que el caminado. Apoyos en 01–03 y 05–07, vuelos en 04 y 08; el pie apoyado retrocede de forma
pareja. Entregar en Game_Assets/Wolf_Run_v019/Sprites/run/01..08.png, con la lámina caminado–salto–carrera
lado a lado, e INTEGRACION_CLAUDE.md con el avance por ciclo y las medidas.
