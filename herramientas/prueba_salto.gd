extends SceneTree
## Mide el salto y la carrera del lobo (player.gd) sobre un suelo plano, sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_salto.gd
## Objetivo, medido cuadro por cuadro del video de Hornet (docs/mecanicas_hornet.md) y escalado al lobo (x1.83):
##   salto completo ~222 px, cima a ~0.44 s, ~0.92 s en el aire; carrera 340 px/s.
## Control total: un toque da un brinco corto (~60 px) y soltar a media subida lo para en seco.

const GROUND := 600.0
var _w: Player
var _paso := 0
var _t := 0.0
var _air := 0.0
var _top := 0.0
var _apex_t := 0.0
var _left := false
var _fallas := 0
var _x0 := 0.0
var _soltado := -1.0


func _initialize() -> void:
	var root := Node2D.new()
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20000, 100)
	cs.shape = shape
	cs.position = Vector2(0, GROUND + 50.0)
	floor_body.add_child(cs)
	root.add_child(floor_body)
	_w = Player.new()
	_w.position = Vector2(0, GROUND)
	root.add_child(_w)
	get_root().add_child.call_deferred(root)


func _physics_process(delta: float) -> bool:
	_t += delta
	if _w == null or not _w.is_inside_tree():
		return false
	match _paso:
		0:
			if _t > 0.5:
				_inicio()
				Input.action_press("jump")
				_paso = 1
		1:  # salto completo: botón apretado todo el tiempo
			if _mide(delta):
				Input.action_release("jump")
				_reporta("completo", 210.0, 235.0, 0.86, 0.98)
				_t = 0.0
				_paso = 2
		2:
			if _t > 0.3:
				_inicio()
				Input.action_press("jump")
				_paso = 3
		3:  # toque: se suelta al cuadro siguiente
			if _t > 0.02:
				Input.action_release("jump")
			if _mide(delta):
				_reporta("toque", 50.0, 90.0, 0.25, 0.40)
				_t = 0.0
				_paso = 40
		40:
			if _t > 0.3:
				_inicio()
				Input.action_press("jump")
				_soltado = -1.0
				_paso = 41
		41:  # suelta a media subida: debe parar en seco (casi no sube más)
			if _soltado < 0.0 and _t > 0.12:
				Input.action_release("jump")
				_soltado = GROUND - _w.position.y
			if _mide(delta):
				var extra := _top - _soltado
				_check("al soltar a media subida para en seco: sube %.0f px más (soltó a %.0f px)" % [extra, _soltado], extra < 12.0)
				_t = 0.0
				_paso = 4
		4:
			if _t > 0.3:
				_x0 = _w.position.x
				Input.action_press("move_right")
				_t = 0.0
				_paso = 5
		5:
			if _t >= 1.0:
				var v := _w.position.x - _x0
				Input.action_release("move_right")
				_check("carrera %.0f px/s (objetivo ~340)" % v, absf(v - 340.0) < 15.0)
				print("[salto] FIN: %s" % ("OK" if _fallas == 0 else "%d fallas" % _fallas))
				quit(1 if _fallas else 0)
				return true
	return false


func _inicio() -> void:
	_t = 0.0
	_air = 0.0
	_top = 0.0
	_apex_t = 0.0
	_left = false


## Devuelve true al aterrizar.
func _mide(delta: float) -> bool:
	var h := GROUND - _w.position.y
	if h > 1.0:
		_left = true
	if _left:
		_air += delta
		if h > _top:
			_top = h
			_apex_t = _air
	return _left and _w.is_on_floor() and _air > 0.05


func _reporta(nombre: String, h0: float, h1: float, a0: float, a1: float) -> void:
	_check("salto %s: %.0f px, cima a %.2f s, %.2f s en el aire" % [nombre, _top, _apex_t, _air],
		_top >= h0 and _top <= h1 and _air >= a0 and _air <= a1)


func _check(what: String, ok: bool) -> void:
	print("[salto] %s: %s" % ["ok" if ok else "FALLA", what])
	if not ok:
		_fallas += 1
