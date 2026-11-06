#!/bin/bash
# Mac: guarda en el proyecto las imagenes bajadas de ChatGPT y las sube a GitHub.
# 1) Descarga las imagenes de ChatGPT en el mismo orden de su "LISTA DE ENTREGA".
# 2) Corre: bash /Users/l03123318/Documents/pintura/herramientas/traer_de_chatgpt.sh
# 3) Pega las rutas de la lista (una por linea) y deja una linea vacia al final.
# Las N imagenes mas recientes de Descargas se guardan, en orden de descarga, en esas N rutas.
cd "$(dirname "$0")/.." || exit 1
DESCARGAS="${DESCARGAS:-$HOME/Downloads}"

echo "Pega la LISTA DE ENTREGA de ChatGPT (una ruta por linea) y deja una linea vacia al final:"
RUTAS=""
while IFS= read -r linea; do
	linea=$(printf '%s' "$linea" | sed 's/^[[:space:]-]*//; s/[[:space:]]*$//; s/`//g')
	[ -z "$linea" ] && break
	case "$linea" in
		Game_Assets/*.png) ;;
		*) echo "  Ignoro (no es una ruta Game_Assets/...png): $linea"; continue ;;
	esac
	case "$linea" in *..*|*" "*) echo "  Ignoro (ruta no valida): $linea"; continue ;; esac
	RUTAS="$RUTAS$linea"$'\n'
done
N=$(printf '%s' "$RUTAS" | grep -c .)
[ "$N" -eq 0 ] && { echo "No pegaste ninguna ruta valida."; exit 1; }

LISTA=$(ls -tr "$DESCARGAS"/ChatGPT*.png 2>/dev/null | tail -n "$N")
HAY=$(printf '%s\n' "$LISTA" | grep -c .)
[ "$HAY" -lt "$N" ] && { echo "Hay $N rutas pero solo $HAY PNG en $DESCARGAS."; exit 1; }

echo; echo "Se van a guardar asi (de la descarga mas vieja a la mas nueva):"
paste -d'|' <(printf '%s\n' "$LISTA") <(printf '%s' "$RUTAS") | while IFS='|' read -r f r; do
	echo "  $r  <-  $(basename "$f")"
done
printf "¿Esta bien? (s/n) "
read -r ok
[ "$ok" = "s" ] || [ "$ok" = "S" ] || { echo "Cancelado, no se movio nada."; exit 1; }

paste -d'|' <(printf '%s\n' "$LISTA") <(printf '%s' "$RUTAS") | while IFS='|' read -r f r; do
	mkdir -p "$(dirname "$r")" && mv "$f" "$r"
done

git pull --no-rebase --no-edit || { echo "No se pudo traer lo ultimo de GitHub; avisale a Claude."; exit 1; }
printf '%s' "$RUTAS" | while IFS= read -r r; do git add "$r"; done
git commit -m "Arte de ChatGPT: $(printf '%s' "$RUTAS" | head -1 | cut -d/ -f2-3) ($N imagenes)"
git push && echo && echo "=== LISTO: avisale a Claude que ya estan las imagenes ==="
