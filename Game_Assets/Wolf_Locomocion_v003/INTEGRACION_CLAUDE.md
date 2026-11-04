# Wolf Locomoción v003 — fase 1: caminar y correr

2026-11-03. Nueva propuesta de locomoción y expresión facial solicitada a partir del atlas de movimiento que aportó el usuario. No está integrada en el juego. Se conservan las entregas anteriores sin modificar; no se tocó characters/, art/, código del juego ni Git.

## Cambios de actuación

- Walk: transferencia de peso más clara, brazos libres con contrapeso corto, cola y bufanda con retraso respecto al cuerpo. Expresión cautelosa, ojo blanco algo más atento, parpadeo breve en cuadros 5–6.
- Run: torso inclinado hacia delante, cabeza adelantada, empuje y fases aéreas más pronunciados, alternancia de brazos, bufanda extendida hacia atrás. **Ojo blanco ovalado abierto en los ocho cuadros**, sin párpado dormido ni parpadeo. Expresión de alerta/temor decidido, sin añadir pupilas negras.
- Se mantiene el lobo negro, su hocico y orejas, el contorno gris claro, la cola gris y la bufanda roja, con textura artesanal. Son dibujos completos; no se reconstruyeron extremidades por piezas.

El atlas de referencia está empaquetado y no determina por sí solo el orden temporal de sus sprites. Se utilizó como referencia de lenguaje de movimiento y siluetas, sin copiar el personaje, máscara, vestido o arma. No se afirma una correspondencia exacta con una animación específica del juego de referencia.

## Formato

| Animación | Cuadros | Celda | Atlas horizontal | FPS | Bucle |
|---|---:|---|---|---:|---|
| walk | 12 | 256×256 RGBA | 3072×256 | 12 | sí |
| run | 8 | 256×256 RGBA | 2048×256 | 16 | sí |

Cuadros individuales: `Animations/walk/body/01..12.png` y `Animations/run/body/01..08.png`. Atlas en `Animations/<nombre>/<nombre>_atlas.png`.

**Origen común recomendado: (-128,-238).** No recentrar cuadros por su área opaca. El suelo de referencia es y=238. En carrera los cuadros aéreos 3,4,7,8 pueden tener los pies por encima del suelo, y las compresiones conservan su flexión natural. Se utiliza una sola escala uniforme por secuencia; no se estiran figuras para forzar la altura de una pose aérea a la de pie. La escala de referencia de contacto se calibra a unos 216 px. La cabeza y el torso del dibujo generado pueden mostrar pequeñas variaciones de proporción respecto a v002; revisar la hoja de expresiones antes de aprobar la sustitución.

Las dos animaciones están **sin arma**, con brazos libres. Esta fase cubre caminar y correr; las poses de varita y los ataques permanecen en las otras entregas y requieren una adaptación posterior si se adopta esta actuación. No combinar automáticamente un arma de v002 con estos brazos, porque sus puntos de agarre cambiaron.

Para una caminata lenta de 0.8 ciclos/s: 12 FPS × speed_scale 0.8 = 9.6 cuadros/s y ciclo de 1.25 s. El GIF de walk usa ese tiempo. Run guarda 16 FPS y ciclo de 0.5 s; ajustar su reproducción junto a la velocidad de desplazamiento del juego. No se certifica que el apoyo del pie tenga velocidad constante.

## Recursos y revisión

`Godot/Wolf.tres` contiene walk y run. Abrir **este** `project.godot` como proyecto independiente y ejecutar `Godot/Preview.tscn` para ver ambas animaciones lado a lado. El `.gdignore` de Game_Assets permanece intacto; el F5 del proyecto principal no cambia de personaje.

`Previews/walk.gif`, `run.gif` y sus hojas `*_contact.png` muestran los ciclos. `Previews/expressions_contact.png` amplía cuatro caras de cada estado para comparar el ojo cauteloso y el ojo abierto. Los fondos de crema y las etiquetas solo existen en las vistas previas.

`VALIDACION.json` incluye conteos, alturas reales, centro horizontal del núcleo del torso, medición de la mancha blanca del ojo por cuadro y checks de apertura en carrera. El centro del torso se mide excluyendo bufanda y cola; no se usa el bounding box de la silueta completa. La estimación de zancada usa dos veces la mayor separación de los grupos de pies en la franja inferior y puede subestimar fases aéreas; no debe sustituir una calibración de velocidad en juego.

`Source/` conserva originales sin retocar, prompts de image_gen integrado y scripts de empaquetado y medición. `References/` conserva la identidad del lobo y el atlas aportado por el usuario como referencia visual, separado de los assets jugables. No exportar esa referencia como sprite del lobo.
