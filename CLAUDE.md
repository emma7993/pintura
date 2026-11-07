# Pintura — contexto para Claude

Metroidvania 2D estilo Hollow Knight en Godot 4.7.2 (GL Compatibility, 1280x720). Vive dentro de la pintura de la portada del álbum de Immix. Dueño: Emma (Emanuel), habla español, prefiere tono formal, respuestas concisas, opciones cuando haya mejoras, y que todo se haga en automático.

## Reparto de trabajo
- ChatGPT/Codex: arte y diseño, siempre en `Game_Assets/` (versionado, con `.gdignore`: Godot NO lo importa).
- Claude: estructura, código e integración. El arte se copia a `characters/...` (p. ej. `characters/lobo/salto_v004/`). No editar los originales de `Game_Assets`; los ajustes se hacen con scripts en `herramientas/`.
- Sprites del lobito: toda entrega se revisa con `Game_Assets/GUIA_LOBITO.md` (medidas del original, rasgos, movimiento de Hornet y errores repetidos de ChatGPT) y `python herramientas/comparar_lobo.py <carpeta>`; actualizar la guía en cada revisión.
- Leer `Game_Assets/LEEME_CODEX_CLAUDE.md` y el `INTEGRACION_CLAUDE.md` de la entrega vigente antes de integrar arte nuevo.

## Estado del juego
- Ojos del lobo (regla de Emma): caminando, entrecerrados y temerosos; desde que corre (correr, saltar, caer) ya está despierto y los abre.
- Fase 1: movimiento lateral. El lobo (negro, bufanda roja, temeroso) solo CAMINA al inicio; `can_jump=false` en `zones/zone_camino_lateral.gd`. Salto solo con Espacio.
- Interfaz de animación: `LoboSprite.animate(delta, speed01, vel_x, air, vy)` en `characters/lobo/lobo_sprite.gd`. Lo usan `player.gd` (zonas laterales) y `walker.gd` (zona de la pintura).
- Zonas: `main.gd` (ZONES), `zones/zone_camino.gd` (pintura), `zones/zone_camino_lateral.gd`, `zones/prueba.tscn` (F6).
- Mundo: `mundo/mapa_datos.gd` es el mapa completo (salas, conexiones, portales). En el juego, la pintura (`zone_camino.gd`) es el centro; Camino = Nivel 1 (`zones/nivel_01_camino.gd`, salas `MapaDatos.NIVEL1`) + resto en bloques (`mundo/mundo.gd` con `en_juego`). Las salidas usan `"zona:entrada"` (p. ej. `mundo:ca_sello`, `z_camino:fin`). M = mapa (main.gd, pausa). Prueba: `herramientas/prueba_camino.gd`.

## Pruebas
- Windows: `herramientas/probar_juego.bat` ejecuta el juego unos segundos, guarda capturas en `pruebas/` y el log en `pruebas/godot_log.txt`. Revisar el log y las capturas antes de pedirle nada a Emma.
- Godot: `C:\Users\Immix\Documents\Godot_v4.7.2-stable_win64_console.exe`.
- Ñ adelanta y L regresa una sala de Camino en el orden del mapa (solo versión de desarrollo; `main.gd`). El Sello musical tiene la puerta sellada al fondo sobre una repisa alta (`sellada`/`clave` en `MapaDatos`) y su entrada no se cierra; prueba: `herramientas/prueba_sello.gd`.
- Ataques: combo de tres golpes de lado y corte hacia arriba con `characters/lobo/combo_v001` (de `Wolf_Combo_v001`, convertido con `herramientas/ajustar_combo_v001.py`); el tajo hacia abajo (pogo) sigue siendo el de pincel_v003.
- Fondos del Nivel 1: `art/worlds/camino/nivel_01_fondos_v003` (copia de `Game_Assets/Nivel_01_Camino/fondos_unificados_v001` con `herramientas/fondos_camino_v003.py`). Panorama: franjas 15/17/18/19 del montaje; hitos colocados por la x de cámara en la que se ven (cabeza y faro lejos, parallax 0.16); tres filas de nubes. Subsuelo 12/13 y pared de cueva 14 en mosaico por código (guardar texturas en `_texturas`, si no salen en blanco). La puerta pintada es el marco 16 (en el arco; Emma pedirá otro modelo). Pedido pendiente: `Game_Assets/PEDIDO_Nivel1_Fondos_v004.md`.
- Camino: se entra cayendo desde la pintura (sin puerta al inicio). La cámara honda es la Cueva de la paleta (`ca_paleta` en `MapaDatos.NIVEL1`): la paleta reemplaza al tintero (en código sigue llamándose `Inventario.tintero`). La cámara de la paleta es plana (fondo `cueva_paleta` de lado a lado, arco de entrada a la izquierda, altar a la derecha). Del lago de tinta (fondo izquierdo de la cueva, entrada de cueva T06 #5 grande) se pasa a la Zona de enemigos por su puerta derecha y por ahí se vuelve; su puerta izquierda está cerrada por ahora (`PUERTAS_CERRADAS` en `mundo.gd`) y por ahora no tiene fondo (`FONDOS`; usará las capas de `PEDIDO_Nivel1_Cueva_v003.md`). El taller del copista se entra por un portal en la Zona de enemigos. Captura de una sala del mundo: `herramientas/captura_mundo.gd -- <sala>`.
- Efectos de respuesta (`characters/lobo/efectos.gd`): polvo de grafito al despegar, aterrizar, correr, dash y pared; aplastar/estirar; `golpe_conectado()` da chispas de tinta, micro-pausa y temblor. Las cámaras suman `Efectos.temblor_ahora()` a su offset; la del mundo se adelanta hacia donde corre.
- La pintura del inicio es `art/backgrounds/camino_cuadro.jpg` (con marco, sin letras; `herramientas/pintura_camino_v001.py`, que también hace la puerta `16_marco_camino`); la máscara sigue en coordenadas de `camino.jpg` (`CUADRO_ESQ`).
- Pozo del Nivel 1 (`WELL_X`): sin tapa; brocal macizo al que se sube y por cuya boca se cae al tiro; repisas a los lados del tiro para volver a subir. La paleta del altar mide `PALETA_ANCHO`; con tinta, el ícono usa `04_paleta_tinta` (`herramientas/paleta_tinta_v001.py`). La puerta del arco es el cuadro de Camino con marco oscuro (`16_marco_camino`, 512x512).
- Interpolación de física activa (`project.godot`): al teletransportar al lobo, `reset_physics_interpolation()`.
- Salto v004 agrandado 6.5 % por código (`SALTO_ESCALA`) para igualar el tamaño de la carrera v027.
- Física del lobo (`player.gd`): salto y carrera medidos de una grabación de Silksong, escalados al tamaño del lobo; `herramientas/prueba_salto.gd` comprueba las medidas (salto completo ~240 px, toque ~70 px, carrera 360).

## Git (dos computadoras: Windows y Mac)
- Repo privado con Git LFS (png, audio, 3D). `herramientas/subir_cambios.*` y `bajar_cambios.*` sincronizan; revisar `git status` antes de subir.
- No commitear `.godot/`, logs ni `pruebas/`. Respetar mayúsculas exactas en rutas `res://` y usar `/`.
- Los archivos .bat usan CRLF y los .sh LF.
