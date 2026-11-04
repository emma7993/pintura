# Flechas de pincel v001

La flecha normal tiene punta redondeada y la crítica roja es más gruesa y afilada. La normal roja pertenece a la paleta y conserva la silueta fina.

- Seis proyectiles normales de un cuadro y seis estelas de cuatro cuadros, con el mismo tinte que su proyectil.
- Un proyectil crítico rojo de un cuadro, estela de cuatro cuadros e impacto de cinco cuadros.
- PNG RGBA 384×384, atlas horizontal por secuencia y recurso `Godot/Pincel_Flechas.tres`.
- `ASSETS.json` lista colores RGB, archivos, anclas y tiempos. Los tonos se eligieron para esta entrega. La textura y la transparencia son comunes a las seis variantes.

## Integración

Los proyectiles y estelas miran a la derecha. La punta visual del proyectil y el borde derecho de la estela se registran en x=352. El eje de referencia está en y=192. Claude puede conectar la estela detrás del proyectil usando este borde y un desplazamiento horizontal de acuerdo con el largo visual. El impacto se coloca en el punto de contacto con pivote (192,192). Las colisiones se ajustan por separado.

Las estelas y el impacto están preparados a 20 FPS sin bucle. La estela puede instanciarse en emisiones sucesivas durante el vuelo. Al detectar impacto crítico, usar `impacto_critico` una vez. `normal_rojo` y `critica_roja` son recursos distintos.

`Source/` conserva la generación original, el prompt y el exportador. El arte queda disponible para integración posterior.

