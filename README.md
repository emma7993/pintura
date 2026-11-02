# Pintura · Zona 1: Camino

Abrir en Godot (4.3 o superior): Import → project.godot → F5 (o el botón de play).

Controles: WASD / flechas = caminar · E / Enter / Espacio = entrar · F1 = ver el área transitable.

Estructura
- main.gd / main.tscn ........ director: entradas, grano de papel, títulos, transiciones, música
- zones/zone_camino.gd ....... zona Camino en la pintura (vista libre, perspectiva)
- zones/zone_camino_lateral.gd  zona Camino en vista lateral (el lobo solo camina)
- zones/prueba.tscn .......... zona de prueba del movimiento (F6): correr y saltar
- characters/lobo/ ........... lobo jugable: player.gd + sprites de Blender (lobo_walk_*)
- characters/lobo/procedural/  lobo dibujado por código (respaldo y zona del camino)
- core/controls.gd ........... controles (teclado y mando)
- art/backgrounds/ ........... pintura del camino y su máscara transitable
- art/reference/ ............. referencia del lobo
- shaders/ · audio/ .......... grano de papel · música (track_05.ogg para el Camino)
- Game_Assets/ ............... biblioteca de arte nueva (lobo, entornos, enemigos...). Godot la ignora; de aqui se copia a characters/ y art/ lo que se usa
- source_art/ ................ arte antiguo hecho con Blender (Godot lo ignora)
- herramientas/ .............. subir_cambios / bajar_cambios (.bat Windows, .sh Mac) para GitHub

Dos computadoras (Windows y Mac): todo lo que esta dentro de pintura/ se sincroniza con GitHub.
- Al empezar: herramientas/bajar_cambios (.bat en Windows, .sh en Mac)
- Al terminar: herramientas/subir_cambios
Poner el arte nuevo dentro de pintura/Game_Assets/ (si queda fuera de pintura/, no se sincroniza).
