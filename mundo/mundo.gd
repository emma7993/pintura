extends Node2D
## Mundo explorable del juego completo en bloques (greybox), armado a partir de mundo/mapa_datos.gd.
## Cada sala es una pantalla y media con paredes, piso y techo; las salas que el esquema une se conectan
## por una puerta lateral o por un hueco en el piso (con repisas para subir). Las salas cerradas tienen una
## barrera con lo que las abre; las puertas del hub y los atajos son portales (E).
## Teclas: M mapa (clic en una sala para ir), G modo libre (cruzar barreras), E portal, R última banca.
## Se corre solo con F6 (mundo/mundo.tscn). El lobo tiene todas sus habilidades.

const CW := 1920.0                        # una sala = una celda de la cuadrícula
const CH := 1080.0
const WALL := 40.0
const DOOR_H := 300.0
const HOLE_W := 300.0
const LADDER_STEP := 150.0                # repisas para subir por un hueco del techo (salto ~225 px)
const INK := Color(0.12, 0.11, 0.12)

var walker: Player
var free_mode := true                     # las barreras de salas cerradas no frenan (para recorrer el diseño)
var visited := {}                         # id -> true

var _rooms := {}                          # id -> {"d": datos, "rect": Rect2, "solid": [], "plat": [], "gates": []}
var _gates: Array[Dictionary] = []        # {"shape": CollisionShape2D, "rect": Rect2, "req": String}
var _portals: Array[Dictionary] = []      # {"rect": Rect2, "room": id, "to": id, "label": String, "req": String}
var _cur := ""
var _bench := MapaDatos.INICIO
var _cam: Camera2D
var _title: Label
var _hint: Label
var _map: MapaUI
var _near_portal := {}


func _ready() -> void:
	Controls.ensure()
	for d in MapaDatos.SALAS:
		var z: Dictionary = MapaDatos.ZONAS[d.zona]
		var cell: Vector2i = z.origen + Vector2i(d.c, d.f)
		var w := float(d.get("ancho", 1))
		_rooms[d.id] = {"d": d, "rect": Rect2(cell.x * CW, cell.y * CH, CW * w, CH), "solid": [], "plat": [], "gates": [], "doors": []}
	var links := _links()
	for id in _rooms:
		_build_room(id, links.get(id, {}))
	_build_portals()

	walker = Player.new()
	walker.max_speed = 400.0
	walker.can_attack = true
	walker.can_dash = true
	walker.can_wall = true
	add_child(walker)
	walker.lobo.set_brush("ink")
	walker.position = _floor_point(MapaDatos.INICIO, 0.3) + Vector2(0, -4)

	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 6.0
	_cam.position = Vector2(0, -80)          # (no offset: el offset no respeta los límites de la sala)
	walker.add_child(_cam)
	_build_ui()
	_cam.reset_smoothing()
	if "--ver-mapa" in OS.get_cmdline_user_args():      # para capturas de revisión
		for id in _rooms:
			if _rooms[id].d.zona in ["camino", "pintura"]:
				visited[id] = true
		_map.visible = true


# --- construcción ------------------------------------------------------------------------------------

## Para cada sala, de qué lados tiene conexión: "left"/"right"/"up"/"down" -> id vecino.
func _links() -> Dictionary:
	var out := {}
	for pair in MapaDatos.CONEXIONES:
		var a: Dictionary = _rooms[pair[0]]
		var b: Dictionary = _rooms[pair[1]]
		var ra: Rect2 = a.rect
		var rb: Rect2 = b.rect
		var side := ""
		if is_equal_approx(ra.end.x, rb.position.x) and is_equal_approx(ra.position.y, rb.position.y):
			side = "right"
		elif is_equal_approx(rb.end.x, ra.position.x) and is_equal_approx(ra.position.y, rb.position.y):
			side = "left"
		elif is_equal_approx(ra.end.y, rb.position.y) and is_equal_approx(ra.position.x, rb.position.x):
			side = "down"
		elif is_equal_approx(rb.end.y, ra.position.y) and is_equal_approx(ra.position.x, rb.position.x):
			side = "up"
		else:
			push_warning("Conexión entre salas no vecinas: %s - %s" % pair)
			continue
		var opposite := {"right": "left", "left": "right", "down": "up", "up": "down"}
		out.get_or_add(pair[0], {})[side] = pair[1]
		out.get_or_add(pair[1], {})[opposite[side]] = pair[0]
	return out


func _build_room(id: String, links: Dictionary) -> void:
	var room: Dictionary = _rooms[id]
	var d: Dictionary = room.d
	var r: Rect2 = room.rect
	var floor_y := r.end.y - WALL
	var hole_x := r.position.x + r.size.x * 0.5 - HOLE_W * 0.5
	# paredes laterales, con puerta a nivel del piso hacia el vecino
	for side in ["left", "right"]:
		var x := r.position.x if side == "left" else r.end.x - WALL
		if links.has(side):
			_solid(room, Rect2(x, r.position.y, WALL, floor_y - DOOR_H - r.position.y))
			room.doors.append(Rect2(x, floor_y - DOOR_H, WALL, DOOR_H))
		else:
			_solid(room, Rect2(x, r.position.y, WALL, r.size.y))
	# piso: hueco hacia la sala de abajo, tapado por una repisa de un solo sentido (↓ + salto para bajar)
	if links.has("down"):
		_solid(room, Rect2(r.position.x, floor_y, hole_x - r.position.x, WALL))
		_solid(room, Rect2(hole_x + HOLE_W, floor_y, r.end.x - hole_x - HOLE_W, WALL))
		_platform(room, Rect2(hole_x, floor_y, HOLE_W, 14))
		room.doors.append(Rect2(hole_x, floor_y, HOLE_W, WALL))
	else:
		_solid(room, Rect2(r.position.x, floor_y, r.size.x, WALL))
	# techo: hueco hacia la sala de arriba, con repisas para subir
	if links.has("up"):
		_solid(room, Rect2(r.position.x, r.position.y, hole_x - r.position.x, WALL))
		_solid(room, Rect2(hole_x + HOLE_W, r.position.y, r.end.x - hole_x - HOLE_W, WALL))
		room.doors.append(Rect2(hole_x, r.position.y, HOLE_W, WALL))
		var y := floor_y - LADDER_STEP
		var k := 0
		while y > r.position.y + 100.0:
			var off := -150.0 if k % 2 == 0 else 150.0
			_platform(room, Rect2(r.position.x + r.size.x * 0.5 + off - 110.0, y, 220, 14))
			y -= LADDER_STEP
			k += 1
	else:
		_solid(room, Rect2(r.position.x, r.position.y, r.size.x, WALL))
	# un par de repisas de adorno (deterministas por sala), lejos del centro
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	for i in 2:
		var px := r.position.x + (r.size.x * (0.12 if i == 0 else 0.68)) + rng.randf_range(0, 120)
		var py := floor_y - rng.randf_range(160, 210) - i * rng.randf_range(0, 140)
		_platform(room, Rect2(px, py, rng.randf_range(200, 300), 14))
	# sala cerrada: barrera en cada entrada, con lo que la abre
	if d.tipo == "cerrada":
		for door in room.doors:
			var g := door as Rect2
			var bar := g
			if g.size.x < g.size.y:          # puerta lateral: barrera vertical del lado de adentro
				bar = Rect2(g.position.x + (WALL if g.position.x == r.position.x else -WALL), g.position.y, WALL, g.size.y)
			else:                             # hueco: barrera horizontal un poco hacia adentro
				bar = Rect2(g.position.x, g.position.y + (WALL + 6.0 if g.position.y == r.position.y else -20.0), g.size.x, 20)
			var body := _body(bar, 1)
			_gates.append({"shape": body.get_child(0), "rect": bar, "req": d.get("req", "")})
			room.gates.append(bar)
	# dibujo y rótulos
	var node := Node2D.new()
	node.z_index = -5
	node.draw.connect(_draw_room.bind(node, id))
	add_child(node)
	room.node = node
	var color: Color = MapaDatos.ZONAS[d.zona].color
	var label := _label("%s\n%s" % [d.nombre, d.nota], 38, Color(color.darkened(0.55), 0.8))
	label.position = r.position + Vector2(90, CH - 660.0)   # a la vista desde el piso
	var extra := []
	if d.tipo == "cerrada":
		extra.append("Cerrada al inicio — se abre con: " + String(d.get("req", "")))
	if d.get("enemigos", "") != "":
		extra.append("Enemigos: " + String(d.enemigos))
	if d.tipo == "jefe":
		extra.append("JEFE")
	if not extra.is_empty():
		var l2 := _label("\n".join(extra), 26, Color(0.5, 0.12, 0.12, 0.85) if d.tipo == "jefe" else Color(INK, 0.7))
		l2.position = r.position + Vector2(90, CH - 540.0)


## Un portal por cada puerta del hub y cada atajo; en el hub van repartidos a lo ancho.
func _build_portals() -> void:
	var count := {}
	for p in MapaDatos.PORTALES:
		for i in 2:
			var here: String = p[i]
			var there: String = p[1 - i]
			var n: int = count.get(here, 0)
			count[here] = n + 1
			var r: Rect2 = _rooms[here].rect
			var x := r.position.x + (0.15 + 0.17 * n) * r.size.x if here == "pintura" else r.end.x - 360.0
			var rect := Rect2(x, r.end.y - WALL - 260.0, 150, 260)
			var label := String(p[2]) if here == "pintura" else "→ " + String(_rooms[there].d.nombre) + " (" + String(MapaDatos.ZONAS[_rooms[there].d.zona].nombre) + ")"
			_portals.append({"rect": rect, "room": here, "to": there, "label": label, "req": p[3]})
			var l := _label("%s\n%s" % [label, p[3]], 20, Color(INK, 0.85))
			l.position = rect.position + Vector2(-40, -70)
			l.size.x = 260


func _solid(room: Dictionary, r: Rect2) -> void:
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	_body(r, 1)
	room.solid.append(r)


func _platform(room: Dictionary, r: Rect2) -> void:
	var body := _body(r, 2)
	(body.get_child(0) as CollisionShape2D).one_way_collision = true
	room.plat.append(r)


func _body(r: Rect2, layer: int) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = layer
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.get_center()
	body.add_child(cs)
	add_child(body)
	return body


func _label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.z_index = -4
	add_child(l)
	return l


func _floor_point(id: String, frac: float) -> Vector2:
	var r: Rect2 = _rooms[id].rect
	return Vector2(r.position.x + r.size.x * frac, r.end.y - WALL - 4.0)


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 9
	add_child(ui)
	_title = Label.new()
	_title.position = Vector2(24, 16)
	_title.add_theme_font_size_override("font_size", 22)
	_title.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88))
	_title.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_title.add_theme_constant_override("outline_size", 6)
	ui.add_child(_title)
	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_hint.position = Vector2(24, -46)
	_hint.add_theme_font_size_override("font_size", 18)
	_hint.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88))
	_hint.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_hint.add_theme_constant_override("outline_size", 5)
	ui.add_child(_hint)
	_map = MapaUI.new()
	_map.mundo = self
	_map.visible = false
	_map.room_clicked.connect(func(id: String) -> void:
		_go_to(id, 0.5)
		_map.visible = false)
	ui.add_child(_map)


# --- juego -------------------------------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	var id := room_at(walker.position + Vector2(0, -40))
	if id != "" and id != _cur:
		_cur = id
		visited[id] = true
		var r: Rect2 = _rooms[id].rect
		_cam.limit_left = int(r.position.x)
		_cam.limit_right = int(r.end.x)
		_cam.limit_top = int(r.position.y)
		_cam.limit_bottom = int(r.end.y)
		if _rooms[id].d.get("banca", false):
			_bench = id
	_near_portal = {}
	for p in _portals:
		if (p.rect as Rect2).grow(30).has_point(walker.position + Vector2(0, -30)):
			_near_portal = p
	if not _near_portal.is_empty() and Input.is_action_just_pressed("interact"):
		var p := _near_portal
		var dest: Dictionary = {}
		for q in _portals:
			if q.room == p.to and q.to == p.room:
				dest = q
		_teleport((dest.rect as Rect2).get_center() + Vector2(0, 130) if not dest.is_empty() else _floor_point(p.to, 0.5))
	_update_ui()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	match k.keycode:
		KEY_M, KEY_TAB:
			_map.visible = not _map.visible
			_map.queue_redraw()
		KEY_G:
			free_mode = not free_mode
			for g in _gates:
				(g.shape as CollisionShape2D).set_deferred("disabled", free_mode)
			for room in _rooms.values():
				(room.node as Node2D).queue_redraw()
		KEY_R:
			_go_to(_bench, 0.3)


func _go_to(id: String, frac: float) -> void:
	_teleport(_floor_point(id, frac))


func _teleport(p: Vector2) -> void:
	walker.position = p
	walker.velocity = Vector2.ZERO
	_cur = ""
	_cam.reset_smoothing()


func room_at(p: Vector2) -> String:
	for id in _rooms:
		if (_rooms[id].rect as Rect2).has_point(p):
			return id
	return ""


func rooms() -> Dictionary:
	return _rooms


func _update_ui() -> void:
	if _cur == "":
		return
	var d: Dictionary = _rooms[_cur].d
	_title.text = "%s · %s   (%d de %d salas visitadas)" % [MapaDatos.ZONAS[d.zona].nombre, d.nombre, visited.size(), _rooms.size()]
	var h := "M: mapa (clic para ir)   ·   G: modo libre %s   ·   R: última banca" % ("SÍ (las barreras no frenan)" if free_mode else "NO (las barreras frenan)")
	if not _near_portal.is_empty():
		h = "E: entrar — %s   ·   se abre con: %s" % [_near_portal.label, _near_portal.req]
	_hint.text = h


# --- dibujo ------------------------------------------------------------------------------------------

func _draw_room(ci: CanvasItem, id: String) -> void:
	var room: Dictionary = _rooms[id]
	var d: Dictionary = room.d
	var r: Rect2 = room.rect
	var zc: Color = MapaDatos.ZONAS[d.zona].color
	var back := zc.lerp(Color(0.97, 0.95, 0.90), 0.72)
	if d.tipo == "jefe":
		back = back.lerp(Color(0.85, 0.55, 0.55), 0.35)
	ci.draw_rect(r, back)
	for s in room.solid:
		ci.draw_rect(s, zc.darkened(0.35))
		ci.draw_rect(s, INK, false, 3.0)
	for p in room.plat:
		ci.draw_rect(p, zc.darkened(0.15))
		ci.draw_line(p.position, Vector2(p.end.x, p.position.y), INK, 3.0)
	for g in room.gates:
		ci.draw_rect(g, Color(0.75, 0.2, 0.25, 0.25 if free_mode else 0.85))
		ci.draw_rect(g, Color(0.4, 0.05, 0.1), false, 2.0)
	var floor_y := r.end.y - WALL
	if d.get("banca", false):
		var bx := r.position.x + 260.0
		ci.draw_rect(Rect2(bx, floor_y - 50, 140, 16), INK)
		ci.draw_rect(Rect2(bx + 10, floor_y - 34, 12, 34), INK)
		ci.draw_rect(Rect2(bx + 118, floor_y - 34, 12, 34), INK)
		ci.draw_string(ThemeDB.fallback_font, Vector2(bx, floor_y - 64), "Banca", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, INK)
		# cascada y lago de tinta del punto de control
		ci.draw_rect(Rect2(bx + 190, r.position.y + WALL, 46, floor_y - r.position.y - WALL), Color(0.05, 0.05, 0.08, 0.75))
		ci.draw_rect(Rect2(bx + 140, floor_y - 10, 150, 10), Color(0.05, 0.05, 0.08, 0.9))
	if d.tipo == "clave" and id != "pintura":
		var c := Vector2(r.position.x + r.size.x * 0.5, floor_y - 160)
		ci.draw_circle(c, 70, Color(1, 0.92, 0.6, 0.35))
		ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -40), c + Vector2(30, 0), c + Vector2(0, 40), c + Vector2(-30, 0)]), Color(0.95, 0.75, 0.25))
		ci.draw_string(ThemeDB.fallback_font, c + Vector2(-120, 80), "Objeto clave: " + String(d.nota), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, INK)
	if d.tipo == "jefe":
		ci.draw_string(ThemeDB.fallback_font, Vector2(r.position.x + r.size.x * 0.5 - 90, r.position.y + r.size.y * 0.5), "JEFE", HORIZONTAL_ALIGNMENT_LEFT, -1, 90, Color(0.55, 0.1, 0.12, 0.6))
	for p in _portals:
		if p.room == id:
			var pr: Rect2 = p.rect
			ci.draw_rect(pr, Color(0.25, 0.2, 0.35, 0.35))
			ci.draw_rect(pr, INK, false, 4.0)
	if id == "pintura":
		var frame := Rect2(r.position.x + r.size.x * 0.5 - 360, r.position.y + 150, 720, 420)
		ci.draw_rect(frame, Color(0.55, 0.42, 0.28))
		ci.draw_rect(frame.grow(-24), Color(0.92, 0.88, 0.80))
		ci.draw_string(ThemeDB.fallback_font, frame.position + Vector2(170, 230), "La Pintura (portada del álbum)", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, INK)
