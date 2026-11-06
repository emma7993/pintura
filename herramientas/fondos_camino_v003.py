"""Fondos del Nivel 1 (Camino), v003: copia las piezas de ChatGPT de
Game_Assets/Nivel_01_Camino/fondos_unificados_v001 (camino/ en boceto y definido, y los dos papeles) a
art/worlds/camino/nivel_01_fondos_v003, sin cambiarlas. Ya vienen con boceto blanco opaco y definido en sepia
uniforme, misma silueta por pareja; piezas.json de nivel_01_estados_v001 sigue sirviendo para 05-08.

Uso: python herramientas/fondos_camino_v003.py
"""
import shutil
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ORIG = RAIZ / "Game_Assets/Nivel_01_Camino/fondos_unificados_v001"
SALIDA = RAIZ / "art/worlds/camino/nivel_01_fondos_v003"


def main():
    for estado in ["boceto", "definido"]:
        (SALIDA / estado).mkdir(parents=True, exist_ok=True)
        for f in sorted((ORIG / estado / "camino").glob("*.png")):
            shutil.copy2(f, SALIDA / estado / f.name)
    shutil.copy2(ORIG / "papeles/boceto_blanco.png", SALIDA / "01_papel_boceto.png")
    shutil.copy2(ORIG / "papeles/definido_sepia.png", SALIDA / "01_papel.png")
    (SALIDA / "LEEME.txt").write_text(
        "Copiado por herramientas/fondos_camino_v003.py desde Game_Assets/Nivel_01_Camino/fondos_unificados_v001 "
        "(no editar a mano).\n", encoding="utf-8")
    print("listo", SALIDA)


if __name__ == "__main__":
    main()
