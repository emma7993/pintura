# Camino — Color v001

Fecha: 2026-11-02. Biblioteca de arte para integrar por Claude. No está activada en el juego ni subida a GitHub. Todas las rutas siguientes son relativas a este paquete.

## Óleo debajo del grafito

`Oleo/` contiene `ground_a_oleo`, `ground_b_oleo`, `ground_c_oleo`, `reeds_oleo`, `stones_oleo`, `tree_left_oleo`, `tree_right_oleo` (PNG RGBA 256×256) y `03_bosque_orilla_oleo.png` (1774×887).

Se siguió la aclaración del usuario: **rellenar interiores; exterior transparente**. El alfa de la silueta original se conserva, añadiendo relleno solo a huecos interiores cerrados. Los contornos abiertos permanecen abiertos; no se inventó una masa de fondo detrás del bosque. El RGB viene de pintura al óleo generada y registrada por límites, con una base de color bajo posibles huecos de la textura. Las pinceladas internas no son un calco de cada línea del boceto. `alignment_report.json` registra tamaños y rellenos. `References/*_graphite.png` conserva las líneas originales para superponer sin desplazamiento, recorte ni escalado.

Revelar el óleo con la máscara en las mismas UV del boceto. No normalizar por bounding box al integrar. El bosque usa el mismo tamaño y origen que su capa original; conservar el factor de parallax existente. La galería `Previews/oleo_contact.png` muestra la superposición de grafito, que puede atenuar mucho el color; consultar también los PNG al óleo solos.

## Máscaras

- `Masks/Strokes/stroke_01.png` a `stroke_12.png`: 512×256, canal L de 8 bits, negro 0, blanco 255 y gris intermedio. Incluyen horizontales, diagonales, arcos y golpes cortos.
- `Masks/Dabs/dab_01.png` a `dab_04.png`: 256×256, mismo formato.
- Muestrear el canal rojo/luminancia; no usar alfa (las máscaras son opacas). Importar sin pérdida y sin reinterpretar como arte de color; comprobar el espacio lineal de la máscara en el shader. Acumular estampas a lo largo de la trayectoria del contacto del pincel con max(), no reiniciar en cada cuadro.

## Cascada de tinta

`Inkfall/Stream/ink_01..08.png`: 160×720. `Inkfall/Base/ink_01..08.png`: 384×128. Ambos RGBA, atlas horizontales de 1280×720 y 3072×128. Reproducir sincronizados a 10 FPS, bucle de 0.8 s. El cuadro virtual 9 vuelve exactamente al 1 y los ocho cuadros exportados son distintos.

El flujo se animó a partir de texturas originales mediante desplazamiento periódico de brillos y ondulación del charco. El contorno exterior permanece estable para evitar vibración. `closure_test.png` es una prueba de cierre, **no un noveno cuadro del ciclo**. Se mantiene brillo frío sutil sobre negro profundo.

Montaje usado: chorro en (112,0), base en (0,676), sobre lienzo 384×804. Así se solapan 44 px. `Previews/inkfall_combined.gif` muestra la composición. Situar el conjunto a la derecha de la puerta, junto al altar, según el mapa del juego.

## Altar, tintero y puerta

- `Altar/altar_small.png`: 256×256, pedestal pequeño con exterior transparente.
- `Altar/inkwell_full.png` / `inkwell_empty.png`: celda 256×256, recipiente registrado en rectángulo (72,126)–(184,238). Boca aproximadamente (128,133). Tapón separado `inkwell_cap.png`, 64×64. Los dos recipientes generados no son idénticos al píxel: hay variaciones menores de vidrio y reflejos; revisar al cambiar de estado.
- `Dip_Splash/dip_splash_01..06.png`: 128×128; atlas 768×128. Reproducir una vez, 14 FPS, al recibir tinta; ancla sugerida (64,112), ajustar al nivel de la boca.
- `Gate/gate_tinta.png`: 256×256, tinta negra. Mismo lienzo y registro por bounding box que `Bocetos_v001/Modulos/gate.png`, pero **el contorno interno del arco y algunas piedras no coinciden al píxel**. No se certifica calco exacto; usar como reemplazo completo de puerta, revisar si se pretende fundir ambos dibujos. Exterior y vano transparentes.
- `Gate/gate_active_glow.png`: 256×256, resplandor cálido opcional detrás del vano; no está integrado en el PNG negro.

## Pincel y barrera

`Objects/brush_pickup.png`: 256×256, pincel con restos de color y luz cálida, transparente alrededor. El lobo y sus capas de pincel están en el paquete hermano `Game_Assets/Wolf_Pincel_v001/`; allí están los contactos exactos por cuadro y estados color/seco/tinta.

`Barrier/barrier_01..08.png`: ocho fases RGBA 256×512 de crecimiento desde abajo. Atlas 2048×512. Reproducir una sola vez a 10 FPS y dejar `Barrier/rest.png`; es idéntico al cuadro 8. Pie visual aproximadamente y=491 por el margen de pintura dentro de la celda; registrar ese punto en el suelo. El GIF de revisión repite para comparar; el recurso Godot no tiene bucle. La barrera es un muro de empaste cálido/frío, no piedra.

## Secuencia a programar por Claude

1. Recoger pincel con una carga de color; usar punta `color`.
2. En cuadros activos del tajo, estampar las máscaras usando el contacto de la punta; descubrir óleo, levantar barrera y hacer retroceder sombras.
3. Consumir la carga y cambiar a `dry`.
4. Cerca del altar, reproducir `dip`; en cuadros 4–5 cargar tinta y lanzar la salpicadura; cambiar a `ink`.
5. Regresar a la puerta, usar `paint_up` y activar `gate_tinta` / resplandor; el retorno al lienzo corresponde al juego.

Esta entrega no incluye shaders de gameplay, colisiones, inventario ni cambios de escenas del juego.

## Conservación y verificación

`Source/` conserva PNG originales sin alterar, prompts y scripts de producción; `References/IMMIX_Pintura_Completa.png` conserva la paleta. Image_gen integrado produjo los originales; registro, máscaras de silueta, atlas, GIF y animación periódica de efectos se procesaron después. No borrar los originales al integrar.

`Godot/Color_Effects.tres` contiene las cuatro animaciones de efectos. Abrir este `project.godot` independiente en Godot 4.7.2 para revisar `Godot/Preview.tscn` con F5/F6. El `.gdignore` de Game_Assets no se cambió y el juego principal no carga el paquete automáticamente.

`VALIDACION.json` comprueba tamaños/rango de máscaras, número de cuadros, cierre del bucle y estado final de barrera. Importación y arranque de ambos proyectos de arte comprobados sin errores de recursos/scripts. El entorno restringido dio avisos de certificados y preferencias de usuario; no son fallos de importación del arte. Los GIF muestran fondos de revisión que no forman parte del alfa exportado.

No se tocó characters/, art/ ni código del juego. No se ejecutó commit, pull ni push. Para compartir en Mac hará falta el commit/push autorizado y después git pull + git lfs pull allí; PNG y GIF resuelven al filtro Git LFS local.
