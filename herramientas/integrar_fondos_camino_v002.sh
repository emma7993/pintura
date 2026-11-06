#!/bin/bash
# Copia los fondos de ChatGPT (Game_Assets/Nivel_01_Camino/Cueva_v002/separacion_v001, capas 01-04) al juego,
# en art/worlds/camino/nivel_01_fondos_v002/. Los originales de Game_Assets no se tocan.
cd "$(dirname "$0")/.." || exit 1
SRC="Game_Assets/Nivel_01_Camino/Cueva_v002/separacion_v001"
DST="art/worlds/camino/nivel_01_fondos_v002"
mkdir -p "$DST"
for f in 01_papel 02_cielo_nubes 03_ruinas_lejanas 04_plano_medio; do
	cp "$SRC/$f.png" "$DST/$f.png"
done
printf 'Copia de integración de %s (ChatGPT, 2026-11-05): capas 01-04 sin cambios (los bordes se funden en el juego con un shader).\nNo editar aquí a mano. Lo usa zones/nivel_01_camino.gd (_build_fondos_v002); F3 alterna con los fondos v001.\n' "$SRC" > "$DST/LEEME.txt"

echo "Listo: $DST"
