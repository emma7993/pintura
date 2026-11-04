# Diseño general del juego — Metroidvania de Immix

> Documento de diseño del juego. Las imágenes mencionadas como «Imagen adjunta» van como archivos aparte con ese nombre.


Nov 3, 2026 · @Emma

## 1. Visión general

Metroidvania 2D compacto: un lobito con un pincel recorre cinco mundos que son las cinco canciones del álbum. Cada mundo le entrega una herramienta (tinta, cuerdas, color) que reabre caminos ya vistos, y al final pinta el paisaje para vencer al jefe final.

**Pilares de diseño**

- **El álbum es el mapa.** El orden de las canciones es el orden de progresión: Camino, Un sueño y muchos momentos, Cambio, Miedo, Al final. La música del juego es la del álbum.
- **Un solo objeto que evoluciona.** El pincel ataca, termina bocetos, se vuelve arpa y arco, y levanta escudos.
- **Los colores son llaves.** La paleta se llena con negro, blanco, amarillo, azul y rojo. Los colores se usan para pintar La Pintura del hub, que cambia el mundo interior, y suben el escudo.
- **Todo pasa por el centro.** La Pintura, al centro del mapa, es el hub: las cinco zonas la rodean y cada zona nueva se abre regresando a ella. Los atajos entre zonas vecinas se desbloquean después.
- **Más simple que Hollow Knight.** Cinco zonas, un jefe por zona, un solo vendedor, y una economía pequeña.

## 2. Dirección de arte

Personaje y enemigos en ilustración 2D dibujada a mano con línea de tinta, al estilo de Hollow Knight; fondos en acuarela. El contraste entre ambos es la identidad visual del juego.

**Estilo del personaje y los enemigos (nombre concreto: cartoon gótico dibujado a mano, tipo Hollow Knight)**

- Contorno de tinta negra limpio y grueso, de ancho constante, sin degradados en la línea.
- Silueta simple y reconocible a tamaño chico; formas redondeadas con puntas pocas y marcadas.
- Color casi plano, con una o dos sombras duras; sin texturas finas.
- Rasgos faciales mínimos: ojos grandes claros como principal recurso de expresión.
- Lobito propuesto: pelaje oscuro, hocico y ojos claros, bufanda larga como único accesorio visible, pincel en la mano o cola.
- Animación cuadro por cuadro con pocos frames y poses exageradas (anticipación y rebote marcados).
- Enemigos con la misma línea; los peligrosos llevan un acento de color.

**Estilo de fondos (acuarela)**

- Lavados húmedo sobre húmedo con bordes que se difuminan y manchas de pigmento que se expanden.
- Pigmento transparente: se ve el blanco del papel en luces y reflejos.
- Textura de papel de acuarela, granulación suave y goteos o chorreaduras en los bordes.
- Sin contornos de tinta en el fondo; la forma la dan las manchas de color.
- 3 a 4 capas de parallax, más pálidas y menos saturadas cuanto más lejos; niebla o lavado blanco entre capas.
- **Regla de legibilidad:** suelos y plataformas transitables llevan un contorno de tinta fino sobre la acuarela; el fondo nunca lleva contorno, para que el jugador distinga qué se pisa.

**Fondos por etapas.** La primera vez que se entra a una zona no tiene color: solo bocetos a lápiz. Los colores se agregan al avanzar, así que cada fondo existe en etapas.

- Etapa 0: boceto a lápiz gris, sin color, con la misma composición que el fondo final.
- Etapa 1: tinta negra, con las líneas y las plataformas.
- Etapas siguientes: una capa transparente de acuarela por cada color (amarillo, blanco, azul, verde, rojo).
- La imagen final, con todos los colores, es la que describen las referencias y la paleta de cada zona.
- Técnica sugerida: generar primero el fondo final y derivar de él el boceto, la tinta y las capas de color, para que todas encajen en el mismo lugar.

**Referencias**

Referencias de acuarela para los fondos (las tres imágenes que siguen). Adjúntalas también en la conversación principal al generar fondos.

[Imagen adjunta: ref_acuarela_1.png — Ref. 1: Montaña y puente de piedra (Camino)]

[Imagen adjunta: ref_acuarela_2.png — Ref. 2: Árbol azul al atardecer (Un sueño y muchos momentos)]

[Imagen adjunta: ref_acuarela_3.png — Ref. 3: Sol grande entre pinos (Miedo)]

| Ref. | Qué tomar de ella | Zona sugerida |
| --- | --- | --- |
| 1. Montaña y puente de piedra | Acuarela detallada, verdes y amarillos cálidos, agua azul clara, casas de tejado rojizo, cielo con nubes en lavado | Camino |
| 2. Árbol azul al atardecer | Cielo amarillo y naranja suave, sol pálido, copa azul y ramas negras, reflejos en el agua | Un sueño y muchos momentos |
| 3. Sol grande entre pinos | Sol rosa y naranja, pinos morados oscuros, reflejos en el agua, chorreaduras en el borde, mancha que se disuelve en el papel | Miedo |

La portada del álbum sirve de referencia para Cambio (bosque bajo el agua), Miedo (ola con faro y mar de tormenta) y Al final (atardecer ámbar, puente y la cabeza dormida).

**Portada del álbum** (referencia general de color y atmósfera):

[Imagen adjunta: portada_immix.jpg — Portada de Immix]

**Mapa de Hollow Knight** (referencia de estructura; el nuestro es más pequeño, como el área marcada en rojo):

[Imagen adjunta: mapa_hk.jpg — Mapa de Hollow Knight]

**Referencias de enemigos** (manchas y figuras de tinta negra brillante con reflejos blancos y chorreaduras; ver la sección de enemigos de Camino):

[Imagen adjunta: ref_enemigo_mancha.png — Ref. enemigo: mancha de tinta]

[Imagen adjunta: ref_enemigo_fantasma.png — Ref. enemigo: fantasma de tinta con goteo]

**Paleta por zona (estado final, ya pintada)**

| Zona | Colores dominantes del fondo | Tono general |
| --- | --- | --- |
| Camino | Verdes suaves, amarillos cálidos, blanco de papel | Calmo, luminoso |
| Un sueño y muchos momentos | Amarillos, azules claros, lilas suaves | Onírico, etéreo |
| Cambio | Azules profundos, verdes de alga, turquesa y destellos de luz | Sumergido, silencioso |
| Miedo | Rojos, rosas, morados oscuros, negro | Tenso, nocturno |
| Al final | Naranjas y rosas de atardecer sobre un muelle, con todos los colores y mucho blanco | Melancólico, de cierre |

**Plantilla base para pegar en cada solicitud de sprites o fondos**

> Ilustración 2D dibujada a mano estilo Hollow Knight: contorno de tinta negra grueso y limpio, color casi plano, silueta simple. Fondos en acuarela: lavados húmedo sobre húmedo, textura de papel, bordes difusos y chorreaduras, sin contornos. Vista lateral 2D, fondo transparente para sprites, hoja alineada en cuadrícula con un frame por celda. Personaje: lobito de pelaje oscuro con bufanda larga y pincel.

## 3. Estructura general del mapa

Las cinco zonas forman un anillo alrededor de La Pintura, en el orden del álbum: cada una se abre desde el hub y, una vez abierta, se conecta con sus vecinas por atajos.

[Imagen adjunta: esquema_mapa_general.png — esquema: mapa general · 1 hub, 4 zonas, 4 atajos]

La Pintura es el centro. Los atajos son propuesta y se desbloquean después de la primera visita a cada zona.

| Conexión | Se abre con | Tipo |
| --- | --- | --- |
| La Pintura a Camino | Primera puerta, siempre abierta | Ruta principal |
| La Pintura a Un sueño y muchos momentos | Puerta pintada con el pincel y el negro | Ruta principal |
| La Pintura a Cambio | Blanco: dash, viento y descenso | Ruta principal |
| La Pintura a Miedo | Melodía completa que calma las olas, y bote | Ruta principal |
| La Pintura a Al final | Pintura completa y melodía final (ver sección 8) | Ruta principal |
| Camino a Un sueño | Melodía del sello musical | Atajo |
| Un sueño a Al final | Agarre de pared | Atajo |
| Cambio a Miedo | Bote y melodía de las olas | Atajo |
| Miedo a Camino | Pintura roja sobre el acantilado | Atajo |
| Al final a Cambio | Planeo con bufanda sobre corrientes | Atajo |

## 4. Colores, habilidades y progresión

Seis hitos en el orden del álbum. El jugador regresa al hub para abrir cada zona nueva, usando lo obtenido en la anterior. Lo marcado como *propuesta* no estaba definido y es decisión tuya.

| # | Dónde | Obtiene | Qué le permite | Escudo |
| --- | --- | --- | --- | --- |
| 1 | Camino (inicio) | Pincel (altar), paleta (cueva) y **negro** | Escudo con el primer brochazo; atacar (zona de enemigos); pintar las líneas para que todo quede mejor dibujado; terminar bocetos | Nivel 1 |
| 2 | Un sueño y muchos momentos | Cuerdas del arpa rota, primeras notas, **amarillo** (cascada) | Pincel-arpa y arco con esencia; pintar las corcheas en las zonas de descanso para darles valor y cambiarlas con el copista | Nivel 2 |
| 3 | Camino (jefe, segunda parte) | **Blanco** | Dash y control del viento a pequeña escala; planear con la bufanda | Nivel 3 |
| 4 | Cambio | Cuerdas del violín, notas restantes, **azul** (cascada) | Pintar agua; mezclar azul con amarillo para crear **verde**, que abre zonas con enredaderas | Nivel 4 |
| 5 | Miedo | Bote, **rojo** | Refuerza el escudo; flecha roja de daño crítico que exige cargar el arco el doble de tiempo | Nivel 5 |
| 6 | Al final | Agarre de pared (ver sección 8) | Escalar muros; pintar el paisaje de la arena | Sin cambio |

**La paleta.** El lobito encuentra en la cueva de Camino una paleta de pintor con espacios para sus cinco colores base (negro, blanco, amarillo, azul y rojo) y para los secundarios que resultan de combinarlos. Para crear un secundario hace falta un mezclador: el copista vende dos y el tercero es el pez crepuscular de la misión del pescador. Los secundarios aparecen en la paleta y algunos tienen utilidad. Se obtienen en la ruta como negro, amarillo, blanco, azul y rojo, y cada uno ocupa el espacio que le toca. Cada color desbloqueado sube un nivel el escudo (1 a 5). Pintar no gasta nada.

| Color | Posición | Se obtiene | Qué da |
| --- | --- | --- | --- |
| Negro | 1 | Camino, al inicio | Pinta las líneas: todo queda mejor dibujado y se completan los bocetos |
| Blanco | 2 | Camino, jefe | Dash y control del viento a pequeña escala |
| Amarillo | 3 | Cascada de Un sueño | Pinta las corcheas en las zonas de descanso y les da valor para cambiarlas con el copista |
| Azul | 4 | Cascada de Cambio | Pinta agua; mezclado con amarillo crea el verde |
| Verde | Mezcla | Azul con amarillo (mezclador 1 del copista) | Desbloquea zonas con enredaderas, que antes se rompían sin color |
| Rojo | 5 | Final de Miedo | Refuerza el escudo; flecha roja de daño crítico que exige cargar el arco el doble de tiempo |
| Naranja | Mezcla | Rojo con amarillo (mezclador 2 del copista) | Llama completa: tercera mejora del pincel con el herrero |
| Morado | Mezcla | Rojo con azul (pez crepuscular, mezclador 3) | Sueño: duerme enemigos, crea plataformas de sombra y abre la torre de la cascada |

**Jefe final.** La arena tiene zonas pintables. Para debilitarlo hay que pintar el paisaje con los colores; sin el último color (rojo) es imposible vencerlo.

**La Pintura: pintar desde afuera.** La Pintura del hub es la portada del álbum. Con la paleta y el pincel, el jugador pinta y descubre partes del cuadro, y al entrar al mundo este cambia: usar un color afuera habilita zonas adentro.

- Cada color pinta una región del cuadro ligada a una zona; pintar no cuesta, solo exige tener el color.
- Por eso, tras cada color nuevo se regresa al hub: pintar afuera abre rutas adentro.
- La Pintura completa abre la puerta de Al final. En la arena final, pintar el paisaje es lo que debilita al jefe.
- Pendiente: definir qué abre cada región de La Pintura; sus efectos son propuestas.

**Pintar las puertas.** Cada zona es una puerta del cuadro, y la primera vez que se entra no tiene color: solo bocetos a lápiz. Cada color que se obtiene se aplica a la puerta de una zona, y dentro se pintan ciertas partes del paisaje: dan estética y, en algunos casos, acceso a otras zonas.

- **Camino:** al inicio se ven bocetos de la obra a lo lejos, sin color. Con el pincel se repinta el arco dañado, la puerta de regreso y, con ella, la siguiente puerta, la de Un sueño; al pintarla, aparecen plataformas dentro.
- **Amarillo:** se agrega al color de la puerta, y en el paisaje se pintan zonas amarillas que dejan pasar a otras zonas.
- **Cada color nuevo** repite el proceso, hasta que el cuadro queda completo.
- **Pendiente:** si cada color se aplica a todas las puertas o solo a la puerta que le corresponde.

## 5. Controles y sistemas

**Controles**

| Acción | Comportamiento |
| --- | --- |
| Atacar | Pincelada; se puede dirigir hacia arriba y hacia abajo |
| Escudo | Pincelada que levanta una barrera en arco hacia donde apuntes; bloquea ataques y se desvanece en poco tiempo. No gasta pintura y tiene enfriamiento. Su fuerza sube con cada color de la paleta (niveles 1 a 5) |
| Acción y pintar | Mismo botón que atacar, pero con un objeto interactivo cerca: completa bocetos y pinta el paisaje |
| Salto | Estándar |
| Dash | Se obtiene con el blanco, al ganar control del viento |
| Agarre de pared | Se obtiene en Al final |
| Cambio de arma | Alterna pincel y arco. El arco es una habilidad especial: flechas más potentes que gastan esencia. Llama la atención de algunos enemigos y los debilita |
| Flecha roja | Con el arco, mantener el botón el doble de tiempo que en un disparo normal. Inflige daño crítico; es más difícil de usar en combate, pero más provechosa si se acierta |
| Tocar el arpa | Propuesta: mantener un botón y elegir notas con direcciones; falta definir |

**Paleta y recursos** (propuesta, falta afianzar)

- **Paleta:** objeto de pintor que se encuentra en la cueva de Camino, con cinco espacios que se llenan al obtener cada color. No se gasta.
- **Escudo:** no gasta pintura y tiene un enfriamiento corto. Su fuerza sube con cada color de la paleta, y el rojo lo refuerza. Nace del primer brochazo en el altar, con la pintura que le queda al pincel.
- **Esencia (la pintura):** al derrotar enemigos salen pequeñas ráfagas de luz que vuelan hacia el lobito y se absorben solas. Es el recurso de las flechas, que son una habilidad especial: más potentes, pero se gastan rápido. Empieza limitada y se recarga en la cascada del punto de control.
- **Corchea (moneda):** el enemigo suelta además una corchea, que cae al suelo y se recoge al pasar. Se obtiene desde el primer enemigo, sin color y sin valor. Tras conseguir el amarillo se pinta en las zonas de descanso y adquiere valor; se cambia con el copista.
- **Punto de control:** cada banca tiene una cascada y un lago de tinta. Son dos acciones separadas: recargar la esencia en la cascada y sentarse junto al lago para recuperar ánimo. Al descansar, los enemigos de la zona reaparecen. Cada zona tiene una zona de descanso con cascada antes del jefe. Al morir, el lobito reaparece en la última zona de descanso donde descansó.
- **Pintar no cuesta:** pintar La Pintura y terminar bocetos solo exigen tener el color.

**Vida como ánimo.** El lobito se debilita cuando lo golpean. Se recupera golpeando enemigos, que llena una reserva de inspiración, y tocando el arpa, que la convierte en ánimo; tocar lo deja vulnerable unos segundos. Tres ideas para el indicador:

| Opción | Cómo se ve | Ventaja |
| --- | --- | --- |
| A. Pentagrama (recomendada) | Cinco notas sobre un pentagrama; cada golpe apaga una y recuperar la enciende | Liga con la música y es muy legible |
| B. Bufanda | La bufanda pierde color y cae; se tiñe al recuperar ánimo | Es parte del personaje, sin interfaz extra |
| C. Retrato | Un pequeño retrato que se desvanece en acuarela gris | Refuerza el tema del arte |

**Moneda: corcheas.** Los enemigos sueltan dos cosas distintas: ráfagas de luz (esencia, se absorben solas) y una corchea (la moneda, cae al suelo). La corchea se obtiene desde el primer enemigo, sin color; tras conseguir el amarillo se pinta en las zonas de descanso y se puede cambiar con el copista. Los precios de mapas, materiales y mezcladores se calculan según la cantidad de enemigos de cada zona: cuesta conseguirlos, pero no demasiado.

**Vendedor (el copista).** Personaje fijo en Camino que transcribe mapas como partituras y los cambia por corcheas pintadas. Vende el mapa de la zona donde se encuentra, los materiales de las tres mejoras del herrero y dos mezcladores de color, que permiten crear el verde y el naranja. Ideas para añadir después: más esencia máxima, más notas en el pentagrama y pistas de melodías.

**Herrero (Cambio).** Aparece a mitad del juego, en el Claro de coral de Cambio. Dice que la verdadera evolución está en la llama del cambio y que necesita esa llama para cambiar. Trabaja gratis: solo quiere revivir la llama verdadera. Cada mejora del pincel (estocadas más peligrosas, envueltas en fuego) exige un material que vende el copista a cambio de corcheas pintadas.

- **Mejora 1:** con el amarillo, el herrero logra encender una llama muy leve. Material 1 del copista.
- **Mejora 2:** cuando el lobito obtiene el rojo, regresa con él. Material 2 del copista.
- **Mejora 3:** con el naranja (rojo con amarillo), la llama queda completa. Material 3 del copista.

**Pescador (misión secundaria, color morado).** Es el pescador del bote de la portada. No ha dormido en cientos de años y solo busca dormir con el agua morada que genera el pez crepuscular. Ocurre tras obtener el rojo, cuando el jugador ya tiene la melodía completa y el arco.

- **Pez crepuscular:** se atrae tocando la melodía de las olas desde la superficie de Cambio y se pesca con el arco. Tiene un ojo azul y otro rojo; al colocarlo en agua de los dos colores, genera agua morada.
- **Tercer mezclador:** el pez es en sí el mezclador del morado. El copista solo vende dos.
- **Recompensa:** tras dormir, el pescador promete su bote. Sirve para regresar al hub desde Miedo y es el atajo entre Cambio y Miedo. Además mejora el escudo para el jefe final (al bloquear un ataque, el atacante es empujado hacia atrás; no queda aturdido, para que no sea demasiado fácil).
- **El morado:** color de sueño; duerme enemigos, crea plataformas de sombra y deja entrar a la torre de la cascada, la zona opcional.

**Notas y melodías.** Las notas se encuentran en Un sueño y se completan en Cambio. Propuesta de tres melodías: una abre el sello de Camino, otra calma las olas de Miedo y otra abre Al final.

## 6. Esquema por zona

Cada cuadro es una sala de 1 a 2 pantallas; las zonas suman unas 70 pantallas en total. Las salas con borde de color son el hub o un objeto clave, las rojas son jefes, las de borde punteado empiezan cerradas, y el punto negro marca una banca. Los nombres y el contenido de cada sala son propuestas.

### Camino (zona 1)

[Imagen adjunta: esquema_camino.png — esquema: Camino · 14 salas, 1 sello, 1 jefe]

- **Despertar:** el lobito entra con miedo y todavía no sabe correr. Lo persiguen sombras, manos que salen del suelo, ojos de distintas formas por todas partes y niebla. Corre, ve un barranco y salta: aprende a correr y a saltar.
- **Altar del pincel:** un pincel descansa en un altar protegido y, por alguna razón, lo deja tomarlo. Le queda algo de pintura: un brochazo genera el escudo y pinta el paisaje. Lo pintado se queda y las manos dejan de seguirlo.
- **Arco dañado:** ve la salida, pero el arco está dañado y hay que repintarlo. Para eso explora una cueva: encuentra la paleta de colores, una zona de enemigos donde aprende a atacar y una cascada donde descansa. Al subir sale junto a la puerta principal. El pozo que da a la cascada estaba bloqueado y ahora, con el ataque, se abre.
- **Segunda parte:** siguiendo el primer camino se ve el sello musical, que se abre con la primera melodía de Un sueño. Detrás están la zona de descanso con cascada y la sala del jefe.
- **Enemigos:** no aparecen en el despertar (solo hay persecución). Entran en la cueva: la zona de enemigos enseña a atacar con Manchones (slimes de tinta). Después del camino principal se suman los Murmullos (vuelan, se burlan) y las Manos de sombra (salen del suelo), y antes de la zona de descanso aparece el Burlón, el más fuerte, que se repite en zonas posteriores.
- **Jefe:** concepto propuesto, una criatura de tinta que borra el camino. Recompensa: el blanco y el dash.
- **Salidas:** la puerta al cuadro lleva a La Pintura, desde donde se abren las demás zonas. Los atajos a Un sueño y a Miedo se desbloquean después.

### Un sueño y muchos momentos (zona 2)

[Imagen adjunta: esquema_un_sueno.png — esquema: Un sueño y muchos momentos · 13 salas, 1 jefe]

- **Ruta principal:** Umbral, Claro de luz, Burbujas, Cascada amarilla y jefe. Las ramas de arriba (Raíces, Árbol, Bóveda) y de abajo (Orilla, Arpa, Cueva) vuelven a la cascada.
- **Arpa rota:** da las cuerdas, el pincel-arpa y el arco. El arco abre la Bóveda lejana.
- **Cascada amarilla:** da el amarillo, con el que se pintan las corcheas para darles valor.
- **Jefe:** concepto propuesto, un recuerdo que cambia de forma. Al vencerlo se regresa a Camino para abrir el sello musical.
- **Atajos:** a Camino y a Al final (agarre de pared) se abren después.

### Cambio (zona 3)

[Imagen adjunta: esquema_cambio.png — esquema: Cambio · 11 salas, 1 jefe]

- **Entrada:** un pozo vertical desde Camino hacia un bosque sumergido en el mar; solo se desciende con la bufanda y corrientes pintadas con blanco (en el agua serían corrientes y burbujas; por confirmar).
- **Ruta principal:** Borde del bosque, Raíces hundidas y Fondo oscuro, con el Claro de coral y el Cardumen como ramas laterales. Cada capa es más profunda y oscura.
- **Final del nivel:** el violín roto da las cuerdas y las notas faltantes; la cascada azul da el azul; con él se pinta agua y, mezclado con amarillo, se crea el verde que abre las zonas con enredaderas.
- **Jefe:** concepto propuesto, una criatura del bosque sumergido que cambia de forma en cada fase.
- **Atajos:** a Al final (planeo) y a Miedo (bote y melodía). El herrero está en el Claro de coral y el pez crepuscular sube a la superficie con la melodía de las olas.

### Miedo (zona 4)

[Imagen adjunta: esquema_miedo.png — esquema: Miedo · 12 salas, 1 jefe]

- **Entrada:** el mar es intransitable hasta tocar la melodía completa; entonces aparece el bote en el Muelle.
- **Ruta principal:** Muelle, Mar embravecido, Isla Medusa, Pintura roja, zona de descanso con cascada y jefe. Faro, Arrecife, Cueva marina y Acantilado son ramas con puzzles de luz, escudo y combate.
- **Pintura roja:** da el rojo, que refuerza el escudo y da la flecha roja, de daño crítico, que exige cargar el arco el doble de tiempo; es necesaria para el jefe.
- **Jefe:** concepto propuesto, una ola colosal con forma de bestia.
- **Atajos:** a Cambio (bote) y a Camino (pintar rojo en el acantilado).

### Al final (zona 5)

[Imagen adjunta: esquema_al_final.png — esquema: Al final · 12 salas, jefe final]

- **Entrada:** dentro de La Pintura, con una combinación de colores y música (opciones en la sección 8). Ambiente: atardecer en un muelle con la cabeza de la portada del álbum al fondo.
- **Habilidad nueva:** en la Goma arábiga se obtiene el agarre de pared, que abre los Muros altos. Es una propuesta; las otras opciones están en la sección 8.
- **Ruta:** una sucesión de salas que combinan bocetos, viento y dash, música y escudo, y mezclas de color, con una zona de descanso con cascada antes de la arena final.
- **Jefe final:** el más difícil. La arena tiene zonas pintables, y sin el rojo es imposible vencerlo.
- **Atajos:** a Un sueño (pared) y a Cambio (planeo).

## 7. Sprites y fondos por mundo

Pega la plantilla de la sección 2 al inicio de cada solicitud y adjunta la referencia de la zona. Pide primero la hoja de estilo del lobito y apruébala antes de generar el resto. Los frames son un mínimo propuesto. Los sprites van en estilo dibujo a tinta; los fondos, en acuarela, por capas separadas.

### A. Globales (todos los mundos)

| Sprite | Estados y frames | Descripción para generar |
| --- | --- | --- |
| Lobito | Reposo 4, correr 8, salto 3, caída 2, ataque con pincel 3 golpes de 4 frames (también hacia arriba y abajo), dash 4, planeo 4, agarre de pared 4, escudo 4, tocar arpa 6, disparar arco 5, golpe recibido 2, muerte 6, sentarse en banca 4 | Lobo pequeño de pelaje oscuro, hocico y ojos claros grandes, bufanda larga, pincel en la mano; contorno negro grueso; silueta legible a tamaño chico |
| Bufanda | Reposo 4, viento fuerte 4, planeo 4 | Pieza aparte para animar con el viento; mismo color en todas las poses |
| Pincel en 3 formas | Pincel, pincel-arpa, pincel-arco, con transición de 4 frames entre ellas | El mismo objeto en tres versiones; las cuerdas se ven en las dos últimas |
| Pincelada de ataque | Negra 4 frames, en tres direcciones | Trazo de tinta negra con borde irregular |
| Escudo en arco | Aparece 3, activo 4, se desvanece 5; niveles 1 a 5, uno por color de la paleta | Barrera en forma de arco hecha de una pincelada de acuarela; cada nivel suma una capa y se ve más densa |
| Flechas de color | Flecha 1, estela 4, impacto 4; una variante por color de la paleta | Trazo fino de pincel con la punta del color de la flecha |
| Ráfaga de esencia | Brotando 4, volando hacia el lobito 6, absorbida 4 | Pequeñas ráfagas de luz que salen del enemigo derrotado y viajan hacia el lobito; distintas de la corchea |
| Corriente de aire y dash | Estela de dash 4; corriente pintada 6 en loop | Trazos blancos curvos que se dibujan solos y flotan |
| Notas musicales (efectos) | 6 notas, cada una con 4 frames de brillo | Símbolos pequeños que flotan al tocar el arpa; un icono por nota |
| Corchea (moneda) | Gris 4, pintada de amarillo 4, recogida 4 | Nota pequeña que sueltan los enemigos; cae gris y se vuelve dorada al pintarla de amarillo |
| Regiones pintables de La Pintura | Sin descubrir (boceto gris) y pintada, una por color: bocetos, viento, luz, agua, fuego | Partes del cuadro del hub que se llenan de color al pintarlas, con aspecto de acuarela |
| Bocetos de entradas | Puerta, puente y plataforma, cada uno en 3 estados: lápiz, a medio pintar, completo | Trazo de lápiz gris que se rellena de tinta; mismo tamaño en los tres estados |
| Sello musical | Apagado 1, activo 4 en loop | Símbolo con pentagrama grabado en la roca que brilla al tocar la melodía |
| Interruptor lejano | Inactivo 1, golpeado 3, activo 1 | Objetivo para el arco |
| Banca | Libre 1, usada 4 | Punto de guardado; variante de color por zona |
| Cascada y lago de tinta | Cascada 8 en loop, lago 4, lobito sentado junto al lago 4 | Recarga la esencia (cascada) y permite recuperar ánimo (lago); acompaña a cada banca |
| Pintura portal (viaje rápido) | Cerrada 1, abierta 6 en loop | Marco de pintura que sirve de atajo al hub |
| Vendedor (el copista) | Reposo 4, hablar 4 | Personaje pequeño con papeles de partitura y un caballete; el diseño lo defines tú |
| Interfaz | Pentagrama de ánimo (5 notas, encendida y apagada), paleta de pintor de 5 espacios (vacío y lleno), medidor de esencia, 5 iconos de color, 6 iconos de nota, contador de corcheas, marco de mapa | Estilo coherente con el marco del mapa de referencia de Hollow Knight |

### B. Camino

| Sprite | Estados y frames | Descripción para generar |
| --- | --- | --- |
| Tileset de Camino | Suelo, pared, techo, plataforma fina, esquinas y pendientes | Contorno de tinta fino sobre acuarela; praderas y caminos de lápiz |
| Fondo de Camino (acuarela) | 3 a 4 capas de parallax, repetibles en horizontal | Montañas pálidas, colinas verdes, casas de tejado rojizo y cielo con nubes en lavado, según la referencia 1 |
| La Pintura (centro del hub) | Incompleta, parcial y completa | Gran cuadro que representa la portada del álbum, dividido en regiones que se pintan con la paleta |
| Props | Postes, lápiz gigante, caballete, tronco, arbusto, cartel | Objetos decorativos; los pintables tienen versión boceto y versión completa |
| Enemigo Manchón | Reposo 4, saltar 6, golpe 4, muerte 5 | Slime de tinta negra brillante y sin forma que salta; el más fácil de vencer |
| Enemigo Murmullo | Volar 6, embestir 4, muerte 5 | Residuo de sombra y tinta que vuela y se burla; encarna miedo y ansiedad |
| Enemigo Manos de sombra | Emerger 5, acechar 4, agarrar 5, hundirse 4, muerte 5 | Manos de sombra que salen del suelo y agarran; las mismas del despertar |
| Enemigo Burlón | Reposo burlón 6, caminar 6, golpe pesado 6, muerte 6 | Bruto musculoso de sombra y tinta que siempre se burla |
| Jefe de Camino | Reposo 6, 3 ataques de 8 frames, transición de fase 8, muerte 10 | Criatura de tinta que borra el camino |

### C. Un sueño y muchos momentos

| Sprite | Estados y frames | Descripción para generar |
| --- | --- | --- |
| Tileset onírico | Suelo, pared, plataformas, raíces | Bosque suave con contorno fino, bordes difuminados |
| Fondo de sueño (acuarela) | 3 a 4 capas de parallax | Cielo amarillo y naranja suave, sol pálido, árboles de copa azul y reflejos en el agua, según la referencia 2 |
| Cascada amarilla | Loop de 8 frames, tres tamaños de piezas | Pintura amarilla que cae; el amarillo de la paleta |
| Arpa rota | Entera, sin cuerdas 1, cuerdas sueltas 4 | Arpa grande abandonada de la que el lobito toma las cuerdas |
| Burbujas | Flotar 6, estallar 4 | Plataformas móviles con forma de recuerdo |
| Enemigo Recuerdo | Flotar 6, atacar 4, desvanecerse 5 | Fantasma translúcido con forma de silueta difusa |
| Enemigo Luciérnaga onírica | Volar 6, explotar 5 | Luz pequeña que persigue al jugador |
| Enemigo Raíz espina | Oculta 1, emerge 4, ataque 4 | Raíz que sale del suelo |
| Jefe de Un sueño | Reposo 6, 3 ataques, transición, muerte | Figura que cambia de forma; amarillo y azul claro |

### D. Cambio

| Sprite | Estados y frames | Descripción para generar |
| --- | --- | --- |
| Tileset por estación | Tres variantes de profundidad del mismo tileset (superficie, medio, fondo) | Mismas piezas, distinta paleta y detalles |
| Fondo de Cambio (acuarela) | 3 a 4 capas, vertical, repetible hacia abajo | Bosque sumergido en el mar: árboles y algas con luz que se filtra desde arriba; sin referencia aún |
| Hojas arrastradas por el viento | Loop de 6 frames | Partículas que indican la dirección del aire |
| Cascada azul | Loop de 8 frames | Pintura azul que cae; marca el final del nivel |
| Violín roto | Entero, sin cuerdas, cuerdas sueltas | Instrumento roto que entrega las cuerdas restantes |
| Enemigo Hoja cortante | Girar 6, embestir 4 | Hoja afilada que viaja con el viento |
| Enemigo Pez de corriente | Volar 6, picada 4, muerte 5 | Pez veloz que corta corrientes |
| Enemigo Ráfaga | Reposo 4, empujar 6 | Remolino que empuja al jugador |
| Jefe de Cambio | Reposo 6, ataques por estación 4×8, transición, muerte | Criatura que cambia de estación en cada fase |

### E. Miedo

| Sprite | Estados y frames | Descripción para generar |
| --- | --- | --- |
| Tileset costero | Rocas, muelle, acantilado, plataformas | Contorno de tinta sobre rocas oscuras |
| Fondo de Miedo (acuarela) | 4 capas, noche con niebla y faro | Sol grande rosa y naranja entre pinos morados oscuros, reflejos en el agua y chorreaduras, según la referencia 3 |
| Olas | Agitada 8 en loop, calmándose 6, calma 4 | Olas gigantes que bloquean el paso; el estado cambia con la música |
| Bote | Reposo 4, navegar 6, girar 4 | Bote pequeño donde cabe el lobito y la bufanda |
| Faro | Apagado 1, encendido 6 | Punto de referencia y puzzle de luz |
| Pintura roja | Brillo 6, recogida 4 | Objeto que da el color rojo |
| Enemigo Medusa de sombra | Flotar 6, descarga 4 | Medusa oscura con luz roja |
| Enemigo Pez espectro | Nadar 6, saltar 4, muerte 5 | Pez que salta desde las olas |
| Enemigo Marejada | Avanzar 6, embestir 6 | Ola pequeña con cara; exige escudo |
| Jefe de Miedo | Reposo 6, ataques de ola 4×8, transición, muerte | Ola colosal con forma de bestia |

### F. Al final

| Sprite | Estados y frames | Descripción para generar |
| --- | --- | --- |
| Tileset final | Mezcla de los cuatro tilesets anteriores, con bordes que los unen | Cumbre de piedra con contorno de tinta |
| Fondo final (acuarela) | 4 capas | Atardecer en un muelle, con la cabeza de la portada del álbum asomando al fondo y un elemento adicional por definir; sin referencia aún |
| Goma arábiga | Brillo 6, recogida 4 | Objeto que da el agarre de pared (propuesta) |
| Muros de agarre | Normal y agarrado | Muros con textura que el lobito puede escalar |
| Sala de paleta | Mesa de paleta, vacía y con color, 4 frames | Lugar de prueba de los colores antes del jefe (por definir) |
| Enemigos de la zona | Versiones apagadas de Manchón, Recuerdo, Hoja y Marejada | Misma silueta, paleta gris |
| Jefe final | Reposo, 5 ataques, 3 transiciones de fase, muerte | El más grande del juego; se debilita al pintar el paisaje de la arena |
| Escena de cierre | 4 a 6 ilustraciones fijas | Imágenes finales del lobito y La Pintura completa |

## 8. Qué falta: ideas y decisiones abiertas

**Entrada a Al final.** Tres ideas que combinan color y música:

| Opción | Qué pasa | Por qué funciona |
| --- | --- | --- |
| A. Completar La Pintura (recomendada) | En el hub, el jugador pinta el cuadro con los colores que ya tiene y toca la melodía final; el cuadro se abre y se entra en él | La Pintura es el centro del mapa y representa la portada del álbum |
| B. Cuatro sellos de color | Cada zona deja un sello; en el hub se tocan cuatro notas en el orden de las zonas, cada una con su color | Obliga a recordar el recorrido del álbum |
| C. Puente de color | Se pinta un puente de seis colores sobre un abismo del hub y se toca la melodía para que se afirme | Premia haber mezclado todos los secundarios |

**Habilidad de pared en Al final.** Debe ligarse al arte:

| Opción | Historia |
| --- | --- |
| A. Goma arábiga (recomendada) | Es el aglutinante real de la acuarela; el pigmento se pega al papel, y el lobito a los muros |
| B. Espátula del pintor | Se clava en la pared como un piolet |
| C. Carboncillo | Las manos dejan marcas que se agarran a la piedra |

**Decisiones de diseño pendientes**

- Elegir moneda (corcheas, partituras o acuarelas) y el indicador de ánimo (pentagrama, bufanda o retrato).
- Jefes de Un sueño, Cambio y Miedo: forma, ataques y qué aprende el jugador al vencerlos.
- Qué gasta esencia (¿solo las flechas?) y cuánto dura cada recarga.
- Cómo se tocan las melodías con el arpa en el control.
- Qué región de La Pintura abre cada color y qué utilidad tiene cada color secundario.
- Qué cambia en el mundo interior al pintar cada región de La Pintura.

**Elementos que aún no aparecen en tus notas**

- Música: cada zona lleva la canción que tiene su nombre; faltan el menú, las salas de jefe y los efectos de sonido.
- Historia: quién es el lobito y qué representa La Pintura completa.
- Referencias para los fondos de Cambio (bosque sumergido) y Al final (muelle al atardecer).
- Plataforma y control: teclado, mando o ambos, y resolución de pantalla.
- Dificultad, guardado y accesibilidad (por ejemplo, ayudas de daño).

**Qué llevar a la conversación principal**

1. Este documento.
2. Las tres referencias de acuarela.
3. El mapa de Hollow Knight con el área marcada y una imagen de su personaje para el estilo.
4. La hoja de estilo del lobito, cuando exista.

**Orden de trabajo sugerido**

1. Hoja de estilo del lobito y de un fondo de prueba (Camino).
2. Tileset, fondo y tres enemigos de Camino.
3. Prototipo de Camino con pincel, bocetos y escudo.
4. Las demás zonas en el orden del álbum.

## 9. Prompts de sprites listos para copiar

Cada recuadro es un mensaje completo para la conversación principal. Pega primero el prefijo que corresponda (sprites o fondos) y, justo después, el prompt del elemento. Adjunta la referencia de acuarela de la zona en los fondos y la hoja de estilo del lobito en todos los sprites, cuando ya exista. Los frames son un mínimo propuesto.

**Prefijo para sprites**

```text
Ilustración 2D dibujada a mano, estilo cartoon gótico tipo Hollow Knight. Contorno de tinta negra grueso y limpio, de ancho constante. Color casi plano con una o dos sombras duras, sin texturas finas. Silueta simple y reconocible a tamaño chico, formas redondeadas. Vista lateral 2D. Fondo transparente. Hoja de sprites alineada en cuadrícula, un frame por celda, con el mismo tamaño de celda y la misma escala en todos los frames. Protagonista: lobito de pelaje oscuro, hocico y ojos grandes claros, bufanda larga y pincel en la mano.
```

**Prefijo para fondos**

```text
Fondo de videojuego 2D en acuarela: lavados húmedo sobre húmedo, bordes difusos y manchas de pigmento que se expanden, pigmento transparente que deja ver el blanco del papel, textura de papel de acuarela con granulación suave y goteos o chorreaduras en los bordes. Sin contornos de tinta y sin personajes. Entregar por capas separadas de parallax (lejana, media y cercana), repetibles en horizontal, más pálidas y menos saturadas cuanto más lejos, con niebla o lavado blanco entre capas.
```

**Orden sugerido:** primero el prompt 1 (hoja de estilo del lobito) y apruébalo; después el resto de la sección A; luego las zonas en el orden del álbum.

### A1. Globales: lobito, bufanda, pincel, arco y flecha roja

**1. Hoja de estilo del lobito**

```text
Hoja de estilo del personaje: el lobito, de frente, de perfil y de tres cuartos, en pose neutra, más tres expresiones de cara (neutral, determinado, asustado) y una pose sosteniendo el pincel. Pelaje oscuro casi negro, hocico y ojos grandes claros, orejas puntiagudas, bufanda larga de un solo color liso, cuerpo pequeño y redondeado. Añadir muestras de la paleta de colores usada. Sin animación.
```

**2a. Lobito: reposo**

```text
Hoja de sprites del lobito en reposo, 4 frames: respiración suave, la bufanda se mueve poco, pose relajada pero alerta. Mirando a la derecha.
```

**2b. Lobito: correr**

```text
Hoja de sprites del lobito corriendo, 8 frames con ciclo fluido: cuerpo inclinado hacia adelante y bufanda ondeando hacia atrás. Mirando a la derecha.
```

**3a. Lobito: salto**

```text
Hoja de sprites del lobito saltando, 3 frames: impulso, ascenso y cima del salto. Mirando a la derecha, bufanda siguiendo el movimiento.
```

**3b. Lobito: caída**

```text
Hoja de sprites del lobito cayendo, 2 frames: cuerpo estirado hacia abajo, bufanda subiendo. Mirando a la derecha.
```

**3c. Lobito: aterrizaje**

```text
Hoja de sprites del lobito aterrizando, 3 frames: impacto, rodillas flexionadas con rebote y recuperación. Mirando a la derecha, bufanda siguiendo el movimiento.
```

**4a. Lobito: primer golpe con el pincel**

```text
Hoja de sprites del lobito dando un golpe con el pincel de arriba hacia abajo, 4 frames, con anticipación marcada. Mirando a la derecha. Sin el efecto de la pincelada; se entrega aparte.
```

**4b. Lobito: segundo golpe con el pincel**

```text
Hoja de sprites del lobito dando un golpe con el pincel de abajo hacia arriba, 4 frames, con anticipación marcada. Mirando a la derecha. Sin el efecto de la pincelada; se entrega aparte.
```

**4c. Lobito: estocada con el pincel**

```text
Hoja de sprites del lobito dando una estocada hacia adelante con el pincel, 4 frames, con anticipación marcada. Mirando a la derecha. Sin el efecto de la pincelada; se entrega aparte.
```

**4d. Lobito: ataque hacia arriba**

```text
Hoja de sprites del lobito atacando hacia arriba con el pincel, 4 frames, con anticipación marcada. Mirando a la derecha. Sin el efecto de la pincelada; se entrega aparte.
```

**4e. Lobito: ataque hacia abajo**

```text
Hoja de sprites del lobito atacando hacia abajo con el pincel (en el aire), 4 frames, con anticipación marcada. Mirando a la derecha. Sin el efecto de la pincelada; se entrega aparte.
```

**5a. Lobito: dash (con aire)**

```text
Hoja de sprites del lobito haciendo un dash, en 6 frames, mirando a la derecha. Frame 1: anticipación, cuerpo agachado y comprimido, orejas hacia atrás. Frames 2 a 4: cuerpo estirado y horizontal, brazos y pincel hacia atrás, bufanda recta detrás. Frames 5 y 6: frenado con un pequeño deslizamiento. Efecto de aire integrado en cada frame: ráfagas de viento blanco crema dibujadas como trazos curvos de pincel, pequeñas espirales de aire que salen de su espalda empujándolo, líneas de velocidad finas pegadas al cuerpo y motas de aire pálidas que quedan atrás. Se debe sentir que el aire lo impulsa y que él lo domina. Las partículas llevan contorno de tinta negra fino y son semitransparentes. Entregar dos versiones de la hoja: con partículas y solo el lobito, para ajustar el efecto en el motor.
```

**5b. Lobito: planeo (con aire)**

```text
Hoja de sprites del lobito planeando, en 10 frames, mirando a la derecha. Frames 1 a 3: abrir el planeo, la bufanda se extiende como una vela y los brazos se abren. Frames 4 a 7: planeo sostenido en bucle, cuerpo apenas inclinado hacia adelante, bufanda hinchada por el aire, orejas hacia atrás. Frames 8 a 10: cerrar el planeo y recoger los brazos. Efecto de aire integrado: corrientes curvas de aire blanco crema que suben desde abajo y sostienen el cuerpo, pequeñas espirales en las puntas de los brazos y de la bufanda, ondas suaves alrededor de las manos que muestran que el lobito guía el aire. Las partículas llevan contorno de tinta negra fino y son semitransparentes. Entregar dos versiones: con partículas y solo el lobito.
```

**5c. Lobito: agarre de pared (con aire)**

```text
Hoja de sprites del lobito agarrado a una pared que está a su derecha, en 15 frames. Frames 1 a 3: agarrarse al chocar con la pared, cuerpo pegado y bufanda que cae. Frames 4 a 7: sostenido en bucle, con una leve sacudida de la bufanda. Frames 8 a 11: deslizarse despacio hacia abajo en bucle. Frames 12 a 15: impulso de salto desde la pared, empujando hacia la izquierda (usar solo si el juego tiene salto de pared). Efecto de aire integrado: pequeños remolinos de aire blanco crema que se arremolinan contra la pared en el contacto, motas de aire que suben pegadas a la pared mientras se desliza y una ráfaga en espiral que lo lanza en el salto. Se debe sentir que el lobito sujeta y controla el aire. Las partículas llevan contorno de tinta negra fino y son semitransparentes. Entregar dos versiones: con partículas y solo el lobito.
```

**6a. Lobito: escudo**

```text
Hoja de sprites del lobito levantando el escudo, 4 frames: traza con el pincel una pincelada en arco frente a él. Mirando a la derecha. Sin el efecto del escudo; se entrega aparte.
```

**6b. Lobito: tocar el arpa**

```text
Hoja de sprites del lobito tocando el arpa, 6 frames, con el pincel convertido en arpa, ojos cerrados y orejas ligeramente hacia atrás, en pose vulnerable. Mirando a la derecha.
```

**7a. Lobito: sacar el arco**

```text
Hoja de sprites del lobito sacando el arco, 3 frames: el pincel se transforma en arco en su mano. Mirando a la derecha.
```

**7b. Lobito: tensar el arco (carga normal)**

```text
Hoja de sprites del lobito tensando la cuerda del arco, 5 frames (carga normal). Mirando a la derecha. Sin efectos de flecha ni de color; se entregan aparte.
```

**7c. Lobito: disparar**

```text
Hoja de sprites del lobito disparando el arco, 4 frames: suelta la cuerda y el cuerpo se relaja. Mirando a la derecha. Sin efectos de flecha ni de color; se entregan aparte.
```

**7d. Lobito: carga larga (flecha roja)**

```text
Hoja de sprites del lobito con una carga larga del arco, 8 frames: mantiene la tensión el doble de tiempo, con el cuerpo más contraído y la bufanda tensa. Mirando a la derecha. Sin efectos de flecha ni de color; se entregan aparte.
```

**8a. Lobito: golpe recibido**

```text
Hoja de sprites del lobito recibiendo un golpe, 2 frames: sacudida hacia atrás. Mirando a la derecha.
```

**8b. Lobito: muerte**

```text
Hoja de sprites del lobito muriendo, 6 frames: cae de rodillas y se desvanece como tinta que se diluye. Mirando a la derecha.
```

**8c. Lobito: descanso junto al lago**

```text
Hoja de sprites del lobito sentado junto a un lago, 4 frames de descanso: respiración lenta, mirando el agua. Vista de perfil.
```

**9a. Bufanda: reposo**

```text
Pieza aparte de la bufanda del lobito, sin el cuerpo, en reposo, 4 frames. Misma forma y mismo color en todas las poses; extremo sin deshilachar, con punta redondeada.
```

**9b. Bufanda: viento fuerte**

```text
Pieza aparte de la bufanda del lobito, sin el cuerpo, con viento fuerte, 4 frames. Misma forma y mismo color en todas las poses; extremo sin deshilachar, con punta redondeada.
```

**9c. Bufanda: planeo**

```text
Pieza aparte de la bufanda del lobito, sin el cuerpo, extendida como una vela durante el planeo, 4 frames. Misma forma y mismo color en todas las poses; extremo sin deshilachar, con punta redondeada.
```

**10a. Pincel en tres formas**

```text
Hoja de sprites del pincel del lobito en tres formas, cada una en pose estática: pincel normal, pincel-arpa (con cuerdas finas tensadas sobre un marco curvo) y pincel-arco (arco tensado con la misma cuerda). Mismo mango y mismas proporciones en las tres.
```

**10b. Pincel: transición a arpa**

```text
Hoja de sprites del pincel del lobito transformándose de pincel normal a pincel-arpa, 4 frames de transición. Mismo mango y mismas proporciones.
```

**10c. Pincel: transición a arco**

```text
Hoja de sprites del pincel del lobito transformándose de pincel normal a pincel-arco, 4 frames de transición. Mismo mango y mismas proporciones.
```

**11a. Flecha normal**

```text
Hoja de sprites de una flecha hecha de un trazo de pincel: un trazo fino con punta redondeada, 1 frame, más una estela de 4 frames.
```

**11b. Flecha roja**

```text
Hoja de sprites de una flecha roja hecha de trazos de pincel: más gruesa, con punta afilada, estela de 4 frames y un impacto crítico de 5 frames en forma de mancha roja que salpica.
```

**11c. Flecha normal: variantes de color**

```text
Hoja de sprites de la flecha normal hecha de un trazo de pincel (1 frame y estela de 4 frames) en una variante para cada color de la paleta: negro, blanco, amarillo, azul, verde y rojo.
```

### A2. Globales: efectos, corcheas, paleta, puntos de control e interfaz

**12. Pincelada de ataque**

```text
Hoja de efectos de la pincelada de ataque del lobito: un trazo curvo de tinta negra con borde irregular y salpicaduras, en 4 frames (aparece, se extiende, se rompe, desaparece). Tres versiones: horizontal, hacia arriba y hacia abajo. Sin personaje.
```

**13. Escudo en arco, cinco niveles**

```text
Hoja de efectos del escudo del lobito: una barrera en arco hecha de una pincelada de acuarela. Aparece en 3 frames, activa en 4 frames en loop y se desvanece en 5 frames como si se disolviera en el aire. Cinco versiones por nivel de fuerza, cada una más densa y con una capa más de color: nivel 1 negro, nivel 2 blanco, nivel 3 amarillo, nivel 4 azul y nivel 5 rojo. Sin personaje.
```

**14. Dash y corrientes de aire**

```text
Hoja de efectos de viento pintado en blanco: estela de dash horizontal en 4 frames y una corriente de aire que sube, hecha de trazos curvos que se dibujan solos y flotan, en un loop de 6 frames. Trazos finos con contorno de tinta negra delgado, sobre fondo transparente. Sin personaje.
```

**15. Esencia: ráfagas de luz**

```text
Hoja de efectos de la esencia que sueltan los enemigos al ser derrotados: pequeñas ráfagas de luz de acuarela dorada y blanca que brotan en 4 frames, vuelan en un arco hacia la derecha en 6 frames de loop, con una estela corta, y se absorben en 4 frames. Sin contorno negro, solo luz suave. Debe distinguirse claramente de una moneda.
```

**16. Corchea (moneda): gris y pintada**

```text
Hoja de sprites de una corchea (nota musical) pequeña que sirve de moneda: corchea gris sin color, cayendo y rebotando en 4 frames; corchea ya pintada de amarillo dorado, con un destello, 4 frames; y recogida, 4 frames. Además una animación de 6 frames de una corchea gris que se llena de pintura amarilla. Contorno de tinta negra grueso, tamaño muy pequeño y legible.
```

**17. Paleta de pintor y colores**

```text
Hoja de sprites de una paleta de pintor de madera vista de frente, con espacios para los cinco colores base (negro, blanco, amarillo, azul, rojo) y los colores secundarios (verde, naranja, morado). Una versión con todos los espacios vacíos y una versión con cada espacio lleno, cada color en su gota de pintura brillante, más un efecto de 4 frames cuando un espacio se llena. Al lado, 8 iconos cuadrados de los colores, para interfaz.
```

**18. Notas musicales (efectos del arpa)**

```text
Hoja de efectos de seis notas musicales distintas que flotan al tocar un arpa, cada una con un símbolo propio (por ejemplo corchea, negra, blanca, clave, bemol y sostenido) y 4 frames de brillo suave en loop. Trazos de tinta con un toque de color dorado. Sin personaje.
```

**19. Bocetos de entradas**

```text
Hoja de sprites de tres elementos de escenario que se pueden terminar con el pincel: una puerta, un puente y una plataforma. Cada uno en tres estados del mismo tamaño: solo líneas de lápiz grises, a medio pintar con tinta negra y completo y sólido. Los tres estados deben poder superponerse exactamente.
```

**20. Sello musical**

```text
Hoja de sprites de un sello musical grabado en una roca: un círculo con un pentagrama y una clave, apagado (1 frame) y activo con un brillo dorado pulsando (4 frames en loop). Contorno de tinta negra, textura de piedra sencilla.
```

**21. Interruptor lejano**

```text
Hoja de sprites de un interruptor circular para golpear con flechas desde lejos: inactivo (1 frame), golpeado (3 frames de vibración) y activo (1 frame, con un brillo). Diseño simple, tipo diana pintada.
```

**22. Punto de control: banca, cascada y lago de tinta**

```text
Hoja de sprites del punto de control: una banca de madera libre (1 frame) y usada (4 frames), una pequeña cascada de tinta negra y plateada en loop de 8 frames que cae a un lago de tinta con ondas suaves (4 frames). Cada uno por separado para componer la escena. Contorno de tinta negra.
```

**23. Pintura portal**

```text
Hoja de sprites de un marco de pintura que funciona como atajo de viaje rápido: cerrado (1 frame) y abierto, con una ventana brillante que muestra remolinos de acuarela (6 frames en loop). Marco de madera con contorno de tinta negra.
```

**24a. El copista: reposo**

```text
Hoja de sprites del copista, personaje fijo que transcribe mapas como partituras: un personaje pequeño y amable, sentado ante un caballete con papeles de partitura, con una pluma. Animación: reposo, 4 frames. Diseño propio, distinto al lobito, con contorno de tinta negra grueso.
```

**24b. El copista: hablar**

```text
Hoja de sprites del copista, personaje fijo que transcribe mapas como partituras: un personaje pequeño y amable, sentado ante un caballete con papeles de partitura, con una pluma. Animación: hablar, 4 frames. Diseño propio, distinto al lobito, con contorno de tinta negra grueso.
```

**25. Interfaz: ánimo, esencia, corcheas y marco de mapa**

```text
Hoja de interfaz: un pentagrama con cinco notas, cada una encendida (dorada) y apagada (gris), para mostrar el ánimo del lobito; un medidor de esencia hecho de una gota de luz con 6 niveles de llenado; un contador de corcheas con su icono; y un marco decorativo para el mapa, con volutas blancas finas sobre fondo negro. Estilo coherente con Hollow Knight.
```

**26. Regiones pintables de La Pintura**

```text
Hoja de sprites de las partes del cuadro principal que se pintan con la paleta, una por color (negro, blanco, amarillo, azul, verde, rojo): cada región en dos estados, sin descubrir (un boceto gris de líneas finas) y pintada (llena de color de acuarela con textura de papel). Sin contorno negro grueso, estilo acuarela.
```

**27. Enredaderas: rotas y vivas**

```text
Hoja de sprites de enredaderas trepables en vertical: versión sin color, grises y quebradizas, que se rompen en 4 frames, y versión pintada de verde, vivas y firmes, que crecen en 6 frames. Contorno de tinta negra fino, segmentos repetibles en vertical.
```

### B. Camino

**28. Tileset de Camino**

```text
Tileset 2D lateral para el mundo Camino, en cuadrícula de tiles cuadrados: suelo de pradera con tapa de hierba, pared de tierra, techo, plataforma fina, esquinas interiores y exteriores, y pendientes suaves. Contorno de tinta negra fino sobre relleno de acuarela verde suave y ocre, con textura de papel. Tiles que encajan sin costuras.
```

**29. Fondo de Camino (acuarela)**

```text
Fondo de Camino, tres a cuatro capas separadas: montañas pálidas al fondo, colinas verdes, casas de tejado rojizo a lo lejos, un río azul claro y cielo con nubes en lavado. Paleta de verdes suaves, amarillos cálidos y blanco de papel; ambiente calmo y luminoso. Imitar la referencia 1 adjunta (acuarela de montaña y puente de piedra).
```

**30. La Pintura (centro del hub)**

```text
Un gran cuadro enmarcado en el centro de un claro, que representa la portada del álbum: tres estados, incompleto (solo líneas de boceto gris), parcial (algunas regiones pintadas en acuarela) y completo (toda la pintura a color). Marco de madera con contorno de tinta negra; la pintura en estilo acuarela. Tamaño grande, ocupa casi toda la pantalla.
```

**31. Elementos de escenario de Camino**

```text
Hoja de props 2D para Camino: poste de madera, lápiz gigante clavado en el suelo, caballete, tronco, arbusto, cartel de flecha y un banco pequeño. Cada uno en versión completa y en versión boceto (solo líneas de lápiz grises) cuando es un elemento pintable. Contorno de tinta negra grueso.
```

**32a. Enemigo Manchón: reposo**

```text
Hoja de sprites del enemigo Manchón, el enemigo terrestre más simple: un slime de tinta negra brillante y sin forma, como una gota espesa con un reflejo blanco de brillo y dos ojos blancos pequeños, con chorreaduras y salpicaduras de tinta alrededor. Animación: reposo, 4 frames (se estira y se encoge). Mirando a la derecha. Imitar la referencia adjunta de manchas de tinta negra brillante.
```

**32b. Enemigo Manchón: saltar**

```text
Hoja de sprites del enemigo Manchón, el enemigo terrestre más simple: un slime de tinta negra brillante y sin forma, con un reflejo blanco de brillo y dos ojos blancos pequeños, con chorreaduras de tinta. Animación: saltar, 6 frames (se aplasta, salta y cae como gelatina). Mirando a la derecha. Imitar la referencia adjunta de manchas de tinta negra brillante.
```

**32c. Enemigo Manchón: golpe**

```text
Hoja de sprites del enemigo Manchón, un slime de tinta negra brillante y sin forma, con un reflejo blanco de brillo y dos ojos blancos pequeños. Animación: golpe, 4 frames (se lanza contra el jugador y rebota). Mirando a la derecha. Imitar la referencia adjunta de manchas de tinta negra brillante.
```

**32d. Enemigo Manchón: muerte**

```text
Hoja de sprites del enemigo Manchón, un slime de tinta negra brillante y sin forma, con un reflejo blanco de brillo y dos ojos blancos pequeños. Animación: muerte, 5 frames (se derrama como un charco de tinta y se seca). Imitar la referencia adjunta de manchas de tinta negra brillante.
```

**33a. Enemigo Murmullo: volar**

```text
Hoja de sprites del enemigo Murmullo, un enemigo volador hecho de residuos de sombra y tinta que encarna el miedo, la ansiedad y la burla: una nube irregular de humo negro y tinta con jirones que cuelgan, ojos blancos entrecerrados y una boca ancha y torcida que se ríe, con gotas de tinta que caen. Animación: volar, 6 frames (flota ondulando). Mirando a la derecha. Contorno de tinta negra, silueta irregular pero legible. Imitar la referencia adjunta del fantasma de tinta con goteo.
```

**33b. Enemigo Murmullo: burlarse**

```text
Hoja de sprites del enemigo Murmullo, un enemigo volador de humo negro y tinta con jirones que cuelgan, ojos blancos entrecerrados y una boca ancha y torcida. Animación: burlarse, 4 frames (se ríe temblando y se acerca a la cara del jugador). Mirando a la derecha. Imitar la referencia adjunta del fantasma de tinta con goteo.
```

**33c. Enemigo Murmullo: embestir**

```text
Hoja de sprites del enemigo Murmullo, un enemigo volador de humo negro y tinta con jirones que cuelgan, ojos blancos entrecerrados y una boca ancha y torcida. Animación: embestir, 4 frames (se estira y se lanza en línea recta). Mirando a la derecha. Imitar la referencia adjunta del fantasma de tinta con goteo.
```

**33d. Enemigo Murmullo: muerte**

```text
Hoja de sprites del enemigo Murmullo, un enemigo volador de humo negro y tinta con jirones que cuelgan, ojos blancos entrecerrados y una boca ancha y torcida. Animación: muerte, 5 frames (se deshace en gotas y humo). Imitar la referencia adjunta del fantasma de tinta con goteo.
```

**34a. Enemigo Manos de sombra: emerger**

```text
Hoja de sprites del enemigo Manos de sombra: una mano grande hecha de sombra y tinta negra, de dedos largos y huesudos con goteo, que sale del suelo. Animación: emerger, 5 frames. Entregar una variante de una mano y otra de dos manos juntas. Sin ojos; solo silueta y pequeños brillos blancos en las uñas. Contorno de tinta negra grueso.
```

**34b. Enemigo Manos de sombra: acechar**

```text
Hoja de sprites del enemigo Manos de sombra: una mano grande de sombra y tinta negra, de dedos largos y huesudos con goteo, medio salida del suelo. Animación: acechar, 4 frames (los dedos se mueven). Variante de una mano y de dos manos. Sin ojos; pequeños brillos blancos en las uñas. Contorno de tinta negra grueso.
```

**34c. Enemigo Manos de sombra: agarrar**

```text
Hoja de sprites del enemigo Manos de sombra: una mano grande de sombra y tinta negra, de dedos largos y huesudos con goteo. Animación: agarrar, 5 frames (los dedos se cierran). Variante de una mano y de dos manos. Sin ojos; pequeños brillos blancos en las uñas. Contorno de tinta negra grueso.
```

**34d. Enemigo Manos de sombra: hundirse**

```text
Hoja de sprites del enemigo Manos de sombra: una mano grande de sombra y tinta negra, de dedos largos y huesudos con goteo. Animación: hundirse en el suelo, 4 frames. Variante de una mano y de dos manos. Contorno de tinta negra grueso.
```

**34e. Enemigo Manos de sombra: muerte**

```text
Hoja de sprites del enemigo Manos de sombra: una mano grande de sombra y tinta negra, de dedos largos y huesudos con goteo. Animación: muerte, 5 frames (se deshace en tinta). Variante de una mano y de dos manos. Contorno de tinta negra grueso.
```

**34f. Enemigo Burlón: reposo burlón**

```text
Hoja de sprites del enemigo Burlón: un bruto musculoso de hombros enormes hecho de sombra y tinta negra, con brazos gruesos, torso ancho, cabeza pequeña, ojos blancos entrecerrados y una sonrisa enorme de dientes blancos; siempre se está burlando. Animación: reposo burlón, 6 frames (se ríe y señala, los hombros rebotan). Mirando a la derecha. Contorno de tinta negra grueso. Tamaño aproximado de una vez y media el lobito.
```

**34g. Enemigo Burlón: caminar**

```text
Hoja de sprites del enemigo Burlón: un bruto musculoso de hombros enormes hecho de sombra y tinta negra, con brazos gruesos, cabeza pequeña, ojos blancos entrecerrados y una sonrisa enorme de dientes blancos. Animación: caminar, 6 frames (paso pesado y arrogante). Mirando a la derecha. Contorno de tinta negra grueso.
```

**34h. Enemigo Burlón: golpe pesado**

```text
Hoja de sprites del enemigo Burlón: un bruto musculoso de hombros enormes hecho de sombra y tinta negra, con brazos gruesos, cabeza pequeña, ojos blancos entrecerrados y una sonrisa enorme de dientes blancos. Animación: golpe pesado, 6 frames con anticipación larga. Mirando a la derecha. Contorno de tinta negra grueso.
```

**34i. Enemigo Burlón: muerte**

```text
Hoja de sprites del enemigo Burlón: un bruto musculoso de sombra y tinta negra, con brazos gruesos, cabeza pequeña, ojos blancos entrecerrados y una sonrisa enorme de dientes blancos. Animación: muerte, 6 frames (se encoge y se deshace sin dejar de sonreír). Contorno de tinta negra grueso.
```

**35. Jefe de Camino (pendiente)**

Pendiente: los jefes se diseñan al llegar a sus niveles.

**36. Arena del jefe de Camino**

```text
Tileset de una arena de jefe cerrada para Camino: suelo plano ancho, paredes altas y techo, con el mismo estilo que el tileset del mundo pero más oscuro y con manchas de tinta en el suelo. Contorno de tinta negra fino sobre acuarela.
```

### C. Un sueño y muchos momentos

**37. Tileset onírico**

```text
Tileset 2D lateral para el mundo Un sueño y muchos momentos, en cuadrícula de tiles cuadrados: suelo, pared, plataformas flotantes y raíces entrelazadas. Contorno de tinta negra fino sobre relleno de acuarela en amarillos suaves, azules claros y lilas, con bordes difuminados. Tiles que encajan sin costuras.
```

**38. Fondo de Un sueño (acuarela)**

```text
Fondo de Un sueño y muchos momentos, tres a cuatro capas separadas: cielo amarillo y naranja suave, sol pálido y redondo, árboles de copa azul con ramas negras finas, lago con reflejos y recuerdos flotantes como burbujas de luz. Paleta de amarillos, azules claros y lilas; ambiente onírico y etéreo. Imitar la referencia 2 adjunta (árbol azul al atardecer).
```

**39. Cascada amarilla**

```text
Hoja de sprites de una cascada de pintura amarilla en loop de 8 frames, en tres tamaños de pieza (superior, media e inferior) que se pueden apilar, con salpicaduras en la base. Es la cascada donde el lobito obtiene el color amarillo. Contorno de tinta negra fino sobre acuarela amarilla brillante.
```

**40. Arpa rota**

```text
Hoja de sprites de un arpa grande y rota abandonada en el suelo: entera con cuerdas (1 frame), sin cuerdas (1 frame) y cuerdas sueltas flotando hacia el pincel en 4 frames. Madera clara agrietada, contorno de tinta negra grueso, detalles dorados.
```

**41. Burbujas de recuerdo**

```text
Hoja de sprites de burbujas flotantes que sirven de plataformas móviles: flotar en 6 frames y estallar en 4 frames. Cada burbuja transparente con un recuerdo borroso dentro, en acuarela, con contorno de tinta negra fino.
```

**42a. Enemigo Recuerdo: flotar**

```text
Hoja de sprites del enemigo Recuerdo: un fantasma translúcido con forma de silueta difusa y ojos blancos. Animación: flotar, 6 frames. Contorno de tinta negra grueso con relleno azul claro semitransparente.
```

**42b. Enemigo Recuerdo: atacar**

```text
Hoja de sprites del enemigo Recuerdo: un fantasma translúcido con forma de silueta difusa y ojos blancos. Animación: atacar, 4 frames. Contorno de tinta negra grueso con relleno azul claro semitransparente.
```

**42c. Enemigo Recuerdo: desvanecerse**

```text
Hoja de sprites del enemigo Recuerdo: un fantasma translúcido con forma de silueta difusa y ojos blancos. Animación: desvanecerse, 5 frames. Contorno de tinta negra grueso con relleno azul claro semitransparente.
```

**43a. Enemigo Luciérnaga onírica: volar**

```text
Hoja de sprites del enemigo Luciérnaga onírica: una luz pequeña con alas finas que persigue al jugador. Animación: volar, 6 frames. Contorno de tinta negra, brillo amarillo suave.
```

**43b. Enemigo Luciérnaga onírica: explotar**

```text
Hoja de sprites del enemigo Luciérnaga onírica: una luz pequeña con alas finas. Animación: explotar en un destello, 5 frames. Contorno de tinta negra, brillo amarillo suave.
```

**44a. Enemigo Raíz espina: oculta**

```text
Hoja de sprites del enemigo Raíz espina: una raíz con espinas que sale del suelo. Animación: oculta, 1 frame (solo un bulto en el suelo). Contorno de tinta negra grueso, color marrón oscuro con puntas claras.
```

**44b. Enemigo Raíz espina: emerger**

```text
Hoja de sprites del enemigo Raíz espina: una raíz con espinas que sale del suelo. Animación: emerger, 4 frames. Contorno de tinta negra grueso, color marrón oscuro con puntas claras.
```

**44c. Enemigo Raíz espina: ataque**

```text
Hoja de sprites del enemigo Raíz espina: una raíz con espinas que sale del suelo. Animación: ataque, 4 frames. Contorno de tinta negra grueso, color marrón oscuro con puntas claras.
```

**45. Jefe de Un sueño (pendiente)**

Pendiente: los jefes se diseñan al llegar a sus niveles.

**46. Arena del jefe de Un sueño**

```text
Tileset de una arena de jefe cerrada para Un sueño y muchos momentos: suelo plano ancho, paredes y techo de raíces y burbujas, con el mismo estilo que el tileset del mundo pero con luz más intensa. Contorno de tinta negra fino sobre acuarela.
```

### D. Cambio

**47. Tileset de Cambio, tres profundidades**

```text
Tileset 2D lateral para el mundo Cambio, un bosque sumergido en el mar, en cuadrícula de tiles cuadrados: suelo de arena y raíces, pared de coral y troncos, plataformas y esquinas. Tres variantes de la misma pieza según la profundidad: superficie (turquesa claro), medio (azul) y fondo (azul oscuro con verdes profundos). Contorno de tinta negra fino sobre acuarela.
```

**48. Fondo de Cambio (acuarela)**

```text
Fondo de Cambio, tres a cuatro capas separadas, vertical y repetible hacia abajo: un bosque de árboles y algas sumergido en el mar, con rayos de luz que se filtran desde arriba, burbujas, siluetas de troncos lejanos y niebla azul entre capas. Paleta de azules profundos, verdes de alga, turquesa y destellos de luz; ambiente sumergido y silencioso. Imitar la mitad submarina de la portada del álbum adjunta: bosque de árboles pelados bajo el agua con rayos de luz.
```

**49. Burbujas y corrientes de agua**

```text
Hoja de efectos de partículas bajo el agua: burbujas que suben (loop de 6 frames) y corrientes de agua hechas de trazos curvos blancos y azules que indican la dirección del flujo (loop de 6 frames). Trazos finos, contorno de tinta negra delgado. Sin personaje.
```

**50. Cascada azul**

```text
Hoja de sprites de una cascada de pintura azul en loop de 8 frames, en tres tamaños de pieza que se pueden apilar, con salpicaduras en la base. Es la cascada donde el lobito obtiene el color azul. Contorno de tinta negra fino sobre acuarela azul intensa.
```

**51. Violín roto**

```text
Hoja de sprites de un violín grande y roto abandonado en el fondo del mar: entero (1 frame), sin cuerdas (1 frame) y cuerdas sueltas que flotan hacia el pincel (4 frames). Madera oscura agrietada cubierta de algas, contorno de tinta negra grueso.
```

**52a. Enemigo Hoja cortante: girar**

```text
Hoja de sprites del enemigo Hoja cortante: una hoja de alga afilada que gira y se arrastra con la corriente. Animación: girar, 6 frames. Contorno de tinta negra grueso, verde oscuro con borde claro.
```

**52b. Enemigo Hoja cortante: embestir**

```text
Hoja de sprites del enemigo Hoja cortante: una hoja de alga afilada. Animación: embestir, 4 frames. Contorno de tinta negra grueso, verde oscuro con borde claro.
```

**53a. Enemigo Pez de corriente: nadar**

```text
Hoja de sprites del enemigo Pez de corriente: un pez veloz y delgado, con aletas largas y ojos grandes, que corta las corrientes. Animación: nadar, 6 frames. Contorno de tinta negra grueso, azul y plata.
```

**53b. Enemigo Pez de corriente: picada**

```text
Hoja de sprites del enemigo Pez de corriente: un pez veloz y delgado, con aletas largas y ojos grandes. Animación: picada, 4 frames. Contorno de tinta negra grueso, azul y plata.
```

**53c. Enemigo Pez de corriente: muerte**

```text
Hoja de sprites del enemigo Pez de corriente: un pez veloz y delgado, con aletas largas y ojos grandes. Animación: muerte, 5 frames. Contorno de tinta negra grueso, azul y plata.
```

**54a. Enemigo Ráfaga: reposo**

```text
Hoja de sprites del enemigo Ráfaga: un remolino de agua con dos ojos pequeños que empuja al jugador. Animación: reposo, 4 frames. Trazos curvos blancos y azules con contorno de tinta negra delgado.
```

**54b. Enemigo Ráfaga: empujar**

```text
Hoja de sprites del enemigo Ráfaga: un remolino de agua con dos ojos pequeños que empuja al jugador. Animación: empujar, 6 frames. Trazos curvos blancos y azules con contorno de tinta negra delgado.
```

**55. Jefe de Cambio (pendiente)**

Pendiente: los jefes se diseñan al llegar a sus niveles.

**56. Arena del jefe de Cambio**

```text
Tileset de una arena de jefe cerrada para Cambio: suelo plano ancho de arena y raíces, paredes y techo de troncos y coral, con el mismo estilo que el tileset del mundo pero en la profundidad más oscura. Contorno de tinta negra fino sobre acuarela.
```

### E. Miedo

**57. Tileset costero**

```text
Tileset 2D lateral para el mundo Miedo, en cuadrícula de tiles cuadrados: rocas oscuras, muelle de madera, acantilado, plataformas y esquinas. Contorno de tinta negra fino sobre relleno de acuarela en negros, azules profundos y morados oscuros con destellos rojos. Tiles que encajan sin costuras.
```

**58. Fondo de Miedo (acuarela)**

```text
Fondo de Miedo, cuatro capas separadas: un sol grande rosa y naranja detrás de montañas, pinos morados oscuros a los lados, un faro lejano, agua con reflejos del sol y chorreaduras de pintura en el borde inferior, con niebla entre capas. Paleta de rojos, rosas, morados oscuros y negro; ambiente tenso y nocturno. Imitar la referencia 3 adjunta (sol grande entre pinos) y, para la ola con faro y el mar de tormenta, la portada del álbum adjunta.
```

**59. Olas gigantes**

```text
Hoja de sprites de olas gigantes que bloquean el paso, tres estados: agitada en loop de 8 frames (cresta enorme que rompe), calmándose en 6 frames y calma en 4 frames (agua casi plana con ondas suaves). Contorno de tinta negra fino sobre acuarela azul oscura con espuma blanca.
```

**60. Bote**

```text
Hoja de sprites de un bote de madera pequeño donde cabe el lobito con su bufanda, vacío: reposo 4 frames, navegar 6 frames y girar 4 frames. Contorno de tinta negra grueso, madera clara.
```

**61. Faro**

```text
Hoja de sprites de un faro de piedra con luz: apagado (1 frame) y encendido con un haz de luz giratorio (6 frames en loop). Contorno de tinta negra grueso, haz de luz en acuarela amarilla suave.
```

**62. Pintura roja**

```text
Hoja de sprites de la fuente del color rojo, un charco de pintura roja que brota y brilla en loop de 6 frames, más 4 frames de cuando el lobito la recoge y se absorbe. Contorno de tinta negra, acuarela roja intensa.
```

**63a. Enemigo Medusa de sombra: flotar**

```text
Hoja de sprites del enemigo Medusa de sombra: una medusa oscura con luz roja en el centro y tentáculos finos. Animación: flotar, 6 frames. Contorno de tinta negra grueso.
```

**63b. Enemigo Medusa de sombra: descarga eléctrica**

```text
Hoja de sprites del enemigo Medusa de sombra: una medusa oscura con luz roja en el centro y tentáculos finos. Animación: descarga eléctrica, 4 frames. Contorno de tinta negra grueso.
```

**64a. Enemigo Pez espectro: nadar**

```text
Hoja de sprites del enemigo Pez espectro: un pez de aspecto fantasmal que salta desde las olas. Animación: nadar, 6 frames. Contorno de tinta negra grueso, azul pálido semitransparente.
```

**64b. Enemigo Pez espectro: saltar**

```text
Hoja de sprites del enemigo Pez espectro: un pez de aspecto fantasmal. Animación: saltar fuera del agua, 4 frames. Contorno de tinta negra grueso, azul pálido semitransparente.
```

**64c. Enemigo Pez espectro: muerte**

```text
Hoja de sprites del enemigo Pez espectro: un pez de aspecto fantasmal. Animación: muerte, 5 frames. Contorno de tinta negra grueso, azul pálido semitransparente.
```

**65a. Enemigo Marejada: avanzar**

```text
Hoja de sprites del enemigo Marejada: una ola pequeña con dos ojos y dientes de espuma, que obliga a usar el escudo. Animación: avanzar, 6 frames. Contorno de tinta negra grueso, azul oscuro y espuma blanca.
```

**65b. Enemigo Marejada: embestir**

```text
Hoja de sprites del enemigo Marejada: una ola pequeña con dos ojos y dientes de espuma. Animación: embestir, 6 frames. Contorno de tinta negra grueso, azul oscuro y espuma blanca.
```

**66. Jefe de Miedo (pendiente)**

Pendiente: los jefes se diseñan al llegar a sus niveles.

**67. Arena del jefe de Miedo**

```text
Tileset de una arena de jefe para Miedo: una plataforma de piedra ancha sobre el mar, con acantilados a los lados y olas al fondo, con el mismo estilo que el tileset del mundo. Contorno de tinta negra fino sobre acuarela oscura.
```

### F. Al final

Para el fondo y el jefe final, adjunta la portada del álbum: de ahí sale la cabeza que aparece al fondo.

**68. Tileset de Al final**

```text
Tileset 2D lateral para el mundo Al final, en cuadrícula de tiles cuadrados: tablones de un muelle de madera, pilotes, rocas, plataformas, esquinas y pendientes, más piezas de piedra de una cumbre. Contorno de tinta negra fino sobre acuarela en naranjas y rosas de atardecer. Tiles que encajan sin costuras.
```

**69. Fondo de Al final (acuarela)**

```text
Fondo de Al final, cuatro capas separadas: un atardecer en un muelle sobre el mar, cielo en naranjas, rosas y amarillos con mucho blanco de papel, agua con reflejos, y al fondo, grande y lejana, la cabeza que aparece en la pintura de la portada del álbum (adjunta), semi-envuelta en niebla. Ambiente melancólico y de cierre. Usar la portada del álbum adjunta como referencia de paleta, composición y atmósfera: atardecer ámbar, puente en el horizonte y reflejo dorado en el agua.
```

**70. Goma arábiga**

```text
Hoja de sprites de un objeto que da el agarre de pared: una gota grande y dorada de goma arábiga, brillando en loop de 6 frames, y 4 frames de cuando el lobito la recoge y se absorbe. Contorno de tinta negra grueso, acuarela ámbar translúcida.
```

**71. Muros de agarre**

```text
Hoja de tiles de muros verticales que el lobito puede escalar: muro normal y muro agarrado (con una capa brillante de goma arábiga). Contorno de tinta negra fino, textura de piedra, tiles repetibles en vertical.
```

**72. Sala de paleta**

```text
Hoja de sprites de una mesa grande de mezclas de pintor: vacía y con pintura, en 4 frames de brillo suave, con cuencos pequeños de los seis colores (negro, blanco, amarillo, azul, verde y rojo). Contorno de tinta negra grueso.
```

**73a. Enemigos apagados: reposo**

```text
Hoja de sprites de versiones apagadas de los enemigos Manchón, Recuerdo, Hoja cortante y Marejada: la misma silueta que los originales pero en tonos grises, con los ojos blancos apagados. Animación: reposo, 4 frames, una fila por enemigo. Contorno de tinta negra grueso.
```

**73b. Enemigos apagados: ataque**

```text
Hoja de sprites de versiones apagadas de los enemigos Manchón, Recuerdo, Hoja cortante y Marejada: la misma silueta que los originales pero en tonos grises, con los ojos blancos apagados. Animación: ataque, 4 frames, una fila por enemigo. Contorno de tinta negra grueso.
```

**73c. Enemigos apagados: muerte**

```text
Hoja de sprites de versiones apagadas de los enemigos Manchón, Recuerdo, Hoja cortante y Marejada: la misma silueta que los originales pero en tonos grises, con los ojos blancos apagados. Animación: muerte, 5 frames, una fila por enemigo. Contorno de tinta negra grueso.
```

**74. Jefe final**

```text
Hoja de sprites del jefe final: la cabeza gigante dormida de la portada del álbum (adjunta), apoyada de lado y con los ojos cerrados, en estado gris y sin color, que despierta durante la pelea. Reposo 6 frames, cinco ataques de 8 frames cada uno, tres transiciones de fase de 8 frames, un frame de debilidad cuando el paisaje se pinta y muerte 12 frames. Contorno de tinta negra grueso.
```

**75. Arena del jefe final**

```text
Tileset y fondo de una arena de jefe para Al final: un muelle largo al atardecer, con partes del paisaje en gris sin descubrir que se pueden pintar y versiones pintadas a color en acuarela. Contorno de tinta negra fino en el muelle, sin contorno en el paisaje.
```

**76. Escena de cierre**

```text
Cuatro a seis ilustraciones fijas a pantalla completa, en acuarela, del final del juego: el lobito frente a La Pintura completa, el muelle al amanecer, la cabeza de la portada ya con color, y una última imagen del lobito sentado junto al agua. Mismo estilo de acuarela que los fondos, con el lobito en línea de tinta.
```

### G. Herrero, copista y pescador

**77a. Herrero: reposo**

```text
Hoja de sprites del herrero, personaje de Cambio: un personaje fornido y amable de pelo desordenado, con delantal de cuero y un martillo, sentado junto a una forja apagada. Animación: reposo, 4 frames. Diseño propio, distinto al lobito, con contorno de tinta negra grueso.
```

**77b. Herrero: martillar**

```text
Hoja de sprites del herrero, personaje de Cambio: un personaje fornido y amable de pelo desordenado, con delantal de cuero y un martillo. Animación: martillar, 6 frames. Diseño propio, distinto al lobito, con contorno de tinta negra grueso.
```

**77c. Herrero: hablar**

```text
Hoja de sprites del herrero, personaje de Cambio: un personaje fornido y amable de pelo desordenado, con delantal de cuero y un martillo. Animación: hablar, 4 frames. Diseño propio, distinto al lobito, con contorno de tinta negra grueso.
```

**78. Forja y llama de cambio**

```text
Hoja de sprites de una forja con yunque: apagada (1 frame), con una llama muy leve amarilla (4 frames en loop), con llama naranja media (4 frames en loop) y con la llama verdadera del cambio, naranja intensa con destellos rojos (6 frames en loop). Contorno de tinta negra grueso, brasas pequeñas que saltan.
```

**79. Estocada de fuego, tres niveles**

```text
Hoja de efectos de la estocada del pincel envuelta en fuego, tres niveles: nivel 1 con una llama leve amarilla, nivel 2 con llama roja y mayor alcance, y nivel 3 con llama naranja intensa y chispas. Cada nivel en 4 frames, con el efecto extendiéndose hacia la derecha. Sin personaje.
```

**80. Materiales de forja del copista**

```text
Hoja de tres iconos pequeños y cuadrados de materiales de forja, distintos entre sí: un trozo de pedernal, un carbón con vetas rojas y una ceniza brillante en un frasco. Contorno de tinta negra grueso, legibles a tamaño chico.
```

**81. Mezcladores de color**

```text
Hoja de dos iconos pequeños y cuadrados de mezcladores de pintor, uno para el verde y otro para el naranja: un mortero de vidrio con cuchara y una paleta de mezcla con pocillos. Cada uno con una variante apagada y otra brillante, con una gota de color. Contorno de tinta negra grueso.
```

**82a. Pez crepuscular: nadar**

```text
Hoja de sprites del pez crepuscular: un pez pequeño y delgado con un ojo azul y otro rojo, escamas plateadas con reflejos morados. Animación: nadar, 6 frames. Contorno de tinta negra grueso.
```

**82b. Pez crepuscular: salir a la superficie**

```text
Hoja de sprites del pez crepuscular: un pez pequeño y delgado con un ojo azul y otro rojo, escamas plateadas con reflejos morados. Animación: salir a la superficie, 4 frames. Contorno de tinta negra grueso.
```

**82c. Pez crepuscular: ser atrapado con la flecha**

```text
Hoja de sprites del pez crepuscular: un pez pequeño y delgado con un ojo azul y otro rojo, escamas plateadas con reflejos morados. Animación: ser atrapado con la flecha, 4 frames. Contorno de tinta negra grueso.
```

**82d. Pez crepuscular: soltarse en el agua**

```text
Hoja de sprites del pez crepuscular: un pez pequeño y delgado con un ojo azul y otro rojo, escamas plateadas con reflejos morados. Animación: soltarse en el agua, 4 frames. Contorno de tinta negra grueso.
```

**83. Agua morada**

```text
Hoja de efectos del agua morada que genera el pez al mezclar el agua azul y el agua roja: un charco que pasa de azul y rojo a morado, en 6 frames, y un loop de 6 frames de ondas moradas y destellos suaves. Sin contorno negro, acuarela morada translúcida.
```

**84a. Pescador: reposo despierto**

```text
Hoja de sprites del pescador del bote de la portada del álbum (adjunta): un hombre cansado, de pie con una caña, con la misma silueta que en la pintura. Animación: despierto y agotado en reposo, 4 frames. Contorno de tinta negra grueso.
```

**84b. Pescador: hablar**

```text
Hoja de sprites del pescador del bote de la portada del álbum (adjunta): un hombre cansado, de pie con una caña, con la misma silueta que en la pintura. Animación: hablar, 4 frames. Contorno de tinta negra grueso.
```

**84c. Pescador: dormido**

```text
Hoja de sprites del pescador del bote de la portada del álbum (adjunta): un hombre cansado, con la misma silueta que en la pintura. Animación: dormido, sentado en el bote, 4 frames de respiración lenta. Contorno de tinta negra grueso.
```

**85. Bote del pescador**

```text
Hoja de sprites del bote de madera pequeño del pescador de la portada del álbum (adjunta): con el pescador (reposo 4 frames), vacío (reposo 4 frames) y navegando con el lobito a bordo (6 frames). Contorno de tinta negra grueso.
```

**86. Torre de la cascada**

```text
Hoja de sprites de una torre de piedra pequeña junto a una cascada, como la de la portada del álbum (adjunta): cerrada con una puerta sellada de brillo morado (1 frame) y abierta (4 frames). Contorno de tinta negra fino sobre acuarela fría.
```

**87. Plataformas de sombra**

```text
Hoja de sprites de plataformas hechas de sombra morada oscura: aparecen en 4 frames, activas en loop de 4 frames y se desvanecen en 4 frames. Bordes difusos, sin contorno negro grueso, de tres tamaños distintos.
```

**88. Sueño de los enemigos**

```text
Hoja de efectos de un enemigo dormido: un símbolo de «zzz» morado que sube en loop de 6 frames y un destello morado de 4 frames cuando el enemigo se duerme. Sin personaje.
```

**89. Escudo del sueño**

```text
Hoja de efectos de la versión mejorada del escudo, de color morado: aparece en 3 frames, activa en 4 frames en loop, un destello de empuje de 4 frames al bloquear un ataque, con una onda que lanza hacia atrás al atacante y se desvanece en 5 frames. Mismo arco que el escudo normal, con una capa extra de luz morada. Sin personaje.
```

### H. Etapas de color de los fondos

Los prompts de fondo de las secciones B a F describen el estado final, ya pintado. Pide primero ese fondo y, con la misma composición, sus etapas. Cambia el texto entre corchetes por la zona o el color.

**90. Fondo en etapa de boceto a lápiz**

```text
Toma el fondo final de [ZONA] adjunto y entrega la misma composición exactamente igual, pero como un boceto a lápiz gris sobre papel blanco: solo líneas finas de grafito, sin color y sin rellenos, con sombras muy suaves. Mismas capas separadas de parallax, mismo encuadre y mismos elementos.
```

**91. Fondo en etapa de tinta negra**

```text
Toma el boceto a lápiz de [ZONA] adjunto y entrega la misma composición con las líneas principales y las plataformas pasadas a tinta negra, con trazo de pincel grueso y limpio, sobre papel blanco, sin color. Las plataformas transitables deben verse con un contorno claro. Mismo encuadre y capas.
```

**92. Capa de color transparente**

```text
Toma la composición de [ZONA] adjunta y entrega una capa transparente solo de acuarela de color [COLOR], que cubra únicamente las partes del paisaje que se pintan con ese color: [PARTES], y nada más. Fondo transparente, bordes difusos de acuarela, y la misma posición y tamaño que el fondo para poder superponerla exactamente.
```

**93. Puertas del cuadro, tres estados**

```text
Hoja de sprites de una puerta dentro de un cuadro enmarcado que lleva a una zona: en boceto a lápiz gris (1 frame), pintada con tinta negra (1 frame) y con una mancha de color de acuarela en su interior que se va llenando (6 frames). Marco de madera con contorno de tinta negra grueso. Una versión por zona.
```

**94. Plataformas que aparecen al pintar la puerta**

```text
Hoja de sprites de plataformas dibujadas en tinta negra que aparecen dentro de una zona cuando se pinta su puerta: boceto a lápiz (1 frame), trazo de tinta que se dibuja solo (5 frames) y plataforma sólida (1 frame), en tres tamaños. Contorno de tinta negra grueso.
```

### I. Inicio de Camino

Estos elementos aparecen en la primera zona, que al entrar no tiene color: todo va en gris a lápiz y tinta, hasta que el brochazo pinta parte del paisaje.

**95a. Sombras perseguidoras: correr**

```text
Hoja de sprites de una sombra que persigue al lobito: figura negra y alargada, sin rasgos salvo dos ojos blancos. Animación: correr hacia la izquierda, 6 frames. Contorno de tinta negra grueso, silueta irregular.
```

**95b. Sombras perseguidoras: estirarse**

```text
Hoja de sprites de una sombra que persigue al lobito: figura negra y alargada, sin rasgos salvo dos ojos blancos. Animación: estirarse para atrapar, 4 frames, hacia la izquierda. Contorno de tinta negra grueso, silueta irregular.
```

**95c. Sombras perseguidoras: desvanecerse**

```text
Hoja de sprites de una sombra que persigue al lobito: figura negra y alargada, sin rasgos salvo dos ojos blancos. Animación: desvanecerse, 5 frames. Contorno de tinta negra grueso, silueta irregular.
```

**96a. Manos del suelo: salir**

```text
Hoja de sprites de manos largas y negras que salen del suelo para agarrar. Animación: salir, 5 frames. Tres variantes de tamaño. Contorno de tinta negra grueso.
```

**96b. Manos del suelo: agarrar**

```text
Hoja de sprites de manos largas y negras que salen del suelo para agarrar. Animación: agarrar, 4 frames. Tres variantes de tamaño. Contorno de tinta negra grueso.
```

**96c. Manos del suelo: retirarse**

```text
Hoja de sprites de manos largas y negras que salen del suelo para agarrar. Animación: retirarse al suelo, 5 frames. Tres variantes de tamaño. Contorno de tinta negra grueso.
```

**96d. Manos del suelo: versión pintada**

```text
Hoja de sprites de manos largas en gris pálido y quietas, para cuando el paisaje ya está pintado: 1 frame por cada una de las tres variantes de tamaño. Contorno de tinta negra grueso.
```

**97a. Ojos en la oscuridad: abrir**

```text
Hoja de sprites de ojos de distintas formas y tamaños que flotan en la oscuridad (redondos, rasgados, múltiples, con pupila vertical). Animación: abrir, 4 frames. Blancos con pupila negra, sin cuerpo, fondo transparente.
```

**97b. Ojos en la oscuridad: mirar**

```text
Hoja de sprites de ojos de distintas formas y tamaños que flotan en la oscuridad (redondos, rasgados, múltiples, con pupila vertical). Animación: mirar, 4 frames en bucle. Blancos con pupila negra, sin cuerpo, fondo transparente.
```

**97c. Ojos en la oscuridad: cerrar**

```text
Hoja de sprites de ojos de distintas formas y tamaños que flotan en la oscuridad (redondos, rasgados, múltiples, con pupila vertical). Animación: cerrar, 4 frames. Blancos con pupila negra, sin cuerpo, fondo transparente.
```

**98. Niebla**

```text
Hoja de efectos de niebla para capas de primer plano: bandas de niebla gris que se desplazan lentamente en loop de 8 frames, repetibles en horizontal, en acuarela gris translúcida, sin contorno.
```

**99. Altar del pincel**

```text
Hoja de sprites de un altar de piedra con un pincel sobre él: protegido por una barrera de sombra (1 frame), con la barrera abriéndose (6 frames) y abierto con el pincel brillando suavemente (4 frames). Contorno de tinta negra grueso, piedra gris.
```

**100. Brochazo del escudo y paisaje pintado**

```text
Hoja de efectos del primer brochazo del lobito: una pincelada grande en arco que se extiende en 6 frames, forma el escudo y deja una mancha de acuarela que se expande por el paisaje a su alrededor en 8 frames, hasta quedar fija. Acuarela translúcida con textura de papel, sin contorno negro.
```

**101. Arco dañado y reparado**

```text
Hoja de sprites de la puerta de salida de Camino, un arco de piedra: dañado y agrietado, en boceto a lápiz gris (1 frame), repintado con tinta negra que se dibuja solo (6 frames) y completo (1 frame). Contorno de tinta negra grueso.
```

**102. Pozo bloqueado**

```text
Hoja de sprites de un pozo en el suelo: bloqueado con rocas y raíces (1 frame), golpeado y rompiéndose (5 frames) y abierto, con una luz tenue en el fondo (1 frame). Contorno de tinta negra grueso.
```

**103. Tileset de la cueva de Camino**

```text
Tileset 2D lateral de una cueva para Camino, en cuadrícula de tiles cuadrados: suelo, paredes irregulares, techo con estalactitas, plataformas y esquinas. Contorno de tinta negra fino sobre grises a lápiz, con detalles en acuarela muy pálida; la cueva está casi sin color. Tiles que encajan sin costuras.
```
