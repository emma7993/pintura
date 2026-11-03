#!/bin/sh
# Revisa una entrega de ChatGPT/Codex antes de integrarla. Uso: herramientas/revisar_entrega.sh Wolf_Varita_v002
# Resultado en pantalla y en pruebas/revision_<carpeta>.txt. Busca Godot en /Applications si no esta en GODOT.
cd "$(dirname "$0")/.."
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
"$GODOT" --headless --path . -s res://herramientas/revisar_entrega.gd -- "$1"
