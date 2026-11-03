# Pedido para ChatGPT/Codex — Sombras_v001 (manos del suelo y bruma)

Copiar desde aquí:

---

Necesito una entrega nueva para Pintura: **Game_Assets/Sombras_v001/**. Son las sombras que persiguen al lobo en el Nivel 1 (Camino) y que más adelante serán enemigos. Hoy están dibujadas por código como una masa negra con brazos; quiero reemplazarlas con arte. Diseño **original**. Deben encajar con el mundo de boceto a grafito sobre papel crema (Nivel_01_Camino/Bocetos_v001) y con el lobo (Wolf_Pincel_v001): negros de tinta, grises fríos, textura de grafito y bordes que se deshilachan como trazo de lápiz.

Son de dos tipos que trabajan juntos:

## 1. Manos que salen del suelo
- Brazos largos y delgados de tinta negra que brotan de un charco oscuro en el suelo y se estiran hacia el lobo para atraparlo.
- Mezcla de dos sensaciones:
  - **Amenaza pesada y corrupta:** la mano sale de un charco espeso que burbujea; brazo grueso en la base, con brillos rojo oscuro tenues en las grietas y un ojo pálido en el dorso de la mano.
  - **Garabato inquieto:** dedos larguísimos y huesudos, articulaciones de más, contorno tembloroso como trazo de lápiz nervioso; se arrastran por el suelo como si tantearan.
- Variantes: **3 diseños de mano** (A delgada y larga, B gruesa con garras, C pequeña y rápida). Cada una tiene sus animaciones.
- Celdas RGBA de **256×512**, el suelo en **y = 480** (donde se apoya el charco) y la mano mirando a la **derecha** (el lobo siempre huye hacia la derecha).

| Animación | Cuadros | FPS | Bucle | Notas |
|---|---:|---:|---|---|
| emerge | 8 | 12 | no | El charco se abre y la mano sube hasta la altura máxima (~380 px). |
| reach | 8 | 10 | sí | Se estira hacia adelante tanteando; los dedos se abren y se cierran. |
| grab | 6 | 14 | no | Zarpazo rápido hacia adelante y abajo. Cuadros 3–4 = contacto (golpe). |
| sink | 6 | 12 | no | Se hunde de vuelta en el charco. |
| dissolve | 8 | 12 | no | Toca el color del pincel y se deshace en humo y trazos que se borran. |

- **Charco** aparte: `puddle_loop` de 8 cuadros, 384×96, en bucle, borde estable. Es el pie común de todas las manos.
- Dar en el JSON el punto de contacto del golpe (cuadros 3–4 de grab) y la punta de los dedos por cuadro en reach y grab.

## 2. Bruma: nubes negras y grises que avanzan
- Una pared de niebla densa, negra en el fondo y gris humo en el borde, que avanza desde la izquierda de la pantalla y se traga el boceto. Con remolinos lentos y jirones que se adelantan.
- Piezas:
  - **front_loop:** el borde delantero de la bruma, 8 cuadros, 512×1024, en bucle a 8 FPS. El lado derecho se deshilacha en jirones; el lado izquierdo es negro casi opaco y **empata en continuidad con body**.
  - **body:** textura de relleno 512×1024 que **se repite sin costuras** en horizontal y vertical (negro con variaciones grises suaves), para cubrir todo lo que queda detrás del borde.
  - **wisps:** 6 jirones sueltos de 128×128 (humo que se adelanta y se disipa), cada uno como animación de 6 cuadros sin bucle.
  - **eyes:** 3 pares de ojos pálidos que parpadean dentro de la bruma (128×64, 4 cuadros: abierto, medio, cerrado, medio).
  - **recoil:** 6 cuadros de 512×1024 del borde retrocediendo y desgarrándose al chocar con la pincelada de color.

## 3. Formato de entrega (como en las entregas anteriores)
- PNG RGBA y cuadros numerados desde 01; además, atlas horizontales.
- `Godot/` con SpriteFrames (`Sombras_Manos.tres`, `Sombras_Bruma.tres`) y un Preview.tscn.
- `Previews/` con GIF y hojas de contacto sobre fondo crema y sobre el boceto del camino.
- `VALIDACION.json`:
  - Tamaños.
  - Suelo de las manos en y=480 en todos los cuadros.
  - Bucles cerrados (el último cuadro empata con el primero).
  - Costura nula de body en sus cuatro bordes.
- `INTEGRACION_CLAUDE.md` con anclas, FPS, cuadros de golpe y cualquier advertencia.
- `Source/` con originales y prompts.
- No tocar characters/, art/, el código ni git.

---
