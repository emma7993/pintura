extends Node2D
## Zona "Camino" en vista lateral. El lobo solo camina (el salto se desbloquea más adelante).
## Izquierda: vuelve al camino de la pintura. Derecha: siguiente zona (aún no existe).

signal exit_requested(next_zone: String)
signal near_exit_changed(is_near: bool)

const GROUND_Y := 600.0
const WIDTH := 4200.0
const SPAWN := Vector2(260, 600)
const TRACK := 5                                  # canción: Camino
const WALK_SPEED := 120.0
const EXITS := [
	{"id": "camino", "x": 110.0, "r": 80.0},
	{"id": "z_sueno", "x": 4090.0, "r": 80.0},
]
const INK := Color(0.16, 0.14, 0.14)
const CHALK := Color(0.62, 0.62, 0.60)

var walker: Player
var cur_exit := ""
var near_exit := false
var _moved := false
var _t := 0.0


func _ready() -> void:
	_build_background()
	_build_ground()
	_build_trunks()

	walker = Player.new()
	walker.max_speed = WALK_SPEED
	walker.can_jump = false
	walker.position = SPAWN
	add_child(walker)

	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 5.0
	cam.limit_left = 0
	cam.limit_right = int(WIDTH)
	cam.limit_bottom = int(GROUND_Y + 160.0)
	cam.offset = Vector2(0, -70)
	walker.add_child(cam)
	cam.make_current()   # la cámara de la zona anterior aún existe; con interpolación de física no cede sola
	cam.reset_smoothing()


func _build_background() -> void:
	# cielo de papel: degradado fijo detrás de todo (tonos de la pintura del camino)
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)
	var grad := Gradient.new()
	grad.set_color(0, Color(0.78, 0.72, 0.58))
	grad.set_color(1, Color(0.93, 0.90, 0.78))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0.5, 0.0)
	gt.fill_to = Vector2(0.5, 1.0)
	gt.width = 8
	gt.height = 256
	var rect := TextureRect.new()
	rect.texture = gt
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)


func _build_ground() -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(WIDTH + 400.0, 400.0)
	cs.shape = shape
	cs.position = Vector2(WIDTH / 2.0, GROUND_Y + 200.0)
	body.add_child(cs)
	add_child(body)

	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-200, GROUND_Y), Vector2(WIDTH + 200, GROUND_Y), Vector2(WIDTH + 200, GROUND_Y + 400), Vector2(-200, GROUND_Y + 400)])
	poly.color = INK
	poly.z_index = -10
	add_child(poly)
	var edge := Line2D.new()
	edge.points = PackedVector2Array([Vector2(-200, GROUND_Y), Vector2(WIDTH + 200, GROUND_Y)])
	edge.width = 5.0
	edge.default_color = CHALK
	edge.z_index = -9
	add_child(edge)


func _build_trunks() -> void:
	# troncos de relleno (provisional: aquí irá el arte de la zona)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var x := 360.0
	while x < WIDTH - 300.0:
		var w := rng.randf_range(38.0, 90.0)
		var tr := Polygon2D.new()
		tr.polygon = PackedVector2Array([Vector2(x, GROUND_Y), Vector2(x + w, GROUND_Y), Vector2(x + w * 0.8, GROUND_Y - 900.0), Vector2(x + w * 0.2, GROUND_Y - 900.0)])
		tr.color = Color(0.26, 0.24, 0.22, rng.randf_range(0.35, 0.8))
		tr.z_index = -20
		add_child(tr)
		x += rng.randf_range(260.0, 620.0)


func _process(delta: float) -> void:
	_t += delta
	if absf(walker.velocity.x) > 1.0:
		_moved = true
	var found := ""
	for e in EXITS:
		if absf(walker.position.x - (e["x"] as float)) < (e["r"] as float):
			found = e["id"]
			break
	cur_exit = found
	var now_near := found != "" and _moved
	if now_near != near_exit:
		near_exit = now_near
		near_exit_changed.emit(near_exit)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and near_exit:
		exit_requested.emit(cur_exit)


func _draw() -> void:
	# destellos rojos que marcan las salidas (igual que en el camino de la pintura)
	var pulse := 1.0 + sin(_t * 3.0) * 0.15
	for e in EXITS:
		var c := Vector2(e["x"] as float, GROUND_Y - 70.0)
		draw_circle(c, 46.0 * pulse, Color(0.75, 0.1, 0.12, 0.10))
		draw_circle(c, 26.0 * pulse, Color(0.75, 0.1, 0.12, 0.28))
		draw_circle(c, 9.0, Color(0.95, 0.85, 0.8, 0.9))


func track() -> int:
	return TRACK


func zone_title() -> String:
	return "Camino"
