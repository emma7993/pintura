"""Pintura de Camino con el marco que mandó Emma (art/backgrounds/camino_marco_fuente.webp, 1125x1125).

La pintura de adentro es la misma que art/backgrounds/camino.jpg, pero con la palabra «Camino» escrita; se
cubre con camino.jpg (sin letras), que encaja en (109, 113) a 906 px. Salidas:
- art/backgrounds/camino_cuadro.jpg: el cuadro completo, a la escala en la que la pintura mide 1304 px (la del
  mundo de la pintura y su máscara camino_walk.png); la pintura empieza en CUADRO_ESQ.
- art/worlds/camino/nivel_01_fondos_v003/{boceto,definido}/16_marco_camino.png: la puerta del Nivel 1, el mismo
  cuadro (marco oscuro, sin letras) a 512x512; el boceto lo lleva como lápiz claro.
Uso: python herramientas/pintura_camino_v001.py
"""
from PIL import Image, ImageOps

FUENTE = "art/backgrounds/camino_marco_fuente.webp"
PINTURA = "art/backgrounds/camino.jpg"
LADO, X0, Y0 = 906, 109, 113          # dónde está la pintura dentro del marco de la fuente
V3 = "art/worlds/camino/nivel_01_fondos_v003"

pint = Image.open(PINTURA).convert("RGB")
k = pint.width / LADO
marco = Image.open(FUENTE).convert("RGB")
grande = marco.resize((round(marco.width * k), round(marco.height * k)), Image.LANCZOS)
esq = (round(X0 * k), round(Y0 * k))
grande.paste(pint, esq)
grande.save("art/backgrounds/camino_cuadro.jpg", quality=92)
print("camino_cuadro.jpg", grande.size, "pintura en", esq)

# puerta del Nivel 1: el cuadro tal cual (marco oscuro, sin letras), 512x512; el boceto es el mismo a lápiz claro
puerta = grande.resize((512, 512), Image.LANCZOS)
puerta.convert("RGBA").save(f"{V3}/definido/16_marco_camino.png")
gris = ImageOps.autocontrast(puerta.convert("L"), cutoff=2)
lapiz = gris.point(lambda v: round(255 - (255 - v) * 0.20))
Image.merge("RGBA", (lapiz, lapiz, lapiz, Image.new("L", lapiz.size, 255))).save(f"{V3}/boceto/16_marco_camino.png")
print("16_marco_camino.png (cuadro de la puerta, 512x512)")
