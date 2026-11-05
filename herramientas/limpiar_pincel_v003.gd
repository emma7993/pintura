extends SceneTree
## Quita de characters/lobo/pincel_v003 las animaciones que el juego ya no usa (reemplazadas por la carrera,
## el salto y el combo nuevos) de sus siete SpriteFrames, y de brush_contacts.json. Los PNG se borran aparte.
##   Godot --headless --path . -s res://herramientas/limpiar_pincel_v003.gd

const DIR := "res://characters/lobo/pincel_v003"
const QUITAR := ["run", "jump_start", "jump_up", "fall", "land", "slash_side", "slash_up"]


func _initialize() -> void:
	for f in ["Wolf_body", "Wolf_brush_back", "Wolf_brush_base", "Wolf_smear", "Wolf_tip_color", "Wolf_tip_dry", "Wolf_tip_ink"]:
		var path := DIR + "/Godot/%s.tres" % f
		var sf: SpriteFrames = load(path)
		for a in QUITAR:
			if sf.has_animation(a):
				sf.remove_animation(a)
		var err := ResourceSaver.save(sf, path)
		print("[limpiar] %s: %s" % [f, "ok" if err == OK else "error %d" % err])
	var contacts: Array = JSON.parse_string(FileAccess.get_file_as_string(DIR + "/brush_contacts.json"))
	contacts = contacts.filter(func(c: Dictionary) -> bool: return not c.animation in QUITAR)
	var out := FileAccess.open(DIR + "/brush_contacts.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(contacts, "  "))
	out.close()
	print("[limpiar] brush_contacts.json: %d registros" % contacts.size())
	quit()
