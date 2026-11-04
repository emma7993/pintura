class_name MapaUI
extends Control
## Mapa en pantalla (M), al estilo de un mapa de metroidvania: todas las salas en su lugar, con el color de
## su zona; las visitadas van rellenas, las demás solo en contorno. Marca bancas, jefes, objetos clave,
## salas cerradas, portales (líneas punteadas) y dónde está el lobo. Lo usan main.gd (en el juego) y
## mundo/mundo.gd (corrido solo, F6), con todo armado desde mundo/mapa_datos.gd.

signal room_clicked(id: String)

var zonas: Array = []                     # zonas que se muestran; vacío = todas
var visitadas: Dictionary = {}            # id -> true
var pos := Vector2.INF                    # el lobo, en coordenadas de la cuadrícula; INF = no se marca
var viajar := false                       # clic en una sala para ir (solo en pruebas)

var _scale := 1.0
var _offset := Vector2.ZERO
var _rects := {}                          # id -> Rect2


func _ready() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size
	mouse_filter = Control.MOUSE_FILTER_STOP


func _shown(id: String) -> bool:
	return zonas.is_empty() or MapaDatos.sala(id).zona in zonas


func _fit() -> void:
	_rects.clear()
	var bounds := Rect2()
	var first := true
	for d in MapaDatos.SALAS:
		if not _shown(d.id):
			continue
		var r := MapaDatos.rect(d.id)
		_rects[d.id] = r
		bounds = r if first else bounds.merge(r)
		first = false
	var area := Rect2(60, 90, 1160, 560)
	_scale = minf(area.size.x / bounds.size.x, area.size.y / bounds.size.y)
	_offset = area.position + (area.size - bounds.size * _scale) * 0.5 - bounds.position * _scale


func _to_map(p: Vector2) -> Vector2:
	return p * _scale + _offset


func _draw() -> void:
	_fit()
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.03, 0.03, 0.04, 0.94))
	var heading := "Mapa"
	if zonas.size() == 1:
		heading = "Mapa · " + String(MapaDatos.ZONAS[zonas[0]].nombre)
	draw_string(font, Vector2(0, 50), heading, HORIZONTAL_ALIGNMENT_CENTER, size.x, 34, Color(0.95, 0.93, 0.88))
	# portales: líneas punteadas entre las salas que unen
	for p in MapaDatos.PORTALES:
		if _rects.has(p[0]) and _rects.has(p[1]):
			draw_dashed_line(_to_map((_rects[p[0]] as Rect2).get_center()), _to_map((_rects[p[1]] as Rect2).get_center()), Color(0.8, 0.8, 0.8, 0.35), 1.5, 6.0)
	# conexiones internas
	for c in MapaDatos.CONEXIONES:
		if _rects.has(c[0]) and _rects.has(c[1]):
			draw_line(_to_map((_rects[c[0]] as Rect2).get_center()), _to_map((_rects[c[1]] as Rect2).get_center()), Color(0.9, 0.9, 0.85, 0.5), 2.0)
	for id in _rects:
		var d := MapaDatos.sala(id)
		var rr: Rect2 = _rects[id]
		var r := Rect2(_to_map(rr.position), rr.size * _scale).grow(-3)
		var zc: Color = MapaDatos.ZONAS[d.zona].color
		var seen := visitadas.has(id)
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
		var fs := 10 if zonas.size() != 1 else 16
		draw_string(font, r.position + Vector2(6, r.size.y * 0.5 + 5), String(d.nombre), HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 8, fs, name_color)
	# nombres de las zonas (solo con varias)
	if zonas.size() != 1:
		for z in MapaDatos.ZONAS:
			if not zonas.is_empty() and not z in zonas:
				continue
			var zd: Dictionary = MapaDatos.ZONAS[z]
			var o: Vector2i = zd.origen
			draw_string(font, _to_map(Vector2(o.x * MapaDatos.CW, o.y * MapaDatos.CH)) + Vector2(0, -6), String(zd.nombre), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, zd.color.lightened(0.25))
	# el lobo
	if pos != Vector2.INF:
		var w := _to_map(pos)
		draw_circle(w, 7, Color(0.95, 0.2, 0.2))
		draw_circle(w, 3.5, Color(1, 1, 1))
	var legend := "● banca   azul: objeto clave   rojo: jefe   punteado: cerrada al inicio   línea punteada: portal o atajo   ·   M para cerrar"
	if viajar:
		legend += "   ·   clic en una sala para ir"
	draw_string(font, Vector2(0, 690), legend, HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Color(0.85, 0.85, 0.82))


func _dashed_rect(r: Rect2, c: Color) -> void:
	var pts := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y), r.position]
	for i in 4:
		draw_dashed_line(pts[i], pts[i + 1], c, 2.0, 5.0)


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if not viajar or mb == null or not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	var p := (mb.position - _offset) / _scale
	for id in _rects:
		if (_rects[id] as Rect2).has_point(p):
			room_clicked.emit(id)
			return
