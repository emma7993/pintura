#!/bin/bash
# Copia al juego, sin cambios, los estados de Camino de ChatGPT (Game_Assets/Nivel_01_Camino/Cueva_v002/estados_v001):
# boceto/ (antes de pintar la puerta), definido/ (después) y el papel, en art/worlds/camino/nivel_01_estados_v001/,
# y calcula las piezas de las hojas 05-08 (piezas.json) con herramientas/piezas_camino.py.
cd "$(dirname "$0")/.." || exit 1
SRC="Game_Assets/Nivel_01_Camino/Cueva_v002/estados_v001"
DST="art/worlds/camino/nivel_01_estados_v001"
mkdir -p "$DST/boceto" "$DST/definido"
cp "$SRC/compartido/01_papel.png" "$DST/01_papel.png"
for f in 02_cielo_nubes 03_ruinas_lejanas 04_plano_medio 05_terreno_vegetacion 06_cueva_modulos 07_pozo 08_foso_espinas 09_cabeza_lejana 10_faro_lejano; do
	cp "$SRC/boceto/$f.png" "$DST/boceto/$f.png"
	cp "$SRC/definido/$f.png" "$DST/definido/$f.png"
done
python3 herramientas/piezas_camino.py
printf 'Copia de integración de %s (ChatGPT, 2026-11-05), sin cambios.\nboceto/: antes de pintar la puerta del Nivel 1; definido/: después (se dibuja desde la puerta al pintarla).\npiezas.json: rectángulo y fila de pisada de cada pieza de las hojas 05-08 (herramientas/piezas_camino.py).\nLo usa zones/nivel_01_camino.gd; F3 alterna con los bocetos v001.\n' "$SRC" > "$DST/LEEME.txt"
echo "Listo: $DST"
