"""Zona del faro: versiones de 20_mar_agitado_derecha y 22_mar_lejano con el borde izquierdo fundido en
transparencia (rampa de 500 px), para el primer tramo de cada mar; sin esto se veía un corte recto donde empieza
el mar. Lee y escribe en art/worlds/camino/nivel_01_fondos_v003/{boceto,definido} (copias de Game_Assets).
Uso: python herramientas/faro_mar_v001.py
"""
from PIL import Image
import numpy as np

V3 = "art/worlds/camino/nivel_01_fondos_v003"
RAMPA = 500
for estado in ("boceto", "definido"):
    for nombre in ("20_mar_agitado_derecha", "22_mar_lejano"):
        im = np.array(Image.open(f"{V3}/{estado}/{nombre}.png").convert("RGBA")).astype(float)
        x = np.arange(im.shape[1])
        f = np.clip(x / RAMPA, 0.0, 1.0)
        f = f * f * (3 - 2 * f)                       # suave en los dos extremos
        im[..., 3] *= f[None, :]
        Image.fromarray(im.round().astype(np.uint8)).save(f"{V3}/{estado}/{nombre}_inicio.png")
        print(estado, nombre + "_inicio.png")
