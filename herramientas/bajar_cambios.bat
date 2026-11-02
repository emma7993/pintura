@echo off
rem Trae lo ultimo de GitHub (usar al empezar a trabajar en una computadora).
cd /d "%~dp0.."
git pull --rebase --autostash
echo.
echo === LISTO ===
git status -sb
