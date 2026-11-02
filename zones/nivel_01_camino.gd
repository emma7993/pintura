extends Node2D
## Nivel 1 — Camino (prueba jugable) con los bocetos de grafito de Codex (art/worlds/camino/nivel_01_bocetos_v001).
## Guion: el lobo aparece con miedo y solo camina; unas sombras lo persiguen y lo obligan a apurarse y luego
## a correr. A lo lejos ve una luz al otro lado de un hueco (ahí descubre el salto). La luz guarda el pincel,
## primer upgrade: con él pinta una barrera de óleo detrás de sí y las sombras se quedan atrás.
## Se corre solo con F6 (zones/nivel_01_camino.tscn) o entrando desde el camino de la pintura (main.gd).

signal exit_requested(next_zone: String)
signal near_exit_changed(is_near: bool)

const ART := "res://art/worlds/camino/nivel_01_bocetos_v001"
const GROUND_Y := 600.0
const WIDTH := 6000.0
const SPAWN := Vector2(260, 600)
const TRACK := 5                          # canción: Camino
const GAP := Vector2(3950, 4120)          # hueco que hay que saltar (x de inicio, x de fin); primer salto: generoso
const BRUSH_X := 4560.0                   # la luz con el pincel
const EXIT_X := 5800.0
## Tramos: [desde x, velocidad máxima del lobo, velocidad de las sombras, distancia máxima de las sombras]
const STAGES := [
	[0.0, 115.0, 85.0, 760.0],            # miedo: solo camina
	[1700.0, 215.0, 190.0, 560.0],        # se apura
	[3000.0, 360.0, 320.0, 430.0],        # corre
]
const SHADOW_START_X := 650.0             # las sombras aparecen cuando el lobo pasa de aquí
const CALM_SPEED := 180.0                 # paso del lobo cuando ya no lo persiguen
const INK := Color(0.07, 0.06, 0.07)
const OIL := [Color(0.72, 0.10, 0.12), Color(0.86, 0.58, 0.18), Color(0.16, 0.22, 0.50), Color(0.93, 0.86, 0.70), Color(0.58, 0.07, 0.10)]

var walker: Player
var cur_exit := ""
var near_exit := false
var shadow_x := -INF                      # frente de las sombras (px de mundo); -INF = aún no aparecen
var has_brush := false
var barrier_x := -INF                     # -INF = sin barrera
var shadows_gone := false

var _t := 0.0
var _stage := 0
var _shadow_speed := 0.0
var _shadow_alpha := 1.0
var _barrier_k := 0.0                     # 0..1: crecimiento de la barrera
var _checkpoint := SPAWN
var _busy := false
var _moved := false
var _metrics := {}
var _env: Node2D
var _shadow_layer: Node2D
var _cam: Camera2D
var _hint: Label
var _fade: ColorRect
var _vignette: TextureRect


func _ready() -> void:
	Controls.ensure()
	for item in JSON.parse_string(FileAccess.get_file_as_string(ART + "/inventory.json")):
		_metrics[item.id] = item
	_env = (load(ART + "/Godot/Environment.tscn") as PackedScene).instantiate()
	_env.set("ground_y", GROUND_Y)
	_env.set("world_width", WIDTH)
	_env.set("show_modules", false)       # solo fondos: el terreno se arma aquí, con el hueco
	add_child(_env)
	_build_ground()
	_build_decor()

	walker = Player.new()
	walker.max_speed = STAGES[0][1]
	walker.can_jump = false
	walker.position = SPAWN
	add_child(walker)

	_shadow_layer = Node2D.new()
	_shadow_layer.z_index = 20            # las sombras cubren al lobo cuando lo alcanzan
	_shadow_layer.draw.connect(_draw_shadows)
	add_child(_shadow_layer)

	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 5.0
	_cam.limit_left = 0
	_cam.limit_right = int(WIDTH)
	_cam.limit_bottom = int(GROUND_Y + 160.0)
	_cam.offset = Vector2(0, -70)
	walker.add_child(_cam)
	_cam.reset_smoothing()
	_build_ui()

	if "--auto-nivel1" in OS.get_cmdline_user_args():
		add_child((load("res://herramientas/auto_nivel1.gd") as GDScript).new())


# --- terreno y decoración -------------------------------------------------------------------------

func _build_ground() -> void:
	_ground_strip(-160.0, GAP.x)
	_ground_strip(GAP.y, WIDTH + 200.0)
	_solid(Rect2(-200, GROUND_Y, GAP.x + 200, 400))
	_solid(Rect2(GAP.y, GROUND_Y, WIDTH - GAP.y + 400, 400))
	_solid(Rect2(-240, GROUND_Y - 1200, 240, 1200))          # bordes del mundo
	_solid(Rect2(WIDTH, GROUND_Y - 1200, 240, 1200))
	# bordes del hueco: piedras para que se lea dónde se acaba el suelo
	_place("stones", Vector2(GAP.x - 20, GROUND_Y + 8), 0.7, -8)
	_place("stones", Vector2(GAP.y + 30, GROUND_Y + 8), 0.7, -8)


## Tira de suelo a lápiz entre x0 y x1 con los módulos ground_a/b/c (sin colisión: va aparte).
func _ground_strip(x0: float, x1: float) -> void:
	var x := x0
	var i := 0
	while x < x1 - 40.0:
		var id: String = ["ground_a", "ground_b", "ground_c"][i % 3]
		var b: Array = _metrics[id].bounds
		var f := 2.0
		var s := _sprite(id, -10)
		s.scale = Vector2.ONE * f
		s.position = Vector2(x - float(b[0]) * f, GROUND_Y - float(b[1]) * f)
		# el último módulo se recorta para no invadir el hueco
		var room := x1 - x
		if room < float(b[2]) * f:
			s.region_enabled = true
			s.region_rect = Rect2(0, 0, float(b[0]) + room / f, 256)
		x += maxf(60.0, float(b[2]) * f - 30.0)
		i += 1


func _solid(r: Rect2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.position = r.get_center()
	body.add_child(cs)
	add_child(body)


func _build_decor() -> void:
	for e in [["tree_left", 760.0, 2.4], ["tree_right", 1900.0, 2.8], ["tree_left", 2900.0, 2.6], ["tree_right", 5100.0, 2.6]]:
		_place(e[0], Vector2(e[1], GROUND_Y + 4), e[2], -18).modulate.a = 0.38
	for j in 17:
		var x := 420.0 + j * 330.0
		if x > GAP.x - 120 and x < GAP.y + 120:
			continue
		_place("reeds" if j % 2 == 0 else "stones", Vector2(x, GROUND_Y + 5), 0.55, -8).modulate.a = 0.6
	_place("pedestal", Vector2(BRUSH_X, GROUND_Y + 5), 0.6, -8)
	_place("gate", Vector2(EXIT_X, GROUND_Y + 4), 1.8, -18).modulate.a = 0.5


func _place(id: String, at: Vector2, f: float, depth: int) -> Sprite2D:
	var s := _sprite(id, depth)
	var b: Array = _metrics[id].bounds
	s.position = at - Vector2(float(b[0]) + float(b[2]) * 0.5, float(b[1]) + float(b[3])) * f
	s.scale = Vector2.ONE * f
	return s


func _sprite(id: String, depth: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(ART + "/Modulos/" + id + ".png")
	s.centered = false
	s.z_index = depth
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(s)
	return s


func _build_ui() -> void:
	var dark := CanvasLayer.new()
	dark.layer = 4                         # oscurece el borde izquierdo cuando las sombras se acercan
	add_child(dark)
	var g := Gradient.new()
	g.set_color(0, Color(INK, 0.85))
	g.set_color(1, Color(INK, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.width = 256
	gt.height = 8
	_vignette = TextureRect.new()
	_vignette.texture = gt
	_vignette.stretch_mode = TextureRect.STRETCH_SCALE
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
	_vignette.offset_right = 520.0
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.modulate.a = 0.0
	dark.add_child(_vignette)

	var ui := CanvasLayer.new()
	ui.layer = 9
	add_child(ui)
	_fade = ColorRect.new()
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.color = Color(INK, 0.0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(_fade)
	_hint = Label.new()
	_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hint.position = Vector2(-450, -90)
	_hint.size = Vector2(900, 40)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	_hint.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_hint.add_theme_constant_override("outline_size", 6)
	_hint.modulate.a = 0.0
	ui.add_child(_hint)


func _show_hint(text: String, hold := 3.5) -> void:
	print("[nivel1] %.1f s: %s" % [_t, text])
	_hint.text = text
	var tw := create_tween()
	tw.tween_property(_hint, "modulate:a", 1.0, 0.4)
	tw.tween_interval(hold)
	tw.tween_property(_hint, "modulate:a", 0.0, 0.8)


# --- guion ------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_t += delta
	var x := walker.position.x
	if absf(walker.velocity.x) > 1.0:
		_moved = true

	# tramo actual: el miedo empuja al lobo a ir cada vez más rápido
	var st: Array = STAGES[0]
	for i in STAGES.size():
		if x >= (STAGES[i][0] as float):
			st = STAGES[i]
			if i > _stage:
				_stage = i
				_checkpoint = Vector2(STAGES[i][0] as float, GROUND_Y)
				print("[nivel1] %.1f s: tramo %d (lobo %d px/s, sombras %d px/s)" % [_t, i, st[1], st[2]])
	var target: float = st[1]
	if shadows_gone:
		target = CALM_SPEED
	elif has_brush:
		target = STAGES[STAGES.size() - 1][1]
	walker.max_speed = move_toward(walker.max_speed, target, 140.0 * delta)

	# a lo lejos se ve la luz y el hueco: aquí descubre el salto
	if not walker.can_jump and x > GAP.x - 420.0:
		walker.can_jump = true
		_show_hint("Espacio: saltar  (mantén para llegar más lejos)")

	if shadow_x == -INF and x > SHADOW_START_X and not shadows_gone:
		shadow_x = x - (STAGES[0][3] as float) - 200.0
		_shadow_speed = STAGES[0][2]
		print("[nivel1] %.1f s: aparecen las sombras" % _t)
	if shadow_x != -INF and not shadows_gone:
		_update_shadows(delta, st)

	if walker.position.y > GROUND_Y + 450.0:
		_caught("cayó al hueco")
	if not has_brush and absf(x - BRUSH_X) < 70.0 and walker.is_on_floor():
		_take_brush()
	if has_brush and barrier_x == -INF and not _busy and Input.is_action_just_pressed("paint"):
		_paint_barrier()

	_update_camera(delta)
	_update_exits()
	queue_redraw()
	_shadow_layer.queue_redraw()


func _update_shadows(delta: float, st: Array) -> void:
	var speed: float = st[2]
	var leash: float = st[3]
	if has_brush:
		speed = 430.0          # tras el destello vuelven más rápido que el lobo: hay que pintar
		leash = 520.0
	_shadow_speed = move_toward(_shadow_speed, speed, 90.0 * delta)
	shadow_x = maxf(shadow_x + _shadow_speed * delta, walker.position.x - leash)
	if barrier_x != -INF:
		# la barrera de óleo las detiene y se deshacen contra ella
		shadow_x = minf(shadow_x, barrier_x - 26.0)
		if shadow_x >= barrier_x - 40.0 and _barrier_k >= 1.0:
			_shadow_alpha = maxf(0.0, _shadow_alpha - delta / 2.5)
			if _shadow_alpha <= 0.0:
				shadows_gone = true
				_vignette.modulate.a = 0.0
				_show_hint("Las sombras se quedaron atrás")
				return
	var near := walker.position.x - shadow_x
	_vignette.modulate.a = clampf(1.0 - (near - 120.0) / 650.0, 0.0, 1.0) * _shadow_alpha
	if near < 30.0 and not _busy:
		_caught("lo alcanzaron las sombras")


func _caught(why: String) -> void:
	if _busy:
		return
	_busy = true
	print("[nivel1] %.1f s: %s; vuelve a x=%d" % [_t, why, _checkpoint.x])
	walker.enabled = false
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.6)
	await tw.finished
	walker.position = _checkpoint
	walker.velocity = Vector2.ZERO
	walker.max_speed = STAGES[_stage][1]
	if shadow_x != -INF:
		shadow_x = _checkpoint.x - (STAGES[_stage][3] as float) - 150.0
		_shadow_speed = 0.0
	_cam.reset_smoothing()
	tw = create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.6)
	await tw.finished
	walker.enabled = true
	_busy = false


func _take_brush() -> void:
	has_brush = true
	_checkpoint = Vector2(BRUSH_X, GROUND_Y)
	# el destello de la luz empuja a las sombras hacia atrás un momento
	if shadow_x != -INF:
		shadow_x = minf(shadow_x, BRUSH_X - 950.0)
		_shadow_speed = 0.0
	var flash := create_tween()
	_fade.color = Color(1.0, 0.96, 0.85, 0.0)
	flash.tween_property(_fade, "color:a", 0.75, 0.12)
	flash.tween_property(_fade, "color:a", 0.0, 0.9)
	flash.tween_callback(func() -> void: _fade.color = Color(INK, 0.0))
	_show_hint("El pincel.  F: pintar una barrera detrás de ti", 5.0)


func _paint_barrier() -> void:
	barrier_x = walker.position.x - 110.0 * walker.lobo.facing
	if barrier_x > walker.position.x:      # mirando a la izquierda: igual la pinta del lado de las sombras
		barrier_x = walker.position.x - 110.0
	print("[nivel1] %.1f s: pinta la barrera en x=%d (sombras a %d px)" % [_t, barrier_x, walker.position.x - shadow_x])
	_barrier_k = 0.0
	var tw := create_tween()
	tw.tween_property(self, "_barrier_k", 1.0, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _update_camera(delta: float) -> void:
	# mira hacia adelante cuando corre, para ver lo que viene
	var ahead := clampf(walker.velocity.x * 0.45, -60.0, 200.0)
	_cam.offset.x = move_toward(_cam.offset.x, ahead, 220.0 * delta)


func _update_exits() -> void:
	var found := ""
	if absf(walker.position.x - 110.0) < 80.0 and shadow_x == -INF:
		found = "camino"
	elif shadows_gone and absf(walker.position.x - EXIT_X) < 90.0:
		found = "z_sueno"
	cur_exit = found
	var now_near := found != "" and _moved
	if now_near != near_exit:
		near_exit = now_near
		near_exit_changed.emit(near_exit)
		if near_exit and exit_requested.get_connections().is_empty():
			_show_hint("Fin de la prueba  ·  E: salir (en el juego completo)")


func _unhandled_input(event: InputEvent) -> void:
	if near_exit and InputMap.has_action("interact") and event.is_action_pressed("interact"):
		exit_requested.emit(cur_exit)


# --- dibujo -----------------------------------------------------------------------------------------

func _draw() -> void:
	# salidas: destello rojo, como en el camino de la pintura
	var pulse := 1.0 + sin(_t * 3.0) * 0.15
	for e in [[110.0, shadow_x == -INF], [EXIT_X, shadows_gone]]:
		if e[1]:
			var c := Vector2(e[0] as float, GROUND_Y - 70.0)
			draw_circle(c, 46.0 * pulse, Color(0.75, 0.1, 0.12, 0.10))
			draw_circle(c, 26.0 * pulse, Color(0.75, 0.1, 0.12, 0.28))
			draw_circle(c, 9.0, Color(0.95, 0.85, 0.8, 0.9))
	if not has_brush:
		_draw_light()


## La luz que se ve a lo lejos, con el pincel flotando sobre el pedestal.
func _draw_light() -> void:
	var c := Vector2(BRUSH_X, GROUND_Y - 150.0 + sin(_t * 1.6) * 6.0)
	var p := 1.0 + sin(_t * 2.2) * 0.08
	draw_colored_polygon(PackedVector2Array([c + Vector2(-26, 0), c + Vector2(26, 0), c + Vector2(90, -620), c + Vector2(-90, -620)]), Color(1.0, 0.93, 0.72, 0.16))
	for k in [[150.0, 0.07], [95.0, 0.12], [55.0, 0.22], [28.0, 0.45]]:
		draw_circle(c, (k[0] as float) * p, Color(1.0, 0.90, 0.62, k[1] as float))
	# pincel: mango, virola y cerdas con óleo rojo en la punta
	var a := c + Vector2(-34, 30)
	var b := c + Vector2(16, -18)
	draw_line(a, b, Color(0.36, 0.22, 0.14), 7.0)
	draw_line(b, b + Vector2(9, -9), Color(0.78, 0.76, 0.72), 9.0)
	draw_colored_polygon(PackedVector2Array([b + Vector2(5, -14), b + Vector2(14, -5), b + Vector2(30, -26), b + Vector2(26, -30)]), Color(0.72, 0.10, 0.12))


## Barrera de óleo: trazos gruesos y ondulados que crecen desde el suelo.
func _draw_barrier(ci: CanvasItem) -> void:
	var h := 300.0 * _barrier_k
	for i in 7:
		var x0 := barrier_x - 48.0 + i * 16.0
		var pts := PackedVector2Array()
		var steps := 14
		for s in steps + 1:
			var y := GROUND_Y + 6.0 - h * float(s) / steps
			pts.append(Vector2(x0 + sin(float(s) * 0.7 + i * 1.9) * 9.0 + sin(_t * 1.5 + i) * 2.0, y))
		var col: Color = OIL[i % OIL.size()]
		ci.draw_polyline(pts, col, 20.0 - absf(i - 3.0) * 2.0, true)
	# brillo de la pintura fresca
	if h > 10.0:
		ci.draw_line(Vector2(barrier_x - 6, GROUND_Y - 20), Vector2(barrier_x + 2, GROUND_Y - h + 24), Color(1, 0.97, 0.9, 0.55), 3.0, true)


## Sombras: una masa de tinta con borde ondulante, brazos que se estiran y ojos pálidos.
func _draw_shadows() -> void:
	# la barrera va en esta misma capa, después de las sombras, para que queden detrás de ella
	if shadow_x == -INF or shadows_gone:
		if barrier_x != -INF:
			_draw_barrier(_shadow_layer)
		return
	var fx := shadow_x
	var top := GROUND_Y - 1100.0
	var bottom := GROUND_Y + 200.0
	for layer in [[70.0, 0.22], [32.0, 0.5], [0.0, 0.93]]:
		var reach: float = layer[0]
		var pts := PackedVector2Array()
		pts.append(Vector2(fx - 3000.0, top))
		var y := top
		while y <= bottom:
			var w := sin(y * 0.018 + _t * 2.6) * 34.0 + sin(y * 0.051 - _t * 4.3) * 15.0
			# más cerca del suelo, el frente se adelanta (se arrastra hacia el lobo)
			var lean := clampf((y - GROUND_Y + 560.0) / 560.0, 0.0, 1.0) * 60.0
			pts.append(Vector2(fx + reach + w + lean - 60.0, y))
			y += 18.0
		pts.append(Vector2(fx - 3000.0, bottom))
		_shadow_layer.draw_colored_polygon(pts, Color(INK, (layer[1] as float) * _shadow_alpha))
	# brazos que se estiran hacia el lobo
	for i in 5:
		var base := Vector2(fx, GROUND_Y - 30.0 - i * 70.0)
		var arm_len := 70.0 + 45.0 * sin(_t * 2.1 + i * 1.3)
		if barrier_x != -INF:
			arm_len = minf(arm_len, barrier_x - 50.0 - fx)   # chocan contra la barrera
		var arm := PackedVector2Array()
		for s in 9:
			var k := float(s) / 8.0
			arm.append(base + Vector2(k * arm_len, sin(k * 4.0 + _t * 3.0 + i) * 14.0 * k))
		_shadow_layer.draw_polyline(arm, Color(INK, 0.85 * _shadow_alpha), 9.0, true)
	# ojos
	for i in 3:
		var blink := 1.0 if fmod(_t + i * 1.7, 4.0) > 0.18 else 0.15
		var e := Vector2(fx - 70.0 - i * 120.0, GROUND_Y - 150.0 - i * 95.0 + sin(_t + i) * 8.0)
		for dx in [-9.0, 9.0]:
			_shadow_layer.draw_set_transform(e + Vector2(dx, 0), 0.0, Vector2(1.0, blink))
			_shadow_layer.draw_circle(Vector2.ZERO, 4.0, Color(0.95, 0.93, 0.88, 0.8 * _shadow_alpha))
	_shadow_layer.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if barrier_x != -INF:
		_draw_barrier(_shadow_layer)


func track() -> int:
	return TRACK


func zone_title() -> String:
	return "Camino"
