extends Node
## Director del juego: carga zonas, entrada, grano de papel, títulos y transiciones.

const NAMES := {"camino": "El camino", "z_camino": "Camino", "z_sueno": "Un sueño y muchos momentos", "z_miedo": "Miedo", "z_cambio": "Cambio", "z_final": "Al final"}
const ZONES := {
	"camino": "res://zones/zone_camino.gd",
	"z_camino": "res://zones/zone_camino_lateral.gd",
}

var zone: Node
var title: Label
var hint: Label
var fade: ColorRect
var music: AudioStreamPlayer
var _busy := false
var _first := true
const LEGEND := "No es para mí, es para ti…"


func _ready() -> void:
	_setup_input()
	_build_ui()
	music = AudioStreamPlayer.new()
	add_child(music)
	_load_zone("camino")
	_fade_to(0.0, 1.6)
	if "--auto-prueba" in OS.get_cmdline_user_args():
		add_child((load("res://herramientas/auto_prueba.gd") as GDScript).new())


func _load_zone(id: String) -> void:
	if zone:
		zone.queue_free()
	zone = (load(ZONES[id]) as GDScript).new()
	add_child(zone)
	move_child(zone, 0)
	zone.exit_requested.connect(_on_exit_requested)
	zone.near_exit_changed.connect(func(n: bool) -> void:
		if n:
			hint.text = "Entrar a «%s»   ·   E" % NAMES.get(zone.cur_exit, "")
		hint.modulate.a = 1.0 if n else 0.0)
	if _first:
		_first = false
		_show_title(LEGEND, 4.2)
	_play_track(zone.track())


func _on_exit_requested(next_zone: String) -> void:
	if _busy:
		return
	_busy = true
	hint.modulate.a = 0.0
	if zone and "walker" in zone:
		zone.walker.enabled = false
	await _fade_to(1.0, 0.9)
	if ZONES.has(next_zone):
		_load_zone(next_zone)
		await _fade_to(0.0, 0.9)
	else:
		# la siguiente zona aún no existe: mensaje y volver al camino
		_show_title(String(NAMES.get(next_zone, "…")) + "  (continuará)")
		await get_tree().create_timer(2.6).timeout
		_load_zone("camino")
		await _fade_to(0.0, 0.9)
	_busy = false


func _fade_to(a: float, t: float) -> void:
	var tw := create_tween()
	tw.tween_property(fade, "color:a", a, t)
	await tw.finished


func _show_title(text: String, hold := 2.2) -> void:
	title.text = text
	title.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_interval(0.8)
	tw.tween_property(title, "modulate:a", 1.0, 1.2)
	tw.tween_interval(hold)
	tw.tween_property(title, "modulate:a", 0.0, 1.6)


func _play_track(n: int) -> void:
	for ext in ["ogg", "mp3", "wav"]:
		var path := "res://audio/track_%02d.%s" % [n, ext]
		if ResourceLoader.exists(path):
			music.stream = load(path)
			music.play()
			return
	music.stop()


func _build_ui() -> void:
	var grain_layer := CanvasLayer.new()
	grain_layer.layer = 5
	add_child(grain_layer)
	var grain := ColorRect.new()
	grain.set_anchors_preset(Control.PRESET_FULL_RECT)
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/paper.gdshader")
	grain.material = mat
	grain_layer.add_child(grain)

	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	var ui_top := CanvasLayer.new()
	ui_top.layer = 11            # los textos van por encima del fundido
	add_child(ui_top)

	title = Label.new()
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.grow_horizontal = Control.GROW_DIRECTION_BOTH
	title.position = Vector2(-500, -240)
	title.size = Vector2(1000, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	title.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	title.add_theme_constant_override("outline_size", 8)
	title.modulate.a = 0.0
	ui_top.add_child(title)

	hint = Label.new()
	hint.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint.grow_horizontal = Control.GROW_DIRECTION_BOTH
	hint.position = Vector2(-300, 34)
	hint.size = Vector2(600, 40)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.text = "E  ·  entrar"
	hint.add_theme_font_size_override("font_size", 24)
	hint.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	hint.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	hint.add_theme_constant_override("outline_size", 6)
	hint.modulate.a = 0.0
	ui_top.add_child(hint)

	fade = ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.color = Color(0.06, 0.05, 0.05, 1.0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(fade)


func _setup_input() -> void:
	_action("move_left", [KEY_A, KEY_LEFT], JOY_BUTTON_DPAD_LEFT, JOY_AXIS_LEFT_X, -1.0)
	_action("move_right", [KEY_D, KEY_RIGHT], JOY_BUTTON_DPAD_RIGHT, JOY_AXIS_LEFT_X, 1.0)
	_action("move_up", [KEY_W, KEY_UP], JOY_BUTTON_DPAD_UP, JOY_AXIS_LEFT_Y, -1.0)
	_action("move_down", [KEY_S, KEY_DOWN], JOY_BUTTON_DPAD_DOWN, JOY_AXIS_LEFT_Y, 1.0)
	_action("interact", [KEY_E, KEY_ENTER, KEY_SPACE], JOY_BUTTON_A, -1, 0.0)


func _action(action_name: String, keys: Array, joy_button: int, axis: int, axis_val: float) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.3)
	for k in keys:
		var e := InputEventKey.new()
		e.physical_keycode = k
		InputMap.action_add_event(action_name, e)
	var b := InputEventJoypadButton.new()
	b.button_index = joy_button
	InputMap.action_add_event(action_name, b)
	if axis >= 0:
		var m := InputEventJoypadMotion.new()
		m.axis = axis
		m.axis_value = axis_val
		InputMap.action_add_event(action_name, m)
