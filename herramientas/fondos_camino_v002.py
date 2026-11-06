"""Fondos del Nivel 1 (Camino), v002: a partir de art/worlds/camino/nivel_01_estados_v001 (ChatGPT, sin tocar).

- boceto/: cada capa se rellena de blanco papel dentro de su silueta (la del definido), con las líneas de lápiz
  encima; así una capa tapa a la de atrás en vez de verse encimadas.
- definido/: todas las capas con el mismo tono (grafito cálido sobre el papel) y aclaradas hacia el papel según
  la distancia, opacas. Antes cada una tenía su color y transparencia.
- 05-08 (terreno): definido al mismo tono de piedra cálida que el relleno del suelo.
- 01_papel_boceto.png: papel blanco para antes de pintar la puerta; 01_papel.png: el papel cálido de siempre.

Uso: python herramientas/fondos_camino_v002.py
"""
from pathlib import Path
from PIL import Image, ImageChops, ImageFilter, ImageOps

RAIZ = Path(__file__).resolve().parent.parent
ORIG = RAIZ / "art/worlds/camino/nivel_01_estados_v001"
SALIDA = RAIZ / "art/worlds/camino/nivel_01_fondos_v002"

BLANCO = (250, 249, 246)          # papel del boceto
SOMBRA = (38, 34, 31)             # grafito más oscuro del definido
PIEDRA = (246, 238, 228)          # luz de la piedra del terreno pintado (relleno del suelo: 217,201,186)
TERRENO = ["05_terreno_vegetacion", "06_cueva_modulos", "07_pozo", "08_foso_espinas"]
# capa: cuánto se aclara hacia el papel (lejanía)
LEJANIA = {
    "02_cielo_nubes": 0.45,
    "03_ruinas_lejanas": 0.30,
    "09_cabeza_lejana": 0.30,
    "10_faro_lejano": 0.30,
    "04_plano_medio": 0.12,
}


def mezcla(a, b, k):
    return tuple(round(a[i] + (b[i] - a[i]) * k) for i in range(3))


def boceto_blanco(boceto: Image.Image, definido: Image.Image) -> Image.Image:
    # silueta: alfa del definido unido al del boceto, cerrado un poco para que no queden huecos
    sil = ImageChops.lighter(definido.getchannel("A"), boceto.getchannel("A"))
    sil = sil.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(1.2))
    base = Image.new("RGBA", boceto.size, BLANCO + (0,))
    base.putalpha(sil)
    base.alpha_composite(boceto)
    return base


def definido_uniforme(definido: Image.Image, papel: tuple, lejos: float) -> Image.Image:
    lum = ImageOps.autocontrast(definido.convert("L"), cutoff=0.5)
    claro = mezcla(papel, papel, 0)
    oscuro = mezcla(SOMBRA, papel, lejos)
    rgb = ImageOps.colorize(lum, black=oscuro, white=claro)
    out = rgb.convert("RGBA")
    a = definido.getchannel("A").point(lambda v: min(255, round(v * 1.6)))   # opaco: antes se transparentaba
    out.putalpha(a)
    return out


def main():
    (SALIDA / "boceto").mkdir(parents=True, exist_ok=True)
    (SALIDA / "definido").mkdir(parents=True, exist_ok=True)
    papel_img = Image.open(ORIG / "01_papel.png").convert("RGB")
    papel_img.save(SALIDA / "01_papel.png")
    papel = papel_img.resize((1, 1), Image.Resampling.BOX).getpixel((0, 0))
    # papel blanco con la misma textura del papel cálido, muy suave
    lum = ImageOps.autocontrast(papel_img.convert("L"), cutoff=1)
    ImageOps.colorize(lum, black=(232, 230, 226), white=(253, 252, 250)).save(SALIDA / "01_papel_boceto.png")
    for capa, lejos in LEJANIA.items():
        b = Image.open(ORIG / "boceto" / f"{capa}.png").convert("RGBA")
        d = Image.open(ORIG / "definido" / f"{capa}.png").convert("RGBA")
        boceto_blanco(b, d).save(SALIDA / "boceto" / f"{capa}.png")
        definido_uniforme(d, papel, lejos).save(SALIDA / "definido" / f"{capa}.png")
        print("listo", capa)
    # piezas de terreno (05-08): el boceto se copia igual; el definido, al tono de piedra cálida del relleno
    for hoja in TERRENO:
        Image.open(ORIG / "boceto" / f"{hoja}.png").save(SALIDA / "boceto" / f"{hoja}.png")
        d = Image.open(ORIG / "definido" / f"{hoja}.png").convert("RGBA")
        lum = ImageOps.autocontrast(d.convert("L"), cutoff=0.3)
        out = ImageOps.colorize(lum, black=SOMBRA, white=PIEDRA).convert("RGBA")
        out.putalpha(d.getchannel("A"))
        out.save(SALIDA / "definido" / f"{hoja}.png")
        print("listo", hoja)
    (SALIDA / "LEEME.txt").write_text(
        "Generado por herramientas/fondos_camino_v002.py desde nivel_01_estados_v001 (no editar a mano).\n"
        "boceto/: relleno blanco dentro de la silueta y lápiz encima. definido/: mismo tono y lejanía, opaco.\n",
        encoding="utf-8")


if __name__ == "__main__":
    main()
