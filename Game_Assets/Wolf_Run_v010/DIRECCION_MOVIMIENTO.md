# Propuesta de movimiento — Pintura

Dirección artística propia: conservar la silueta clara del lobo, la carrera compacta, el pincel rígido y los ataques legibles; sumar una sensación de continuidad y ligereza con transiciones y movimiento secundario. Son decisiones propuestas para Pintura, no una reproducción de los sistemas de Silksong u Ori.

## Orden recomendado de producción

1. Mantener esta carrera de ocho poses a 20 FPS como base aprobable. Ajustar la cadencia a la velocidad del jugador; añadir cuadros solo donde falte una fase concreta.
2. Dibujar run_start (2–3 cuadros), run_stop (3), turn (2–3): inclinación al arrancar, apoyo corto al frenar y cambio de peso al girar. Cabeza, manos y pincel conservan escala. Estas transiciones aportan continuidad entre acciones, no alargan el ciclo de carrera.
3. Diferenciar despegue, subida, ápice, caída y aterrizaje: una compresión breve al apoyar, extensión natural en el aire y recuperación corta. No aumentar ni reducir la cabeza para fingir elasticidad.
4. Añadir retraso suave de cola y bufanda respecto al torso, especialmente en cambios de dirección y aterrizajes. Conservar el dibujo plano aprobado. No deformar el pincel ni hacer vibrar las manos.
5. Ataques con anticipación corta, impacto muy claro y recuperación breve. Usar el arco del pincel y estelas discretas para conectar las poses, conservando legibilidad.

## Integración a cargo de Claude

- Respuesta inmediata al mando, con aceleración y frenado breves que no hagan al personaje pesado. Probar los valores en el juego, sin asumir que equivalen a los títulos de referencia.
- Sincronizar la fase del pie con la velocidad de avance; no reiniciar run a cada actualización. Variar la cadencia según velocidad, evitando patinaje.
- Cambiar de estado por condiciones concretas: inicio/freno/giro, contacto con suelo y velocidad vertical. Evitar fundidos que produzcan pies o manos dobles entre sprites.
- Para saltos accesibles, evaluar salto de altura variable, pequeño margen tras salir del borde y memoria breve de la pulsación antes de aterrizar. Son opciones de control, no animaciones ya entregadas.
- Exageración visual leve y localizada en cuerpo, cola y bufanda; la colisión del jugador y el pincel siguen estables. Revisar transiciones en cámara lenta y luego a velocidad de juego.

## Referencias consultadas

La nota oficial de Moon/Xbox sobre Ori destaca conjuntamente la continuidad visual de la animación y la respuesta del control: https://news.xbox.com/en-us/2020/11/10/ori-and-the-will-of-the-wisps-embraces-the-power-of-xbox-series-xs/

Esta propuesta no depende de adoptar 3D ni de conocer el número de sprites de esos juegos. La entrega v010 solo recupera la mano del fondo; las transiciones y ajustes de control anteriores quedan pendientes.
