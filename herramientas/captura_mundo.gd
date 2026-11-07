extends SceneTree
## Captura de una sala del mundo en bloques (para revisar fondos sin jugar). Necesita pantalla:
##   Godot --path . -s res://herramientas/captura_mundo.gd -- ca_enemigos   -> pruebas/mundo_<sala>.png

var _f := 0
var _m: Node
var _sala := "ca_enemigos"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		_sala = args[0]
	_m = load("res://mundo/mundo.gd").new()
	_m.set("en_juego", true)
	_m.set("entrada", _sala)
	root.add_child(_m)


func _process(_d: float) -> bool:
	_f += 1
	if _f == 40:
		DirAccess.make_dir_recursive_absolute("res://pruebas")
		root.get_texture().get_image().save_png("res://pruebas/mundo_%s.png" % _sala)
		print("[captura] pruebas/mundo_%s.png" % _sala)
		return true
	return false
