# Pedido: Wolf_Run_v021 — volver a v016 y corregir solo cuatro cosas

Emma eligió la carrera **v016** como la mejor (`Game_Assets/Wolf_Run_v016/Sprites/run/01..08.png`). Las
versiones v017 a v020 se descartan. Trabaja SOBRE los ocho PNG de v016.

## Regla principal
NO generes la carrera de nuevo y NO redibujes al personaje. Las poses, la zancada, la inclinación, las
proporciones, la cabeza, el ojo, las orejas, la cola, las piernas, el registro (pies en 192,352) y el
movimiento de v016 se quedan EXACTAMENTE como están. Al terminar, cada cuadro debe verse igual a v016
salvo los cuatro puntos de abajo.

## Solo estas cuatro correcciones
1. Brazos y manos (edición local, con máscara que solo deje tocar los brazos): en v016 los brazos parecen
   tiras pegadas sobre el torso. Redibújalos en el mismo lugar y la misma posición, del mismo carbón que el
   cuerpo, con el contorno gris solo en el borde exterior, y que terminen EN PUNTA como las manos del salto
   (`Wolf_Salto_v004/Sprites/02_jump_up.png`), sin puño redondo. En 06, el brazo de atrás no debe salir
   como un rectángulo fuera de la espalda: que apenas se asome detrás del torso.
2. Bufanda (por script): v016 la tiene cerca de 35% más grande que el caminado original. Redúcela para que
   el área roja quede entre 1300 y 1500 px², conservando su forma, su ondeo hacia atrás y sus flecos. La
   banda del cuello, un poco más delgada.
3. Grano (por script): v016 quedó plano (desviación ~2.7). Agrega el grano fino del caminado original
   hasta una desviación de 4.5 a 5.5 en el carbón del cuerpo, sin cambiar el tono (mediana 33–35).
4. Limpieza (edición local): borrar las rayitas grises sueltas bajo la cola y detrás del pie trasero en 01
   y 02, y la cuña negra suelta en el torso y la rodilla de 03.

## Comprobación
Pon v016 y v021 lado a lado: deben verse como el mismo dibujo, solo con brazos más limpios, manos en
punta, bufanda un poco menor, grano y sin manchas. Corre `herramientas/comparar_lobo.py` sobre la
carpeta nueva e incluye la tabla.

## Formato
Igual que v016: 8 PNG transparentes de 384x384, mirando a la derecha, pies en (192,352), 20 fps.
Entregar en `Game_Assets/Wolf_Run_v021/Sprites/run/01..08.png` con una lámina v016 junto a v021 e
`INTEGRACION_CLAUDE.md`.
