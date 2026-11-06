#!/bin/bash
# Mac: instala (una vez) la subida automatica de Game_Assets cada 2 minutos. Para quitarla:
#   bash herramientas/instalar_subida_automatica.sh quitar
REPO="$(cd "$(dirname "$0")/.." && pwd)"
PLIST="$HOME/Library/LaunchAgents/mx.pintura.subida.plist"
LOG="$HOME/Library/Logs/pintura_subida.log"
launchctl unload "$PLIST" 2>/dev/null
if [ "$1" = "quitar" ]; then
	rm -f "$PLIST"; echo "Subida automatica quitada."; exit 0
fi
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
	<key>Label</key><string>mx.pintura.subida</string>
	<key>ProgramArguments</key><array><string>/bin/bash</string><string>$REPO/herramientas/subida_automatica.sh</string></array>
	<key>StartInterval</key><integer>120</integer>
	<key>RunAtLoad</key><true/>
	<key>StandardOutPath</key><string>$LOG</string>
	<key>StandardErrorPath</key><string>$LOG</string>
</dict></plist>
PL
launchctl load "$PLIST" && echo "Listo: cada 2 minutos se sube lo nuevo de Game_Assets. Registro: $LOG"
