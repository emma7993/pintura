#!/bin/bash
# Mac: junta en el Escritorio lo que ChatGPT necesita para diseñar Camino (documento + 10 imagenes) y abre la carpeta.
# Uso (desde cualquier carpeta): bash /Users/l03123318/Documents/pintura/herramientas/preparar_contexto_camino.sh
cd "$(dirname "$0")/.." || exit 1
git pull --no-rebase --no-edit -q && git lfs pull
DEST="$HOME/Desktop/Contexto_Camino_ChatGPT"
rm -rf "$DEST" && mkdir -p "$DEST"
B="Game_Assets/Nivel_01_Camino/Bocetos_v001"
for f in \
	Game_Assets/CONTEXTO_CAMINO_ChatGPT.md \
	docs/diseno/portada_immix.jpg \
	docs/diseno/esquema_camino.png \
	docs/diseno/ref_acuarela_1.png \
	docs/diseno/ref_enemigo_mancha.png \
	docs/diseno/ref_enemigo_fantasma.png \
	"$B/Referencias/Camino_Inacabado.png" \
	"$B/Previews/scene_01.png" \
	"$B/Previews/scene_03.png" \
	Game_Assets/Wolf_Pincel_v003/References/identity.png \
	docs/diseno/Diseno_Metroidvania_Immix.md
do
	cp "$f" "$DEST/" || echo "No encontre: $f"
done
echo "Listo: $(ls "$DEST" | wc -l | tr -d ' ') archivos en $DEST"
open "$DEST"
