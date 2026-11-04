# Pincel en tres formas — v001

Pincel-lanza principal, pincel-arco con una cuerda y pincel-arpa con varias cuerdas. Se mantienen madera negra fina, virola corta, cerdas claras manchadas de tinta y argolla. No se modifica al lobo ni su carrera. La forma principal reutiliza el pincel canónico existente de Wolf_Pincel_v003; las nuevas formas se diseñaron en una única generación integrada.

## Entrega

- Formas/pincel_lanza.png, pincel_arco.png y pincel_arpa.png: PNG RGBA de 384×384.
- Transiciones/: seis direcciones entre las tres formas, con cuatro cuadros numerados 01–04 por dirección y atlas 1536×384.
- Godot/Pincel_Formas.tres: seis animaciones sin bucle a 16 FPS y tres estados estáticos.
- Previews/tres_formas.png: lámina de diseño. ciclo_formas.gif y .apng: recorrido entre formas. GIF individual por transición.
- Source/: original generado, prompt, pincel principal original, punta y exportador reproducible.

**Cuatro cuadros incluyen origen y destino:** forma A, transformación inicial, transformación avanzada, forma B. Duración propuesta 0.25 segundos a 16 FPS. Los GIF tienen pausas largas en los extremos para revisar el diseño; esas pausas no forman parte del recurso de Godot.

Los estados extremos se comparten exactamente entre todas las animaciones: por ejemplo, arco al finalizar lanza_a_arco es el mismo PNG que al iniciar arco_a_arpa. Las vueltas utilizan los mismos cuadros invertidos, sin generaciones extra. VALIDACION.json comprueba esa igualdad y los bordes transparentes.

## Anclas e integración

Origen común de cada celda. La argolla inferior se registra alrededor de (140,323); offset propuesto (−140,−323) si Claude utiliza la argolla como pivote de transformación. Es un ancla visual para la primera revisión; el punto real de agarre de cada forma necesita alinearse con sus futuras poses del lobo. No se exportan contactos de mano medidos.

Las tres formas comparten escala de presentación; el pincel principal conserva sus 215 px nominales. Arco y arpa cambian el contorno al curvarse, sin normalizar cada cuadro por su área opaca. La lámina tiene textura de grafito y cuerdas finas: revisar también los PNG/APNG, pues el GIF pierde grano y detalle de líneas.

Esta entrega diseña formas y transformación, no añade disparo, flecha, tañido del arpa, ataques, proyectiles ni animaciones del personaje. El arma sigue materializándose únicamente cuando se utiliza, conforme a la última dirección del usuario; no añadirla a la carrera. No se han modificado characters/, art/, código, Git ni entregas anteriores. El recurso Godot queda preparado, sin integración en el juego principal.
