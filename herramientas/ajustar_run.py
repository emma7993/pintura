"""Carrera del lobo para el juego, sin tocar los originales de Game_Assets.

Base: Wolf_Run_v021 (v016 con la bufanda adelgazada y la limpieza de ChatGPT). Los brazos de v021 salieron
negro sobre negro y parpadean en movimiento, así que dentro de su máscara (Source/Masks/NN_brazos.png, fuera de
la de bufanda) se vuelven a poner los brazos de v016. Encima, grano fino de lápiz en el carbón del cuerpo
(v016 quedó plano, desviación ~2.7; meta ~5). Escribe characters/lobo/run_v021/01..08.png.

Uso: python herramientas/ajustar_run.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

RAIZ = Path(__file__).resolve().parent.parent
V016 = RAIZ / "Game_Assets/Wolf_Run_v016/Sprites/run"
ORIG = RAIZ / "Game_Assets/Wolf_Run_v021/Sprites/run"
MASCARAS = RAIZ / "Game_Assets/Wolf_Run_v021/Source/Masks"
SALIDA = RAIZ / "characters/lobo/run_v021"
rng = np.random.default_rng(16)


def ajustar(im: Image.Image, nombre: str) -> Image.Image:
    a = np.array(im.convert("RGBA")).astype(np.float32)
    # brazos de v016 donde v021 los redibujó (sin tocar la bufanda nueva)
    brazos = np.array(Image.open(MASCARAS / f"{nombre}_brazos.png").convert("L")) > 0
    bufanda = np.array(Image.open(MASCARAS / f"{nombre}_bufanda.png").convert("L")) > 0
    viejo = np.array(Image.open(V016 / f"{nombre}.png").convert("RGBA")).astype(np.float32)
    sel = brazos & ~bufanda
    a[sel] = viejo[sel]
    # grano de lápiz en el carbón del cuerpo
    carbon = (a[..., 3] > 128) & (a[..., 0] < 70) & (a[..., 1] < 70) & (a[..., 2] < 70)
    ruido = rng.normal(128.0, 40.0, carbon.shape).clip(0, 255).astype(np.uint8)
    ruido = np.array(Image.fromarray(ruido).filter(ImageFilter.GaussianBlur(0.6))).astype(np.float32) - 128.0
    ruido *= 4.3 / max(ruido.std(), 1e-6)
    for c in range(3):
        canal = a[..., c]
        canal[carbon] = np.clip(canal[carbon] + ruido[carbon], 0, 255)
    return Image.fromarray(a.clip(0, 255).astype(np.uint8))


def main():
    SALIDA.mkdir(parents=True, exist_ok=True)
    for f in sorted(ORIG.glob("0*.png")):
        ajustar(Image.open(f), f.stem).save(SALIDA / f.name)
        print("listo", f.name)


if __name__ == "__main__":
    main()
