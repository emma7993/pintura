# Control de calidad v003

Comprobado: 8 cuadros de caminata y 6 de alerta; RGBA con alfa real; celdas 256×256; atlas 2048×256 y 1536×256; márgenes sin personaje recortado; apoyo sustancial alineado en y=238; escala común dentro de cada secuencia. Métricas en qa_metrics.json. Se conserva el alfa original al componer.

Inspección visual de planchas: pasos opuestos más claros que v002, brazos contenidos, giro de cabeza real hacia atrás con torso hacia adelante; sin símbolos añadidos. Alerta examinada sobre fondo claro: los colores fuera del personaje tienen alfa cero y no producen el halo que parecía verse en el visor de origen. Persisten pequeñas variaciones de trazo, postura y zancada entre cuadros generados; se requiere revisión visual en el escenario antes de aprobar el resultado definitivo. No se afirma ausencia absoluta de deslizamiento: depende de la velocidad del personaje.

Godot 4.7.2: importación y carga sin errores de recursos o scripts. Prueba automática PASS: número de cuadros, alerta no cíclica, intervalo 7–14 s, activación en reposo, cancelación inmediata por movimiento, orientación izquierda, finalización a idle y cancelación en aire. El entorno emitió errores de permisos para logs/configuración de usuario y almacén de certificados, ajenos a los recursos.

No se probó ni instaló dentro de pintura. No se ejecutó una sesión visual interactiva completa de juego. La preview permite al usuario revisar movimiento y transiciones en su Godot.
