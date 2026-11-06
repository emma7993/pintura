#!/bin/bash
# Mac: sube a GitHub lo nuevo de Game_Assets (lo que guarda ChatGPT). Lo corre launchd cada 2 minutos
# (instalar con herramientas/instalar_subida_automatica.sh). Solo toca Game_Assets; nunca el codigo.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
cd "$(dirname "$0")/.." || exit 1
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }
[ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ] && { log "git ocupado (merge/rebase a medias); no subo"; exit 0; }
cambios=$(git status --porcelain -- Game_Assets)
[ -z "$cambios" ] && exit 0
# espera a que ChatGPT termine de escribir: los cambios deben quedar iguales 45 s
sleep 45
[ "$cambios" = "$(git status --porcelain -- Game_Assets)" ] || { log "Game_Assets sigue cambiando; reintento luego"; exit 0; }
n=$(printf '%s\n' "$cambios" | grep -c .)
git add -A -- Game_Assets
git commit -q -m "Entrega de ChatGPT (subida automatica): $n archivo(s) en Game_Assets" -- Game_Assets || exit 0
if git pull -q --no-rebase --no-edit && git push -q; then
	log "subidos $n archivo(s)"
	osascript -e "display notification \"$n archivo(s) de Game_Assets subidos a GitHub\" with title \"Pintura\"" 2>/dev/null
else
	log "ERROR al subir; revisar con git status"
	osascript -e 'display notification "No se pudo subir a GitHub; avisale a Claude" with title "Pintura"' 2>/dev/null
fi
