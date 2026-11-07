# Pedido para ChatGPT — Nivel 1: profundidad de la cueva y plataformas variadas (Cueva_v003)

Hoy la cueva del Nivel 1 (del lago de tinta a la cámara de la paleta) tiene una sola pared de fondo
(`14_cueva_pared`) en mosaico: se ve plana. Para que se sienta profunda, con más cosas a lo lejos, el fondo se
arma con **tres capas de parallax**, que se mueven a distinta velocidad al correr:

| Capa | Se mueve con la cámara | Qué lleva |
|---|---|---|
| Lejana | ~20 % | lo más hondo: cavernas enormes, columnas y bruma; casi sin detalle, la más clara |
| Media | ~50 % | arcos de roca, pilares, escaleras en ruinas, raíces; detalle medio |
| Cercana | ~80 % | estalactitas y rocas que enmarcan arriba y abajo; la más oscura y detallada |

Tres capas es lo normal (Hollow Knight usa de tres a cinco). Con eso basta para que se lea la profundidad. La
capa de primer plano (rocas que pasan delante del lobo) es opcional; se puede pedir después.

La Zona de enemigos también es cueva: usará estas mismas tres capas, así que no necesita un fondo aparte.

Además se piden variaciones de las plataformas del nivel, para intercalarlas y que no se repita siempre la
misma piedra.

Mismas reglas que `fondos_unificados_v001`:
- dos estados con la misma silueta y la misma máscara alfa;
- boceto: gris neutro, interior relleno de blanco papel opaco;
- definido: el mismo sepia claro de la entrega anterior.

## Cómo usarlo
1. Abrir un chat nuevo de ChatGPT y adjuntar, de `Game_Assets/Nivel_01_Camino/fondos_unificados_v001/`:
   - `definido/camino/14_cueva_pared.png` y `boceto/camino/14_cueva_pared.png` (tono de la cueva);
   - `definido/camino/06_cueva_modulos.png` (techo con estalactitas y la entrada de cueva con escaleras);
   - `definido/camino/05_terreno_vegetacion.png` y `definido/camino/07_pozo.png` (plataformas de hoy);
   - `definido/cueva_paleta/01_vista_general.png` (cámara de la paleta).
2. Pegar el mensaje de abajo.
3. Guardar en `Game_Assets/Nivel_01_Camino/cueva_v003/boceto/` y `/definido/`, con `comparativas/` (un montaje
   de las tres capas encimadas) y unas notas para Claude.

---

## Mensaje para ChatGPT

Seguimos con los fondos del juego 2D de plataformas de lado, en el mismo estilo de las imágenes adjuntas. Cada
pieza va en dos estados con la misma silueta, el mismo tamaño y la misma máscara alfa:
- boceto: línea de lápiz gris, interior relleno de blanco papel opaco;
- definido: el mismo dibujo terminado en el sepia claro de las piezas adjuntas, sin gris frío ni color.

Diseño original. Sin texto, firma ni marco. Sin personajes.

**Parte 1: fondo de la cueva en tres capas de parallax.** Es una cueva subterránea enorme, vista de lado. Las
tres capas se encima una sobre otra y deben sentirse muy profundas, como si la cueva siguiera lejos hacia
adentro. Cada capa se repite en horizontal sin costura (la columna de la izquierda empata con la de la derecha).
El suelo por donde camina el personaje queda a 3/4 de la altura de cada imagen.

1. `24_cueva_lejana.png`: PNG de 2048x1024, sin transparencia.
   - Es lo más hondo de la cueva: cavernas enormes una detrás de otra, columnas de roca altísimas, un lago
     subterráneo muy lejano, rayos de luz tenue que bajan de grietas del techo y bruma.
   - Poco detalle y poco contraste: es la capa más clara y se lee lejana.
2. `25_cueva_media.png`: PNG transparente de 2048x1024.
   - Plano medio: arcos naturales de roca, pilares, estalagmitas, una escalera de piedra en ruinas que sube a
     ninguna parte, raíces que cuelgan.
   - Detalle medio, un poco más oscura que la lejana.
   - Deja huecos transparentes amplios entre las formas para que se vea la capa lejana detrás.
3. `26_cueva_cercana.png`: PNG transparente de 2048x1024.
   - Enmarca la vista: estalactitas grandes que cuelgan de la orilla de arriba y rocas y estalagmitas que
     salen de la orilla de abajo.
   - La franja del centro, entre el 30 % y el 70 % de la altura, queda transparente: ahí corre el personaje.
   - Es la capa más oscura y con más detalle.

**Parte 2: variaciones de las plataformas.** Para intercalarlas con las que ya hay y que el nivel no se vea
repetido. Misma escala, mismo grosor y misma línea de pisada (la orilla de arriba, plana) que las adjuntas.
Todas en PNG transparente; cada una en su propio archivo, con la orilla de arriba recta y a la misma altura
dentro de su archivo.

4. `27_piedra_flotante_a.png`, `_b.png` y `_c.png` (512x256 cada una): tres variaciones de la piedra flotante
   de `05_terreno_vegetacion`. Una con musgo y una raíz que cuelga, otra más rota, en dos trozos juntos, y otra
   con una mata de pasto encima.
5. `28_repisa_a.png`, `_b.png` y `_c.png` (768x192 cada una): tres variaciones de la repisa larga de
   `07_pozo`. Una de losas de piedra labrada, otra de roca natural con grietas y otra con una viga de madera
   vieja debajo.
6. `29_suelo_cueva_a.png`, `_b.png` y `_c.png` (1024x256 cada una): tres tramos del suelo de la cueva que se
   puedan poner uno tras otro en cualquier orden. Todos empatan en sus bordes izquierdo y derecho a la misma
   altura. Uno con piedras sueltas, uno con charcos secos y uno con raíces que salen del suelo.

Antes de entregar, revisa cuatro cosas:
- en cada pieza, el boceto y el definido tienen la misma silueta;
- los bocetos están rellenos de blanco;
- 24, 25 y 26 se repiten sin costura en horizontal;
- las tres capas encimadas se leen de lejos a cerca: la lejana clara y suave, la cercana oscura y detallada.
