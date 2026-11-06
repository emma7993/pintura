#!/bin/bash
# Mac: toma las 6 imagenes PNG mas recientes de Descargas (en el orden en que se bajaron), las guarda como
# Game_Assets/Nivel_01_Camino/Cueva_v002/01_roca_corte.png ... 06_puertas.png y las sube a GitHub.
# Uso (desde cualquier carpeta): bash /Users/l03123318/Documents/pintura/herramientas/traer_cueva_v002.sh
cd "$(dirname "$0")/.." || exit 1
DESCARGAS="${DESCARGAS:-$HOME/Downloads}"
DESTINO="Game_Assets/Nivel_01_Camino/Cueva_v002"
NOMBRES="01_roca_corte 02_cueva_fondo 03_cueva_modulos 04_pozo 05_foso_y_plataformas 06_puertas"

LISTA=$(ls -tr "$DESCARGAS"/ChatGPT*.png 2>/dev/null | tail -n 6)
CUANTAS=$(printf '%s\n' "$LISTA" | grep -c .)
if [ "$CUANTAS" -lt 6 ]; then
	echo "Solo encontre $CUANTAS imagen(es) PNG en $DESCARGAS; hacen falta 6."
	exit 1
fi

echo "Se van a guardar asi (de la mas vieja a la mas nueva):"
i=1
printf '%s\n' "$LISTA" | while IFS= read -r f; do
	echo "  $(echo $NOMBRES | cut -d' ' -f$i).png  <-  $(basename "$f")"
	i=$((i + 1))
done
printf "¿Esta bien? (s/n) "
read -r ok
[ "$ok" = "s" ] || [ "$ok" = "S" ] || { echo "Cancelado, no se movio nada."; exit 1; }

mkdir -p "$DESTINO"
i=1
printf '%s\n' "$LISTA" | while IFS= read -r f; do
	mv "$f" "$DESTINO/$(echo $NOMBRES | cut -d' ' -f$i).png"
	i=$((i + 1))
done

git pull --no-rebase --no-edit || { echo "No se pudo traer lo ultimo de GitHub; avisale a Claude."; exit 1; }
git add "$DESTINO"
git commit -m "Arte de cueva v002 de ChatGPT"
git push && echo && echo "=== LISTO: avisale a Claude que ya estan las imagenes ==="
