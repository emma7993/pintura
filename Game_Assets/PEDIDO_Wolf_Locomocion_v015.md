# Pedido: Wolf_Locomocion_v015 — correr y saltar con el mismo estilo del caminado

Rehaz la carrera y el salto del lobito copiando exactamente el estilo del caminado que ya está en el juego.
Las entregas Wolf_Run_v014 y Wolf_Jump_Fall_v001 se ven como otro personaje junto al caminado; no las uses como referencia de estilo.

## Referencia obligatoria (el estilo que manda)
- `Game_Assets/Wolf_Pincel_v003/Animations/walk/body/` (caminado, 8 cuadros) y `idle/body/`.
- `Game_Assets/Wolf_Pincel_v003/References/identity.png` y `cautious_eye_reference.png`.
- Superpón cada cuadro nuevo sobre `walk/body/01.png` antes de entregar: deben parecer el mismo dibujo.

## Qué copiar del caminado (y qué cambió mal en v014)
- Cuerpo: negro liso y plano, sin textura de lápiz ni grano (v014 tiene textura granulada).
- Contorno: línea fina gris claro, limpia y uniforme, del mismo grosor que el caminado.
- Bufanda: rojo vivo y plano, como en el caminado, sin patrón ni tono ladrillo o café (v014 la hizo apagada y con textura). Mismo largo y ancho que en el caminado; puede ondear más por la velocidad, pero no crecer.
- Ojo: blanco, entrecerrado, con el párpado temeroso del caminado (v014 lo hizo redondo y grande).
- Orejas: negras con el mismo borde; sin interior blanco (v014 se lo agregó).
- Cola: gris con la base oscura, como el caminado; sin punta blanca.
- Proporciones: igual de esbelto, misma altura de cabeza, mismas patas delgadas. Mismo tamaño en pantalla que el caminado.

## Animaciones (solo cuerpo, sin pincel: el pincel aparece solo al usarlo)
1. `run`: 8 cuadros en ciclo a 20 fps, mirando a la derecha. Postura inclinada hacia adelante, zancada larga, una fase en el aire. El pie apoyado retrocede de forma pareja de un cuadro a otro (sin patinar).
2. `jump_start` (1 cuadro): impulso, agachado.
3. `jump_up` (1 cuadro): subiendo rápido, cuerpo estirado.
4. `jump_apex` (1 cuadro): cima, un instante suspendido.
5. `fall` (1 cuadro): cayendo rápido, patas listas para aterrizar.
6. `land` (1 cuadro): aterrizaje, flexionado.

El salto del juego sube recto y rápido, flota en la cima y cae deprisa (como Hollow Knight o Silksong): las poses deben leerse claras en esas tres fases.

## Formato técnico (igual que Wolf_Pincel_v003)
- PNG transparente, celdas de 384x384, suelo en y=352, personaje centrado en x=192.
- Misma escala que `walk/body` (misma altura de orejas a pies).
- Carpetas: `Sprites/run/01..08.png`, `Sprites/jump_fall/jump_start.png, jump_up.png, jump_apex.png, fall.png, land.png`.
- Incluir una lámina de comparación (caminado, carrera y salto lado a lado) e `INTEGRACION_CLAUDE.md`.
- No tocar `Wolf_Pincel_v003`: idle, walk, dash, pared, tajos, pintar, daño y muerte ya tienen el estilo correcto y se quedan como están.

## Para lo que siga
Toda entrega nueva del lobito (combo, formas del pincel, flechas, etc.) debe seguir este mismo estilo del caminado.
