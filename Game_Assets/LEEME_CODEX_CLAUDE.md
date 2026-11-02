# Biblioteca de arte — traspaso Codex / Claude

Instalación local: 2026-11-02. Codex produce y conserva arte en Game_Assets; Claude mantiene estructura, código e integración del juego.

## Entrega vigente

`Wolf_Assets_Release_v003/` contiene la entrega completa, incluidas referencias, originales, prompts, guía reutilizable y proyecto de preview. La versión `Wolf_Assets_v001_Pending/` se conserva como historial; sus advertencias sobre la ausencia de pose aprobada ya no describen v003.

Leer primero `Wolf_Assets_Release_v003/INTEGRACION_CLAUDE.md`. El juego continúa usando los archivos actuales de `characters/lobo/`; instalar la biblioteca no cambia el personaje activo.

`Game_Assets/.gdignore` es intencional: la biblioteca se versiona con Git, pero el proyecto principal no la importa. Abrir el proyecto independiente `Wolf_Assets_Release_v003/Godot_Preview/project.godot` para revisar v003. No quitar el `.gdignore` para integrar un solo personaje.

## Git y dos computadoras

Revisión local: rama `main`, upstream `origin/main`, remoto `https://github.com/emma7993/pintura.git`. La referencia local coincide con el upstream almacenado; no se consultó el estado remoto ni se validó autenticación de GitHub.

Git LFS 3.8.1 está instalado en Windows, los filtros están activos y el hook `pre-push` invoca LFS. `git lfs fsck --objects --pointers` pasó para los objetos ya versionados. `.gitattributes` cubre PNG, GIF, APNG, WebP, audio y formatos 3D. Los PNG/APNG nuevos resuelven al filtro LFS; la entrega todavía está sin añadir al índice. La validación LFS de los nuevos objetos corresponde al momento de preparar su commit.

En Mac, antes de abrir el proyecto:

1. Instalar Git LFS si falta y ejecutar `git lfs install` en el clon.
2. Guardar o confirmar el trabajo local antes de traer cambios. Ejecutar `git pull --rebase` y después `git lfs pull` cuando se autorice la sincronización.
3. Comprobar `git lfs fsck`, `git status` y que los PNG sean imágenes reales, no punteros de texto.
4. Abrir con Godot 4.7.2 para reproducir esta verificación. El README general menciona 4.3+, pero `project.godot` declara 4.7; versiones anteriores no se comprobaron.

`herramientas/.gitattributes` fija LF para `.sh` y CRLF para `.bat` sin cambiar los scripts existentes ni la configuración global. En Mac se pueden ejecutar con `bash herramientas/bajar_cambios.sh` o habilitar permisos con `chmod +x herramientas/*.sh`. Evitar renombrados que solo cambien mayúsculas; usar rutas con el caso exacto y `/` en `res://`.

Los scripts `subir_cambios` hacen `git add -A`, commit, pull y push de todo el trabajo local y no detienen todas las etapas ante errores. Revisar los cambios antes de usarlos. No se ejecutaron estos scripts, ni pull, push, commit o staging durante esta instalación. Existen cambios previos de Claude en README y characters/lobo, conservados íntegramente.

Las carpetas `.godot/` son cachés excluidas de Git; conservar los `.import` y `.uid` generados fuera de la caché. No copiar cachés entre computadoras. El estado de la instalación de Godot/Git LFS en Mac queda pendiente de comprobar allí.
