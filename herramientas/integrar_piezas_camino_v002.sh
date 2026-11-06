#!/bin/bash
# Copia las hojas de piezas de ChatGPT (Game_Assets/Nivel_01_Camino/Cueva_v002/separacion_v001, 05-08) al juego, sin
# cambios, en art/worlds/camino/nivel_01_piezas_v002/, y calcula sus piezas (piezas.json) con piezas_camino_v002.py.
cd "$(dirname "$0")/.." || exit 1
SRC="Game_Assets/Nivel_01_Camino/Cueva_v002/separacion_v001"
DST="art/worlds/camino/nivel_01_piezas_v002"
mkdir -p "$DST"
for f in 05_terreno_vegetacion 06_cueva_modulos 07_pozo 08_foso_espinas; do
	cp "$SRC/$f.png" "$DST/$f.png"
done
python3 herramientas/piezas_camino_v002.py
printf 'Copia de integración de %s (ChatGPT, 2026-11-05): hojas 05-08 sin cambios.\npiezas.json: rectángulo y fila de pisada de cada pieza (herramientas/piezas_camino_v002.py).\nLo usa zones/nivel_01_camino.gd (_pieza, _build_piezas_v002); F3 alterna con los bocetos v001.\n' "$SRC" > "$DST/LEEME.txt"
echo "Listo: $DST"
