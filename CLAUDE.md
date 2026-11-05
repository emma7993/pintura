# Pintura — contexto para Claude

Metroidvania 2D estilo Hollow Knight en Godot 4.7.2 (GL Compatibility, 1280x720). Vive dentro de la pintura de la portada del álbum de Immix. Dueño: Emma (Emanuel), habla español, prefiere tono formal, respuestas concisas, opciones cuando haya mejoras, y que todo se haga en automático.

## Reparto de trabajo
- ChatGPT/Codex: arte y diseño, siempre en `Game_Assets/` (versionado, con `.gdignore`: Godot NO lo importa).
- Claude: estructura, código e integración. El arte se copia a `characters/...` (p. ej. `characters/lobo/v003/`). No editar los originales de `Game_Assets`; los ajustes se hacen con scripts en `herramientas/`.
- Leer `Game_Assets/LEEME_CODEX_CLAUDE.md` y el `INTEGRACION_CLAUDE.md` de la entrega vigente antes de integrar arte nuevo.

## Estado del juego
- Fase 1: movimiento lateral. El lobo (negro, bufanda roja, temeroso) solo CAMINA al inicio; `can_jump=false` en `zones/zone_camino_lateral.gd`. Salto solo con Espacio.
- Interfaz de animación: `LoboSprite.animate(delta, speed01, vel_x, air, vy)` en `characters/lobo/lobo_sprite.gd`. Lo usan `player.gd` (zonas laterales) y `walker.gd` (zona de la pintura).
- Zonas: `main.gd` (ZONES), `zones/zone_camino.gd` (pintura), `zones/zone_camino_lateral.gd`, `zones/prueba.tscn` (F6).
- Mundo: `mundo/mapa_datos.gd` es el mapa completo (salas, conexiones, portales). En el juego, la pintura (`zone_camino.gd`) es el centro; Camino = Nivel 1 (`zones/nivel_01_camino.gd`, salas `MapaDatos.NIVEL1`) + resto en bloques (`mundo/mundo.gd` con `en_juego`). Las salidas usan `"zona:entrada"` (p. ej. `mundo:ca_sello`, `z_camino:fin`). M = mapa (main.gd, pausa). Prueba: `herramientas/prueba_camino.gd`.

## Pruebas
- Windows: `herramientas/probar_juego.bat` ejecuta el juego unos segundos, guarda capturas en `pruebas/` y el log en `pruebas/godot_log.txt`. Revisar el log y las capturas antes de pedirle nada a Emma.
- Godot: `C:\Users\Immix\Documents\Godot_v4.7.2-stable_win64_console.exe`.
- Ñ adelanta y L regresa una sala de Camino en el orden del mapa (solo versión de desarrollo; `main.gd`). El Sello musical tiene la puerta sellada al fondo sobre una repisa alta (`sellada`/`clave` en `MapaDatos`) y su entrada no se cierra; prueba: `herramientas/prueba_sello.gd`.
- Ataques: combo de tres golpes de lado y corte hacia arriba con `characters/lobo/combo_v001` (de `Wolf_Combo_v001`, convertido con `herramientas/ajustar_combo_v001.py`); el tajo hacia abajo (pogo) sigue siendo el de pincel_v003.
- Física del lobo (`player.gd`): salto y carrera medidos de una grabación de Silksong, escalados al tamaño del lobo; `herramientas/prueba_salto.gd` comprueba las medidas (salto completo ~240 px, toque ~70 px, carrera 360).

## Git (dos computadoras: Windows y Mac)
- Repo privado con Git LFS (png, audio, 3D). `herramientas/subir_cambios.*` y `bajar_cambios.*` sincronizan; revisar `git status` antes de subir.
- No commitear `.godot/`, logs ni `pruebas/`. Respetar mayúsculas exactas en rutas `res://` y usar `/`.
- Los archivos .bat usan CRLF y los .sh LF.
