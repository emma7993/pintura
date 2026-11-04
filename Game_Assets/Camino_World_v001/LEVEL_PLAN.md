# Camino — propuesta de nivel pequeño

Estas ocho salas son una propuesta para construir con el kit, no ocho niveles nuevos. Solo Camino está confirmado. Las dimensiones se expresan como pantallas de 1280×720 y deben ajustarse a la movilidad aprobada por Claude.

| Sala | Extensión sugerida | Función | Motivo visual |
| --- | --- | --- | --- |
| 01 Umbral | 1 pantalla | Entrada y retorno al hub | Mucho lienzo, un arco interrumpido |
| 02 Paso borrado | 1.5 | Ver un puente que todavía no existe; desvío inferior seguro | Orillas claras y contorno abierto |
| 03 Ribera muda | 1.5 | Exploración sin habilidad; observar ritmo ambiental | Árboles, juncos, restos de acueducto |
| 04 Resguardo | 1 | Encontrar lápiz sin combate | Pedestal sencillo, vacío y foco por contraste |
| 05 Primer trazo | 1 | Completar puente corto en espacio seguro | Anclas visibles, sin muerte como castigo tutorial |
| 06 Arcos suspendidos | 2 | Aplicar la misma acción y descubrir regreso corto | Plataformas de piedra/grafito |
| 07 Margen oscuro | 1.5 | Tensión; reservar una amenaza por aprobar | Mancha baja con aviso legible |
| 08 Camino propio | 1 | Abrir atajo y volver al hub | Puente completo, grafito más firme |

Ruta propuesta: 01→02→03→04→05→06→07→08; 08 enlaza con 02 para demostrar dominio. El bloqueo artístico se resuelve con lápiz, sin depender de salto doble, dash ni habilidades nuevas. El controlador actual de Camino lateral desactiva el salto: Claude debe decidir su habilitación antes de convertir plataformas altas en rutas obligatorias. El montaje visual actual conserva el suelo continuo para no modificar esa jugabilidad.

## Interacción mínima sugerida

1. Acercarse al lápiz, mostrar icono de interacción del sistema actual y recogerlo.
2. Mostrar un puente incompleto con dos apoyos; mantener la acción cerca del ancla, no trazar con ratón.
3. Revelar la forma progresivamente; al terminar, convertir el puente en sólido y guardar su ID.
4. Restablecer la música desde el progreso guardado al volver a la sala.

La recogida del lápiz, colisiones de puente y guardado son tareas de integración para Claude; un sprite visible no implica que esa mecánica esté implementada.

## Amenazas propuestas para aprobar

| Propuesta | Material y silueta | Comportamiento propuesto | Coste |
| --- | --- | --- | --- |
| Mano de borradura | Mano abierta hecha de rayados y borrón; sin ojos ni adornos | Mancha anticipa 0.7 s, emerge, intenta sujetar, se retrae; se evita caminando fuera del área | Medio: estados, hitbox temporal y animación dedicada |
| Nudo de grafito | Ovillo bajo de trazos sin rasgos humanos | Cruza un tramo corto y pausa; se evita desde un resguardo | Bajo, pero no producir definitivo sin aprobación |
| Hueco de pigmento | Vacío irregular de lienzo con borde raspado | Peligro estático claramente marcado | Bajo; evitar confundirlo con terreno restaurable |

Primera recomendación: una sola mano, en una sala de ensayo y sin daño permanente al inicio. No añadir variantes ni jefe para «completar» el kit. La referencia a otras obras sirve para la sensación de amenaza, no para copiar sus diseños.
