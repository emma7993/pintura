#!/bin/bash
# Mac: crea en el Escritorio el icono "Entregar a Claude" (doble clic = herramientas/entregar_a_claude.sh). Se corre una vez.
REPO="$(cd "$(dirname "$0")/.." && pwd)"
ICONO="$HOME/Desktop/Entregar a Claude.command"
printf '#!/bin/bash\nbash "%s/herramientas/entregar_a_claude.sh"\n' "$REPO" > "$ICONO"
chmod +x "$ICONO" "$REPO/herramientas/entregar_a_claude.sh"
echo "Listo: en el Escritorio esta \"Entregar a Claude\". Doble clic cuando bajes imagenes de ChatGPT."
