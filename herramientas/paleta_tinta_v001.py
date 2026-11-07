"""Paleta con tinta: copia de cueva_paleta/04_paleta (definido) con el hueco grande de abajo a la izquierda lleno
de tinta negra, para el ícono de arriba cuando la paleta tiene tinta. No toca el original de Game_Assets.
Uso: python herramientas/paleta_tinta_v001.py
"""
from PIL import Image, ImageDraw, ImageFilter

DIR = "art/worlds/camino/nivel_01_fondos_v003/definido/cueva_paleta"
im = Image.open(f"{DIR}/04_paleta.png").convert("RGBA")
# hueco de abajo a la izquierda: centro y radios en px de la imagen 1254x1254
cx, cy, rx, ry = 254, 667, 78, 70
capa = Image.new("RGBA", im.size, (0, 0, 0, 0))
d = ImageDraw.Draw(capa)
d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=(14, 13, 18, 255))
d.ellipse((cx - rx * 0.55, cy - ry * 0.62, cx - rx * 0.05, cy - ry * 0.32), fill=(70, 72, 84, 150))   # brillo
capa = capa.filter(ImageFilter.GaussianBlur(1.5))
im.alpha_composite(capa)
im.save(f"{DIR}/04_paleta_tinta.png")
print("04_paleta_tinta.png")
