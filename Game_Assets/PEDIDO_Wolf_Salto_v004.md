# Pedido: Wolf_Salto_v004 — ajuste final del salto

Referencia para todo el juego: el lobo original que aparece al inicio (quieto y caminando):
`Game_Assets/Wolf_Pincel_v003/Animations/idle/body/` y `walk/body/`. Todos los sprites se comparan contra él.

Parte de `Wolf_Salto_Estudio_v003`, que ya está casi perfecto: conserva las cinco poses, el registro, el
tamaño, la bufanda, el contorno, las orejas y las proporciones.

## Ojo: cambia según la acción (correcto en v003)
Caminando, entrecerrado y temeroso. Desde que corre ya está despierto: correr, saltar y caer con el ojo abierto.
El impulso y el aterrizaje pueden ir con el ojo cerrado por el esfuerzo.

## Lo único que falta igualar al lobo original
1. Negro del cuerpo: el carbón del original (entre RGB 32 y 41), no negro puro. v003 viene en ~22 y se ve
   más pesado y oscuro que el lobo del inicio.
2. Grano: tan suave como en el original. v003 tiene cerca de 50% más textura en el cuerpo.
3. Cola: la del original es grande y esponjada, con una punta gris claro amplia y redondeada (cerca de la
   mitad de la cola, gris ~RGB 160) y el contorno gris rodeándola completa. En v003 la cola es cerca de la
   mitad de tamaño, la punta es más oscura (~136), en picos delgados y sin contorno en la parte gris.
   Copiar la forma, el tamaño y el color de la cola del original; puede cambiar solo su ángulo según la pose.

## Formato
Igual que v003: PNG transparente de 384x384, pies en (192,352), misma escala. Entregar en
`Game_Assets/Wolf_Salto_v004/Sprites/` con 01_jump_start, 02_jump_up, 03_jump_apex, 04_fall y 05_land,
más una lámina con el lobo original al lado del salto.
