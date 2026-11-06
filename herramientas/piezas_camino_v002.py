"""Encuentra las piezas sueltas de las hojas 05-08 de ChatGPT (Cueva_v002/separacion_v001) por su canal alfa y
escribe sus rectangulos en art/worlds/camino/nivel_01_piezas_v002/piezas.json. El juego las usa como regiones
de las hojas originales (AtlasTexture), sin recortar ni reescalar los PNG.
Uso: python3 herramientas/piezas_camino_v002.py"""
import json
from pathlib import Path
from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Game_Assets/Nivel_01_Camino/Cueva_v002/separacion_v001"
DST = ROOT / "art/worlds/camino/nivel_01_piezas_v002"
HOJAS = ["05_terreno_vegetacion", "06_cueva_modulos", "07_pozo", "08_foso_espinas"]


def piezas(im):
    w, h = im.size
    a = im.getchannel("A").point(lambda v: 255 if v > 24 else 0)
    a = a.filter(ImageFilter.MaxFilter(9))          # une trazos sueltos de una misma pieza
    px = a.load()
    seen = bytearray(w * h)
    out = []
    for y0 in range(0, h, 2):
        for x0 in range(0, w, 2):
            if px[x0, y0] == 0 or seen[y0 * w + x0]:
                continue
            stack = [(x0, y0)]
            seen[y0 * w + x0] = 1
            x1 = x2 = x0
            y1 = y2 = y0
            n = 0
            while stack:
                x, y = stack.pop()
                n += 1
                x1, x2, y1, y2 = min(x1, x), max(x2, x), min(y1, y), max(y2, y)
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < w and 0 <= ny < h and px[nx, ny] and not seen[ny * w + nx]:
                        seen[ny * w + nx] = 1
                        stack.append((nx, ny))
            if n > 400:
                out.append([x1, y1, x2 - x1 + 1, y2 - y1 + 1])
    out.sort(key=lambda r: (round(r[1] / 120), r[0]))
    return out


DST.mkdir(parents=True, exist_ok=True)
res = {}
for hoja in HOJAS:
    im = Image.open(SRC / f"{hoja}.png").convert("RGBA")
    res[hoja] = piezas(im)
    print(hoja, len(res[hoja]))
(DST / "piezas.json").write_text(json.dumps(res, indent=1))


# Fila de pisada de cada pieza (px desde el borde de arriba de su rectangulo): mediana del primer pixel opaco
# de las columnas centrales, para que las plantas que sobresalen no cuenten. Y el color medio del relleno.
for hoja in HOJAS:
    im = Image.open(SRC / f"{hoja}.png").convert("RGBA")
    a = im.getchannel("A").load()
    for r in res[hoja]:
        x, y, w, h = r
        tops = []
        for cx in range(x + w // 5, x + w * 4 // 5, max(1, w // 60)):
            for cy in range(y, y + h):
                if a[cx, cy] > 128:
                    tops.append(cy - y)
                    break
        tops.sort()
        r.append(tops[len(tops) // 2] if tops else 0)
(DST / "piezas.json").write_text(json.dumps(res, indent=1))
im = Image.open(SRC / "05_terreno_vegetacion.png").convert("RGBA").crop((300, 380, 1300, 470))
px = [p for p in im.getdata() if p[3] > 250]
print("relleno medio:", [round(sum(p[i] for p in px) / len(px) / 255, 3) for i in range(3)])
