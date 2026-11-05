"""Copia el salto de Codex (Game_Assets/Wolf_Salto_Estudio_v003/Sprites, celdas 384x384 con los pies en
(192,352), como pincel_v003) a characters/lobo/salto_v003 e iguala el negro del cuerpo al del caminado:
el salto viene casi negro puro (~21) y el caminado es carbón (~40). Solo aclara los tonos oscuros; el
contorno gris, el ojo y la bufanda quedan igual. No toca los originales.
Uso (desde la raíz del proyecto):  python herramientas/ajustar_salto_v003.py"""
import os
from PIL import Image

SRC = "Game_Assets/Wolf_Salto_Estudio_v003/Sprites"
DST = "characters/lobo/salto_v003"
NAMES = {"01_jump_start": "jump_start", "02_jump_up": "jump_up", "03_jump_apex": "jump_apex",
         "04_fall": "fall", "05_land": "land"}
LIFT = 19        # diferencia medida entre el negro del caminado (40) y el del salto (21)
DARK = 90        # tonos con el canal más alto bajo esto se aclaran del todo; hasta DARK+30, en degradé

os.makedirs(DST, exist_ok=True)
for src, dst in NAMES.items():
    im = Image.open(os.path.join(SRC, src + ".png")).convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            m = max(r, g, b)
            w = min(1.0, max(0.0, (DARK + 30 - m) / 30.0))
            if w > 0:
                add = round(LIFT * w)
                px[x, y] = (min(255, r + add), min(255, g + add), min(255, b + add), a)
    im.save(os.path.join(DST, dst + ".png"))
print("listo:", DST)
