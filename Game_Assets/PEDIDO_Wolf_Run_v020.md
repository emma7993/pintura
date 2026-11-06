# Pedido: Wolf_Run_v020 — corrección puntual de v019

v019 va por buen camino: figura completa dibujada de una vez, contorno gris en todo el cuerpo, manos en
punta, bufanda hacia atrás y buena carrera. **No la generes de nuevo.** Parte de Source/hoja_final.png de
v019 y haz solo las correcciones de abajo, con ediciones puntuales sobre esa misma hoja y ajustes por
script. Adjunta como referencia visual el caminado original (Wolf_Pincel_v003/Animations/walk/body) y el
salto v004. Autorizo los ajustes deterministas.

## Se conserva de v019 (no tocar)
Las ocho poses de piernas y brazos, la inclinación, el ancho (~164 px), el rebote de la cabeza, el registro
con pies en (192,352), el contorno del cuerpo, las manos en punta, el grano y el ojo abierto.

## Corregir con edición puntual (forma)
1. Cabeza: quitar los picos de pelo extra de la nuca. El original tiene UN solo mechón detrás de la cabeza.
   Cabeza, orejas y hocico con la misma forma que en el caminado; solo cambia el ojo, que va abierto.
2. Cola: igual a la del caminado. Que se curve hacia arriba y hacia atrás desde la cadera, esponjada y
   con tufos suaves y redondeados, no una brocha recta y horizontal con dientes negros afilados. Mismo
   tamaño que en el caminado (en v019 es cerca de 50% más larga). Solo cambia el ángulo según la pose.
3. Bufanda: con el volumen y los pliegues del caminado, no una cinta plana y rígida. La punta ondea hacia
   atrás con algo de curva y movimiento distinto en cada cuadro, y termina en los flecos deshilachados del
   original. Área roja de 1250–1550 px² (v019: 1120–1190).

## Corregir por script (números)
4. Ojo: reducirlo a 32–50 px² de blanco (v019: 56–60), pequeño y redondo como en el salto.
5. Carbón: oscurecer la mediana del cuerpo a 33–35 (v019: 39), sin cambiar el grano (4.3–5.7).
6. Tamaño: el lobo de v019 quedó cerca de 7% más bajo que el caminado (cuello a pies 138 contra 148). Ajustar
   la escala común para que el cuello a pies quede en 140–156 px, con los pies en (192,352).

## Antes de entregar
Pon la carrera junto al caminado y al salto a la misma escala y confirma a la vista que la cabeza, la cola
y la bufanda son las mismas del caminado. Luego corre herramientas/comparar_lobo.py: oreja a ojo 56–68 px,
ojo 32–50 px², bufanda 1250–1550 px², carbón 31–38, grano 4.3–5.7, contorno del cuerpo 85% o más.

## Formato (igual que v019)
8 cuadros en bucle a 20 fps, mirando a la derecha, PNG transparente de 384x384, pies en (192,352).
Entregar en Game_Assets/Wolf_Run_v020/Sprites/run/01..08.png, con la lámina caminado–salto–carrera e
INTEGRACION_CLAUDE.md con el avance por ciclo y las medidas.
