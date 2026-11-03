# Pedido para ChatGPT/Codex — Nivel_01_Camino/Cueva_v001 (cueva, pozo, foso y plataformas)

Copiar desde aquí:

---

Necesito una entrega nueva para el Nivel 1 de Pintura: **Game_Assets/Nivel_01_Camino/Cueva_v001/**. Es la parte nueva del nivel, que ahora es más largo: después del arco hay plataformas, un foso de tinta y la boca de una cueva que baja. En la cueva están el tintero (en una cámara honda) y la cascada de tinta; se vuelve a subir por un pozo junto al arco, rompiendo su tapa desde abajo con el pincel.

Estilo: el mismo de Nivel_01_Camino/Bocetos_v001: boceto a grafito sobre papel crema, línea suelta y rayado de lápiz. La cueva va un poco más oscura (papel gris cálido) pero sigue siendo dibujo a lápiz, no pintura. Diseño original. PNG RGBA con exterior transparente, salvo las texturas repetibles.

## 1. Corte de terreno y cueva
- **rock_fill.png**: textura de roca en corte (rayado de grafito sobre crema grisácea), 512×512, **repetible sin costuras** en horizontal y vertical. Rellena la franja de tierra entre el suelo y el techo de la cueva.
- **cave_back.png**: fondo del interior de la cueva, 1024×512, repetible en horizontal. Papel un poco más oscuro, con grietas y sombras suaves muy tenues.
- **cave_ceiling_a/b/c.png**: 512×128, borde del techo con estalactitas colgando (el borde superior empalma con rock_fill).
- **cave_floor_a/b/c.png**: 256×256, como ground_a/b/c pero de piedra de cueva; misma fila de pisada (~y=126) para que el lobo pise a la misma altura.
- **cave_wall_left/right.png**: 256×768, paredes laterales de la cueva.
- **cave_mouth.png**: 384×256, la boca de la cueva en el suelo de arriba (bordes rotos que caen hacia el hueco).

## 2. Pozo junto al arco
- **well_closed.png**: 320×256, brocal de piedra con una losa encima (cerrado). Pie en y=240.
- **well_open.png**: el mismo brocal sin losa; **well_lid_ground.png**: la losa caída en el suelo, 256×64.
- **well_shaft.png**: 256×512, interior del tiro, **repetible en vertical**, con piedras salientes.
- **well_ledge.png**: 192×48, repisa de piedra que sobresale de la pared del tiro (se pisa por arriba).
- **plug_intact.png**: 256×64, tapa de piedra vista desde abajo (desde la cueva).
- **plug_break 01..08**: 256×192, la tapa se agrieta y se rompe hacia arriba en trozos (sin bucle, 14 FPS); cuadro 3 = impacto.
- **debris 01..06**: 128×128, polvo y piedritas cayendo (sin bucle).

## 3. Plataformas y foso
- **step_float.png**: 192×96, escalón de piedra flotante, pequeño.
- **plateau_side_left/right.png**: 128×256, cara del acantilado de una meseta de 200 px de alto.
- **ink_pit 01..08**: 256×128, tinta negra en el fondo de un foso, en bucle (8 FPS), con brillos fríos como la cascada.
- **pit_edge_left/right.png**: 128×256, bordes rotos del foso.

## 4. Cascada bajo tierra
- **inkfall_ceiling_crack.png**: 256×160, grieta en el techo de la cueva de donde sale la tinta. Empata con el chorro existente (Color_v001/Inkfall/Stream, 160 px de ancho).

## 5. Efectos
- **strike_hit 01..06**: 192×192, golpe de pincel con tinta hacia arriba (salpicadura negra), sin bucle.

## 6. Formato
- Cuadros numerados desde 01 y atlas horizontales para las animaciones.
- `Godot/` con SpriteFrames para las animaciones y un Preview.tscn.
- `Previews/` con hojas de contacto sobre crema y sobre el boceto del camino.
- `INTEGRACION_CLAUDE.md` con anclas (pies, bordes que empatan, fila de pisada) y advertencias.
- `VALIDACION.json`: tamaños, costuras de las texturas repetibles y bucles cerrados.
- `Source/` con originales y prompts.
- No tocar characters/, art/, el código ni git.

---
