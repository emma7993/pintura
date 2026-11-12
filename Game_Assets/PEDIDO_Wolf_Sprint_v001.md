# Pedido: Wolf_Sprint_v001 — sprint, derrape y voltereta

El juego ya tiene el sprint de Hornet (mantener el dash), el derrape al girar y el salto largo con voltereta.
Por ahora usan poses prestadas (la carrera v027 inclinada, la pose de aterrizaje y la pose de la cima girando).
Este pedido es para darles su propio dibujo. Leer antes `Game_Assets/GUIA_LOBITO.md`.

## Método (el que funcionó con el salto v004 y la carrera v027)
Dibujar al personaje COMPLETO en una sola hoja, con estas imágenes adjuntas como referencia de modelo:
- `Game_Assets/Wolf_Run_v027/` (carrera aprobada: mismo tamaño, brazos, ojo abierto y bufanda)
- `Game_Assets/Wolf_Salto_v004/Sprites/03_jump_apex.png` (brazos en punta y cola)

No armar collages ni recortar piezas. Después, solo ediciones puntuales sobre la misma hoja.

## Se conserva (igual que la carrera v027)
Tamaño y masa del cuerpo, cabeza chica, ojo blanco pequeño y abierto, orejas con triángulo gris, contorno gris
fino completo, carbón RGB 32–41 con grano suave, bufanda roja ~RGB 153,50,47 del mismo tamaño (no más grande),
cola grande y esponjada con punta gris clara, brazos delgados que terminan en punta.

## Animaciones
1. **`sprint`** — 8 cuadros en bucle a 24 fps, mirando a la derecha. Es la carrera v027 llevada al límite:
   torso inclinado unos 35–40° hacia adelante (casi horizontal), cabeza adelantada y baja, brazos echados
   hacia atrás, zancada muy larga (pierna de atrás estirada, la de adelante con la rodilla alta), bufanda y
   cola estiradas hacia atrás en horizontal. El pie apoyado retrocede de forma pareja (~78 px de celda por
   cuadro). Dos fases en el aire (cuadros 04 y 08).
2. **`skid`** (derrape) — 3 cuadros, sin bucle, a 12 fps: frena en seco con el cuerpo echado hacia atrás, pies
   por delante clavados en el suelo, rodillas flexionadas, un brazo adelante para equilibrarse; la bufanda y la
   cola siguen de largo hacia adelante por la inercia. Mira en la dirección en la que venía corriendo.
3. **`flip`** (voltereta) — 6 cuadros, sin bucle, a 18 fps: una vuelta completa hacia adelante en el aire, con
   el cuerpo recogido en bola (rodillas al pecho), girando 60° por cuadro; la bufanda y la cola forman un arco
   alrededor del cuerpo. El cuadro 01 enlaza con `jump_apex` y el 06 con `fall`.

## Formato
PNG transparente de 384x384 por cuadro, misma escala que la carrera v027. Pies en (192,352) en `sprint` y
`skid`; en `flip`, el centro del cuerpo en (192,247) en los seis cuadros. Entregar en
`Game_Assets/Wolf_Sprint_v001/Sprites/sprint/01..08.png`, `skid/01..03.png` y `flip/01..06.png`, con un GIF de
cada animación, una lámina junto a la carrera v027 y el salto v004, e `INTEGRACION_CLAUDE.md` con el avance por
ciclo medido del sprint.
