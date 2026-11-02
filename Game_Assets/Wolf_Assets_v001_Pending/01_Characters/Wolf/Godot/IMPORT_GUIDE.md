# Integración prevista en Godot 4

Pendiente de atlas validado; no hay un recurso SpriteFrames funcional en este paquete.

Colocar Game_Assets dentro de la carpeta del proyecto que contiene project.godot para que sea accesible como res://Game_Assets/. Si la carpeta del proyecto es otra, copiar allí este directorio; una carpeta externa no queda enlazada automáticamente.

Con el atlas final: crear AnimatedSprite2D y un recurso SpriteFrames; añadir animación Wolf_Walk_Fearful. Usar Añadir fotogramas desde hoja, 8 columnas y 1 fila, seleccionar 01 a 08 de izquierda a derecha; velocidad 8 FPS y loop activado. Confirmar que los cuadros miden 256 × 256.

Mantener centered activado. Una vez medido el punto de apoyo (px, py) dentro de la celda, usar offset = (128-px, 128-py) para situarlo sobre el origen del nodo. Registrar ese punto en el manifiesto; no usar un valor supuesto.

Elegir filtro lineal para el acabado ilustrado y revisar halos sobre fondos claros y oscuros. Evitar compresión con pérdida. Para orientación izquierda puede usarse flip_h si no se requiere dibujo asimétrico específico.

El movimiento del jugador debe responder independientemente de la animación. Idle y Walk se alternarán cuando exista un Idle aprobado; no utilizar un archivo ficticio. Esta entrega no implementa un controlador.
