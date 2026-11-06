extends SceneTree
## Capturas del Nivel 1 en puntos fijos (para revisar arte sin jugar). Necesita pantalla (xvfb en Linux):
##   Godot --path . -s res://herramientas/captura_nivel1.gd -- x,y x,y ...   -> pruebas/captura_N.png
## Sin puntos usa una lista de lugares clave. «--v001» captura con el arte anterior (como F3); «--puerta», con la
## puerta ya pintada (arte definido).

var _puntos: Array[Vector2] = []
var _lvl: Node
var _i := 0
var _espera := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for a in args:
		if "," in a:
			var p := a.split(",")
			_puntos.append(Vector2(float(p[0]), float(p[1])))
	if _puntos.is_empty():
		_puntos = [Vector2(700, 600), Vector2(4200, 490), Vector2(6800, 490), Vector2(7950, 490), Vector2(5980, 490),
			Vector2(5300, 1250), Vector2(6300, 1250), Vector2(7250, 1550), Vector2(8550, 1250)]
	Inventario.reiniciar()
	Inventario.pincel = true
	Inventario.progreso = {"n1_sombras": true, "n1_trazo_x": 5210.0}
	if "--puerta" in args:
		Inventario.progreso["n1_puerta"] = true
	_lvl = (load("res://zones/nivel_01_camino.tscn") as PackedScene).instantiate()
	root.add_child(_lvl)
	if "--v001" in args:
		_lvl.call("_set_fondos_v002", false)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://pruebas"))


func _process(_delta: float) -> bool:
	if _i >= _puntos.size():
		return true
	var w: Node2D = _lvl.get("walker")
	if _espera == 0:
		w.position = _puntos[_i]
		w.set("velocity", Vector2.ZERO)
		(_lvl.get("_cam") as Camera2D).reset_smoothing()
	_espera += 1
	if _espera >= 20:
		var img := root.get_viewport().get_texture().get_image()
		img.save_png(ProjectSettings.globalize_path("res://pruebas/captura_%d.png" % (_i + 1)))
		print("[captura] %d: %s" % [_i + 1, _puntos[_i]])
		_i += 1
		_espera = 0
	return false
