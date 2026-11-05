extends Node
## Director del juego: carga zonas, entrada, grano de papel, títulos y transiciones.

const NAMES := {"camino": "El camino", "mundo": "Camino", "z_camino": "Camino", "z_sueno": "Un sueño y muchos momentos", "z_miedo": "Miedo", "z_cambio": "Cambio", "z_final": "Al final"}
const ZONES := {
	"camino": "res://zones/zone_camino.gd",
	"z_camino": "res://zones/nivel_01_camino.gd",
	"mundo": "res://mundo/mundo.gd",       # el resto de Camino, en bloques, hasta que tenga arte
}
## Zonas del mapa (M) que se muestran por ahora.
const MAP_ZONES := ["camino"]

var zone: Node
var title: Label
var hint: Label
var fade: ColorRect
var music: AudioStreamPlayer
var _busy := false
var _first := true
var _choosing := false            # esperando "continuar" o "nueva partida" al arrancar
var map: MapaUI
const LEGEND := "No es para mí, es para ti…"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # el mapa pausa el juego, pero main sigue atendiendo teclas
	Controls.ensure()
	_build_ui()
	music = AudioStreamPlayer.new()
	add_child(music)
	var auto := "--auto-prueba" in OS.get_cmdline_user_args()
	if auto:
		Inventario.reiniciar()
	else:
		Inventario.cargar()
	_load_zone("camino")
	_fade_to(0.0, 1.6)
	if auto:
		add_child((load("res://herramientas/auto_prueba.gd") as GDScript).new())
	elif _has_save():
		# hay una partida guardada: se elige seguir o empezar de cero antes de caminar
		_choosing = true
		zone.walker.enabled = false
		hint.text = "Partida guardada.   Enter: continuar   ·   N: nueva partida"
		hint.modulate.a = 1.0


func _has_save() -> bool:
	return Inventario.pincel or Inventario.tintero or not Inventario.progreso.is_empty()


## N (o 0 en cualquier momento): borra la partida y vuelve a empezar desde el principio de la pintura.
func _new_game() -> void:
	Inventario.reiniciar()
	(load("res://zones/zone_camino.gd") as GDScript).set("return_pos", Vector2.ZERO)
	get_tree().reload_current_scene()


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	if k.keycode in [KEY_M, KEY_TAB] and not _choosing and not _busy:
		_toggle_map()
	elif map.visible:
		if k.keycode == KEY_ESCAPE:
			_toggle_map()
	elif OS.is_debug_build() and not _choosing and not _busy and (_es_ene(k) or k.keycode == KEY_L):
		_saltar_sala(1 if _es_ene(k) else -1)
	elif k.keycode == KEY_0 or (_choosing and k.keycode == KEY_N):
		_new_game()
	elif _choosing and k.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_E, KEY_SPACE]:
		_choosing = false
		hint.modulate.a = 0.0
		zone.walker.enabled = true


## Ñ (o la tecla de la Ñ en un teclado inglés: ;) para adelantar sala.
func _es_ene(k: InputEventKey) -> bool:
	return k.keycode == 209 or k.unicode in [241, 209] or k.physical_keycode == KEY_SEMICOLON


## Solo para probar (versión de desarrollo): Ñ adelanta y L regresa una sala de Camino, en el orden del
## mapa. Las del Nivel 1 se recorren dentro del nivel; las demás, en el resto de Camino (mundo).
func _saltar_sala(paso: int) -> void:
	var orden := MapaDatos.orden("camino")
	var cur := String(zone.map_room()) if zone and zone.has_method("map_room") else ""
	var i := orden.find(cur)
	var j := (0 if paso > 0 else orden.size() - 1) if i < 0 else wrapi(i + paso, 0, orden.size())
	var id: String = orden[j]
	var destino := "z_camino" if id in MapaDatos.NIVEL1 else "mundo"
	print("[main] prueba: sala %s -> %s" % [cur, id])
	_show_title("Sala %d de %d · %s" % [j + 1, orden.size(), MapaDatos.sala(id).nombre], 0.6)
	if zone and zone.get_script().resource_path == ZONES[destino] and zone.has_method("ir_a_sala"):
		zone.ir_a_sala(id)
	else:
		_on_exit_requested(destino + ":" + id)


## Mapa (M): pausa el juego y muestra lo recorrido; el lobo se marca si la zona sabe dónde está.
func _toggle_map() -> void:
	map.visible = not map.visible
	get_tree().paused = map.visible
	if map.visible:
		map.visitadas = Inventario.visitadas
		map.pos = zone.map_pos() if zone and zone.has_method("map_pos") else Vector2.INF
		map.queue_redraw()


func _process(_delta: float) -> void:
	if zone and zone.has_method("map_room") and not get_tree().paused:
		Inventario.visitar(zone.map_room())


## id puede traer el punto de llegada: "z_camino:fin", "mundo:ca_sello".
func _load_zone(id: String) -> void:
	var parts := id.split(":")
	if zone:
		zone.queue_free()
	zone = (load(ZONES[parts[0]]) as GDScript).new()
	zone.process_mode = Node.PROCESS_MODE_PAUSABLE
	if "en_juego" in zone:
		zone.en_juego = true
	if "entrada" in zone and parts.size() > 1:
		zone.entrada = parts[1]
	add_child(zone)
	move_child(zone, 0)
	zone.exit_requested.connect(_on_exit_requested)
	zone.near_exit_changed.connect(func(n: bool) -> void:
		if n:
			var custom: String = zone.exit_hint if "exit_hint" in zone else ""
			hint.text = custom if custom != "" else "Entrar a «%s»   ·   E" % NAMES.get(String(zone.cur_exit).split(":")[0], "")
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
	if ZONES.has(next_zone.split(":")[0]):
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

	map = MapaUI.new()
	map.zonas = MAP_ZONES
	map.visible = false
	ui_top.add_child(map)

	fade = ColorRect.new()
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.color = Color(0.06, 0.05, 0.05, 1.0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(fade)
