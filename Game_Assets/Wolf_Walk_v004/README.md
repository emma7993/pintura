# Caminata V4: postura más recta y bufanda

Variante artística del 2026-11-02, pendiente de aceptación visual en el escenario.

Cambios solicitados: pecho/cabeza algo más elevados, menor inclinación hacia delante y ondulación discreta de la punta de la bufanda. Se conservan el dibujo artesanal, perfil derecho, brazos contenidos y ocho fases de paso. Por petición expresa del usuario, ahora está copiada y conectada al juego principal en `characters/lobo/v004/`; Claude mantiene el desarrollo de los controladores.

## Revisar

Abrir el proyecto principal y pulsar F5 para ver V4. También se puede abrir este `project.godot` como preview independiente: flechas para controlar; espacio para alternar demo.

## Entrega para Claude

- Atlas: `SpriteSheets/walk_v004.png`, RGBA 2048×256, ocho celdas 256×256, 8 FPS en loop, suelo y=238, offset=(0,-110).
- Frames: `Individual_Frames/walk/walk_01.png` a `walk_08.png`.
- Recurso de ejemplo: `Godot/Wolf.tres`.
- Original sin modificar y prompt exacto: `Source/walk_upright_original.png`, `Source/PROMPT.txt`. Creado con image_gen integrado; `Source/pack.gd` realiza únicamente recorte, escala común y empaquetado técnico con Godot.
- Las referencias, guía de identidad y skill reutilizable siguen en `../Wolf_Assets_Release_v003/00_Art_Direction/`. Esta solicitud modifica expresamente la postura encogida anterior para la caminata.

Integración realizada: `characters/lobo/v004/Godot/Wolf.tres` deriva del recurso activo V3 y cambia únicamente la referencia al atlas de caminata. `characters/lobo/lobo_sprite.gd` apunta al recurso V4. Se conservan mirada, idle, reproducción, escala por profundidad y lógica del controlador. V3 sigue disponible para volver atrás cambiando FRAMES_PATH. Comparar tamaño visual en escenario: mismo tamaño de celda no garantiza idéntica silueta.

La demo incluye una copia sin cambios de `look_around_v003.png` y mantiene su idle original: la nueva postura afecta solo a caminar. Revisar el salto de postura al detenerse antes de aprobar. No se regeneró la mirada.

## QA

Importación y ejecución headless en Godot 4.7.2 completadas. `Verify.gd`: RESULT PASS (carga de todas las texturas, dimensiones, 8 cuadros/8 FPS/loop, orientación y transiciones de mirada). Atlas inspeccionado visualmente: ocho figuras completas; bufanda cambia entre fases y torso algo más vertical. El alfa significativo no toca límites de las celdas fuente; escala única y suelo común registrados en `Source/packing_metrics.json`. El empaquetado usa umbral alfa 0.1 para calcular encuadre y conserva el alfa de los recortes; no pinta ni deforma la imagen.

No se ha validado una reproducción visual interactiva del loop 08→01 ni el gamefeel en el escenario; revisar posible variación lateral entre cuadros y continuidad de la tela. Las pequeñas variaciones de dibujo de generación siguen sujetas a aceptación. No se declara aprobación final.

Persisten mensajes del entorno sobre certificados y permisos de preferencias del editor; no se detectaron errores de recursos ni scripts. Los logs locales están excluidos de Git. No se hizo commit ni push.
