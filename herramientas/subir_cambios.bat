@echo off
rem Guarda todo lo nuevo y lo sube a GitHub (para usar en cualquier computadora con Windows).
cd /d "%~dp0.."
git add -A
git commit -m "Sincroniza proyecto" -m "Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>" -m "Claude-Session: https://claude.ai/code/session_01AHia5tgndhufgfykvxzacv"
git pull --rebase --autostash
git push
echo.
echo === LISTO ===
git status -sb
