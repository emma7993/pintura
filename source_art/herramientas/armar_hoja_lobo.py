"""Arma la hoja de sprites del lobo (8 columnas x 2 filas, celdas de 338x509) a partir de
los 16 cuadros renderizados en Blender (768x768, fondo transparente).
Uso: python armar_hoja_lobo.py <carpeta_con_cuadros_01..16.png> <salida_hoja.png>
La ventana de recorte (235,164) deja el origen del nodo en los pies; no la cambies o el lobo
se moverá/escalará en el juego."""
import sys
from PIL import Image

CELL_W, CELL_H, COLS, ROWS = 338, 509, 8, 2
CROP_X, CROP_Y = 235, 164

def main(folder, out):
    sheet = Image.new("RGBA", (CELL_W * COLS, CELL_H * ROWS), (0, 0, 0, 0))
    for n in range(COLS * ROWS):
        fr = Image.open(f"{folder}/new_{n + 1:02d}.png").convert("RGBA")
        cell = fr.crop((CROP_X, CROP_Y, CROP_X + CELL_W, CROP_Y + CELL_H))
        sheet.paste(cell, ((n % COLS) * CELL_W, (n // COLS) * CELL_H))
    sheet.save(out)

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
