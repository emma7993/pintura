extends SceneTree
## Prueba de las mecánicas del lobo en el Nivel 1, sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_mecanicas.gd
## dash, deslizarse por la pared y saltar desde ella, tajo que deshace una mano (gasta tinta),
## rebote (pogo) sobre las espinas y daño al caer en ellas.

var _t := 0.0
var _paso := 0
var _n: Node
var _w: Player
var _x0 := 0.0
var _min_vy := 9999.0
var _slid := false


func _initialize() -> void:
	Inventario.reiniciar()
	Inventario.pincel = true
	Inventario.tintero = true
	Inventario.tinta = 50.0
	Inventario.progreso["n1_sombras"] = true
	Inventario.progreso["n1_trazo_x"] = 5300.0
	Inventario.guardar()
	Inventario.atajo = 3
	change_scene_to_file("res://zones/nivel_01_camino.tscn")


func _suelta() -> void:
	for a in ["move_left", "move_right", "move_up", "move_down", "jump", "attack", "dash"]:
		Input.action_release(a)


func _physics_process(delta: float) -> bool:
	_t += delta
	if _t < 0.6:
		return false
	_n = current_scene
	_w = _n.walker
	match _paso:
		0:  # dash
			_x0 = _w.position.x
			Input.action_press("dash")
			_paso = 1
			_t = 0.6
		1:
			if _t > 1.0:
				print("[mec] dash: avanzó %d px en 0.4 s" % (_w.position.x - _x0))
				_suelta()
				_w.position = Vector2(_n.PLATEAU.x - 120.0, _n.HIGH_Y)
				_paso = 2
				_t = 0.6
		2:  # salta contra la pared de la meseta y la empuja
			Input.action_press("move_right")
			if _t > 0.7 and _t < 0.75:
				Input.action_press("jump")
			if _w.lobo.special == "wall_slide":
				_slid = true
				_min_vy = minf(_min_vy, -_w.velocity.y)
			if _slid and _t > 1.6:
				Input.action_release("jump")
				_paso = 3
				_t = 0.6
			elif _t > 3.0:
				print("[mec] pared: NO se deslizó (special=%s, en pared=%s)" % [_w.lobo.special, _w.is_on_wall()])
				_paso = 4
				_t = 0.6
		3:
			if _t < 0.65:
				Input.action_press("jump")
			elif _t > 0.75:
				print("[mec] pared: se deslizó (caída máx. %d px/s); salto de pared vx=%d vy=%d" % [-_min_vy, _w.velocity.x, _w.velocity.y])
				_suelta()
				_paso = 4
				_t = 0.6
		4:  # mano frente al lobo: tajo con tinta
			_w.position = Vector2(_n.WELL_X - 430.0, _n.HIGH_Y)   # entre el arco y el pozo
			_w.velocity = Vector2.ZERO
			_w.lobo.face(1.0)
			_n._sombras._spawn_hand(_n.WELL_X - 370.0, _n.HIGH_Y)
			_paso = 5
			_t = 0.6
		5:
			if _t > 0.9 and _t < 0.95:
				Input.action_press("attack")
			if _t > 1.4:
				Input.action_release("attack")
				var anims := []
				for h in _n._sombras._hands:
					anims.append(String(h.sprite.animation))
				print("[mec] tajo a una mano: tinta %d (antes 50), manos: %s" % [Inventario.tinta, anims])
				_n._sombras.clear_hands()
				_w.position = Vector2((_n.PIT.x + _n.PIT.y) * 0.5, _n.HIGH_Y - 120.0)
				_w.velocity = Vector2.ZERO
				_paso = 6
				_t = 0.6
		6:  # pogo sobre las espinas
			Input.action_press("move_down")
			if _w.position.y > _n.PIT_FLOOR - 200.0 and not Input.is_action_pressed("attack"):
				Input.action_press("attack")
			if _w.velocity.y < -500.0:
				print("[mec] pogo sobre las espinas: rebotó (vy=%d, vida %d)" % [_w.velocity.y, _w.vida])
				_suelta()
				_paso = 7
				_t = 0.6
			elif _t > 3.0:
				print("[mec] pogo: NO rebotó (vida %d)" % _w.vida)
				_suelta()
				_paso = 7
				_t = 0.6
		7:  # caer en las espinas sin golpear
			_w.position = Vector2((_n.PIT.x + _n.PIT.y) * 0.5, _n.HIGH_Y - 50.0)
			_w.velocity = Vector2.ZERO
			_paso = 8
			_t = 0.6
		8:
			if _t > 3.0:
				print("[mec] cae en las espinas: vida %d de %d, x=%d" % [_w.vida, Player.MAX_VIDA, _w.position.x])
				Inventario.reiniciar()
				quit()
				return true
	return false
