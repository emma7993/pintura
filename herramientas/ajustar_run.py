"""Carrera del lobo para el juego, sin tocar los originales de Game_Assets.

Base: Wolf_Run_v022 (v021 con los brazos de v016 y las manos afiladas en punta). En los cuadros 04-06 la mano
de atrás queda sobre la cola y el cuerpo; al afilarla, v022 recortó un hueco rectangular en ellos, así que ahí
(máscara Source/Masks/NN_mano_1.png) se deja la base sin afilar. Encima, grano fino de lápiz en el carbón del
cuerpo (meta ~5 de desviación, como el original). Escribe characters/lobo/run_v022/01..08.png.

Uso: python herramientas/ajustar_run.py
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

RAIZ = Path(__file__).resolve().parent.parent
ENTREGA = RAIZ / "Game_Assets/Wolf_Run_v022"
ORIG = ENTREGA / "Sprites/run"
BASE = ENTREGA / "Source/Base"
MASCARAS = ENTREGA / "Source/Masks"
SALIDA = RAIZ / "characters/lobo/run_v022"
SIN_AFILAR = {"04": ["mano_1"], "05": ["mano_1"], "06": ["mano_1"]}   # mano sobre la cola: v022 abría hueco
rng = np.random.default_rng(16)


def ajustar(im: Image.Image, nombre: str) -> Image.Image:
    a = np.array(im.convert("RGBA")).astype(np.float32)
    for mano in SIN_AFILAR.get(nombre, []):
        sel = np.array(Image.open(MASCARAS / f"{nombre}_{mano}.png").convert("L")) > 0
        base = np.array(Image.open(BASE / f"{nombre}.png").convert("RGBA")).astype(np.float32)
        a[sel] = base[sel]
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
