extends Node2D
## Nivel 1 — Camino (prueba jugable) con los bocetos de grafito de Codex (art/worlds/camino/nivel_01_bocetos_v001).
## Guion: el lobo aparece con miedo y solo camina; unas sombras lo persiguen y lo obligan a apurarse y luego
## a correr. A lo lejos ve una luz al otro lado de un hueco (ahí descubre el salto). La luz guarda el pincel,
## primer upgrade: con él pinta una barrera de óleo detrás de sí y las sombras se quedan atrás.
## La luz está en una plataforma alta al otro lado del hueco. El pincel trae restos de color para un solo
## trazo (la barrera) y queda seco. La puerta de regreso al lienzo principal es un boceto apagado: más
## adelante, en un altar pequeño junto a una cascada de tinta negra, hay un tintero vacío: se guarda en el
## inventario (core/inventario.gd), se llena en el lago de tinta al pie de la cascada y con esa tinta se
## vuelve a la puerta y se pinta para que se active. La tinta se gasta y hay que volver a llenarlo.
## Se corre solo con F6 (zones/nivel_01_camino.tscn) o entrando desde el camino de la pintura (main.gd).

signal exit_requested(next_zone: String)
signal near_exit_changed(is_near: bool)

const ART := "res://art/worlds/camino/nivel_01_bocetos_v001"
const COLOR_ART := "res://art/worlds/camino/nivel_01_color_v001"   # óleo, máscaras, barrera, cascada, altar
const MASK_ORIGIN := Vector2(-200, -500)  # máscara de pintura: esquina superior izquierda en px de mundo
const MASK_SIZE := Vector2(8000, 1400)
const MASK_DIV := 4.0                     # px de mundo por px de máscara
const GROUND_Y := 600.0
const WIDTH := 7600.0
const SPAWN := Vector2(260, 600)
const TRACK := 5                          # canción: Camino
const GAP := Vector2(3950, 4110)          # hueco que hay que saltar (x de inicio, x de fin)
const HIGH_Y := 490.0                     # suelo de la plataforma alta, después del hueco (salto máx. ~175 px)
const BRUSH_X := 4560.0                   # la luz con el pincel
const EXIT_X := 5700.0                    # puerta de regreso al lienzo principal
const GATE_SCALE := 1.8
const GROUND_LINE := 126.0               # fila de los módulos ground_a/b/c que queda bajo los pies
const ALTAR_X := 6950.0                   # altar pequeño con el tintero
const FALL_X := 7230.0                    # cascada de tinta negra, al lado del altar
const LAKE_R := 160.0                     # medio ancho del lago de tinta al pie de la cascada
## Tramos: [desde x, velocidad máxima del lobo, velocidad de las sombras, distancia máxima de las sombras]
const STAGES := [
	[0.0, 127.0, 122.0, 520.0],           # miedo: solo camina (las sombras casi lo igualan)
	[1700.0, 215.0, 190.0, 560.0],        # se apura
	[3000.0, 360.0, 320.0, 430.0],        # corre
]
const SHADOW_START_X := 380.0             # las sombras aparecen al poco de empezar a caminar
const CALM_SPEED := 198.0                 # paso del lobo cuando ya no lo persiguen
const RUN_SPEED := 380.0                  # con Shift, una vez libre de las sombras
const INK := Color(0.07, 0.06, 0.07)
const STROKE_ANGLE := PI / 3.0            # pincelada de color: 60° sobre la horizontal
const STROKE_LEN := 1000.0                # largo de la pincelada (del suelo hasta arriba de la pantalla)

var walker: Player
var cur_exit := ""
var near_exit := false
var shadow_x := -INF                      # frente de las sombras (px de mundo); -INF = aún no aparecen
var has_brush := false
var brush := ""                           # restos del pincel: "color" (un trazo) o "seco"; la tinta sale del tintero
var barrier_x := -INF                     # -INF = sin barrera
var shadows_gone := false
var gate_open := false                    # la puerta ya se pintó

var _t := 0.0
var _gate_k := 0.0                        # 0..1: avance de la pintura de la puerta
var _gate_sketch: Sprite2D                # boceto gris de la puerta
var _gate_paint: Sprite2D                 # la puerta entintada, se revela de abajo hacia arriba
var _gate_glow: Sprite2D
var _at_gate := false
var _at_altar := false
var _at_lake := false
var _acting := false                      # el lobo está pintando o mojando el pincel: no camina
var _brush_pickup: Sprite2D
var _inkwell: Sprite2D                    # tintero sobre el altar
var _splash: AnimatedSprite2D
var _effects: SpriteFrames
var _mask_img: Image                      # dónde ya pintó el pincel (0..255), en coordenadas de mundo
var _mask_tex: ImageTexture
var _mask_dirty := false
var _strokes: Array[Image] = []
var _oil_mat: ShaderMaterial
var _last_tip := Vector2.ZERO
var _brush_label: Label
var _ink_icon: TextureRect
var _ink_bar: ColorRect                   # barra del tintero: fondo; su hijo es el nivel de tinta
var _ink_fill: ColorRect
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
	_effects = load(COLOR_ART + "/Godot/Color_Effects.tres")
	_build_paint_mask()
	_build_ground()
	_build_decor()
	_build_color_props()

	walker = Player.new()
	walker.max_speed = STAGES[0][1]
	walker.can_jump = false
	walker.position = SPAWN
	add_child(walker)
	walker.lobo.action_frame.connect(_on_action_frame)
	walker.lobo.action_finished.connect(_on_action_finished)

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
	_build_ui()

	var auto := "--auto-nivel1" in OS.get_cmdline_user_args()
	if auto:
		Inventario.reiniciar()               # la prueba automática siempre empieza de cero
	else:
		Inventario.cargar()
	_restore_progress()
	if Inventario.atajo >= 0:
		_apply_shortcut(Inventario.atajo)
		Inventario.atajo = -1
	elif _shortcuts_on() and not auto:
		_show_hint("Atajos de prueba:  0 reiniciar · 1 hueco · 2 pincel · 3 sin sombras · 4 lago · 5 puerta", 4.0)
	_cam.reset_smoothing()
	if auto:
		add_child((load("res://herramientas/auto_nivel1.gd") as GDScript).new())


# --- partida guardada y atajos de prueba ------------------------------------------------------------

## Devuelve el nivel al punto guardado: sombras vencidas (con su pincelada), tintero tomado, puerta pintada.
func _restore_progress() -> void:
	if Inventario.pincel and not Inventario.hecho("n1_sombras"):
		Inventario.pincel = false          # tomó el pincel pero no venció a las sombras: se repite ese tramo
	if Inventario.pincel:
		has_brush = true
		brush = "seco"
		_brush_pickup.visible = false
	if Inventario.hecho("n1_sombras"):
		shadows_gone = true
		barrier_x = Inventario.progreso.get("n1_trazo_x", BRUSH_X + 650.0)
		_barrier_k = 1.0
		for part in 3:
			_stroke_part(part)
		walker.run_speed = RUN_SPEED
		walker.can_jump = true
		walker.max_speed = CALM_SPEED
		_checkpoint = Vector2(BRUSH_X, HIGH_Y)
		walker.position = Vector2(BRUSH_X + 200.0, HIGH_Y)
	if Inventario.tintero:
		_inkwell.visible = false
	if Inventario.hecho("n1_puerta"):
		gate_open = true
		_gate_k = 1.0
		_gate_paint.visible = true
		walker.position = Vector2(EXIT_X + 120.0, HIGH_Y)   # vuelve del lienzo por la puerta
	_update_inventory_ui()


## Atajos solo en versiones de desarrollo (F6 / F5 en el editor) y cuando el nivel se corre solo.
func _shortcuts_on() -> bool:
	return OS.is_debug_build() and get_tree().current_scene == self


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo or not _shortcuts_on():
		return
	var n := k.keycode - KEY_0
	if n < 0 or n > 5:
		return
	# cada atajo arma la partida que necesita y vuelve a cargar el nivel
	Inventario.reiniciar()
	if n >= 3:
		Inventario.pincel = true
		Inventario.progreso["n1_sombras"] = true
		Inventario.progreso["n1_trazo_x"] = BRUSH_X + 650.0
	if n >= 4:
		Inventario.tintero = true
	if n == 5:
		Inventario.tinta = Inventario.TINTA_MAX
	Inventario.guardar()
	Inventario.atajo = n
	get_tree().reload_current_scene()


func _apply_shortcut(n: int) -> void:
	var names := ["desde el principio (partida borrada)", "antes del hueco, corriendo", "junto al pincel",
		"sin sombras, rumbo al altar", "en el lago con el tintero vacío", "en la puerta con el tintero lleno"]
	match n:
		1:
			walker.position = Vector2(GAP.x - 700.0, GROUND_Y)
			walker.max_speed = STAGES[2][1]
			shadow_x = walker.position.x - 430.0
			_shadow_speed = STAGES[2][2]
		2:
			walker.position = Vector2(BRUSH_X - 40.0, HIGH_Y)
			walker.max_speed = STAGES[2][1]
			walker.can_jump = true
			shadow_x = BRUSH_X - 700.0
			_shadow_speed = 320.0
		3:
			walker.position = Vector2(ALTAR_X - 250.0, HIGH_Y)
		4:
			walker.position = Vector2(FALL_X - 120.0, HIGH_Y)
		5:
			walker.position = Vector2(EXIT_X - 160.0, HIGH_Y)
	print("[nivel1] atajo %d: %s" % [n, names[n]])
	_show_hint("Atajo %d: %s" % [n, names[n]], 2.5)


# --- terreno y decoración -------------------------------------------------------------------------

func _build_ground() -> void:
	_ground_strip(-160.0, GAP.x, GROUND_Y)
	_ground_strip(GAP.y, WIDTH + 200.0, HIGH_Y)
	_solid(Rect2(-200, GROUND_Y, GAP.x + 200, 400))
	_solid(Rect2(GAP.y, HIGH_Y, WIDTH - GAP.y + 400, 510))
	_solid(Rect2(-240, GROUND_Y - 1200, 240, 1200))          # bordes del mundo
	_solid(Rect2(WIDTH, GROUND_Y - 1200, 240, 1200))
	# pared de la plataforma alta y piedras en el borde del hueco
	var wb: Array = _metrics.wall.bounds
	_place("wall", Vector2(GAP.y + 30, GROUND_Y + 40), 170.0 / float(wb[3]), -9).modulate.a = 0.8
	_place("stones", Vector2(GAP.x - 20, GROUND_Y + 8), 0.7, -8)
	_place("stones", Vector2(GAP.y + 40, HIGH_Y + 8), 0.6, -8)


## Altura del suelo en x: baja antes del hueco, alta después.
func _ground_at(x: float) -> float:
	return HIGH_Y if x >= GAP.y else GROUND_Y


## Tira de suelo a lápiz entre x0 y x1 a la altura y (sin colisión: va aparte).
func _ground_strip(x0: float, x1: float, ground: float) -> void:
	var x := x0
	var i := 0
	while x < x1 - 40.0:
		var id: String = ["ground_a", "ground_b", "ground_c"][i % 3]
		var b: Array = _metrics[id].bounds
		var f := 2.0
		var s := _sprite(id, -10)
		s.scale = Vector2.ONE * f
		# los pies van dentro del trazo del suelo (fila ~120-130 del módulo), no sobre su borde superior
		s.position = Vector2(x - float(b[0]) * f, ground - GROUND_LINE * f)
		# el último módulo se recorta para no invadir el hueco
		var room := x1 - x
		if room < float(b[2]) * f:
			s.region_enabled = true
			s.region_rect = Rect2(0, 0, float(b[0]) + room / f, 256)
		_add_oil(s, id)
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
	# self_modulate: el grafito se atenúa, pero el óleo de debajo (hijo) conserva su color al pintarse
	for e in [["tree_left", 760.0, 2.4], ["tree_right", 1900.0, 2.8], ["tree_left", 2900.0, 2.6], ["tree_right", 5100.0, 2.6], ["tree_left", 6450.0, 2.2]]:
		_place(e[0], Vector2(e[1], _ground_at(e[1]) + 4), e[2], -18).self_modulate.a = 0.38
	for j in 20:
		var x := 420.0 + j * 330.0
		if x > GAP.x - 120 and x < GAP.y + 120:
			continue
		if absf(x - EXIT_X) < 200.0 or absf(x - FALL_X) < LAKE_R + 60.0:
			continue
		_place("reeds" if j % 2 == 0 else "stones", Vector2(x, _ground_at(x) + 5), 0.55, -8).self_modulate.a = 0.6
	_place("pedestal", Vector2(BRUSH_X, HIGH_Y + 5), 0.6, -8)
	# puerta: boceto gris apagado; encima, su versión entintada (gate_tinta, mismo lienzo), oculta hasta que se pinta
	_gate_sketch = _place("gate", Vector2(EXIT_X, HIGH_Y + 4), GATE_SCALE, -18)
	_gate_sketch.modulate.a = 0.5
	_gate_glow = _place("gate", Vector2(EXIT_X, HIGH_Y + 4), GATE_SCALE, -19)
	_gate_glow.texture = load(COLOR_ART + "/Gate/gate_active_glow.png")
	_gate_glow.modulate.a = 0.0
	_gate_paint = _place("gate", Vector2(EXIT_X, HIGH_Y + 4), GATE_SCALE, -17)
	_gate_paint.texture = load(COLOR_ART + "/Gate/gate_tinta.png")
	_gate_paint.region_enabled = true
	_gate_paint.visible = false


## Arte de color de Codex: pincel en la luz, altar con el tintero y cascada de tinta con su lago.
func _build_color_props() -> void:
	_brush_pickup = _color_sprite("Objects/brush_pickup.png", -6)
	_brush_pickup.centered = true
	_brush_pickup.scale = Vector2.ONE * 0.42
	# altar: el mismo pedestal a lápiz que el del pincel (sin color); encima, el tintero de vidrio vacío,
	# aclarado para que se lea transparente (pie del frasco en y=236 de su celda)
	var ped := _place("pedestal", Vector2(ALTAR_X, HIGH_Y + 5.0), 0.6, -8)
	var top: float = ped.position.y + float(_metrics.pedestal.bounds[1]) * 0.6
	_inkwell = _color_sprite("Altar/inkwell_empty.png", -7)
	_inkwell.scale = Vector2.ONE * 0.5
	_inkwell.position = Vector2(ALTAR_X - 128.0 * 0.5, top + 4.0 - 236.0 * 0.5)
	_inkwell.modulate = Color(1.45, 1.45, 1.5, 0.95)
	# cascada: chorro 160x720 en (112,0) y charco 384x128 en (0,676) de un lienzo 384x804; el agua del
	# charco (y≈100 de su celda) queda a ras del suelo alto
	var origin := Vector2(FALL_X - 192.0, HIGH_Y + 8.0 - 776.0)
	# el chorro baja 60 px más que en el montaje de Codex: su borde inferior recto queda dentro del charco
	for e in [["ink_stream", Vector2(112, 60), -6], ["ink_base", Vector2(0, 676), -5]]:
		var a := AnimatedSprite2D.new()
		a.sprite_frames = _effects
		a.centered = false
		a.position = origin + (e[1] as Vector2)
		a.z_index = e[2]
		a.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(a)
		a.play(e[0])
	_splash = AnimatedSprite2D.new()
	_splash.sprite_frames = _effects
	_splash.centered = false
	_splash.z_index = 22
	_splash.visible = false
	_splash.animation_finished.connect(func() -> void: _splash.visible = false)
	add_child(_splash)


func _color_sprite(path: String, depth: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(COLOR_ART + "/" + path)
	s.centered = false
	s.z_index = depth
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(s)
	return s


# --- óleo bajo el grafito -------------------------------------------------------------------------

## Máscara de pintura del nivel (L8, 1/4 de resolución) y material que revela el óleo donde ya se pintó.
func _build_paint_mask() -> void:
	_mask_img = Image.create(int(MASK_SIZE.x / MASK_DIV), int(MASK_SIZE.y / MASK_DIV), false, Image.FORMAT_L8)
	_mask_tex = ImageTexture.create_from_image(_mask_img)
	for i in 12:
		var im := (load(COLOR_ART + "/Masks/Strokes/stroke_%02d.png" % (i + 1)) as Texture2D).get_image()
		if im.is_compressed():
			im.decompress()
		im.convert(Image.FORMAT_L8)
		_strokes.append(im)
	_oil_mat = ShaderMaterial.new()
	_oil_mat.shader = load("res://zones/oleo_revelado.gdshader")
	_oil_mat.set_shader_parameter("paint_mask", _mask_tex)
	_oil_mat.set_shader_parameter("mask_rect", Vector4(MASK_ORIGIN.x, MASK_ORIGIN.y, MASK_SIZE.x, MASK_SIZE.y))
	# capa que colorea el fondo y el grafito (multiplicando) donde pasó la pincelada; el lobo queda encima
	var white := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	white.fill(Color.WHITE)
	var layer := Sprite2D.new()
	layer.texture = ImageTexture.create_from_image(white)
	layer.centered = false
	layer.position = MASK_ORIGIN
	layer.scale = MASK_SIZE / 4.0
	layer.z_index = -4
	var mat := ShaderMaterial.new()
	mat.shader = load("res://zones/pintura_multiplica.gdshader")
	mat.set_shader_parameter("paint_mask", _mask_tex)
	mat.set_shader_parameter("oil", load(COLOR_ART + "/Barrier/rest.png"))
	mat.set_shader_parameter("mask_rect", Vector4(MASK_ORIGIN.x, MASK_ORIGIN.y, MASK_SIZE.x, MASK_SIZE.y))
	layer.material = mat
	add_child(layer)


## Pone debajo de un módulo de grafito su versión al óleo (si existe), con el mismo registro y recorte.
func _add_oil(s: Sprite2D, id: String) -> void:
	var path := COLOR_ART + "/Oleo/" + id + "_oleo.png"
	if not ResourceLoader.exists(path):
		return
	var o := Sprite2D.new()
	o.texture = load(path)
	o.centered = false
	o.show_behind_parent = true
	o.region_enabled = s.region_enabled
	o.region_rect = s.region_rect
	o.material = _oil_mat
	o.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	s.add_child(o)


## Estampa una máscara de trazo (512x256) centrada en `at`, de `length` px de largo y girada `angle`.
## Acumula con max(): lo pintado no se borra.
func _stamp(at: Vector2, length: float, angle: float, idx := -1) -> void:
	var src: Image = _strokes[idx if idx >= 0 else randi() % _strokes.size()]
	var sw := src.get_width()
	var sh := src.get_height()
	var k := length / MASK_DIV / sw            # px de máscara por px de la estampa
	var c := (at - MASK_ORIGIN) / MASK_DIV
	var r := Vector2(sw, sh).length() * 0.5 * k
	var ca := cos(angle)
	var sa := sin(angle)
	for y in range(maxi(0, int(c.y - r)), mini(_mask_img.get_height(), int(c.y + r) + 1)):
		for x in range(maxi(0, int(c.x - r)), mini(_mask_img.get_width(), int(c.x + r) + 1)):
			var dx := x - c.x
			var dy := y - c.y
			var u := int((dx * ca + dy * sa) / k + sw * 0.5)
			var v := int((-dx * sa + dy * ca) / k + sh * 0.5)
			if u < 0 or v < 0 or u >= sw or v >= sh:
				continue
			var m := src.get_pixel(u, v).r
			if m > _mask_img.get_pixel(x, y).r:
				_mask_img.set_pixel(x, y, Color(m, m, m))
	_mask_dirty = true



func _place(id: String, at: Vector2, f: float, depth: int) -> Sprite2D:
	var s := _sprite(id, depth)
	var b: Array = _metrics[id].bounds
	s.position = at - Vector2(float(b[0]) + float(b[2]) * 0.5, float(b[1]) + float(b[3])) * f
	s.scale = Vector2.ONE * f
	_add_oil(s, id)
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
	_brush_label = Label.new()
	_brush_label.position = Vector2(24, 18)
	_brush_label.add_theme_font_size_override("font_size", 20)
	_brush_label.add_theme_color_override("font_color", Color(0.96, 0.92, 0.82))
	_brush_label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05))
	_brush_label.add_theme_constant_override("outline_size", 6)
	ui.add_child(_brush_label)
	_ink_icon = TextureRect.new()
	_ink_icon.position = Vector2(16, 44)
	_ink_icon.size = Vector2(48, 48)
	_ink_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ink_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_ink_icon.visible = false
	ui.add_child(_ink_icon)
	_ink_bar = ColorRect.new()
	_ink_bar.position = Vector2(68, 66)
	_ink_bar.size = Vector2(170, 12)
	_ink_bar.color = Color(0.96, 0.92, 0.82, 0.55)
	_ink_bar.visible = false
	ui.add_child(_ink_bar)
	_ink_fill = ColorRect.new()
	_ink_fill.position = Vector2(2, 2)
	_ink_fill.color = Color(0.03, 0.03, 0.05)
	_ink_bar.add_child(_ink_fill)


func _set_brush(state: String) -> void:
	brush = state
	print("[nivel1] %.1f s: pincel -> %s" % [_t, state])
	_update_inventory_ui()


## Indicador provisional del inventario (arriba a la izquierda): pincel, tintero y nivel de tinta.
## También pone la punta que se ve en el pincel del lobo: color, tinta o seca.
func _update_inventory_ui() -> void:
	var lines: Array[String] = []
	if has_brush:
		lines.append("Pincel: restos de color (un trazo)" if brush == "color" else "Pincel")
	if Inventario.tintero:
		_ink_fill.size = Vector2(166.0 * Inventario.tinta / Inventario.TINTA_MAX, 8)
		var icon := AtlasTexture.new()
		icon.atlas = load(COLOR_ART + "/Altar/inkwell_%s.png" % ("full" if Inventario.tinta > 0.0 else "empty"))
		icon.region = Rect2(64, 118, 128, 128)
		_ink_icon.texture = icon
	_ink_icon.visible = Inventario.tintero
	_ink_bar.visible = Inventario.tintero
	_brush_label.text = "\n".join(lines)
	if has_brush and walker:
		var tip := "color" if brush == "color" else ("ink" if Inventario.tinta > 0.0 else "dry")
		if walker.lobo.brush != tip:
			walker.lobo.set_brush(tip)


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
		shadow_x = x - 700.0                  # entran por el borde izquierdo de la pantalla...
		_shadow_speed = 280.0                  # ...de golpe, y luego se calman al paso del tramo
		print("[nivel1] %.1f s: aparecen las sombras" % _t)
	if shadow_x != -INF and not shadows_gone:
		_update_shadows(delta, st)

	if walker.position.y > GROUND_Y + 450.0:
		_caught("cayó al hueco")
	if not has_brush and absf(x - BRUSH_X) < 70.0 and walker.is_on_floor():
		_take_brush()
	_update_places(x)
	if has_brush and not _busy and not _acting and Input.is_action_just_pressed("paint"):
		if brush == "color" and not shadows_gone:
			_paint_barrier()
		elif _at_altar and not Inventario.tintero:
			_take_inkwell()
		elif _at_lake and Inventario.tintero:
			_fill_inkwell()
		elif _at_gate and not gate_open and _gate_k == 0.0:
			if Inventario.gastar(Inventario.COSTO_PUERTA):
				_paint_gate()
			else:
				_show_hint("No hay tinta suficiente", 1.5)
		elif brush == "seco":
			_show_hint("El pincel está seco" if Inventario.tinta <= 0.0 else "Aquí no hay nada que pintar", 1.2)
	_update_gate_paint()
	if _mask_dirty:
		_mask_dirty = false
		_mask_tex.update(_mask_img)

	_update_camera(delta)
	_update_exits()
	_check_exit()
	queue_redraw()
	_shadow_layer.queue_redraw()


func _update_shadows(delta: float, st: Array) -> void:
	var speed: float = st[2]
	var leash: float = st[3]
	if has_brush:
		speed = 470.0          # tras el destello vuelven más rápido que el lobo: hay que pintar
		leash = 520.0
	_shadow_speed = move_toward(_shadow_speed, speed, 90.0 * delta)
	shadow_x = maxf(shadow_x + _shadow_speed * delta, walker.position.x - leash)
	if _acting and barrier_x == -INF:
		shadow_x = minf(shadow_x, walker.position.x - 240.0)   # mientras se gira a pintar, no lo alcanzan
	if barrier_x != -INF:
		# la barrera de óleo las detiene y se deshacen contra ella
		shadow_x = minf(shadow_x, barrier_x - 26.0)
		if shadow_x >= barrier_x - 40.0 and _barrier_k >= 1.0:
			_shadow_alpha = maxf(0.0, _shadow_alpha - delta / 2.5)
			if _shadow_alpha <= 0.0:
				shadows_gone = true
				_vignette.modulate.a = 0.0
				walker.run_speed = RUN_SPEED           # ya sin miedo: corre y salta cuando quiere
				Inventario.progreso["n1_trazo_x"] = barrier_x
				Inventario.marcar("n1_sombras")
				walker.can_jump = true
				_show_hint("Las sombras se quedaron atrás… pero el pincel quedó seco.  Shift: correr", 4.5)
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
	_checkpoint = Vector2(BRUSH_X, HIGH_Y)
	# el destello de la luz empuja a las sombras hacia atrás un momento
	if shadow_x != -INF:
		shadow_x = minf(shadow_x, BRUSH_X - 600.0)
		_shadow_speed = 320.0
	var flash := create_tween()
	_fade.color = Color(1.0, 0.96, 0.85, 0.0)
	flash.tween_property(_fade, "color:a", 0.75, 0.12)
	flash.tween_property(_fade, "color:a", 0.0, 0.9)
	flash.tween_callback(func() -> void: _fade.color = Color(INK, 0.0))
	Inventario.pincel = true
	Inventario.guardar()
	_brush_pickup.visible = false
	_set_brush("color")
	_show_hint("El pincel. Le queda color para un trazo.  F: dar una pincelada contra las sombras", 5.0)


## Acción de pincel: el lobo se detiene, se gira hacia `dir` y reproduce la animación; lo que pinta
## ocurre en _on_action_frame (cuadros 4–6 del tajo) y vuelve a caminar en _on_action_finished.
func _start_action(anim: StringName, dir: float) -> void:
	_acting = true
	walker.enabled = false
	walker.velocity.x = 0.0
	walker.lobo.face(dir)
	walker.lobo.play_action(anim)


func _on_action_frame(anim: StringName, frame: int) -> void:
	var tip := walker.lobo.tip_global(anim, frame)
	match anim:
		&"paint_rise", &"paint_up":
			if brush == "color":
				# primera pincelada (con los restos de color): sube del suelo en diagonal
				if frame == 4:
					_start_stroke(tip)
				if frame >= 4 and frame <= 6:
					_stroke_part(frame - 4)
				if frame == 6:
					_set_brush("seco")     # se acabó la carga de color
			elif frame == 4:
				_reveal_gate()
		&"dip":
			if frame == 4:
				_splash.position = Vector2(tip.x, HIGH_Y + 4.0) - Vector2(64, 112)
				_splash.visible = true
				_splash.play("dip_splash")
				Inventario.llenar()
				print("[nivel1] %.1f s: llena el tintero" % _t)
				_update_inventory_ui()
				_show_hint("Tintero lleno. La tinta se gasta al pintar: vuelve aquí a llenarlo", 4.0)
	_last_tip = tip


func _on_action_finished(_anim: StringName) -> void:
	_acting = false
	if not _busy:
		walker.enabled = true


## Las sombras siempre vienen por la izquierda: se gira hacia ellas y las enfrenta con una pincelada
## ascendente (paint_rise de Wolf_Varita_v002).
func _paint_barrier() -> void:
	print("[nivel1] %.1f s: se gira y pinta la barrera (sombras a %d px)" % [_t, walker.position.x - shadow_x])
	_start_action(&"paint_rise", -1.0)


## Pincelada de color: una estocada diagonal (~60°) sobre el fondo, del suelo delante del lobo (que mira
## a las sombras) hacia arriba y atrás, por donde sube la punta de la varita en paint_rise (cuadros 4–6).
## No es un muro: es color sobre el lienzo, y las sombras no lo cruzan. barrier_x es el pie del trazo.
func _start_stroke(tip: Vector2) -> void:
	barrier_x = tip.x
	print("[nivel1] %.1f s: pincelada de color en x=%d" % [_t, barrier_x])
	_barrier_k = 0.0
	var tw := create_tween()
	tw.tween_property(self, "_barrier_k", 1.0, 0.6)


## Un tercio de la pincelada por cuadro activo (0 el pie, 2 arriba): tres estampas por tercio.
func _stroke_part(part: int) -> void:
	var foot := Vector2(barrier_x, _ground_at(barrier_x) + 50.0)
	var dir := Vector2(cos(-STROKE_ANGLE), sin(-STROKE_ANGLE))   # hacia arriba a la derecha
	for i in 3:
		var k := (part * 3 + i + 0.5) / 9.0                        # de 0 (pie) a 1 (arriba)
		_stamp(foot + dir * STROKE_LEN * k + Vector2(randf_range(-10, 10), 0), 520.0, -STROKE_ANGLE, [1, 4, 3][i] - 1)


## Avisos al llegar a la puerta, al altar o al lago (solo una vez por visita).
func _update_places(x: float) -> void:
	var at_gate := absf(x - EXIT_X) < 170.0 and shadows_gone and not gate_open
	if at_gate and not _at_gate:
		if Inventario.tinta >= Inventario.COSTO_PUERTA:
			_show_hint("F: pintar la puerta con tinta")
		else:
			_show_hint("La puerta es solo un boceto. Hace falta tinta para pintarla…", 3.5)
	_at_gate = at_gate
	var at_altar := absf(x - ALTAR_X) < 110.0 and has_brush and shadows_gone and not Inventario.tintero
	if at_altar and not _at_altar:
		_show_hint("Un tintero sobre el altar.  F: tomarlo")
	_at_altar = at_altar
	var at_lake := absf(x - FALL_X) < LAKE_R and Inventario.tintero
	if at_lake and not _at_lake and Inventario.tinta < Inventario.TINTA_MAX:
		_show_hint("El lago de tinta.  F: llenar el tintero")
	_at_lake = at_lake


func _take_inkwell() -> void:
	Inventario.tintero = true
	Inventario.tinta = 0.0
	Inventario.guardar()
	_inkwell.visible = false
	print("[nivel1] %.1f s: toma el tintero (vacío)" % _t)
	_update_inventory_ui()
	_show_hint("Tomaste el tintero. Está vacío: llénalo en el lago de tinta", 4.0)


## Moja el pincel en el lago: la tinta entra en los cuadros 4–5 del dip (ver _on_action_frame).
func _fill_inkwell() -> void:
	if Inventario.tinta >= Inventario.TINTA_MAX:
		_show_hint("El tintero ya está lleno", 1.2)
		return
	_start_action(&"dip", signf(FALL_X - walker.position.x))


func _paint_gate() -> void:
	print("[nivel1] %.1f s: pinta la puerta (tinta restante %d)" % [_t, Inventario.tinta])
	_update_inventory_ui()
	_start_action(&"paint_up", signf(EXIT_X - walker.position.x))


## La tinta sube por la puerta desde el pie del trazo (cuadro 4 de paint_up).
func _reveal_gate() -> void:
	_gate_paint.visible = true
	var tw := create_tween()
	tw.tween_property(self, "_gate_k", 1.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_callback(func() -> void:
		gate_open = true
		Inventario.marcar("n1_puerta")
		print("[nivel1] %.1f s: la puerta se activa" % _t)
		_show_hint("La puerta está abierta"))


## Revela la puerta entintada de abajo hacia arriba según _gate_k; el boceto se apaga y el vano se ilumina.
func _update_gate_paint() -> void:
	if not _gate_paint.visible:
		return
	var b: Array = _metrics.gate.bounds
	var bottom := float(b[1]) + float(b[3])
	var h := float(b[3]) * _gate_k
	var base := Vector2(EXIT_X, HIGH_Y + 4) - Vector2(float(b[0]) + float(b[2]) * 0.5, bottom) * GATE_SCALE
	_gate_paint.region_rect = Rect2(0, bottom - h, 256, h)
	_gate_paint.position = base + Vector2(0, (bottom - h) * GATE_SCALE)
	_gate_sketch.modulate.a = 0.5 * (1.0 - _gate_k * 0.8)
	_gate_glow.modulate.a = _gate_k * (0.85 + sin(_t * 3.0) * 0.15)


func _update_camera(delta: float) -> void:
	# mira hacia adelante cuando corre, para ver lo que viene
	var ahead := clampf(walker.velocity.x * 0.45, -60.0, 200.0)
	_cam.offset.x = move_toward(_cam.offset.x, ahead, 220.0 * delta)


func _update_exits() -> void:
	# única salida: la puerta pintada, que lleva de vuelta al lienzo principal
	var found := ""
	if gate_open and absf(walker.position.x - EXIT_X) < 90.0:
		found = "camino"
	cur_exit = found
	var now_near := found != "" and _moved
	if now_near != near_exit:
		near_exit = now_near
		near_exit_changed.emit(near_exit)
		if near_exit and exit_requested.get_connections().is_empty():
			_show_hint("E: volver al lienzo  (en el juego completo)")


func _check_exit() -> void:
	if near_exit and not _busy and InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		print("[nivel1] %.1f s: entra por la puerta hacia «%s»" % [_t, cur_exit])
		exit_requested.emit(cur_exit)


# --- dibujo -----------------------------------------------------------------------------------------

func _draw() -> void:
	if not has_brush:
		_draw_light()


## La luz que se ve a lo lejos: un haz cálido sobre el pedestal y el pincel (brush_pickup) flotando en ella.
func _draw_light() -> void:
	var c := Vector2(BRUSH_X, HIGH_Y - 150.0 + sin(_t * 1.6) * 6.0)
	var p := 1.0 + sin(_t * 2.2) * 0.08
	draw_colored_polygon(PackedVector2Array([c + Vector2(-26, 0), c + Vector2(26, 0), c + Vector2(90, -620), c + Vector2(-90, -620)]), Color(1.0, 0.93, 0.72, 0.16))
	for k in [[150.0, 0.07], [95.0, 0.12], [55.0, 0.22], [28.0, 0.45]]:
		draw_circle(c, (k[0] as float) * p, Color(1.0, 0.90, 0.62, k[1] as float))
	_brush_pickup.position = c
	_brush_pickup.rotation = sin(_t * 1.1) * 0.06


## Sombras: una masa de tinta con borde ondulante, brazos que se estiran y ojos pálidos.
func _draw_shadows() -> void:
	# la barrera es un sprite delante de esta capa (z 21): las sombras quedan detrás de ella
	if shadow_x == -INF or shadows_gone:
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
		var base := Vector2(fx, _ground_at(fx + 60.0) - 30.0 - i * 70.0)
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


func track() -> int:
	return TRACK


func zone_title() -> String:
	return "Camino"
