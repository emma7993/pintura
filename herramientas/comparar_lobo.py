"""Compara una entrega de sprites del lobito contra el lobo original (Wolf_Pincel_v003 idle/walk) y el salto.

Uso (desde la raiz del proyecto):
    python herramientas/comparar_lobo.py Game_Assets/Wolf_Run_v017/Sprites/run [salida.png]

Imprime medidas por cuadro y su diferencia contra el original, y guarda una lamina (original, salto y la
entrega a la misma escala, con zoom de cabeza y manos). Celdas de 384x384, pies en (192,352).
Ver Game_Assets/GUIA_LOBITO.md para los rangos aceptables.
"""
import glob
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

G = "Game_Assets"
REF = [G + "/Wolf_Pincel_v003/Animations/walk/body/01.png", G + "/Wolf_Pincel_v003/Animations/idle/body/01.png"]
SALTO = [G + "/Wolf_Salto_v004/Sprites/02_jump_up.png", G + "/Wolf_Salto_v004/Sprites/03_jump_apex.png"]


def medir(p):
    a = np.array(Image.open(p).convert("RGBA")).astype(int)
    al = a[..., 3] > 128
    rgb = a[..., :3]
    mx, mn = rgb.max(-1), rgb.min(-1)
    ys, xs = np.nonzero(al)
    dark = al & (mx < 60)
    red = al & (rgb[..., 0] > 110) & (rgb[..., 1] < 80) & (rgb[..., 2] < 80)
    grey = al & (mn > 110) & (mx - mn < 25)
    white = al & (mn > 225)
    m = {"alto": int(352 - ys.min()), "ancho": int(xs.max() - xs.min() + 1), "cuerpo": int(dark.sum()),
         "bufanda": int(red.sum()), "gris": int(grey.sum()),
         "carbon": int(np.median(rgb[dark].mean(-1))), "grano": round(float(rgb[dark].mean(-1).std()), 1)}
    wy, wx = np.nonzero(white)
    if len(wy):
        ey, ex = wy.mean(), wx.mean()
        m["ojo_y"] = round(float(ey), 1)
        m["ojo_px"] = int(len(wy))
        m["oreja_ojo"] = round(float(ey - ys.min()), 1)  # tamano de cabeza: punta de oreja a ojo
        fila = np.nonzero(al[int(ey)])[0]
        m["ojo_hocico"] = int(fila.max() - ex) if len(fila) else -1
    # cuello a pies: primera fila con rojo hasta el suelo (largo de cuerpo y piernas)
    ry = np.nonzero(red.any(1))[0]
    if len(ry):
        m["cuello_pies"] = int(352 - ry.min())
        # cuerpo bajo la bufanda, sin la cola (x >= 150): area y contorno gris en el borde
        sub, gsub = al[ry.max() + 2:, 150:], grey[ry.max() + 2:, 150:]
        p = np.pad(sub, 1)
        borde = sub & ~(p[2:, 1:-1] & p[:-2, 1:-1] & p[1:-1, 2:] & p[1:-1, :-2])
        cerca = np.zeros_like(gsub)
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                cerca |= np.roll(np.roll(gsub, dy, 0), dx, 1)
        m["cuerpo_area"] = int(sub.sum())
        m["contorno"] = int(round(100.0 * (borde & cerca).sum() / max(int(borde.sum()), 1)))
    return m


def lamina(grupos, out):
    W, Z = 384, 2
    cols = max(len(g) for g in grupos)
    crop = (120, 110, 300, 260)  # cabeza, bufanda y manos
    cw, ch = (crop[2] - crop[0]) * Z, (crop[3] - crop[1]) * Z
    img = Image.new("RGBA", (cols * W, len(grupos) * (W + ch)), (226, 216, 196, 255))
    d = ImageDraw.Draw(img)
    for r, g in enumerate(grupos):
        y0 = r * (W + ch)
        for c, p in enumerate(g):
            im = Image.open(p).convert("RGBA")
            img.alpha_composite(im, (c * W, y0))
            z = im.crop(crop).resize((cw, ch), Image.NEAREST)
            img.alpha_composite(z, (c * W + (W - cw) // 2, y0 + W))
            d.line([(c * W, y0 + 352), (c * W + W, y0 + 352)], fill=(150, 140, 120, 255))
            d.text((c * W + 6, y0 + 6), os.path.basename(p), fill=(60, 50, 40, 255))
    img.save(out)


def main():
    d = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else "pruebas/comparar_lobo.png"
    frames = sorted(glob.glob(d + "/*.png"))
    ref = [medir(p) for p in REF]
    base = {k: np.mean([r[k] for r in ref]) for k in ref[0]}
    claves = ["alto", "ancho", "cuerpo", "bufanda", "gris", "carbon", "grano", "oreja_ojo", "ojo_hocico", "ojo_px", "cuello_pies", "cuerpo_area", "contorno"]
    print("%-14s" % "cuadro" + "".join("%11s" % k for k in claves))
    for nombre, m in [("original", base)] + [(os.path.basename(p), medir(p)) for p in SALTO + frames]:
        fila = []
        for k in claves:
            v = m.get(k, float("nan"))
            fila.append("%11s" % ("%.0f" % v if nombre == "original" or k in ("alto", "ancho", "carbon")
                                  else "%+.0f%%" % (100.0 * (v - base[k]) / base[k]) if base[k] else "-"))
        print("%-14s" % nombre + "".join(fila))
    ms = [medir(p) for p in frames]
    if ms and "ojo_y" in ms[0]:
        oy = [m["ojo_y"] for m in ms]
        saltos = [abs(oy[i] - oy[i - 1]) for i in range(len(oy))]
        print("rebote del ojo: %.1f px (mayor salto entre cuadros %.1f px)" % (max(oy) - min(oy), max(saltos)))
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    lamina([REF + SALTO, frames], out)
    print("lamina:", out)


if __name__ == "__main__":
    main()
