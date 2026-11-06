# Guía del lobito — modelo único para todos los sprites

Todo sprite del lobito (correr, saltar, atacar, dash, pared, daño, etc.) se compara contra este documento
antes de integrarse. El objetivo es que el personaje se vea igual en todo momento y que las animaciones
pasen de una a otra sin saltos de estilo ni de tamaño. Claude lo actualiza en cada revisión.

## 1. Modelo de referencia
- Dibujo, proporciones y materiales: el lobo original del inicio,
  `Wolf_Pincel_v003/Animations/walk/body/01.png` e `idle/body/01.png`. Este dibujo manda sobre todo lo demás.
- Brazos y manos: los del salto, `Wolf_Salto_v004/Sprites/02_jump_up.png` y `03_jump_apex.png`. Son brazos
  delgados que terminan **en punta**, sin puño redondo ni mitón. A Emma le gustan así; se usan en todas las
  animaciones (excepto el caminado tímido, que lleva las manos juntas en el pecho).
- Formato: PNG transparente de 384x384, mirando a la derecha, pies en (192,352), misma escala que el caminado.

## 2. Medidas del original (rangos aceptables)
Se miden con `python herramientas/comparar_lobo.py <carpeta de cuadros>`. Las cifras son de una pose de pie;
en poses agachadas o estiradas, el alto y el ancho cambian, pero la cabeza, el ojo, la bufanda y la cola no.

| Medida | Original | Aceptable | Qué indica |
|---|---|---|---|
| Punta de oreja a centro del ojo | 62 px | 56–68 | tamaño de la cabeza |
| Ojo a punta del hocico | 16 px | 14–20 | largo del hocico |
| Ojo (área blanca) | ~40 px² | 32–50 | tamaño del ojo: pequeño |
| Bufanda (área roja) | ~1400 px² | 1250–1550 | tamaño de la bufanda |
| Carbón del cuerpo (mediana) | 34 (RGB 32–41) | 31–38 | negro: carbón, no negro puro |
| Grano (desv. del carbón) | ~5 | 4.3–5.7 | textura suave: ni plana ni rasposa |
| Cuello a pies, de pie | 148 px | 140–156 | largo de torso y piernas |
| Ancho, de pie | 133 px | — | |
| Proporción cabeza / cuerpo (oreja-ojo ÷ cuello-pies) | 0.42 | 0.38–0.46 | que no se haga cabezón |
| Área del cuerpo bajo la bufanda, sin cola | ~4200 px² | 3800–4600 | grosor de torso y piernas |
| Borde del cuerpo con contorno gris | 90% | 85% o más | contorno completo, mismo dibujo |
| Grosor de pierna, a la altura de la espinilla | 17–19 px | 15–20 | piernas finas pero no de alambre |

Las cifras ayudan, pero **no bastan**: v018 pasó todas las de cabeza, ojo y bufanda y aun así era otro
personaje. La revisión visual contra el caminado y el salto es obligatoria.

## 3. Rasgos fijos
- Cuerpo: delgado, de extremidades largas y finas. Cabeza chica respecto al cuerpo. Nunca cabezón,
  panzón ni de piernas cortas.
- Contorno: gris claro y delgado, como el original, solo en el borde exterior de la silueta.
- Orejas: dos, puntiagudas, la delantera con triángulo gris claro adentro. Detrás de la cabeza, un solo
  mechón; no agregar picos de pelo extra.
- Ojo: blanco, pequeño y redondo. Caminando, entrecerrado y temeroso. Desde que corre (correr, saltar,
  caer, atacar) está despierto y abierto. Impulso, aterrizaje y golpes pueden llevar el ojo cerrado.
- Bufanda: rojo RGB ~153,50,47, con pliegues y sombra. La banda del cuello es delgada. La punta puede
  ondear con el movimiento, pero no crece.
- Cola: la del original, grande y esponjada, con la punta gris claro amplia y redondeada (gris ~160) y el
  contorno gris completo. Solo cambia el ángulo según la pose.

## 4. Movimiento (Hornet como guía, descrita en palabras)
Usar a Hornet (Silksong) solo como referencia de movimiento. No copiar su dibujo ni pasarle sus imágenes
a la herramienta de arte.
- Carrera normal (no el sprint): torso inclinado hacia adelante unos 15–20°, cabeza adelantada y un poco
  baja, mirada al frente. Piernas largas: la de atrás se estira recta al empujar y la de adelante sube la
  rodilla y estira el pie al frente. Zancada media: más que un trote, menos que un split. El cuerpo sube y
  baja poco (3–5 px). Ciclo de 8 cuadros a 20 fps, unos 150–170 px de ancho máximo.
- En general: poses claras y legibles, con anticipación y seguimiento; la cabeza se mantiene estable y la
  bufanda y la cola siguen el movimiento con un poco de retraso.

## 5. Patrones de ChatGPT (lo que suele salir mal)
Historial: v014 otro dibujo; v015 ojo entrecerrado y bufanda grande; v016 brazos pegados, grano plano y
zancada de sprint; v017 cabezón, ojo grande, trote agachado y grano rasposo; v018 collage: cabeza, bufanda
y cola recortadas del caminado y pegadas sobre un cuerpo nuevo de alambre, sin contorno.
v019 (método correcto, la mejor hasta ahora): figura completa con contorno y buena carrera, pero cabeza con
picos de pelo extra y ojo 45–50% grande, cola recta y horizontal con dientes negros afilados, bufanda como
cinta rígida sin pliegues, carbón más claro (39) y figura ~7% más baja.

**Lo que sí funcionó (salto v003/v004):** dibujar al personaje COMPLETO en una sola hoja con la
herramienta de imágenes, usando las hojas del caminado y del salto como imágenes de referencia, y después
hacer ediciones puntuales sobre esa misma hoja (cola, bufanda, grano). Ese es el método a seguir.
0. **No armar collages.** Recortar cabeza, bufanda y cola y pegarlas sobre un cuerpo dibujado aparte da un
   muñeco desarmado: el cuerpo pierde el contorno gris (18–25% contra 90%), las piernas salen de alambre
   sin pies, la bufanda cuelga como al caminar en vez de ondear hacia atrás, la cola queda suelta y los
   brazos casi desaparecen. Las cifras de cabeza pasan, pero el dibujo no.
1. **Al rehacer las poses desde cero sin referencia visual, pierde el modelo**: la cabeza y el ojo crecen,
   el cuerpo se hace corto y grueso. La solución no es pegar piezas (punto 0), sino dibujar todo junto con
   el caminado y el salto adjuntos como imagen, y revisar las medidas después.
2. **Sobrecorrige las cifras**: si se le dice "falta grano", lo pone de más; si "la zancada es muy larga",
   la hace un trote corto. Dar siempre el valor del original y un rango, no solo "más" o "menos".
3. **La bufanda siempre sale más grande** (entre 30% y 40% de más en v015–v017). Recordarlo en cada pedido.
4. **Engrosa el contorno y agrega picos de pelo** en la cabeza.
5. **Las manos salen como mitones o puños redondos**; hay que pedir explícitamente brazos delgados que
   terminan en punta, como en el salto.
6. **Corrige lo pedido y rompe lo que estaba bien**: listar siempre lo que se conserva de la versión anterior.
7. Mide y documenta bien el registro, los pies y el avance por ciclo; eso sí se puede confiar.
8. **Optimiza para las cifras en vez del dibujo**: si se le dan números, los cumple aunque el resultado se
   vea mal. Pedir siempre que se compare visualmente con el caminado y el salto antes de entregar.
9. **Al dibujar la figura completa, estiliza la cabeza y la cola**: agrega picos de pelo en la nuca, agranda
   el ojo, hace la cola recta como brocha con dientes afilados y la bufanda como cinta plana. Pedir que
   esas partes sean iguales al caminado y corregirlas con ediciones puntuales sobre la misma hoja, sin
   volver a generar todo.
10. **Sí acepta ajustes deterministas** (por script) para color y tamaño: carbón, tamaño del ojo, escala.
   Usarlos para lo numérico y dejar la herramienta de imágenes solo para la forma.

11. **Cada versión nueva aleja el resultado**: de v017 a v020 se perdió la frescura de v016, que Emma
   prefirió. Cuando una versión ya gusta, trabajar SOBRE sus PNG con pocas correcciones (máximo cuatro),
   la mayoría por script, y prohibir explícitamente regenerar o redibujar. Pedidos cortos y concretos.

**Base vigente de la carrera: v016** (elegida por Emma el 2026-11-06). Pedido de corrección: v021.
Ya está en el juego (`characters/lobo/run_v016`, zancada 446 px por ciclo) con el grano puesto por
`herramientas/ajustar_run_v016.py`. Probado por script: el grano sale bien; adelgazar la bufanda o achicar
el ojo erosionando bordes NO sirve (se pierden los flecos y el ojo queda con anillo). Eso, y los brazos,
van por edición local de ChatGPT (v021).

## 6. Revisión de cada entrega (Claude)
1. Correr `herramientas/comparar_lobo.py` y revisar la lámina con zoom de cabeza y manos.
2. Comparar contra las tablas de las secciones 2 y 3, y el movimiento contra la sección 4.
3. Escribir el pedido siguiente con: lo que se conserva, lo que se corrige con valores del original y
   rangos, y el formato. Actualizar la sección 5 con los patrones nuevos.

### Revisión de producción v019 (2026-11-05)

La v019 parte de figuras completas dibujadas juntas con las dos hojas de referencia adjuntas. Se recuperó
el contorno completo de cuerpo y pies y se registraron los apoyos. Las ediciones de la herramienta de
imágenes alteraron también color, área del ojo y ancho de bufanda entre revisiones. El paquete conserva
las fuentes y medidas reales; sigue en revisión técnica, con `all_requested_numeric_ranges_pass=false`.
Consultar `Wolf_Run_v019/INTEGRACION_CLAUDE.md` antes de integrarlo. Esta nota no cambia los rangos ni
constituye aprobación del dibujo. Está pendiente la elección del usuario sobre ajustes deterministas
de los cuadros existentes o revisión previa del GIF.

### Corrección puntual v020 (2026-11-05)

El pedido v020 autoriza expresamente ajustes deterministas y resuelve la elección pendiente de v019.
Parte de su hoja final: dos ediciones locales de forma, con caminado y salto como referencias, y máscaras
que bloquean las poses originales fuera de cabeza, cola y bufanda. La calibración por script deja ojo
39–40 px², carbón 33–34, grano 4.9–5.2 y bufanda 1445–1531 px². Escala común 1.04, cuello–pies 142–147 px.

Al revisar el comparador, distinguir el borde real de las aristas artificiales que crea su recorte en
x=150 y debajo de la bufanda. En v020/02 y 08 el valor literal es 84%, pero el mismo umbral y vecindad sobre el
borde calculado antes del recorte dan 100%. No cambiar el cuerpo ni los rangos de esta guía para ocultarlo:
conservar ambos datos y la explicación en la entrega. El comparador original no fue modificado.
Ver `Wolf_Run_v020/INTEGRACION_CLAUDE.md`. La aprobación artística sigue correspondiendo al usuario.
