extends SceneTree
## Capturas de las acciones del lobo (combo, tajo arriba, dash, tajo abajo y pared) sobre un suelo plano con una
## pared a la derecha (necesita pantalla). Sirve para revisar que todas las animaciones midan lo mismo:
##   Godot --path . -s res://herramientas/captura_acciones.gd   -> pruebas/accion_NN.png (un cuadro cada 0.05 s)

const GROUND := 520.0
var _w: Player
var _t := 0.0
var _n := 0
var _prox := 0.0
var _cam: Camera2D


func _initialize() -> void:
	var root := Node2D.new()
	var fondo := CanvasLayer.new()
	fondo.layer = -10
	var papel := ColorRect.new()
	papel.color = Color(0.96, 0.93, 0.87)
	papel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(papel)
	root.add_child(fondo)
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(40000, 100)
	cs.shape = shape
	cs.position = Vector2(0, GROUND + 50.0)
	floor_body.add_child(cs)
	var linea := Line2D.new()
	linea.points = PackedVector2Array([Vector2(-20000, GROUND), Vector2(20000, GROUND)])
	linea.width = 2.0
	linea.default_color = Color(0.45, 0.40, 0.35)
	root.add_child(linea)
	for i in 400:                              # marcas cada 100 px para leer el avance
		var m := Line2D.new()
		m.points = PackedVector2Array([Vector2(i * 100 - 20000, GROUND), Vector2(i * 100 - 20000, GROUND + 12)])
		m.width = 2.0
		m.default_color = Color(0.45, 0.40, 0.35)
		root.add_child(m)
	root.add_child(floor_body)
	var pared := StaticBody2D.new()
	pared.collision_layer = 1
	var pcs := CollisionShape2D.new()
	var pshape := RectangleShape2D.new()
	pshape.size = Vector2(100, 2000)
	pcs.shape = pshape
	pcs.position = Vector2(1250, GROUND - 1000.0)
	pared.add_child(pcs)
	var plinea := Line2D.new()
	plinea.points = PackedVector2Array([Vector2(1200, GROUND), Vector2(1200, GROUND - 2000)])
	plinea.width = 2.0
	plinea.default_color = Color(0.45, 0.40, 0.35)
	root.add_child(plinea)
	root.add_child(pared)
	Inventario.reiniciar()
	Inventario.progreso = {"n1_sombras": true}
	_w = Player.new()
	_w.position = Vector2(0, GROUND)
	_w.can_dash = true
	_w.can_attack = true
	_w.can_wall = true
	root.add_child(_w)
	_cam = Camera2D.new()
	_cam.offset = Vector2(0, -160)
	_w.add_child(_cam)
	get_root().add_child.call_deferred(root)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://pruebas"))


func _physics_process(delta: float) -> bool:
	_t += delta
	if _w == null or not _w.is_inside_tree():
		return false
	_w.lobo.solo_correr = true
	_w.lobo.set_brush("ink")
	# guion: combo de tres, tajo arriba, dash, salto con tajo abajo, carrera a la pared, salto y resbalar
	_tecla("attack", (_t > 0.8 and _t < 0.85) or (_t > 1.12 and _t < 1.17) or (_t > 1.44 and _t < 1.49) or (_t > 2.1 and _t < 2.15) or (_t > 3.25 and _t < 3.3))
	_tecla("move_up", _t > 2.0 and _t < 2.3)
	_tecla("dash", _t > 2.6 and _t < 2.65)
	_tecla("jump", (_t > 2.95 and _t < 3.2) or (_t > 4.6 and _t < 5.0))
	_tecla("move_down", _t > 3.15 and _t < 3.6)
	_tecla("move_right", _t > 3.9 and _t < 6.4)
	if _t >= _prox and _t > 0.7:
		_prox = _t + 0.05
		var img := root.get_viewport().get_texture().get_image()
		img.save_png(ProjectSettings.globalize_path("res://pruebas/accion_%03d.png" % _n))
		_n += 1
	if _t > 6.5:
		Inventario.reiniciar()
		quit()
		return true
	return false


func _tecla(a: String, on: bool) -> void:
	if on and not Input.is_action_pressed(a):
		Input.action_press(a)
	elif not on and Input.is_action_pressed(a):
		Input.action_release(a)
