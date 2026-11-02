# Pintura · Zona 1: Camino

Abrir en Godot (4.3 o superior): Import → project.godot → F5 (o el botón de play).

Controles: WASD / flechas = caminar · E / Enter / Espacio = entrar · F1 = ver el área transitable.

Estructura
- main.gd ............ director: entradas, grano de papel, títulos, transiciones, música
- zones/zone_camino.gd  la zona (pintura + camino + entrada a la ruina)
- wolf/wolf.gd ....... el lobo como muñeco articulado (animación por código)
- wolf/wolf_data.gd .. piezas del lobo trazadas de la imagen de referencia
- wolf/walker.gd ..... movimiento sobre el camino, escala por profundidad
- assets/camino.jpg .. la pintura (sin marco ni firma)
- assets/camino_walk.png  máscara: lo blanco es transitable
- audio/ ............. poner track_05.ogg (Camino) para que suene en esta zona
