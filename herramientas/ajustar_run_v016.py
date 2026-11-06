"""Correcciones por script de la carrera v016 (la que eligió Emma), sin tocar los originales de Game_Assets.

Lee Game_Assets/Wolf_Run_v016/Sprites/run/01..08.png y escribe en characters/lobo/run_v016/:
- grano: grano fino de lápiz sobre el carbón del cuerpo (v016 quedó plano, desviación ~2.7; meta ~5).
Brazos y bufanda se quedan como están: los corrige ChatGPT (a script, la bufanda perdía los flecos).

Uso: python herramientas/ajustar_run_v016.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

RAIZ = Path(__file__).resolve().parent.parent
ORIG = RAIZ / "Game_Assets/Wolf_Run_v016/Sprites/run"
SALIDA = RAIZ / "characters/lobo/run_v016"
rng = np.random.default_rng(16)


def ajustar(im: Image.Image) -> Image.Image:
    a = np.array(im.convert("RGBA")).astype(np.float32)
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
        ajustar(Image.open(f)).save(SALIDA / f.name)
        print("listo", f.name)


if __name__ == "__main__":
    main()
