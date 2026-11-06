# Contexto para ChatGPT — Mundo 1: Camino

Documento para adjuntar en ChatGPT al diseñar el mundo Camino. Resume lo que ya existe en el juego, lo que
está decidido y lo que falta. Lo mantiene Claude; si algo cambia en el juego, se actualiza aquí.

## 1. El juego en pocas líneas
- Metroidvania 2D de plataformas, vista lateral, hecho en Godot 4.7 (pantalla 1280×720). Inspirado en la
  estructura y la legibilidad de Hollow Knight y Silksong, con identidad propia: no copiar escenarios,
  personajes ni recursos de otros juegos.
- Todo ocurre dentro de una pintura al óleo inacabada: la portada del álbum de Immix. Cinco mundos, uno por
  canción y en el orden del álbum: **Camino**, Un sueño y muchos momentos, Cambio, Miedo y Al final.
- El hub es **La Pintura**: un cuadro al centro del mapa. Las zonas son sus puertas. Pintar el cuadro desde
  afuera con los colores obtenidos abre caminos adentro.
- Protagonista: un lobito negro con bufanda roja, tímido y temeroso, que gana confianza al aprender a
  dibujar y pintar. Lleva un pincel que ataca, termina bocetos y más adelante se vuelve arpa y arco.
- Los colores son llaves (negro, blanco, amarillo, azul y rojo, y mezclas). La música es la del álbum.

## 2. Reglas de arte vigentes (lo que ya está en el juego)
- **Los mundos empiezan sin terminar:** la primera vez son un boceto de grafito sobre papel casi blanco. Línea
  gris suelta, trazos dobles exploratorios, líneas interrumpidas, poco rayado, interiores sin rellenar y
  mucho blanco. Nada de color, masas negras ni piedra renderizada.
- **El color se revela pintando:** debajo de cada boceto hay una versión al óleo del mismo dibujo, que el lobo
  descubre con sus pinceladas. Por eso cada fondo o pieza existe en dos versiones que deben coincidir al
  píxel: **boceto a grafito** y **óleo** (mismo encuadre, mismo tamaño, mismo contorno).
- **Legibilidad:** lo que se pisa lleva un trazo superior claro; el fondo nunca debe confundirse con suelo.
- **Fondos en capas de parallax** (3 o 4), más pálidas cuanto más lejos, cada una en PNG aparte.
- **Personaje y enemigos:** dibujo a mano con contorno limpio, color casi plano y ojos claros como principal
  expresión. Los enemigos son tinta y sombra: negro brillante, reflejos blancos y chorreaduras.
- **El lobito** (no lo rediseñes; ver `identity.png`): negro carbón con grano suave, contorno gris claro,
  bufanda roja (~RGB 153,50,47), orejas con triángulo gris claro, cola grande y esponjada con punta gris
  claro. Ojos: caminando, entrecerrados y temerosos; desde que corre, abiertos.
- **Formato:** PNG con transparencia real, vista lateral plana, sin texto, firma ni marco. Claude recorta,
  escala, hace repetibles las texturas y lo integra; no hace falta acertar medidas exactas.

## 3. El mapa de Camino (14 salas)
Ver `esquema_camino.png`. Cada sala ocupa 1 o 2 pantallas.

| Sala | Qué pasa | Estado en el juego |
|---|---|---|
| Despertar | Aparece con miedo y solo camina; lo persiguen sombras, manos que salen del suelo y bruma | **Jugable** |
| Barranco | Las sombras lo obligan a correr; ve una luz al otro lado de un hueco y aprende a saltar | **Jugable** |
| Altar del pincel | La luz guarda el pincel con restos de color: un trazo pinta una barrera de óleo y las sombras se quedan atrás | **Jugable** |
| Arco dañado | Puerta de regreso a La Pintura; es un boceto apagado y hay que pintarlo con tinta. Junto a él, un pozo cerrado | **Jugable** |
| Entrada a la cueva | Escalón, meseta, foso con espinas y la boca de una cueva que baja | **Jugable**, arte provisional |
| Cascada | Bajo tierra: cascada y lago de tinta donde se llena el tintero; primer descanso | **Jugable** |
| Pozo bloqueado | Desde abajo, un golpe de pincel rompe la tapa y se sube hasta el arco | **Jugable**, arte provisional |
| Taller del copista | Puerta en la cueva hacia el vendedor | Solo puerta provisional |
| Zona de enemigos | Por un paso con hojas junto a la cascada: aprende a atacar con Manchones | Bloque sin arte |
| Cueva de la paleta | Encuentra la paleta de colores | Bloque sin arte |
| Sello musical | Puerta sellada al fondo, sobre una repisa alta; se abre con la Melodía 1 (de Un sueño) | Bloque sin arte |
| Zona de descanso | Banca con cascada de pintura, antes del jefe | Bloque sin arte |
| Sala del jefe | Criatura de tinta que borra el camino; da el blanco y el dash | Bloque sin arte |
| Atajos a Un sueño y a Miedo | Se abren más adelante (melodía / pintura roja) | Bloque sin arte |

"Bloque sin arte" significa que la sala ya existe y se recorre con rectángulos grises, pero le falta todo el
diseño visual y de niveles.

## 4. Lo que el lobo ya sabe hacer
Caminar, correr, saltar (alto si se mantiene el botón, corto con un toque), dash, deslizarse en paredes, combo
de tres golpes con el pincel, corte hacia arriba y golpe hacia abajo para rebotar (pogo). Recibe daño y muere.
Medidas en el juego: salto completo ~240 px, carrera 360 px/s; el lobo mide unos 120 px de alto.

## 5. Arte que ya existe para Camino
- Bocetos de grafito del Nivel 1: cielo lejano, acueducto con faro, bosque en la orilla, suelos, plataformas,
  árboles, juncos, piedras, puente, pedestal, puerta (`scene_01` a `scene_04` muestran cómo se ve).
- Óleo bajo el grafito, cascada de tinta animada, altar, tintero, barrera de óleo y máscaras de pincelada.
- Sombras: bruma y manos que brotan del suelo.
- En proceso, contigo: cueva, pozo, foso y puertas (`PEDIDO_Nivel1_Cueva_v002_ChatGPT.md`).

## 6. Enemigos de Camino (diseño acordado, falta arte)
- **Manchón:** slime de tinta negra brillante que salta; el más fácil (zona de enemigos de la cueva).
- **Murmullo:** residuo de sombra y tinta que vuela y se burla; encarna el miedo y la ansiedad.
- **Manos de sombra:** salen del suelo y agarran; las mismas del despertar.
- **Burlón:** bruto de sombra y tinta, el más fuerte; siempre se burla.
- **Jefe:** criatura de tinta que borra el camino.

## 7. Decisiones abiertas donde puedes proponer
- Historia: quién es el lobito y qué representa La Pintura completa.
- Diseño visual y de niveles de las salas en "bloque sin arte".
- Indicador de vida o ánimo (propuestas: pentagrama, bufanda o retrato) y moneda (corcheas).
- Forma y ataques del jefe de Camino.
- Cómo se ve el sello musical y la paleta de colores.

Cuando propongas, da 2 o 3 opciones con una recomendada. Cuando generes arte, sigue las reglas de la
sección 2 y entrega cada pieza o capa por separado.

## 8. Cómo entregar cada imagen (obligatorio)
Emma descarga tus imágenes y un script las guarda en el proyecto según las rutas que tú indiques; Claude
las toma de ahí y las integra al juego. Por eso, en **cada respuesta donde generes imágenes**:

1. Debajo de cada imagen escribe su ruta: `Ruta: Game_Assets/...png`.
2. Al final de la respuesta, un bloque de código titulado **LISTA DE ENTREGA** con todas las rutas de esa
   respuesta, una por línea, **en el mismo orden en que aparecen las imágenes** (es el orden de descarga).
3. Después, un bloque **NOTAS PARA CLAUDE** con lo que Claude necesita para integrarlas: qué es cada pieza,
   cuál es su versión grafito y cuál su óleo, qué parte se pisa, qué debe repetirse y qué se anima.

Reglas de las rutas:
- Carpeta base: `Game_Assets/Camino/<tema>_v001/`, donde `<tema>` es la sala o el tipo de pieza
  (`despertar`, `barranco`, `zona_enemigos`, `enemigo_manchon`, `fondo_lejano`...). Si rehaces una pieza ya
  entregada, sube la versión (`_v002`) en lugar de reemplazar la anterior.
- Excepción: la entrega de cueva, pozo, foso y puertas en curso usa `Game_Assets/Nivel_01_Camino/Cueva_v002/`
  con los nombres de su pedido (`01_roca_corte.png` ... `06_puertas.png`).
- Nombres en minúsculas, sin espacios, acentos ni ñ, con guion bajo y terminados en `.png`.
- Las versiones pareja llevan el mismo nombre con sufijo: `..._grafito.png` y `..._oleo.png`.

Ejemplo:
```
LISTA DE ENTREGA
Game_Assets/Camino/zona_enemigos_v001/fondo_cueva_grafito.png
Game_Assets/Camino/zona_enemigos_v001/fondo_cueva_oleo.png
```
