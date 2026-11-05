"""Copia el combo de Codex (Game_Assets/Wolf_Combo_v001/Concepto_01/Poses, celdas 512x512 con los pies en
(256,448)) a celdas de 384x384 con los pies en (192,352), como pincel_v003, para que el lobo use un solo
desplazamiento. No cambia la escala ni toca los originales.
Uso (desde la raíz del proyecto):  python herramientas/ajustar_combo_v001.py"""
import os
from PIL import Image

SRC = "Game_Assets/Wolf_Combo_v001/Concepto_01/Poses"
DST = "characters/lobo/combo_v001"
SHIFT = (192 - 256, 352 - 448)

for attack in ("attack_01", "attack_02", "attack_03"):
    os.makedirs(os.path.join(DST, attack), exist_ok=True)
    for i in range(1, 5):
        im = Image.open(os.path.join(SRC, attack, "%02d.png" % i)).convert("RGBA")
        cell = Image.new("RGBA", (384, 384), (0, 0, 0, 0))
        cell.alpha_composite(im, dest=(0, 0), source=(-SHIFT[0], -SHIFT[1], -SHIFT[0] + 384, -SHIFT[1] + 384))
        lost = im.getchannel("A").point(lambda v: 255 if v > 20 else 0).getbbox()
        if lost and (lost[0] < -SHIFT[0] or lost[1] < -SHIFT[1] or lost[2] > 384 - SHIFT[0] or lost[3] > 384 - SHIFT[1]):
            print("aviso: %s/%02d se recorta (%s)" % (attack, i, lost))
        cell.save(os.path.join(DST, attack, "%02d.png" % i))
print("listo:", DST)
