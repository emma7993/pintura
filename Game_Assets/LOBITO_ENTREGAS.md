# Índice de entregas recientes del lobito para Claude

Punto de entrada para las entregas de arte de esta sesión. Leer las notas de cada paquete antes de integrar. Los originales anteriores se conservan y no deben mezclarse automáticamente por el número de versión. Este índice no indica qué archivos están activos en el juego o publicados en GitHub.

| Área | Paquete | Estado y alcance |
|---|---|---|
| Carrera | [Wolf_Run_v013](Wolf_Run_v013/INTEGRACION_CLAUDE.md) | Hoja detallada elegida por el usuario, con restauración puntual de cola; sin pincel. Máster con comparación de píxeles fuera de la cola. |
| Salto y caída | [Wolf_Jump_Fall_v001](Wolf_Jump_Fall_v001/INTEGRACION_CLAUDE.md) | Cinco poses nuevas: tres de salto y dos de caída/aterrizaje. PNG, atlas, ASSETS.json, SpriteFrames y previews. Pendiente de revisión e integración. |
| Combo | [Wolf_Combo_v001/Concepto_01](Wolf_Combo_v001/Concepto_01/INTEGRACION_CLAUDE.md) | Diseño de tres golpes aprobado como dirección artística. Doce poses clave; no son animaciones finales con capas/contactos. |
| Formas del pincel | [Pincel_Formas_v001](Pincel_Formas_v001/INTEGRACION_CLAUDE.md) | Lanza, arco y arpa con cuatro cuadros por transición en seis direcciones. |
| Flechas | [Pincel_Flechas_v003](Pincel_Flechas_v003/INTEGRACION_CLAUDE.md) | Flecha normal fina en seis colores y crítica roja. Incluye estelas e impacto para el pincel-arco. |

Regla vigente: el pincel no se transporta en la carrera; se materializa al atacar o utilizarlo. Los conceptos anteriores de desenvaine/guardado en la espalda deben adaptarse a esa regla antes de producir sus animaciones finales.

Codex mantiene el arte en Game_Assets. Claude controla la integración, los estados, la física, las colisiones y las rutas finales del juego. La biblioteca se publicó en main con Git LFS. Para actualizar el clon de la otra computadora, ejecutar `git pull --ff-only` y luego `git lfs pull`.
