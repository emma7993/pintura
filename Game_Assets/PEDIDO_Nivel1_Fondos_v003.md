# Pedido para ChatGPT — Nivel 1: la casa lejana y el subsuelo (Fondos_v003)

Claude ya arregló el fondo del Nivel 1 por script (`herramientas/fondos_camino_v002.py`). Los bocetos
llevan relleno blanco, los definidos tienen un solo tono, y la lejanía va en una capa: camino, casa y faro.
Faltan dos cosas que solo se pueden dibujar:
1. **La casa** de la pintura. Ahora ocupa su lugar la cabeza dormida.
2. **El subsuelo**: la tierra bajo el suelo donde camina el lobo y las paredes de la cueva. Hoy es un
   relleno liso con rayas dibujadas por código.

Todo va en dos estados, igual que `Cueva_v002/estados_v001`:
- **boceto**: antes de pintar la puerta. Lápiz gris sobre blanco, y el interior de cada forma RELLENO DE
  BLANCO PAPEL, opaco. No debe quedar transparente: si no, se ven a través las capas de atrás.
- **definido**: después. Grafito terminado, con sombras, en el mismo tono cálido de las capas ya
  integradas: sepia muy suave, no gris frío ni azulado.

## Cómo usarlo
1. Abrir un chat nuevo de ChatGPT y adjuntar como referencia (en `pintura/`):
   - `art/worlds/camino/nivel_01_fondos_v002/boceto/10_faro_lejano.png` y
     `definido/10_faro_lejano.png` (estilo y tono de los dos estados).
   - `art/worlds/camino/nivel_01_fondos_v002/definido/05_terreno_vegetacion.png` (tono del suelo).
   - `docs/diseno/portada_immix.jpg` (la pintura: la casa está en el centro, sobre la roca de la cascada).
2. Pegar el mensaje de abajo.
3. Guardar los PNG, sin editar, en `Game_Assets/Nivel_01_Camino/Fondos_v003/boceto/` y `/definido/`, con
   los nombres indicados. Agregar una lámina `comparacion.png` con boceto y definido lado a lado.
4. Subir y avisar a Claude.

---

## Mensaje para ChatGPT

Vamos a hacer piezas de fondo para un videojuego 2D de plataformas visto de lado. Todo está dibujado a
lápiz de grafito sobre papel, como las imágenes adjuntas. Cada pieza va en DOS versiones con la misma
silueta y en el mismo lugar del lienzo:
- boceto: línea de lápiz gris, suelta, con poco rayado. El interior de la forma va relleno de blanco papel
  opaco, como en el faro adjunto. No lo dejes transparente.
- definido: el mismo dibujo terminado en grafito, con sombras suaves y textura, en tono sepia cálido muy
  claro, igual que el faro definido y el terreno adjuntos. No uses gris frío, azul, color, negro puro ni
  piedra renderizada en 3D.

Vista lateral plana. Diseño original. Sin texto, firma, marco ni números.

1. `11_casa_lejana.png` — PNG transparente de 1774x887. La casa de la pintura adjunta: la pequeña
   construcción de piedra en el centro, sobre la roca de donde sale la cascada. Se dibuja como se vería a lo
   lejos: la casa sobre su peñasco, con la cascada cayendo debajo, ocupando unos 640 px de ancho y apoyada
   en la parte de abajo del lienzo. Mismo tamaño y nivel de detalle que el faro adjunto.

2. `12_subsuelo.png` — PNG cuadrado de 1024x1024, SIN transparencia, repetible como mosaico por los cuatro
   lados. Es la tierra y la roca vista en corte, bajo el suelo donde camina el personaje: estratos
   horizontales suaves, algunas piedras y raíces sugeridas, grietas finas. Tono parejo en toda la imagen,
   sin bordes, sin viñeta y sin ningún elemento grande que llame la atención. En boceto, papel blanco con
   líneas de lápiz claras; en definido, el tono de la piedra del suelo adjunto, un poco más oscuro.

3. `13_subsuelo_borde.png` — PNG transparente de 1024x256, repetible en horizontal. Es la franja de
   arriba del subsuelo: la orilla de tierra justo bajo la losa del suelo. Arriba, raíces finas, piedritas y
   un borde irregular que se funde hacia abajo con la textura 12. Que empate sin costura con la imagen 12.

4. `14_cueva_pared.png` — PNG de 1024x1024, SIN transparencia, repetible como mosaico. Es la pared del
   fondo dentro de la cueva, detrás del personaje. Como la 12, pero más oscura y con menos detalle, para
   que se lea como fondo. Boceto: blanco con un gris muy leve. Definido: sepia un poco más oscuro que la 12.

Antes de entregar, pon cada boceto junto a su definido y confirma tres cosas: misma silueta, el boceto
relleno de blanco (no transparente) y el definido en el mismo tono cálido que el faro adjunto. Las
texturas 12, 13 y 14 deben repetirse sin que se note la costura.
