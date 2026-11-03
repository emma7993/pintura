@echo off
rem Revisa una entrega de ChatGPT/Codex antes de integrarla. Uso: revisar_entrega.bat Wolf_Varita_v002
rem Resultado en pantalla y en pruebas\revision_<carpeta>.txt
set GODOT=C:\Users\Immix\Documents\Godot_v4.7.2-stable_win64_console.exe
cd /d "%~dp0.."
"%GODOT%" --headless --path . -s res://herramientas/revisar_entrega.gd -- %1
