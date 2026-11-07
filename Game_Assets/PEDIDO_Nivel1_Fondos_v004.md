# Pedido para ChatGPT — Nivel 1: continuación de los puentes y paredes de risco (Fondos_v004)

`fondos_unificados_v001` ya está en el juego. Faltan dos piezas:
1. **Continuación de los puentes.** El plano medio (`04_plano_medio`: risco, puente de arco y ladera)
   termina en un corte recto a la derecha, y entre eso y la casa no hay nada.
2. **Paredes de risco.** Los bordes de los huecos y del foso, donde el lobo cae y más adelante podrá
   pegarse a la pared, hoy son rectángulos lisos.

Mismas reglas que `fondos_unificados_v001`:
- dos estados con la misma silueta y la misma máscara alfa;
- boceto: gris neutro, interior relleno de blanco papel opaco;
- definido: el mismo sepia claro de la entrega anterior.

## Cómo usarlo
1. Abrir un chat nuevo de ChatGPT y adjuntar, de `Game_Assets/Nivel_01_Camino/fondos_unificados_v001/`:
   - `definido/camino/04_plano_medio.png` y `boceto/camino/04_plano_medio.png`;
   - `definido/camino/11_casa_lejana.png`;
   - `definido/camino/08_foso_espinas.png` (bordes de roca ya usados);
   - `definido/camino/12_subsuelo.png` (tono de la tierra);
   - `comparativas/montaje_parallax_comparado.jpg`.
2. Pegar el mensaje de abajo.
3. Guardar en `Game_Assets/Nivel_01_Camino/fondos_unificados_v002/boceto/camino/` y `/definido/camino/`,
   con `comparativas/` y unas notas para Claude.

---

## Mensaje para ChatGPT

Seguimos con los fondos del juego 2D de plataformas de lado, en el mismo estilo de las imágenes
adjuntas. Cada pieza va en dos estados con la misma silueta, el mismo tamaño y la misma máscara alfa:
- boceto: línea de lápiz gris, interior relleno de blanco papel opaco;
- definido: el mismo dibujo terminado en el sepia claro de las piezas adjuntas, sin gris frío ni color.

Diseño original. Sin texto, firma ni marco.

1. `20_puentes_continuacion.png`: PNG transparente de 1774x887, a la misma escala que `04_plano_medio`.
   - Continúa hacia la derecha el corte recto del final de `04_plano_medio`.
   - Su borde izquierdo debe empatar con ese corte: misma altura del risco, mismas capas de roca y
     plantas.
   - Después, el terreno baja en una ladera suave con algunos arbustos.
   - Termina a la derecha en un peñasco bajo, al nivel de la base de la casa adjunta (11), para que la
     casa y su cascada queden apoyadas encima.
   - El borde derecho se funde en transparencia.
   - Sin puentes nuevos ni edificios.

2. `21_risco_pared.png`: PNG transparente de 384x1024, que se repita en vertical sin costura (la fila de
   arriba empata con la de abajo).
   - Es la pared de roca de un risco vista de lado, como el costado de los bordes de `08_foso_espinas`.
   - Ocupa los 300 px de la izquierda, con su orilla derecha irregular: rocas salientes, grietas
     verticales, algunas raíces.
   - Los 84 px de la derecha son transparentes, salvo lo que sobresale de la orilla.
   - Se usará sola y en espejo, para los dos lados de un hueco.

3. `22_risco_arranque.png`: PNG transparente de 384x256.
   - Es la parte de arriba de la pared 21: donde la orilla del suelo se dobla y empieza la caída.
   - Abajo empata exacto con la fila de arriba de 21.
   - Arriba lleva la orilla del suelo con un poco de pasto, del mismo grosor que la losa del suelo de
     `08_foso_espinas`.

4. `23_abismo.png`: PNG de 1024x1024, sin transparencia, que se repita en X y en Y.
   - Es el fondo de un hueco profundo: roca lejana y bruma que oscurece hacia abajo.
   - Lleva menos detalle que `12_subsuelo` y debe leerse como lejano.

Antes de entregar, revisa cuatro cosas:
- en cada pieza, el boceto y el definido tienen la misma silueta;
- los bocetos están rellenos de blanco;
- el borde izquierdo de la pieza 20 empata con el corte de `04_plano_medio`;
- 21, 22 y 23 se repiten sin costura.
