#!/bin/bash
# Guarda todo lo nuevo y lo sube a GitHub (Mac/Linux). Primera vez: chmod +x herramientas/*.sh
cd "$(dirname "$0")/.." || exit 1
git add -A
git commit -m "Sincroniza proyecto"
git pull --rebase --autostash
git push
echo; echo "=== LISTO ==="; git status -sb
