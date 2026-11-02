@echo off
rem Ejecuta el nivel 1 (Camino) ~45 s con el guion de herramientas/auto_nivel1.gd, guarda capturas (pruebas\nivel1_*.png) y log (pruebas\nivel1_log.txt).
set GODOT=C:\Users\Immix\Documents\Godot_v4.7.2-stable_win64_console.exe
cd /d "%~dp0.."
if not exist pruebas mkdir pruebas
del /q pruebas\nivel1_*.png 2>nul
"%GODOT%" --path . res://zones/nivel_01_camino.tscn --write-movie pruebas\nivel1_.png --fixed-fps 10 --quit-after 700 -- --auto-nivel1 > pruebas\nivel1_log.txt 2>&1
echo Listo. Revisa la carpeta pruebas.
