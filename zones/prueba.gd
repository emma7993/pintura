extends Node2D
## Zona de prueba para el movimiento (vista lateral). Se corre sola con F6.
## R = volver al inicio.

const SPAWN := Vector2(150, 600)
const INK := Color(0.16, 0.14, 0.14)
const CHALK := Color(0.62, 0.62, 0.60)
const WOOD := Color(0.30, 0.22, 0.18)

var player: Player
var cam: Camera2D


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.93, 0.88, 0.77))

	# suelo (con un hueco en el medio)
	_block(Rect2(-200, 600, 1600, 400))
	_block(Rect2(1700, 600, 2000, 400))
	# plataformas de un solo sentido (se pueden atravesar desde abajo)
	_block(Rect2(400, 470, 200, 24), true)
	_block(Rect2(720, 350, 200, 24), true)
	_block(Rect2(1040, 470, 200, 24), true)
	_block(Rect2(1430, 530, 140, 24), true)
	# pared baja y escalones
	_block(Rect2(2300, 480, 80, 120))
	_block(Rect2(2700, 500, 200, 100))
	_block(Rect2(3050, 420, 220, 24), true)

	player = Player.new()
	player.position = SPAWN
	add_child(player)

	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	cam.limit_left = -200
	cam.limit_right = 3700
	cam.limit_bottom = 900
	cam.offset = Vector2(0, -60)
	player.add_child(cam)
	cam.make_current()   # la cámara de la zona anterior aún existe; con interpolación de física no cede sola

	var ui := CanvasLayer.new()
	add_child(ui)
	var label := Label.new()
	label.position = Vector2(24, 18)
	label.text = "A/D o flechas: correr   ·   Espacio: saltar (mantén = más alto)\n↓ + salto: bajar de una plataforma   ·   R: reiniciar"
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	label.add_theme_constant_override("outline_size", 6)
	ui.add_child(label)


func _physics_process(_delta: float) -> void:
	if player.position.y > 1300.0:
		_respawn()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		_respawn()


func _respawn() -> void:
	player.position = SPAWN
	player.velocity = Vector2.ZERO


func _block(r: Rect2, one_way := false) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 2 if one_way else 1
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.get_center()
	cs.one_way_collision = one_way
	body.add_child(cs)
	add_child(body)

	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	poly.color = WOOD if one_way else INK
	poly.z_index = -10
	add_child(poly)
	var edge := Line2D.new()
	edge.points = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y)])
	edge.width = 5.0
	edge.default_color = CHALK
	edge.z_index = -9
	add_child(edge)
