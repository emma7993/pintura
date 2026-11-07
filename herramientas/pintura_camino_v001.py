"""Pintura de Camino con el marco que mandó Emma (art/backgrounds/camino_marco_fuente.webp, 1125x1125).

La pintura de adentro es la misma que art/backgrounds/camino.jpg, pero con la palabra «Camino» escrita; se
cubre con camino.jpg (sin letras), que encaja en (109, 113) a 906 px. Salidas:
- art/backgrounds/camino_cuadro.jpg: el cuadro completo, a la escala en la que la pintura mide 1304 px (la del
  mundo de la pintura y su máscara camino_walk.png); la pintura empieza en CUADRO_ESQ.
- art/worlds/camino/nivel_01_fondos_v003/{boceto,definido}/16_marco_camino.png: el marco de la puerta del Nivel 1
  (16_marco_pintura) con esta pintura adentro; el boceto la lleva como lápiz muy claro.
Uso: python herramientas/pintura_camino_v001.py
"""
from PIL import Image, ImageOps

FUENTE = "art/backgrounds/camino_marco_fuente.webp"
PINTURA = "art/backgrounds/camino.jpg"
LADO, X0, Y0 = 906, 109, 113          # dónde está la pintura dentro del marco de la fuente
DENTRO = (87, 196, 426, 535)          # lienzo dentro de 16_marco_pintura (512x768)
V3 = "art/worlds/camino/nivel_01_fondos_v003"

pint = Image.open(PINTURA).convert("RGB")
k = pint.width / LADO
marco = Image.open(FUENTE).convert("RGB")
grande = marco.resize((round(marco.width * k), round(marco.height * k)), Image.LANCZOS)
esq = (round(X0 * k), round(Y0 * k))
grande.paste(pint, esq)
grande.save("art/backgrounds/camino_cuadro.jpg", quality=92)
print("camino_cuadro.jpg", grande.size, "pintura en", esq)

w, h = DENTRO[2] - DENTRO[0], DENTRO[3] - DENTRO[1]
chica = pint.resize((w, h), Image.LANCZOS)
for estado in ("boceto", "definido"):
    m = Image.open(f"{V3}/{estado}/16_marco_pintura.png").convert("RGBA")
    if estado == "boceto":
        gris = ImageOps.autocontrast(chica.convert("L"), cutoff=2)
        lapiz = gris.point(lambda v: round(255 - (255 - v) * 0.22))
        adentro = Image.merge("RGBA", (lapiz, lapiz, lapiz, Image.new("L", (w, h), 255)))
    else:
        adentro = chica.convert("RGBA")
    m.paste(adentro, DENTRO[:2])
    m.save(f"{V3}/{estado}/16_marco_camino.png")
    print(estado, "16_marco_camino.png")
