# Pedido: Wolf_Run_v018 — carrera normal con el modelo exacto del lobo original

Lee primero `Game_Assets/GUIA_LOBITO.md`: tiene las medidas del lobo original con sus rangos y los rasgos
que no cambian.

Referencias:
- Modelo (manda sobre todo): `Wolf_Pincel_v003/Animations/walk/body/01.png` e `idle/body/01.png`.
- Brazos y manos: `Wolf_Salto_v004/Sprites/02_jump_up.png` y `03_jump_apex.png`.

## Problema principal de v017: se perdió el modelo
Al rehacer las poses, el lobo se volvió otro personaje: cabeza cerca de 22% más grande, ojo 60–80% más
grande, cuerpo corto y grueso, piernas cortas siempre dobladas, contorno más grueso y picos de pelo extra
en la cabeza. Se ve cabezón y agachado.

**Cómo evitarlo:** toma la cabeza, la bufanda y la cola del caminado original a escala 1:1, sin redibujarlas.
Solo se gira la cabeza un poco hacia adelante, se ondea la punta de la bufanda y se cambia el ángulo de la
cola. Torso, brazos y piernas se redibujan con el mismo grosor y largo que en el original.

## Se conserva de v017
Registro con pies en (192,352), ojo abierto, triángulo gris en la oreja, carbón (mediana 34), rojo de la
bufanda, rebote suave de la cabeza (4–6 px, más alta en 04 y 08), apoyos en 01–03 y 05–07 y vuelos en 04 y 08.

## Corregir, con los valores del original
1. Cabeza: de la punta de la oreja al centro del ojo, 56–68 px (original 62; v017 76). Proporción cabeza
   entre cuerpo de 0.38 a 0.46 (original 0.42; v017 0.54).
2. Ojo: pequeño, de 32 a 50 px² de blanco (original 40; v017 64–73).
3. Cuerpo: delgado como el original, con extremidades largas y finas; no panzón.
4. Contorno: gris claro y delgado como en el original, solo en el borde exterior. Detrás de la cabeza, un
   solo mechón: quitar los picos de pelo extra.
5. Grano: igual al original (desviación cerca de 5). En v016 quedó plano y en v017 quedó rasposo (20–38%
   de más).
6. Bufanda: 1250–1550 px² de rojo (original ~1400). En v015, v016 y v017 salió 30–40% más grande. Banda
   del cuello delgada, con pliegues y sombra.
7. Brazos y manos: delgados como en el salto, **terminando en punta**, sin puño redondo ni mitón. Codos
   doblados, alternados y opuestos a las piernas: el de adelante sube a la altura del pecho y el de atrás
   pasa junto a la cadera, a la vista y separado del torso.

## Movimiento: carrera normal (no sprint)
v016 abría las piernas en split (sprint) y v017 es un trote agachado. Lo correcto está en medio:
- Torso inclinado hacia adelante unos 15–20°, cabeza adelantada y un poco baja, mirando al frente.
- La pierna de atrás se estira recta al empujar (01 y 05). La de adelante sube la rodilla al pasar (03 y 07)
  y estira el pie al frente antes de apoyar.
- Ancho máximo del dibujo: 150–170 px (v016 llegaba a 190; v017 a 149, pero con piernas encogidas).
- Debe sentirse ligero, decidido y en control; ni desesperado ni tímido.

## Formato
8 cuadros en bucle a 20 fps, mirando a la derecha. PNG transparente de 384x384, pies en (192,352), misma
escala que el caminado. El pie apoyado retrocede de forma pareja. Entregar en
`Game_Assets/Wolf_Run_v018/Sprites/run/01..08.png`, con una lámina del lobo original, el salto y la carrera
lado a lado a la misma escala, e `INTEGRACION_CLAUDE.md` con el avance por ciclo medido y las medidas de la
tabla de la guía para cada cuadro.
