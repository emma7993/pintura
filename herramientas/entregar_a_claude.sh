#!/bin/bash
# Mac: sube a GitHub las imagenes PNG nuevas de Descargas (desde la ultima entrega) a Game_Assets/_entrada/<fecha>/.
# Claude las revisa, les pone su ruta y nombre definitivos y las integra al juego. No importa el orden ni el nombre.
# Se usa con doble clic en "Entregar a Claude" del Escritorio (lo crea herramientas/instalar_entregar.sh).
cd "$(dirname "$0")/.." || exit 1
DESCARGAS="${DESCARGAS:-$HOME/Downloads}"
MARCA="$HOME/.pintura_ultima_entrega"
[ -f "$MARCA" ] || touch -t "$(date -v-1d +%Y%m%d%H%M 2>/dev/null || date -d '-1 day' +%Y%m%d%H%M)" "$MARCA"

LISTA=$(find "$DESCARGAS" -maxdepth 1 -type f -iname 'ChatGPT*' \( -iname '*.png' -o -iname '*.webp' -o -iname '*.jpg' \) -newer "$MARCA" | sort)
N=$(printf '%s' "$LISTA" | grep -c .)
if [ "$N" -eq 0 ]; then
	echo "No hay imagenes nuevas de ChatGPT (archivos \"ChatGPT Image...\") en Descargas desde la ultima entrega."; echo "Si tus imagenes de ChatGPT se bajan con otro nombre, avisale a Claude."
	read -r -p "Enter para cerrar" _; exit 0
fi
echo "Imagenes nuevas en Descargas ($N):"
printf '%s\n' "$LISTA" | while IFS= read -r f; do echo "  $(basename "$f")"; done
read -r -p "¿Las subo para Claude? (s/n) " ok
[ "$ok" = "s" ] || [ "$ok" = "S" ] || { echo "Cancelado, no se movio nada."; read -r -p "Enter para cerrar" _; exit 1; }

DEST="Game_Assets/_entrada/$(date +%Y%m%d_%H%M)"
mkdir -p "$DEST"
printf '%s\n' "$LISTA" | while IFS= read -r f; do
	nombre=$(basename "$f" | tr ' ,' '__' | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null | tr -cd 'A-Za-z0-9._-')
	mv "$f" "$DEST/$nombre"
done
touch "$MARCA"
git pull --no-rebase --no-edit -q || { echo "No se pudo traer lo ultimo de GitHub; avisale a Claude."; read -r -p "Enter para cerrar" _; exit 1; }
git add "$DEST"
git commit -q -m "Entrega para Claude: $N imagen(es) en $DEST"
if git push -q; then
	echo; echo "=== LISTO: $N imagen(es) subidas. Dile a Claude \"ya esta la entrega\" y pegale la LISTA y las NOTAS de ChatGPT ==="
else
	echo "No se pudo subir a GitHub; avisale a Claude."
fi
read -r -p "Enter para cerrar" _
