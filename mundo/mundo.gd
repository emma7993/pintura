extends Node2D
## Mundo explorable del juego completo en bloques (greybox), armado a partir de mundo/mapa_datos.gd.
## Cada sala es una pantalla y media con paredes, piso y techo; las salas que el esquema une se conectan
## por una puerta lateral o por un hueco en el piso (con repisas para subir). Las salas cerradas tienen una
## barrera con lo que las abre; las puertas del hub y los atajos son portales (E).
## Teclas: M mapa (clic en una sala para ir), G modo libre (cruzar barreras), E portal, R última banca.
## Se corre solo con F6 (mundo/mundo.tscn): todo el mapa y el lobo con todas sus habilidades.
## En el juego (main.gd, en_juego = true) solo arma el resto de Camino: las salas que ya son el Nivel 1
## (MapaDatos.NIVEL1) no se arman, y al entrar en ellas se vuelve al Nivel 1 por el lugar que toca. Desde
## una banca se vuelve a la pintura; los atajos a otras zonas aún llevan a «continuará».

signal exit_requested(next_zone: String)
signal near_exit_changed(is_near: bool)

const CW := MapaDatos.CW                  # una sala = una celda de la cuadrícula
const CH := MapaDatos.CH
const WALL := 40.0
const DOOR_H := 300.0
const HOLE_W := 300.0
const LADDER_STEP := 150.0                # repisas para subir por un hueco del techo (salto ~225 px)
const LEDGE := Vector2(620.0, 170.0)      # repisa alta del fondo con la puerta sellada (ancho, alto; salto ~240 px)
const INK := Color(0.12, 0.11, 0.12)
const TRACK := 5                          # canción: Camino
## Dónde aparece el lobo al llegar desde el Nivel 1 (sala -> fracción del ancho).
const ENTRADAS := {"ca_sello": 0.06, "ca_enemigos": 0.94, "ca_copista": 0.25}
## Al pasar de una sala de aquí a una del Nivel 1: a qué punto del Nivel 1 se llega.
## Del lago de tinta (cueva del Nivel 1) se llega a la Zona de enemigos por su puerta derecha, y por ahí se vuelve.
const SALIDAS := {
	"ca_sello>ca_arco": "z_camino:fin", "ca_enemigos>ca_paleta": "z_camino:ca_paleta",
	"ca_a_sueno>ca_paleta": "z_camino:cueva", "ca_enemigos>ca_cascada": "z_camino:cueva",
}
const CAE: Array[String] = []             # salas a las que se llega cayendo por el hueco del techo
## Puertas laterales cerradas por ahora (llevarán a otra zona más adelante).
const PUERTAS_CERRADAS := {"ca_enemigos": ["left"]}
## Fondo dibujado de una sala: [archivo, región, en espejo]. La Zona de enemigos usa la entrada de cueva
## (pieza 5 de 06_cueva_modulos de los fondos del Nivel 1), recortada al formato de la sala.
const FONDOS := {
	# (la Zona de enemigos usará las tres capas de la cueva: pedido en Game_Assets/PEDIDO_Nivel1_Cueva_v003.md)
}
## Zona del juego (main.gd) a la que lleva un portal hacia otra zona.
const ZONA_JUEGO := {"pintura": "camino", "sueno": "z_sueno", "miedo": "z_miedo", "cambio": "z_cambio", "final": "z_final"}

var en_juego := false                     # lo pone main.gd antes de agregarlo
var entrada := ""                         # sala por la que se llega (ENTRADAS)
var cur_exit := ""
var exit_hint := ""
var near_exit := false
var _leaving := false
var _last_room := ""                      # última sala armada en la que estuvo (no se borra al teletransportar)

var walker: Player
var free_mode := true                     # las barreras de salas cerradas no frenan (para recorrer el diseño)
var visited := {}                         # id -> true

var _rooms := {}                          # id -> {"d": datos, "rect": Rect2, "solid": [], "plat": [], "gates": []}
var _gates: Array[Dictionary] = []        # {"shape": CollisionShape2D, "rect": Rect2, "req": String}
var _portals: Array[Dictionary] = []      # {"rect": Rect2, "room": id, "to": id, "label": String, "req": String}
var _cur := ""
var _bench := MapaDatos.INICIO
var _cam: Camera2D
var _cam_ahead := 0.0
var _title: Label
var _hint: Label
var _map: MapaUI
var _near_portal := {}
var _fondos := {}                         # id -> Texture2D (se guarda: si no, se libera y sale en blanco)


func _ready() -> void:
	Controls.ensure()
	for d in MapaDatos.SALAS:
		if en_juego and d.zona != "camino":
			continue
		var fuera: bool = en_juego and d.id in MapaDatos.NIVEL1
		_rooms[d.id] = {"d": d, "rect": MapaDatos.rect(d.id), "solid": [], "plat": [], "gates": [], "doors": [], "fuera": fuera}
	var links := _links()
	for id in _rooms:
		if not _rooms[id].fuera:
			_build_room(id, links.get(id, {}))
	_build_portals()

	walker = Player.new()
	walker.max_speed = 360.0
	var all := not en_juego or Inventario.pincel
	walker.can_attack = all
	walker.can_dash = all
	walker.can_wall = all
	add_child(walker)
	walker.lobo.solo_correr = true            # en el resto de Camino ya solo corre
	walker.lobo.set_brush("ink" if not en_juego or Inventario.tinta > 0.0 else ("dry" if Inventario.pincel else ""))
	if en_juego:
		var e := entrada if _rooms.has(entrada) and not _rooms[entrada].fuera else "ca_sello"
		walker.position = _floor_point(e, ENTRADAS.get(e, 0.3)) + Vector2(0, -4)
		if e in CAE:                          # por el centro del hueco del techo, entre las repisas
			walker.position = Vector2((_rooms[e].rect as Rect2).get_center().x, (_rooms[e].rect as Rect2).position.y + 90.0)
		elif ENTRADAS.get(e, 0.3) > 0.5:
			walker.lobo.face(-1)
	else:
		walker.position = _floor_point(MapaDatos.INICIO, 0.3) + Vector2(0, -4)

	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 6.0
	_cam.position = Vector2(0, -80)          # (no offset: el offset no respeta los límites de la sala)
	walker.add_child(_cam)
	_cam.make_current()   # la cámara de la zona anterior aún existe; con interpolación de física no cede sola
	_build_ui()
	walker.reset_physics_interpolation()
	_cam.reset_smoothing()
	if "--ver-mapa" in OS.get_cmdline_user_args() and not en_juego:      # para capturas de revisión
		for id in _rooms:
			if _rooms[id].d.zona in ["camino", "pintura"]:
				visited[id] = true
		_open_map(true)


# --- construcción ------------------------------------------------------------------------------------

## Para cada sala, de qué lados tiene conexión: "left"/"right"/"up"/"down" -> id vecino.
func _links() -> Dictionary:
	var out := {}
	for pair in MapaDatos.CONEXIONES:
		if not _rooms.has(pair[0]) or not _rooms.has(pair[1]):
			continue
		var a: Dictionary = _rooms[pair[0]]
		var b: Dictionary = _rooms[pair[1]]
		if a.d.get("sellada", "") == pair[1] or b.d.get("sellada", "") == pair[0]:
			continue                          # se cruza por la puerta sellada (portal), no por un hueco
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
		if links.has(side) and not side in PUERTAS_CERRADAS.get(id, []):
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
	var sealed := d.has("sellada")
	if sealed:
		_solid(room, Rect2(r.end.x - WALL - LEDGE.x, floor_y - LEDGE.y, LEDGE.x, LEDGE.y))
	for i in 2:
		if sealed and i == 1:
			continue                          # ahí está la repisa alta
		var px := r.position.x + (r.size.x * (0.12 if i == 0 else 0.68)) + rng.randf_range(0, 120)
		var py := floor_y - rng.randf_range(160, 210) - i * rng.randf_range(0, 140)
		_platform(room, Rect2(px, py, rng.randf_range(200, 300), 14))
	# sala cerrada: barrera en cada entrada, con lo que la abre
	if d.tipo == "cerrada" and not sealed:
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
	if sealed:
		extra.append("Puerta sellada al fondo — se abre con: " + String(d.get("req", "")))
	elif d.tipo == "cerrada":
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
			if not _rooms.has(here) or _rooms[here].fuera:
				continue
			var n: int = count.get(here, 0)
			count[here] = n + 1
			var r: Rect2 = _rooms[here].rect
			var x := r.position.x + (0.15 + 0.17 * n) * r.size.x if here == "pintura" else r.end.x - 360.0
			var rect := Rect2(x, r.end.y - WALL - 260.0, 150, 260)
			var td := MapaDatos.sala(there)
			var label := String(p[2]) if here == "pintura" else "→ " + String(td.nombre) + " (" + String(MapaDatos.ZONAS[td.zona].nombre) + ")"
			var exit := ""                    # portal hacia algo que aquí no está armado: se sale a esa zona
			if not _rooms.has(there) or _rooms[there].fuera:
				exit = ZONA_JUEGO.get(td.zona, "camino")
			_portals.append({"rect": rect, "room": here, "to": there, "label": label, "req": p[3], "exit": exit})
			var l := _label("%s\n%s" % [label, p[3]], 20, Color(INK, 0.85))
			l.position = rect.position + Vector2(-40, -70)
			l.size.x = 260
	# puerta sellada: al fondo, sobre la repisa alta; del otro lado, una puerta igual
	for id in _rooms:
		var d: Dictionary = _rooms[id].d
		var there := String(d.get("sellada", ""))
		if there == "" or _rooms[id].fuera:
			continue
		var r: Rect2 = _rooms[id].rect
		var floor_y := r.end.y - WALL
		var a := Rect2(r.end.x - WALL - 330.0, floor_y - LEDGE.y - 260.0, 150, 260)
		_portals.append({"rect": a, "room": id, "to": there, "label": "Puerta sellada → " + String(MapaDatos.sala(there).nombre),
			"req": d.get("req", ""), "exit": "", "clave": d.get("clave", "")})
		if _rooms.has(there) and not _rooms[there].fuera:
			var rb: Rect2 = _rooms[there].rect
			var b := Rect2(rb.end.x - 600.0, rb.end.y - WALL - 260.0, 150, 260)
			_portals.append({"rect": b, "room": there, "to": id, "label": "Puerta sellada → " + String(d.nombre),
				"req": d.get("req", ""), "exit": "", "clave": d.get("clave", "")})


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
	if en_juego:
		return                                # en el juego, el mapa (M) y los avisos los pone main.gd
	_map = MapaUI.new()
	_map.viajar = true
	_map.visible = false
	_map.room_clicked.connect(func(id: String) -> void:
		_go_to(id, 0.5)
		_map.visible = false)
	ui.add_child(_map)


# --- juego -------------------------------------------------------------------------------------------

func _physics_process(_delta: float) -> void:
	# la cámara se adelanta hacia donde corre el lobo (en la posición, que sí respeta los límites de la sala);
	# el temblor de los golpes va en el offset, que es de pocos píxeles
	var ahead := clampf(walker.velocity.x * 0.4, -150.0, 150.0)
	_cam_ahead = move_toward(_cam_ahead, ahead, 200.0 * _delta)
	_cam.position.x = _cam_ahead
	_cam.offset = Efectos.temblor_ahora()
	var id := room_at(walker.position + Vector2(0, -40))
	if id != "" and id != _cur:
		_cur = id
		_last_room = id
		visited[id] = true
		var r: Rect2 = _rooms[id].rect
		_cam.limit_left = int(r.position.x)
		_cam.limit_right = int(r.end.x)
		_cam.limit_top = int(r.position.y)
		_cam.limit_bottom = int(r.end.y)
		if _rooms[id].d.get("banca", false):
			_bench = id
	if en_juego and not _leaving:
		# entró en una sala que es del Nivel 1: se pasa al Nivel 1 por el lugar que toca
		for fid in _rooms:
			if _rooms[fid].fuera and (_rooms[fid].rect as Rect2).has_point(walker.position + Vector2(0, -40)):
				_leave(String(SALIDAS.get(_last_room + ">" + fid, "z_camino")))
				break
	_near_portal = {}
	for p in _portals:
		if (p.rect as Rect2).grow(30).has_point(walker.position + Vector2(0, -30)):
			_near_portal = p
	var at_bench: bool = en_juego and _cur != "" and _rooms[_cur].d.get("banca", false) \
		and absf(walker.position.x - ((_rooms[_cur].rect as Rect2).position.x + 330.0)) < 110.0
	if Input.is_action_just_pressed("interact") and not _leaving:
		if at_bench:
			Inventario.guardar()
			_leave("camino")
		elif not _near_portal.is_empty() and not _abierta(_near_portal):
			print("[mundo] puerta sellada: %s" % _near_portal.req)
		elif not _near_portal.is_empty():
			var p := _near_portal
			if p.exit != "":
				_leave(String(p.exit))
			else:
				var dest: Dictionary = {}
				for q in _portals:
					if q.room == p.to and q.to == p.room:
						dest = q
				_teleport((dest.rect as Rect2).get_center() + Vector2(0, 130) if not dest.is_empty() else _floor_point(p.to, 0.5))
	if en_juego:
		var h := ""
		if at_bench:
			h = "E: descansar y volver a la pintura"
		elif not _near_portal.is_empty() and not _abierta(_near_portal):
			h = "Puerta sellada   ·   se abre con: %s" % _near_portal.req
		elif not _near_portal.is_empty():
			h = "E: %s   ·   se abre con: %s" % [_near_portal.label, _near_portal.req]
		if h != exit_hint:
			exit_hint = h
			near_exit = h != ""
			near_exit_changed.emit(near_exit)
	_update_ui()


## Las puertas selladas se abren con su marca de Inventario (corrido solo, F6: también en modo libre).
func _abierta(p: Dictionary) -> bool:
	var clave := String(p.get("clave", ""))
	return clave == "" or Inventario.hecho(clave) or (not en_juego and free_mode)


## Lleva al lobo a una sala de aquí (Ñ / L en main.gd).
func ir_a_sala(id: String) -> void:
	_go_to(id, ENTRADAS.get(id, 0.3))


func _leave(to: String) -> void:
	if not en_juego or exit_requested.get_connections().is_empty():
		return
	_leaving = true
	cur_exit = to
	print("[mundo] sale de «%s» hacia «%s»" % [_last_room, to])
	exit_requested.emit(to)


func track() -> int:
	return TRACK


## Sala en la que está el lobo (para el mapa de main.gd).
func map_room() -> String:
	return _cur


## Posición del lobo en la cuadrícula del mapa.
func map_pos() -> Vector2:
	return walker.position


func _open_map(show: bool) -> void:
	_map.visitadas = visited
	_map.pos = walker.position
	_map.visible = show
	_map.queue_redraw()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	if en_juego and k.keycode != KEY_G:
		return
	match k.keycode:
		KEY_M, KEY_TAB:
			_open_map(not _map.visible)
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
	walker.reset_physics_interpolation()   # sin esto se ve un barrido de un cuadro
	_cur = ""
	_cam.reset_smoothing()


func room_at(p: Vector2) -> String:
	for id in _rooms:
		if not _rooms[id].fuera and (_rooms[id].rect as Rect2).has_point(p):
			return id
	return ""


func rooms() -> Dictionary:
	return _rooms


func _update_ui() -> void:
	if _cur == "":
		return
	var d: Dictionary = _rooms[_cur].d
	if en_juego:
		_title.text = "%s · %s" % [MapaDatos.ZONAS[d.zona].nombre, d.nombre]
		return
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
	if FONDOS.has(id):
		var f: Array = FONDOS[id]
		if not _fondos.has(id):
			_fondos[id] = load(f[0])
		if f[2]:                                 # en espejo sobre el centro de la sala
			ci.draw_set_transform(Vector2(r.position.x + r.end.x, 0.0), 0.0, Vector2(-1, 1))
		ci.draw_texture_rect_region(_fondos[id], r, f[1])
		ci.draw_set_transform(Vector2.ZERO)
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
			if p.has("clave") and not _abierta(p):
				ci.draw_rect(pr, Color(0.22, 0.16, 0.13))          # puerta cerrada con el sello de la melodía
				ci.draw_rect(pr, INK, false, 4.0)
				var c := pr.get_center()
				ci.draw_circle(c, 40, Color(0.72, 0.16, 0.2))
				ci.draw_arc(c, 40, 0, TAU, 32, Color(0.35, 0.05, 0.08), 3.0)
				ci.draw_string(ThemeDB.fallback_font, c + Vector2(-14, 16), "♪", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color(0.98, 0.92, 0.8))
			else:
				ci.draw_rect(pr, Color(0.25, 0.2, 0.35, 0.35))
				ci.draw_rect(pr, INK, false, 4.0)
	if id == "pintura":
		var frame := Rect2(r.position.x + r.size.x * 0.5 - 360, r.position.y + 150, 720, 420)
		ci.draw_rect(frame, Color(0.55, 0.42, 0.28))
		ci.draw_rect(frame.grow(-24), Color(0.92, 0.88, 0.80))
		ci.draw_string(ThemeDB.fallback_font, frame.position + Vector2(170, 230), "La Pintura (portada del álbum)", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, INK)
