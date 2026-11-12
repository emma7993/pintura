extends SceneTree
## Mide el dash, el sprint, el derrape y el salto en sprint del lobo (player.gd) sobre un suelo plano, sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_sprint.gd
## Objetivo, medido del video de Hornet (docs/mecanicas_hornet.md) y escalado al lobo (x1.83):
##   dash ~243 px en 0.25 s; sprint ~707 px/s (el doble de la carrera); giro en sprint ~0.65 s con derrape;
##   salto en sprint ~595 px de largo y la misma altura que el salto normal (~220 px).

const GROUND := 600.0
var _w: Player
var _paso := 0
var _t := 0.0
var _x0 := 0.0
var _top := 0.0
var _fallas := 0
var _volt := false


func _initialize() -> void:
	var root := Node2D.new()
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40000, 100)
	cs.shape = shape
	cs.position = Vector2(0, GROUND + 50.0)
	floor_body.add_child(cs)
	root.add_child(floor_body)
	_w = Player.new()
	_w.position = Vector2(0, GROUND)
	_w.can_dash = true
	root.add_child(_w)
	get_root().add_child.call_deferred(root)


func _physics_process(delta: float) -> bool:
	_t += delta
	if _w == null or not _w.is_inside_tree():
		return false
	match _paso:
		0:
			if _t > 0.5:
				Input.action_press("move_right")
				_sig(1)
		1:  # corre y da un toque de dash (sin mantenerlo)
			if _t > 0.5:
				_x0 = _w.position.x
				Input.action_press("dash")
				_sig(2)
		2:
			if _t > 0.03:
				Input.action_release("dash")
			if _t >= 0.25:
				var d := _w.position.x - _x0
				_check("dash: %.0f px en 0.25 s (objetivo ~243)" % d, absf(d - 243.0) < 30.0)
				_check("dash sin mantener: no entra en sprint", not _w.is_sprinting())
				_sig(3)
		3:  # vuelve a la carrera
			if _t > 0.5:
				_check("tras el dash vuelve a la carrera (%.0f px/s)" % _w.velocity.x, absf(_w.velocity.x - Player.RUN_SPEED) < 10.0)
				Input.action_press("dash")
				_sig(4)
		4:  # dash mantenido: sprint
			if _t > 0.8:
				_x0 = _w.position.x
				_sig(5)
		5:
			if _t >= 1.0:
				var v := _w.position.x - _x0
				_check("sprint: %.0f px/s (objetivo ~707)" % v, absf(v - 707.0) < 30.0)
				_check("sprint: el lobo va inclinado", _w.lobo.sprinting)
				Input.action_release("move_right")
				Input.action_press("move_left")
				_sig(6)
		6:  # giro en sprint: derrapa, para y arranca hacia el otro lado
			if _t < 0.15:
				_volt = _volt or _w.lobo.special == "skid"
			if _w.velocity.x <= -Player.RUN_SPEED * Player.SPRINT_MULT + 5.0:
				_check("giro en sprint: %.2f s hasta la velocidad tope contraria (objetivo ~0.65)" % _t, absf(_t - 0.65) < 0.12)
				_check("giro en sprint: derrapa", _volt)
				_volt = false
				_sig(7)
			elif _t > 2.0:
				_check("giro en sprint: no llegó a la velocidad tope", false)
				_sig(7)
		7:  # salto en sprint
			if _t > 0.3:
				_x0 = _w.position.x
				_top = 0.0
				Input.action_press("jump")
				_sig(8)
		8:
			_top = maxf(_top, GROUND - _w.position.y)
			_volt = _volt or absf(_w.lobo.get_child(0).rotation) > 1.0
			if _t > 0.2 and _w.is_on_floor():
				var d := absf(_w.position.x - _x0)
				_check("salto en sprint: %.0f px de largo (objetivo ~595), %.0f px de alto, %.2f s" % [d, _top, _t],
					absf(d - 595.0) < 70.0 and _top > 200.0 and _top < 240.0)
				_check("salto en sprint: da la voltereta", _volt)
				Input.action_release("jump")
				_sig(9)
		9:  # sigue en sprint al aterrizar con el dash apretado; al soltarlo vuelve a la carrera
			if _t > 0.4:
				_check("aterriza y sigue en sprint (%.0f px/s)" % _w.velocity.x, _w.is_sprinting() and _w.velocity.x < -600.0)
				Input.action_release("dash")
				_sig(10)
		10:
			if _t > 0.4:
				_check("al soltar el dash vuelve a la carrera (%.0f px/s)" % _w.velocity.x, absf(_w.velocity.x + Player.RUN_SPEED) < 10.0)
				Input.action_release("move_left")
				print("[sprint] FIN: %s" % ("OK" if _fallas == 0 else "%d fallas" % _fallas))
				quit(1 if _fallas else 0)
				return true
	return false


func _sig(paso: int) -> void:
	_paso = paso
	_t = 0.0


func _check(what: String, ok: bool) -> void:
	print("[sprint] %s: %s" % ["ok" if ok else "FALLA", what])
	if not ok:
		_fallas += 1
