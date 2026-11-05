# Pedido para ChatGPT — Nivel 1: cueva, pozo, foso y puertas (Cueva_v002)

Reemplaza a `PEDIDO_Nivel1_Cueva_v001.md` (nunca se entregó). Ahora el arte lo genera ChatGPT y Claude lo
recorta, escala, hace repetibles las texturas y lo integra con un script en `herramientas/`. Por eso no se
piden medidas exactas por pieza ni animaciones cuadro por cuadro: solo hojas limpias con buen dibujo.

## Cómo usarlo
1. Abrir un chat nuevo de ChatGPT y adjuntar estas referencias (están en la Mac, en `pintura/`):
   - `Game_Assets/Nivel_01_Camino/Bocetos_v001/Previews/scene_02.png` (cómo se ve el nivel)
   - `Game_Assets/Nivel_01_Camino/Bocetos_v001/Modulos/modulos_atlas.png` (estilo de los módulos)
   - `Game_Assets/Nivel_01_Camino/Bocetos_v001/Referencias/IMMIX_Pintura_Completa.png` (la pintura)
2. Pegar primero el **Mensaje 0** y luego cada imagen (1 a 6) en un mensaje aparte.
3. Descargar cada imagen en PNG, sin editarla, a
   `Game_Assets/Nivel_01_Camino/Cueva_v002/` con el nombre indicado. Si una sale mal, pedir otra versión en
   el mismo chat y guardar la buena con el mismo nombre (las descartadas pueden ir en `Descartes/`).
4. Subir con `git add`, `commit` y `push`, y avisar a Claude.

---

## Mensaje 0 (estilo, pegar una vez)

Vamos a hacer piezas de escenario para un videojuego 2D de plataformas visto de lado. Todo el nivel es un
boceto a lápiz de grafito sobre papel casi blanco, como las imágenes que te adjunto: línea gris suelta,
trazos dobles exploratorios, líneas que se interrumpen, poco rayado, interiores sin rellenar. Nada de
pintura, color, piedra renderizada en 3D, masas negras ni sombras fuertes. Vista lateral plana, sin
perspectiva. Diseño original. Sin texto, firma, marco ni números. La parte de la cueva es igual de lápiz,
solo un poco más rayada y en un gris cálido. Cuando te pida "fondo transparente", entrega PNG con
transparencia real y deja separación clara entre piezas para poder recortarlas.

---

## Imagen 1 — `01_roca_corte.png` (cuadrada, sin transparencia)
Textura de roca vista en corte, para rellenar la tierra entre el suelo de arriba y el techo de una cueva.
Rayado de grafito diagonal y algunas grietas y piedras sugeridas con línea suelta, sobre papel crema
grisáceo claro y parejo. Tono uniforme en toda la imagen, sin bordes, sin viñeta, sin ningún elemento grande
que llame la atención: tiene que poder repetirse como mosaico.

## Imagen 2 — `02_cueva_fondo.png` (horizontal, sin transparencia)
Pared del fondo dentro de una cueva, vista de frente, para poner detrás del personaje. Papel gris cálido un
poco más oscuro que el de la roca, con grietas muy tenues, alguna veta y sombras suaves a lápiz. Muy poco
contraste (es un fondo lejano). Tono parejo de izquierda a derecha, sin suelo ni techo y sin bordes: debe
poder repetirse en horizontal.

## Imagen 3 — `03_cueva_modulos.png` (horizontal, fondo transparente)
Hoja de piezas de cueva a lápiz, separadas en una cuadrícula ordenada:
- Fila 1: tres tramos distintos del borde del techo de la cueva, horizontales y alargados, con estalactitas
  colgando de distintos largos. El borde de arriba es recto (ahí empalma la roca).
- Fila 2: tres tramos distintos de piso de cueva, horizontales y alargados, con la superficie pisable recta
  y clara arriba, y piedras y grietas por debajo.
- Fila 3: la boca de una cueva que se abre en el suelo (bordes de piedra rotos que caen hacia el hueco,
  vista de lado), y una pared lateral de cueva alta y angosta.

## Imagen 4 — `04_pozo.png` (horizontal, fondo transparente)
Hoja de piezas de un pozo antiguo de piedra a lápiz, vistas de lado, separadas:
- Brocal de pozo bajo y ancho (más ancho que alto) con una losa de piedra plana encima, cerrado.
- El mismo brocal sin la losa, abierto: el hueco queda vacío y transparente, sin relleno oscuro.
- La losa sola, caída y un poco inclinada sobre el suelo.
- Una repisa de piedra corta que sobresale de una pared (se pisa por arriba).
- Una tapa de piedra gruesa y horizontal vista desde abajo, con grietas.
- La misma tapa rota en 6 u 8 trozos separados entre sí (para animarla cayendo).
- Un tramo de pared interior del tiro del pozo, vertical, con piedras salientes, que pueda repetirse hacia abajo.

## Imagen 5 — `05_foso_y_plataformas.png` (horizontal, fondo transparente)
Hoja de piezas a lápiz, separadas:
- Una hilera horizontal larga de espinas de piedra para el fondo de un foso, todas de alturas parecidas,
  con las puntas entintadas en negro (lo único con tinta negra de toda la hoja). Que se pueda repetir.
- Los dos bordes rotos de un foso: borde izquierdo y borde derecho, como un corte de tierra que baja.
- Un escalón de piedra pequeño que flota en el aire (una sola piedra plana con raíces o grietas abajo).
- La cara izquierda y la cara derecha de una meseta de piedra alta, como acantilado bajo.

## Imagen 6 — `06_puertas.png` (horizontal, fondo transparente)
Hoja de tres puertas a lápiz, separadas, todas vistas de frente y apoyadas en el suelo:
- Un marco de cuadro antiguo de pie, vacío por dentro (transparente), que es la puerta para volver a la
  pintura. Moldura sencilla, más alto que ancho.
- Una puerta de madera pequeña y vieja dentro de la roca, con un aro de hierro como manija: la entrada al
  taller del copista, dentro de la cueva.
- La boca de un túnel en la roca, en arco, medio tapada por lianas con hojas que cuelgan del borde (las hojas
  son lo único con un poco de color: verde apagado de acuarela). Debe leerse que por ahí se puede pasar.

---

## Para Claude (integración)
Medidas en el juego, en px de mundo (de `zones/nivel_01_camino.gd`): roca entre el suelo alto (y≈516) y el
techo de la cueva (y=800); cueva de 450 px de alto (techo 800, suelo 1250); boca de la cueva 160 px de ancho;
pozo 220 px de ancho por dentro, con su tapa `PLUG` de 220×24; foso de 200 px con espinas de ~46 px;
escalón flotante de 170 px; meseta de 600×300; puerta del copista 100×170; marco de vuelta 120×190; paso de
hojas 120×250. El terreno se monta con los módulos ya escalados; no cambiar colisiones para ajustarse al
arte. Las texturas 1 y 2 se hacen repetibles en el script (mezcla de bordes) y la tapa rota se anima por
código con los trozos de la imagen 4. Copiar el resultado a `art/worlds/camino/nivel_01_cueva_v002/` y
reemplazar los dibujos provisionales (`_draw_rock`, `_draw_cave_back`, `_draw_terrain`, `_draw_leaf_passage`).
