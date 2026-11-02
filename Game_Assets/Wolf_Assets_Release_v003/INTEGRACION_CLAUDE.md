# Lobo v003 — instalación y tareas de integración

## Estado comprobado el 2026-11-02

Escritura comprobada con creación, lectura y eliminación de un archivo temporal en Game_Assets. No se encontraron AGENTS.md en los directorios ascendentes del proyecto ni dentro de Game_Assets o del paquete fuente. Se leyeron README, configuración Godot/Git, documentación artística y scripts de sincronización existentes.

Se copiaron 69 archivos sin reemplazar archivos existentes desde:
`C:\Users\Immix\Documents\Codex\2026-11-02\referenced-chatgpt-conversation-this-is-an\outputs\Wolf_Assets_Release_v003`.

Destino: `Game_Assets/Wolf_Assets_Release_v003/`. `INSTALL_SOURCE_HASHES.json` registra SHA-256 y tamaño de cada archivo original. README, QA y manifest originales se preservan como procedencia: sus frases «no instalado» describen la entrega anterior a esta instalación. Este documento registra el estado actual.

## Rutas

Todas las rutas siguientes parten de la carpeta de esta entrega:

| Uso | Ruta |
| --- | --- |
| Recursos canónicos para integrar | `01_Characters/Wolf/` |
| Atlas | `01_Characters/Wolf/SpriteSheets/walk_v003.png`, `look_around_v003.png` |
| SpriteFrames y adaptador de ejemplo | `01_Characters/Wolf/Godot/Wolf.tres`, `Wolf.gd` |
| Escena de revisión | `01_Characters/Wolf/Godot/Preview.tscn` |
| Frames sueltos | `01_Characters/Wolf/Individual_Frames/walk/`, `look_around/` |
| Referencias y pose aprobada | `00_Art_Direction/References/` |
| Guía artística | `00_Art_Direction/Wolf_Design_Guide.md` |
| Guía reutilizable portable | `00_Art_Direction/Skills/wolf-sprites/SKILL.md` |
| Originales y registro de generación | `01_Characters/Wolf/Source/` |
| GIF/APNG y planchas | `01_Characters/Wolf/Previews/` |
| Proyecto independiente, copia de demostración | `Godot_Preview/project.godot` |

La guía portable se conserva en el repositorio; no se instala globalmente. Para nuevas entregas, consultar primero la pose aprobada y la actualización v003 de la guía. Versionar nuevas propuestas sin reemplazar aprobaciones.

## Contrato de animación

| Nombre real en Wolf.tres | Cuadros | Ritmo | Repetición |
| --- | --- | --- | --- |
| `walk` | 8 | 8 FPS base, 1 s | Sí |
| `look_around` | 6 | 0.99 s total, duraciones por cuadro del recurso | No |
| `idle` | 1 | Pose estática | Pose sostenida |

Celdas RGBA 256×256, atlas 2048×256 y 1536×256, orientación original a la derecha. Suelo y=238; AnimatedSprite2D centrado con offset=(0,-110), que sitúa ese suelo en el origen. Filtro lineal. No normalizar la escala por cuadro.

`Wolf.gd` ofrece `animate(delta, speed01, vel_x=0, air=false, vy=0)`. Mira tras agotarse un intervalo aleatorio de 7–14 s y acumular al menos 0.4 s quieto. El intervalo baja también durante el movimiento: puede mirar poco después de detenerse. Movimiento o aire cancelan la alerta; en aire sostiene idle. No incluye animaciones nuevas de correr o saltar. `trigger_look()` es una llamada forzada que no comprueba reposo por sí misma.

## Tareas para Claude

1. Preservar los cambios locales en `characters/lobo/` y sus controladores. Crear una ruta nueva, por ejemplo `res://characters/lobo/v003/`, y copiar allí juntas las carpetas `Godot/` y `SpriteSheets/` del árbol canónico. Las referencias del recurso son relativas; mantener esa estructura. No usar rutas bajo Game_Assets desde el juego: están excluidas por `.gdignore`.
2. Adaptar el código actual explícitamente: `lobo_sprite.gd` declara `class_name LoboSprite`, usa `BASE_SCALE=0.42`, pivote `_flip`, sombra y offset=(-22,-152). El ejemplo v003 no declara esa clase, usa `BASE_SCALE=0.65`, `flip_h` y otro tamaño de celda. No reemplazarlo a ciegas ni declarar la misma clase dos veces. Mantener responsabilidad de movimiento, colisiones y profundidad en los controladores existentes.
3. Conectar el recurso y la mirada al contrato animate; conservar orientación y escala por profundidad. Revisar velocidad frente a longitud de zancada para evitar deslizamiento. La demo escala ×2 para inspección, no es la escala del escenario.
4. Probar en Camino, Camino lateral y `zones/prueba.tscn`: pies en el suelo, giro, entrada/salida de reposo, interrupción de mirada, salto, sombras, solapes y transiciones. Ajustar colisión a la jugabilidad sin derivarla automáticamente del alfa.
5. Obtener aprobación visual del usuario en el escenario. La importación correcta no equivale a aprobación artística. Mantener el personaje anterior hasta validar la sustitución.

## Verificación reproducible

Ejecutar con el binario Godot 4.7.2 desde la raíz del repositorio (en Mac sustituir `godot` por su ruta):

```text
godot --headless --path Game_Assets/Wolf_Assets_Release_v003/Godot_Preview --editor --import
godot --headless --path Game_Assets/Wolf_Assets_Release_v003/Godot_Preview --script res://Verify.gd
godot --headless --path Game_Assets/Wolf_Assets_Release_v003/Godot_Preview --quit-after 120
```

Resultado local: importación de 20 PNG completada, carga de preview sin errores de recursos/scripts, `Verify.gd` terminó con `RESULT: PASS`. Comprueba carga/tamaño de cada frame, conteos, loop, 8 FPS de walk, intervalo, izquierda/derecha, inicio en reposo, interrupciones y finalización real de la mirada a idle. No valida calidad artística ni integración con el controlador principal. La ejecución headless no sustituye una revisión visual interactiva.

El entorno restringido emitió errores de lectura del almacén de certificados y, durante la importación del editor, acceso a user:// y guardado de preferencias de Godot en AppData. La importación y las pruebas de recursos se completaron; no se verificó el guardado de preferencias del editor. Logs locales `godot_import.log`, `godot_verify.log`, `godot_preview.log`, excluidos de Git.

Abrir el proyecto independiente y usar F5 para revisar: flechas toman control, espacio alterna demo. La preview camina en el sitio y simula pausas para mirar.

Consultar `../LEEME_CODEX_CLAUDE.md` para sincronización Windows/Mac. No se subió ningún cambio a GitHub.
