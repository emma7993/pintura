# Pedido: Wolf_Run_v016 — carrera final

Referencia para todo el juego: el lobo original del inicio (quieto y caminando):
`Game_Assets/Wolf_Pincel_v003/Animations/walk/body/` e `idle/body/`. Para manos y ojo al moverse:
`Game_Assets/Wolf_Salto_Estudio_v003/Sprites/` (subida y cima).

Parte de `Wolf_Locomocion_v015/Sprites/run/`: el tamaño, la inclinación, la zancada y el registro ya están bien.
No uses `Wolf_Run_v014` (es otro dibujo: más grande, bufanda café con textura, interior blanco en las orejas).

## Corregir respecto al lobo original
1. Ojo: abierto, redondo y blanco, como en la subida y la cima del salto. Regla del personaje: caminando,
   entrecerrado y temeroso; desde que corre ya está despierto y abre los ojos. En v015 sigue entrecerrado.
2. Brazos y manos: ya NO van juntos en el pecho. Los brazos se mueven alternados y opuestos a las piernas,
   como una carrera de acción (Hornet en Silksong): codos doblados, un brazo adelante a la altura del pecho
   mientras el otro va atrás junto a la cadera, y cambian en cada paso. Manos pequeñas como en el salto v003.
3. Bufanda: el rojo del original (cerca de RGB 153,50,47); en v015 es más brillante (~176,44,45). Y el mismo
   ancho y largo del original: en v015 ocupa cerca de 50% más del dibujo. Puede ondear hacia atrás por la
   velocidad, pero sin crecer.
4. Orejas: con el triángulo gris claro adentro, como el original (en v015 son negras por completo).
5. Cola: la del original, grande y esponjada, con la punta gris claro amplia y redondeada (cerca de RGB 160,
   la mitad de la cola) y el contorno gris completo. En v015 la punta es más oscura y chica.
6. Negro y grano: el carbón del original (RGB entre 32 y 41) con su grano suave. v015 está bien de tono
   pero quedó demasiado plano, sin grano.

## Formato (igual que v015)
8 cuadros en bucle a 20 fps, mirando a la derecha. PNG transparente de 384x384, pies en (192,352), misma
escala que el caminado. Apoyos en 01–03 y 05–07, fases aéreas en 04 y 08; el pie apoyado retrocede de forma
pareja. Entregar en `Game_Assets/Wolf_Run_v016/Sprites/run/01..08.png`, con una lámina del lobo original, el
salto y la carrera lado a lado, e `INTEGRACION_CLAUDE.md` con el avance por ciclo medido.
