# Modelos del lobito aprobados — 2026-11-06

El usuario eligió estas versiones como definitivas para probarlas juntas en el juego. Las versiones intermedias no sustituyen estos modelos por tener otro número.

| Animación | Ruta aprobada | Contenido |
|---|---|---|
| Reposo | Wolf_Pincel_v003/Animations/idle/body/ | 01..06.png, original |
| Caminata | Wolf_Pincel_v003/Animations/walk/body/ | 01..12.png, original |
| Carrera | Wolf_Run_v027/Sprites/run/ | 01..08.png, 20 FPS, bucle; expresión seria ligeramente enojada |
| Salto/caída | Wolf_Salto_v004/Sprites/ | 01_jump_start, 02_jump_up, 03_jump_apex, 04_fall, 05_land |

Los 31 PNG son RGBA de 384×384. Origen lógico común (192,352). Las rutas y hashes de los archivos exactos están en MODELOS_LOBITO_APROBADOS.json. No regenerar ni retocar el dibujo como parte de la integración.

## Para Claude

Integrar estos tres modelos de locomoción, conservando el resto de las animaciones y la programación que mantiene Claude. Probar transiciones reposo/caminata/carrera y fases de salto/caída/aterrizaje. La aprobación es del arte; verificar en el juego la sincronización de velocidad, los apoyos y el registro de carrera: el export actual tiene pequeñas diferencias de suela por cuadro y no cuenta con un avance uniforme por ciclo certificado. Consultar las notas específicas de cada paquete.

Esta publicación contiene recursos y documentación dentro de Game_Assets. No cambia characters/, art/ ni código. Subir los archivos no activa automáticamente el modelo con F5; la integración corresponde a Claude.

## En la otra computadora

Con los cambios locales guardados, desde el repositorio:

```sh
git pull --ff-only
git lfs pull
```

PNG y GIF usan Git LFS. La caminata y el reposo ya estaban versionados; esta entrega añade la carrera y el salto elegidos con sus fuentes, vistas previas y notas.
