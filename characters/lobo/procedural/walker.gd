class_name Walker
extends Node2D
## Caminante: mueve al lobo libremente (8 direcciones) pero solo sobre el camino.
## `mask` indica dónde se puede pisar; el tamaño del lobo cambia con la profundidad.

signal moved

var mask: Image
var world_scale := 1.5           # píxeles del mundo por píxel de la imagen
var speed := 150.0
var depth_y_far := 280.0         # y (en px de imagen) más lejana
var depth_y_near := 1290.0       # y más cercana
var scale_far := 0.4
var scale_near := 1.35
var wolf: Wolf
var enabled := true
var _vel := Vector2.ZERO


func _ready() -> void:
	wolf = Wolf.new()
	add_child(wolf)


func _walkable(world_pos: Vector2) -> bool:
	var p := world_pos / world_scale
	var x := int(p.x)
	var y := int(p.y)
	if x < 0 or y < 0 or x >= mask.get_width() or y >= mask.get_height():
		return false
	return mask.get_pixel(x, y).r > 0.5


func place(world_pos: Vector2) -> void:
	position = _snap(world_pos)
	_update_depth()


## Si el punto no es transitable, busca el más cercano que sí lo sea (evita que el lobo quede atrapado).
func _snap(world_pos: Vector2) -> Vector2:
	if _walkable(world_pos):
		return world_pos
	var best := world_pos
	var best_d := INF
	for r in range(2, 120, 2):
		for k in 24:
			var a := TAU * k / 24.0
			var c := world_pos + Vector2(cos(a), sin(a)) * r * world_scale
			if _walkable(c) and r * world_scale < best_d:
				best = c
				best_d = r * world_scale
		if best_d < INF:
			break
	return best


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if enabled:
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := dir * speed * clampf(0.35 + 0.7 * _scale_here(), 0.7, 1.25)
	var rate := 520.0 if target.length() > 1.0 else 700.0
	_vel = _vel.move_toward(target, rate * delta)
	if not _walkable(position):
		position = _snap(position)
	var step := _vel * delta
	if step.length() > 0.01:
		var try_pos := position + step
		if _walkable(try_pos):
			position = try_pos
		elif _walkable(position + Vector2(step.x, 0)):
			position += Vector2(step.x, 0)
		elif _walkable(position + Vector2(0, step.y)):
			position += Vector2(0, step.y)
		else:
			_vel = Vector2.ZERO
	_update_depth()
	var sp := clampf(_vel.length() / speed, 0.0, 1.0)
	wolf.animate(delta, sp, _vel.x)
	if sp > 0.05:
		moved.emit()


func _depth01() -> float:
	return clampf((position.y / world_scale - depth_y_far) / (depth_y_near - depth_y_far), 0.0, 1.0)


func _update_depth() -> void:
	var k := _scale_here()
	wolf.scale = Vector2.ONE * Wolf.BASE_SCALE * k
	z_index = int(position.y)


## Recorrido del puente (px de imagen) de la ruina hacia lo más lejano. A lo largo de él el lobo
## se encoge de forma continua, siguiendo la perspectiva de la pintura.
const BRIDGE := [Vector2(612, 440), Vector2(590, 420), Vector2(560, 406), Vector2(500, 392), Vector2(400, 376), Vector2(300, 353), Vector2(200, 332), Vector2(188, 326), Vector2(250, 312), Vector2(300, 303), Vector2(350, 296), Vector2(400, 290), Vector2(445, 284)]
const BRIDGE_SCALE_NEAR := 0.95
const BRIDGE_SCALE_FAR := 0.76

## Escala fuera del puente, según la altura (px de imagen): casi constante entre la ruina y el faro
## y grande abajo, en el agua.
const SCALE_KEYS := [[414.0, 0.95], [668.0, 0.88], [1000.0, 1.10], [1290.0, 1.35]]


func _scale_here() -> float:
	var p := position / world_scale
	if p.y < 450.0:
		var total := 0.0
		var lens: Array[float] = []
		for i in range(BRIDGE.size() - 1):
			var l: float = (BRIDGE[i] as Vector2).distance_to(BRIDGE[i + 1])
			lens.append(l)
			total += l
		var best_d := 1e9
		var best_t := 0.0
		var acc := 0.0
		for i in range(lens.size()):
			var a: Vector2 = BRIDGE[i]
			var b: Vector2 = BRIDGE[i + 1]
			var q := Geometry2D.get_closest_point_to_segment(p, a, b)
			var d := p.distance_to(q)
			if d < best_d:
				best_d = d
				best_t = acc + a.distance_to(q)
			acc += lens[i]
		if best_d < 45.0:
			return lerpf(BRIDGE_SCALE_NEAR, BRIDGE_SCALE_FAR, best_t / total)
	return _scale_at(p.y)


func _scale_at(y: float) -> float:
	if y <= SCALE_KEYS[0][0]:
		return SCALE_KEYS[0][1]
	for i in range(1, SCALE_KEYS.size()):
		if y <= SCALE_KEYS[i][0]:
			var a: Array = SCALE_KEYS[i - 1]
			var b: Array = SCALE_KEYS[i]
			return lerpf(a[1], b[1], (y - a[0]) / (b[0] - a[0]))
	return SCALE_KEYS[SCALE_KEYS.size() - 1][1]
