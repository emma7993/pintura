# Guía del lobo protagonista

## Referencias y autoridad
La hoja recuperada está en References/Wolf_Previous_Sheet.png. El brief histórico completo está en References/Original_Brief.txt. Falta la pose neutra aprobada; no reconstruirla como si fuera el original. La petición actual autoriza producir el paquete completo cuando ambas referencias estén disponibles.

## Identidad invariable
Lobo bípedo de perfil derecho: cuerpo negro, cabeza grande, hocico alargado, orejas triangulares altas con interior gris; ojo blanco sencillo sin pupila. Extremidades largas y delgadas, brazos sin dedos diferenciados. Contornos grises orgánicos y textura sutil de dibujo. Bufanda rojo oscuro con flecos; cola grande curvada de punta gris irregular. Conservar las proporciones de las referencias. No añadir cejas, ropa, garras, símbolos de sobresalto ni sombras de suelo. El lobo conserva dibujo artesanal aunque el mundo sea una pintura al óleo.

## Actuación
Nivel Camino: vulnerabilidad y encogimiento evidentes, cabeza baja, hombros recogidos y brazos cerca del pecho. Pasos cortos, pies próximos al suelo, balanceo de brazos mínimo, cola baja y bufanda con inercia discreta. No correr ni marchar. Wolf_LookAround es una acción futura independiente.

## Contrato técnico provisional
Wolf_Walk_Fearful: 8 cuadros, perfil derecho, loop a 8 FPS, 1 segundo. PNG RGBA, celdas 256 × 256; atlas 2048 × 256, 8 columnas y 1 fila. Confirmar escala con las referencias antes de fijar encuadre y punto de apoyo. Un solo factor de escala para todo el ciclo; nunca ajustar cada cuadro a su caja individual. Misma línea de suelo y origen horizontal; margen transparente en todos los lados. Sin textos ni cuadrícula.

## Orden
01 contacto derecho; 02 transferencia; 03 paso intermedio; 04 preparación izquierda; 05 contacto izquierdo; 06 transferencia opuesta; 07 paso intermedio opuesto; 08 recuperación hacia 01. No duplicar 01 al final para cerrar el loop.

## Archivos futuros
01_Characters/Wolf/Source: salida original de generación y prompt exacto, más archivos editables si existen.
SpriteSheets/Wolf_Walk_Fearful_v001.png: atlas validado.
Individual_Frames/Walk_Fearful/Wolf_Walk_Fearful_01.png hasta 08.png.
Previews: GIF o APNG del loop y plancha de revisión con suelo y celdas, separados de los PNG de juego.
Godot: SpriteFrames .tres y escena de revisión solamente tras validar atlas.

No crear Wolf_Idle ni otras acciones dentro de esta entrega. Versionar sin sobrescribir aprobaciones. Registrar paleta y medidas a partir de las referencias completas, sin inventar valores canónicos.
