"""Ajusta las hojas v003 del lobo (original en Game_Assets, copia de trabajo en characters/lobo/v003).
1) Camina: centra cada cuadro por el centroide del alfa (quita el efecto de 'sancadas').
2) look_around: iguala el color (media/desviacion por canal) al de walk y la centra cada cuadro igual que walk.
Uso: python herramientas/ajustar_lobo_v003.py"""
from PIL import Image
import numpy as np, os
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(R, "Game_Assets/Wolf_Assets_Release_v003/01_Characters/Wolf/SpriteSheets")
DST = os.path.join(R, "characters/lobo/v003/SpriteSheets")
def load(n): return np.array(Image.open(os.path.join(SRC, n+".png")).convert("RGBA"))
def cx(c):
    ys, xs = np.where(c[..., 3] >= 128); return xs.mean()
def shift(c, dx):
    out = np.zeros_like(c); dx = int(round(dx))
    if dx >= 0: out[:, dx:] = c[:, :256-dx]
    else: out[:, :256+dx] = c[:, -dx:]
    return out
walk, look = load("walk_v003"), load("look_around_v003")
W = [walk[:, i*256:(i+1)*256] for i in range(8)]
L = [look[:, i*256:(i+1)*256] for i in range(6)]
TARGET = 128.0
W2 = [shift(c, TARGET - cx(c)) for c in W]
# color: look -> walk
def stats(cells):
    p = np.concatenate([c[..., :3][c[..., 3] > 200].astype(float) for c in cells]); return p.mean(0), p.std(0)
mw, sw = stats(W); ml, sl = stats(L)
L2 = []
for c in L:
    f = c.astype(float)
    f[..., :3] = np.clip((f[..., :3]-ml)/sl*sw+mw, 0, 255)
    L2.append(f.astype(np.uint8))
L2 = [shift(c, TARGET - cx(c)) for c in L2]
for n, cells in [("walk_v003", W2), ("look_around_v003", L2)]:
    Image.fromarray(np.concatenate(cells, 1), "RGBA").save(os.path.join(DST, n+".png"))
print("ok")
