@echo off
rem Ejecuta el nivel 1 (Camino) con el guion de herramientas/auto_nivel1.gd: capturas (pruebas\nivel1_*.png), log (pruebas\nivel1_log.txt)
rem y dos GIF para ver el movimiento: pruebas\nivel1_recorrido.gif (todo el nivel) y pruebas\nivel1_caminata.gif (el lobo de cerca).
set GODOT=C:\Users\Immix\Documents\Godot_v4.7.2-stable_win64_console.exe
cd /d "%~dp0.."
if not exist pruebas mkdir pruebas
del /q pruebas\nivel1_*.png 2>nul
"%GODOT%" --path . res://zones/nivel_01_camino.tscn --write-movie pruebas\nivel1_.png --fixed-fps 10 --quit-after 800 -- --auto-nivel1 > pruebas\nivel1_log.txt 2>&1
"%GODOT%" --headless --path . -s res://herramientas/hacer_gif.gd -- pruebas/nivel1_%%08d.png 0 800 pruebas/nivel1_recorrido.gif 400 2
"%GODOT%" --headless --path . -s res://herramientas/hacer_gif.gd -- pruebas/nivel1_%%08d.png 40 110 pruebas/nivel1_caminata.gif 360 1 380,300,520,420
echo Listo. Revisa la carpeta pruebas.
