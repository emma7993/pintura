extends Node2D
## Zona 1 · Camino. La pintura es el mundo; el lobo recorre el sendero.
## F1: muestra el área transitable.

signal exit_requested(next_zone: String)
signal near_exit_changed(is_near: bool)

## Puntos de entrada (px de la imagen). id = zona a la que llevan.
const EXITS := [
	{"id": "z_cambio", "pos": Vector2(620, 668), "r": 40.0},
	{"id": "z_sueno", "pos": Vector2(196, 328), "r": 32.0},
	{"id": "z_camino", "pos": Vector2(434, 285), "r": 32.0},
	{"id": "z_miedo", "pos": Vector2(716, 426), "r": 36.0},
	{"id": "z_final", "pos": Vector2(479, 1224), "r": 40.0},
]
static var return_pos := Vector2.ZERO

const S := 1.5                                   # escala de la pintura en el mundo
const CUADRO_ESQ := Vector2(157, 163)            # esquina de la pintura dentro de camino_cuadro.jpg
const SPAWN := Vector2(652, 652)                # px de la imagen
const TRACK := 5                                 # canción: Camino

var walker: Walker
var camera: Camera2D
var near_exit := false
var cur_exit := ""
var _moved := false
var _t := 0.0
var _debug: Sprite2D
var _mask_tex: Texture2D


func _ready() -> void:
	# el cuadro completo (camino_cuadro.jpg, de herramientas/pintura_camino_v001.py): la pintura queda en el
	# mismo lugar que antes (la máscara y las salidas no cambian) y el marco la rodea
	var tex: Texture2D = load("res://art/backgrounds/camino_cuadro.jpg")
	var bg := Sprite2D.new()
	bg.texture = tex
	bg.centered = false
	bg.scale = Vector2.ONE * S
	bg.position = -CUADRO_ESQ * S
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bg.z_index = -4000
	add_child(bg)

	_mask_tex = load("res://art/backgrounds/camino_walk.png")
	var mask_img := _mask_tex.get_image()
	if mask_img.is_compressed():
		mask_img.decompress()

	_debug = Sprite2D.new()
	_debug.texture = _mask_tex
	_debug.centered = false
	_debug.scale = Vector2.ONE * S
	_debug.modulate = Color(0.1, 1.0, 0.3, 0.45)
	_debug.z_index = 3000
	_debug.visible = false
	add_child(_debug)

	walker = Walker.new()
	walker.mask = mask_img
	walker.world_scale = S
	add_child(walker)
	walker.moved.connect(func() -> void: _moved = true)
	walker.place((return_pos if return_pos != Vector2.ZERO else SPAWN) * S)
	if Inventario.pincel:                        # ya trae el pincel del Nivel 1: lo lleva como varita
		walker.wolf.set_brush("ink" if Inventario.tinta > 0.0 else "dry")

	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.limit_left = int(-CUADRO_ESQ.x * S)
	camera.limit_top = int(-CUADRO_ESQ.y * S)
	camera.limit_right = int((tex.get_width() - CUADRO_ESQ.x) * S)
	camera.limit_bottom = int((tex.get_height() - CUADRO_ESQ.y) * S)
	camera.offset = Vector2(0, -40)
	walker.add_child(camera)
	camera.reset_smoothing()

	_add_motes()
	queue_redraw()


func _add_motes() -> void:
	# motas de polvo que flotan, para dar vida a la tela
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 0.96, 0.82, 0.55))
	grad.set_color(1, Color(1, 0.96, 0.82, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 32
	gt.height = 32
	var p := CPUParticles2D.new()
	p.texture = gt
	p.amount = 110
	p.lifetime = 10.0
	p.preprocess = 10.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(800, 460)
	p.direction = Vector2(0.4, -1.0)
	p.spread = 40.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 26.0
	p.scale_amount_min = 0.5
	p.scale_amount_max = 2.0
	p.z_index = 3500
	walker.add_child(p)


func _process(delta: float) -> void:
	_t += delta
	var found := ""
	for e in EXITS:
		if walker.position.distance_to((e["pos"] as Vector2) * S) / S < (e["r"] as float) * 1.4:
			found = e["id"]
			break
	cur_exit = found
	var now_near := found != "" and _moved
	if now_near != near_exit:
		near_exit = now_near
		near_exit_changed.emit(near_exit)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		_debug.visible = not _debug.visible
	if event.is_action_pressed("interact") and near_exit:
		return_pos = walker.position / S
		exit_requested.emit(cur_exit)


func _draw() -> void:
	# destellos rojos que marcan las entradas (el rojo de la bufanda como guía)
	var pulse := 1.0 + sin(_t * 3.0) * 0.15
	for e in EXITS:
		var c := (e["pos"] as Vector2) * S + Vector2(0, -40)
		draw_circle(c, 46.0 * pulse, Color(0.75, 0.1, 0.12, 0.10))
		draw_circle(c, 26.0 * pulse, Color(0.75, 0.1, 0.12, 0.28))
		draw_circle(c, 9.0, Color(0.95, 0.85, 0.8, 0.9))


func track() -> int:
	return TRACK


func zone_title() -> String:
	return "Camino"
