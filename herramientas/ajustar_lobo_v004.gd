extends SceneTree
## Ajusta la caminata v004 del lobo (original en Game_Assets, copia de trabajo en characters/lobo/v004).
## Centra cada cuadro por el centroide del alfa, como ajustar_lobo_v003.py: la hoja original queda
## ~9 px a la derecha del reposo/mirada y el lobo saltaba hacia atrás al detenerse.
## La mirada (look_around_v003.png) ya es la copia ajustada de v003 y no se toca.
## GDScript para no depender de Python. Uso:
##   Godot --headless --path . --script res://herramientas/ajustar_lobo_v004.gd

const SRC := "res://Game_Assets/Wolf_Walk_v004/SpriteSheets/walk_v004.png"
const DST := "res://characters/lobo/v004/SpriteSheets/walk_v004.png"
const CELL := 256
const TARGET := 128.0


func _init() -> void:
	var img := Image.load_from_file(ProjectSettings.globalize_path(SRC))
	img.convert(Image.FORMAT_RGBA8)
	var n := img.get_width() / CELL
	var out := Image.create(img.get_width(), CELL, false, Image.FORMAT_RGBA8)
	for i in n:
		var c := img.get_region(Rect2i(i * CELL, 0, CELL, CELL))
		var dx := roundi(TARGET - _centro_x(c))
		out.blit_rect(c, Rect2i(maxi(0, -dx), 0, CELL - absi(dx), CELL), Vector2i(i * CELL + maxi(0, dx), 0))
	out.save_png(ProjectSettings.globalize_path(DST))
	print("ok")
	quit()


func _centro_x(c: Image) -> float:
	var suma := 0.0
	var cuenta := 0
	for y in CELL:
		for x in CELL:
			if c.get_pixel(x, y).a >= 0.5:
				suma += x
				cuenta += 1
	return suma / cuenta
