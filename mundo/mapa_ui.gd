class_name MapaUI
extends Control
## Mapa en pantalla (M), al estilo de un mapa de metroidvania: todas las salas en su lugar, con el color de
## su zona; las visitadas van rellenas, las demás solo en contorno. Marca bancas, jefes, objetos clave,
## salas cerradas, portales (líneas punteadas) y dónde está el lobo. Clic en una sala: ir ahí.

signal room_clicked(id: String)

var mundo: Node2D                         # mundo/mundo.gd

var _scale := 1.0
var _offset := Vector2.ZERO


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP


func _fit() -> void:
	var bounds := Rect2()
	var first := true
	for room in mundo.rooms().values():
		bounds = room.rect if first else bounds.merge(room.rect)
		first = false
	var area := Rect2(60, 90, 1160, 560)
	_scale = minf(area.size.x / bounds.size.x, area.size.y / bounds.size.y)
	_offset = area.position + (area.size - bounds.size * _scale) * 0.5 - bounds.position * _scale


func _to_map(p: Vector2) -> Vector2:
	return p * _scale + _offset


func _draw() -> void:
	if mundo == null:
		return
	_fit()
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.03, 0.03, 0.04, 0.94))
	draw_string(font, Vector2(560, 50), "Mapa", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(0.95, 0.93, 0.88))
	var rooms: Dictionary = mundo.rooms()
	# portales: líneas punteadas entre las salas que unen
	for p in MapaDatos.PORTALES:
		var a := _to_map((rooms[p[0]].rect as Rect2).get_center())
		var b := _to_map((rooms[p[1]].rect as Rect2).get_center())
		draw_dashed_line(a, b, Color(0.8, 0.8, 0.8, 0.35), 1.5, 6.0)
	# conexiones internas
	for c in MapaDatos.CONEXIONES:
		draw_line(_to_map((rooms[c[0]].rect as Rect2).get_center()), _to_map((rooms[c[1]].rect as Rect2).get_center()), Color(0.9, 0.9, 0.85, 0.5), 2.0)
	for id in rooms:
		var room: Dictionary = rooms[id]
		var d: Dictionary = room.d
		var r := Rect2(_to_map(room.rect.position), room.rect.size * _scale).grow(-3)
		var zc: Color = MapaDatos.ZONAS[d.zona].color
		var seen: bool = mundo.visited.has(id)
		draw_rect(r, Color(zc, 0.85 if seen else 0.12))
		var border := zc.lightened(0.3)
		if d.tipo == "jefe":
			border = Color(0.9, 0.25, 0.25)
		elif d.tipo == "clave":
			border = Color(0.45, 0.7, 1.0)
		if d.tipo == "cerrada":
			_dashed_rect(r, Color(border, 0.8))
		else:
			draw_rect(r, border, false, 2.0)
		if d.get("banca", false):
			draw_circle(r.position + Vector2(r.size.x - 9, 9), 4.5, Color(0.98, 0.95, 0.88))
		var name_color := Color(0.05, 0.05, 0.05) if seen else Color(0.85, 0.85, 0.82)
		draw_string(font, r.position + Vector2(4, r.size.y * 0.5 + 4), String(d.nombre), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 6, 10, name_color)
	# zonas
	for z in MapaDatos.ZONAS:
		var zd: Dictionary = MapaDatos.ZONAS[z]
		var o: Vector2i = zd.origen
		draw_string(font, _to_map(Vector2(o.x * mundo.CW, o.y * mundo.CH)) + Vector2(0, -6), String(zd.nombre), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, zd.color.lightened(0.25))
	# el lobo
	var w := _to_map(mundo.walker.position)
	draw_circle(w, 6, Color(0.95, 0.2, 0.2))
	draw_circle(w, 3, Color(1, 1, 1))
	draw_string(font, Vector2(60, 690), "● banca   azul: objeto clave   rojo: jefe   punteado: cerrada al inicio   línea punteada: portal o atajo   ·   clic en una sala para ir   ·   M para cerrar", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0.85, 0.85, 0.82))


func _dashed_rect(r: Rect2, c: Color) -> void:
	var pts := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]
	for i in 4:
		draw_dashed_line(pts[i], pts[i + 1], c, 2.0, 5.0)


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	var p := (mb.position - _offset) / _scale
	var id: String = mundo.room_at(p)
	if id != "":
		room_clicked.emit(id)
