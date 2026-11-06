#!/bin/bash
# Trae lo ultimo de GitHub (Mac/Linux).
cd "$(dirname "$0")/.." || exit 1
git pull --rebase --autostash
echo; echo "=== LISTO ==="; git status -sb
