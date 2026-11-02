"""Arma la hoja de sprites del lobo (8 cuadros, 1 fila) a partir de una hoja de generacion
donde los personajes estan separados por huecos transparentes.
Uso: python armar_hoja_lobo.py <hoja_origen.png> <salida.png> [fila=0] [filas_totales=2]
- Un solo factor de escala (no se reescala nada), misma linea de suelo, ancla horizontal comun.
- Celda 256x320; el suelo queda en y=312 (BASELINE). Offset en Godot: Vector2(128-150, -(312-160)) = (-22,-152)."""
import sys
import numpy as np
from PIL import Image

CELL_W, CELL_H, FRAMES = 256, 320, 8
BASELINE = 312
ANCHOR_X = 150      # el cuerpo queda en x=150 de la celda (la cola larga necesita espacio a la izquierda)

def runs(mask_cols):
    out, s = [], None
    for x, v in enumerate(mask_cols):
        if v and s is None: s = x
        if not v and s is not None: out.append((s, x - 1)); s = None
    if s is not None: out.append((s, len(mask_cols) - 1))
    return out

def main(src, dst, row=0, rows=2):
    im = Image.open(src).convert("RGBA")
    a = np.array(im)
    H, W = a.shape[:2]
    rh = H // rows
    band = a[row * rh:(row + 1) * rh]
    solid = band[..., 3] > 20
    rs = [r for r in runs(solid.any(axis=0)) if r[1] - r[0] > 60]
    assert len(rs) == FRAMES, f"se esperaban {FRAMES} personajes y hay {len(rs)}"
    sheet = Image.new("RGBA", (CELL_W * FRAMES, CELL_H), (0, 0, 0, 0))
    info = []
    for i, (x0, x1) in enumerate(rs):
        crop = band[:, x0:x1 + 1]
        # ancla: centro de masa horizontal del cuerpo oscuro (torso/cabeza), sin cola gris ni bufanda
        r, g, b, al = (crop[..., k].astype(int) for k in range(4))
        body = (al > 200) & (r < 70) & (g < 70) & (b < 70)
        body[: int(rh * 0.08)] = False
        ys, xs = np.nonzero(body)
        anchor = float(xs.mean()) if len(xs) else (x1 - x0) / 2
        left = int(round(ANCHOR_X - anchor))
        cell = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
        cell.paste(Image.fromarray(crop[:CELL_H]), (left, 0))
        sheet.paste(cell, (i * CELL_W, 0))
        info.append((i, x0, x1, round(anchor, 1), left))
    sheet.save(dst)
    for t in info: print("cuadro %d  x %d-%d  ancla %.1f  desplazamiento %d" % t)

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], *(int(v) for v in sys.argv[3:5]))
