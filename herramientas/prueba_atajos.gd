extends SceneTree
## Prueba de los atajos y del guardado del Nivel 1, sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_atajos.gd
## Pulsa cada atajo (1–5), revisa dónde aparece el lobo y qué quedó en la partida, y al final borra la partida (0).

var _t := 0.0
var _paso := 0
var _esperado := {1: "antes del hueco", 2: "pincel", 3: "altar", 4: "lago", 5: "puerta"}


func _initialize() -> void:
	change_scene_to_file("res://zones/nivel_01_camino.tscn")


func _process(delta: float) -> bool:
	_t += delta
	if _t < 1.0:
		return false
	_t = 0.0
	var nivel := current_scene
	if _paso > 0 and _paso <= 5:
		var w: Player = nivel.walker
		print("[atajos] %d (%s): x=%d y=%d  pincel=%s sombras_vencidas=%s tintero=%s tinta=%d" % [
			_paso, _esperado[_paso], w.position.x, w.position.y, nivel.has_brush, nivel.shadows_gone,
			Inventario.tintero, Inventario.tinta])
	if _paso == 6:
		# la partida guardada sobrevive a cerrar el juego: se vuelve a leer del disco
		var c := ConfigFile.new()
		print("[atajos] archivo de partida: ", "OK" if c.load(Inventario.ARCHIVO) == OK else "NO EXISTE",
			"  tinta guardada=", c.get_value("inventario", "tinta", -1))
	if _paso >= 7:
		print("[atajos] FIN")
		quit()
		return true
	_paso += 1
	var key := KEY_0 + (_paso if _paso <= 5 else 0)
	if _paso == 6:
		return false
	var ev := InputEventKey.new()
	ev.keycode = key
	ev.pressed = true
	root.push_input(ev)
	return false
