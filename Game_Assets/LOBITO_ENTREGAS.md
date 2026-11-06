# Índice de entregas recientes del lobito para Claude

Punto de entrada para las entregas de arte de esta sesión. Leer las notas de cada paquete antes de integrar. Los originales anteriores se conservan y no deben mezclarse automáticamente por el número de versión. Este índice no indica qué archivos están activos en el juego o publicados en GitHub.

| Área | Paquete | Estado y alcance |
|---|---|---|
| Modelo del lobito | [Reposo](Wolf_Pincel_v003/Animations/idle/body/01.png) y [caminado](Wolf_Pincel_v003/Animations/walk/body/01.png) | Referencia vigente de dibujo, proporciones y materiales. Ojo entrecerrado al caminar, abierto al correr, ascender, llegar a la cima y caer. |
| Carrera | [Wolf_Run_v027](Wolf_Run_v027/INTEGRACION_CLAUDE.md) | Aprobada por el usuario el 2026-11-06 como modelo definitivo para pruebas. Ocho cuadros a 20 FPS, proporciones revisadas contra salto y expresión seria. Integración y sincronización técnica a cargo de Claude. |
| Salto y caída | [Wolf_Salto_v004](Wolf_Salto_v004/INTEGRACION_CLAUDE.md) | Cinco poses aprobadas por el usuario el 2026-11-06 como modelo definitivo para pruebas. |
| Combo | [Wolf_Combo_v001/Concepto_01](Wolf_Combo_v001/Concepto_01/INTEGRACION_CLAUDE.md) | Diseño de tres golpes aprobado como dirección artística. Doce poses clave; no son animaciones finales con capas/contactos. |
| Formas del pincel | [Pincel_Formas_v001](Pincel_Formas_v001/INTEGRACION_CLAUDE.md) | Lanza, arco y arpa con cuatro cuadros por transición en seis direcciones. |
| Flechas | [Pincel_Flechas_v003](Pincel_Flechas_v003/INTEGRACION_CLAUDE.md) | Flecha normal fina en seis colores y crítica roja. Incluye estelas e impacto para el pincel-arco. |

Regla vigente: el pincel no se transporta en la carrera; se materializa al atacar o utilizarlo. Los conceptos anteriores de desenvaine/guardado en la espalda deben adaptarse a esa regla antes de producir sus animaciones finales.

Codex mantiene el arte en Game_Assets. Claude controla la integración, los estados, la física, las colisiones y las rutas finales del juego. La biblioteca se publicó en main con Git LFS. Para actualizar el clon de la otra computadora, ejecutar `git pull --ff-only` y luego `git lfs pull`.

Modelos aprobados para esta publicación: [MODELOS_LOBITO_APROBADOS.md](MODELOS_LOBITO_APROBADOS.md). La publicación de assets no cambia por sí sola las animaciones activas del juego.
