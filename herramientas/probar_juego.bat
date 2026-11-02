@echo off
rem Ejecuta el juego ~22 s moviendo al lobo solo (herramientas/auto_prueba.gd), guarda capturas (pruebas\cuadro_*.png) y log (pruebas\godot_log.txt).
set GODOT=C:\Users\Immix\Documents\Godot_v4.7.2-stable_win64_console.exe
cd /d "%~dp0.."
if not exist pruebas mkdir pruebas
del /q pruebas\cuadro_*.png 2>nul
"%GODOT%" --path . --write-movie pruebas\cuadro_.png --fixed-fps 10 --quit-after 600 -- --auto-prueba > pruebas\godot_log.txt 2>&1
echo Listo. Revisa la carpeta pruebas.
