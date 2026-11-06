# Pedido: Wolf_Run_v022 — solo las manos en punta

La v021 dejó bien la **bufanda** (1375–1484 px², con sus flecos) y la **limpieza**. Los **brazos** salieron
negro sobre negro, casi sin contorno, con pedacitos sueltos junto a la espalda; en el GIF aparecen y
desaparecen. Claude armó la base buena: v021 con los brazos de v016 puestos de vuelta dentro de
`Source/Masks/NN_brazos.png` (fuera de la máscara de bufanda). Es lo que hace `herramientas/ajustar_run.py`,
sin el grano. Ya está en el juego.

## Base
Arma los ocho cuadros así (con script, sin regenerar nada):
`v021` y, donde `Masks/NN_brazos.png` está encendida y `Masks/NN_bufanda.png` no, los píxeles de `v016`.
Trabaja SOLO sobre esos ocho PNG.

## Única corrección: la punta de las manos
Los brazos de v016 se quedan donde están, con su forma, su grosor y su contorno gris completo: se leen bien
y se mueven bien. Solo cambia el **extremo de cada brazo** (los últimos ~12 px): en vez de terminar romo o
en muñón, que se afile en una punta, como las manos del salto (`Wolf_Salto_v004/Sprites/02_jump_up.png`).
- La punta conserva el contorno gris claro alrededor, igual que el resto del brazo.
- No rellenes el brazo de negro encima del contorno ni borres la línea gris que lo separa del torso: eso
  fue lo que hizo desaparecer los brazos en v021.
- No dejes trazos ni manchas negras sueltas junto a la espalda o la cola.
- Nada fuera de las puntas cambia: compruébalo píxel a píxel contra la base.

## Comprobación
Lámina de los ocho cuadros: base y v022 lado a lado, con zoom de las manos. Y el GIF a 20 fps sobre crema,
revisado cuadro por cuadro: los dos brazos se ven en todos los cuadros y no parpadean.

## Formato
8 PNG transparentes de 384x384, mirando a la derecha, pies en (192,352), 20 fps. Entregar en
`Game_Assets/Wolf_Run_v022/Sprites/run/01..08.png` con la lámina, el GIF e `INTEGRACION_CLAUDE.md`. Sin grano
nuevo (lo pone Claude).
