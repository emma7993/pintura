# Pedido: Wolf_Run_v017 — carrera final (ajuste de v016)

Referencia para todo el juego: el lobo original del inicio (quieto y caminando):
`Game_Assets/Wolf_Pincel_v003/Animations/walk/body/` e `idle/body/`. Manos y ojo al moverse:
`Game_Assets/Wolf_Salto_v004/Sprites/` (subida y cima).

Parte de `Wolf_Run_v016/Sprites/run/`. Ya están bien y se conservan: ojo abierto, tono carbón, rojo de la
bufanda, cola, orejas con gris adentro, registro, pies en (192,352) y formato.

## Movimiento: carrera normal, no sprint
El personaje corre de forma ágil pero controlada, como la carrera normal de un juego de acción 2D (la
carrera de base, no el sprint). Debe sentirse ligero y decidido, no desesperado.
1. Pasos más cortos y rápidos: los pies caen cerca y debajo del cuerpo, con las rodillas que suben al
   frente. En v016 las piernas se abren casi en split (el dibujo llega a 190 px de ancho, contra 133 del
   caminado). Que no pase de unos 150 px.
2. Inclinación: el torso inclinado hacia adelante unos 15–20°, con la cabeza adelantada y un poco baja,
   mirando al frente. Cabeza y espalda forman una sola línea que empuja hacia adelante. En v016 el torso va
   casi vertical.
3. Rebote suave: la cabeza sube y baja 3–5 px de forma pareja en el ciclo, más alta en las fases aéreas.
   En v016 se queda fija y salta 10 px de golpe en 04 y 08.

## Dibujo
4. Brazos: dibujarlos como parte del cuerpo, no como tiras pegadas encima. Usar el mismo carbón, con el
   contorno gris solo en el borde exterior de la silueta. El brazo de atrás apenas se asoma detrás del
   torso; en v016 sale como un rectángulo plano fuera de la espalda (06). El de adelante va con el codo
   doblado y una mano pequeña como en el salto. Siguen alternados y opuestos a las piernas.
5. Grano: v016 tiene cerca de la mitad de la textura del original y se ve plano. Igualar el grano suave
   del lobo del inicio.
6. Bufanda: ocupa cerca de 40% más que en el original. La banda del cuello debe ser tan delgada como en
   el original, con sus pliegues y su sombra. La punta puede ondear hacia atrás, pero con el mismo largo.
7. Limpieza: quitar las rayitas grises sueltas bajo la cola y detrás del pie trasero (01 y 02) y la cuña
   negra suelta en el torso y la rodilla de 03. La pierna que cruza por delante debe llevar su propio
   contorno.

## Formato (igual que v016)
8 cuadros en bucle a 20 fps, mirando a la derecha. PNG transparente de 384x384, pies en (192,352), misma
escala que el caminado. Apoyos en 01–03 y 05–07, fases aéreas en 04 y 08; el pie apoyado retrocede de forma
pareja. Entregar en `Game_Assets/Wolf_Run_v017/Sprites/run/01..08.png`, con una lámina del lobo original, el
salto y la carrera lado a lado, e `INTEGRACION_CLAUDE.md` con el avance por ciclo medido.
