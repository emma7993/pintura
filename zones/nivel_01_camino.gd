extends Node2D
## Nivel 1 — Camino (prueba jugable) con los bocetos de grafito de Codex (art/worlds/camino/nivel_01_bocetos_v001).
## Guion: el lobo aparece con miedo y solo camina; unas sombras lo persiguen y lo obligan a apurarse y luego
## a correr. A lo lejos ve una luz al otro lado de un hueco (ahí descubre el salto). La luz guarda el pincel,
## primer upgrade: con él pinta una barrera de óleo detrás de sí y las sombras se quedan atrás.
## La luz está en una plataforma alta al otro lado del hueco. El pincel trae restos de color para un solo
## trazo y queda seco. La puerta (arco) de regreso al lienzo es un boceto apagado; junto a ella hay un pozo
## cerrado. Más adelante: un escalón, una meseta y un foso con espinas (corriendo se salta), y la boca
## de una cueva que baja. Abajo, en una cámara honda, el tintero vacío (core/inventario.gd); a la izquierda,
## bajo tierra, la cascada de tinta donde se llena; de vuelta bajo el pozo, un golpe de pincel rompe su tapa
## y se sube por él hasta el arco, que se pinta con tinta para volver al lienzo. La tinta se gasta.
## Las sombras (bruma y manos que brotan del suelo) son zones/sombras.gd.
## Se corre solo con F6 (zones/nivel_01_camino.tscn) o entrando desde el camino de la pintura (main.gd).
## En el juego es el principio de Camino (MapaDatos.NIVEL1): al inicio hay una puerta de vuelta a la pintura;
## por el extremo derecho, por el fondo izquierdo de la cueva y por la puerta del copista se sigue al resto
## de Camino (mundo/mundo.gd); «entrada» dice por dónde se vuelve de ahí.

signal exit_requested(next_zone: String)
signal near_exit_changed(is_near: bool)

const ART := "res://art/worlds/camino/nivel_01_bocetos_v001"
const COLOR_ART := "res://art/worlds/camino/nivel_01_color_v001"   # óleo, máscaras, barrera, cascada, altar
## Arte de ChatGPT en dos estados: boceto/ antes de pintar la puerta y definido/ después; al pintarla, lo
## definido se dibuja desde la puerta hacia todo el paisaje (zones/revelar_dibujo.gdshader). F3 alterna con v001.
const ESTADOS := "res://art/worlds/camino/nivel_01_estados_v001"
const DIBUJO_DURA := 3.2                  # s que tarda el frente en cruzar la pantalla al pintar la puerta
const DIBUJO_FIN := 2600.0                # radio (px de pantalla) que cubre toda la pantalla
const T05 := "05_terreno_vegetacion"
const T06 := "06_cueva_modulos"
const T07 := "07_pozo"
const T08 := "08_foso_espinas"
## Fondos v003 (herramientas/fondos_camino_v003.py, de fondos_unificados_v001 de ChatGPT): bocetos blancos
## opacos y definidos en sepia uniforme, misma silueta por pareja.
const FONDOS := "res://art/worlds/camino/nivel_01_fondos_v003"
## Cielo, se repite: [archivo, parallax, z, opacidad, alto en pantalla, y de la parte de arriba sobre GROUND_Y,
## en espejo]. Encuadre con el lobo en el suelo: la pantalla va de GROUND_Y - 430 (arriba) a GROUND_Y + 290; las
## nubes solo ocupan la parte de arriba de la imagen, así que se apilan tres filas para cuando el lobo sube.
const CAPAS_V002 := [
	["02_cielo_nubes", 0.08, -70, 1.0, 600.0, -470.0, false],
	["02_cielo_nubes", 0.065, -71, 0.9, 600.0, -747.0, true],
	["02_cielo_nubes", 0.05, -72, 0.8, 600.0, -1024.0, false],
]
## Panorama: el montaje de ChatGPT (fondos_unificados_v001/montaje_parallax.json, lienzo de 3548x1000) escalado
## MONTAJE_ESCALA, con su borde de abajo bajo el suelo del inicio. Cada capa con su parallax; se ven como en el
## montaje cuando la cámara está en MONTAJE_CAM y se separan un poco hacia los extremos (profundidad).
const MONTAJE_ESCALA := 0.75
const MONTAJE_X := -100.0
const MONTAJE_ABAJO := 70.0               # px bajo GROUND_Y donde queda el borde de abajo del montaje (la cabeza entera)
const MONTAJE_CAM := 5000.0
const MONTAJE_REF := 0.25                 # parallax de los hitos (puentes, casa y faro)
## Franjas que se repiten en x: [archivo, parallax, z, y de arriba en el montaje]
const FRANJAS_V003 := [
	["15_horizonte", 0.20, -66, 430.0],
	["17_colinas_enlace", 0.22, -62, 180.0],
	["18_laderas_rocosas", 0.27, -56, 480.0],
	["19_costa_enlace", 0.29, -50, 290.0],
]
## Partes de la pintura, en orden: [archivo, parallax, z, x de la cámara en la que se ve al centro, y de la
## base sobre GROUND_Y, ancho en pantalla, recorte del PNG, opacidad]. La cabeza y el faro, muy lejos: chicos,
## lentos y detrás de las colinas, como algo enorme en el horizonte.
const HITOS_V003 := [
	["03_ruinas_lejanas", 0.14, -65, 7000.0, -230.0, 1100.0, [0, 50, 1774, 450], 0.8],   # puentes y acueductos lejanos
	["09_cabeza_lejana", 0.16, -64, 2500.0, -232.0, 330.0, [17, 171, 1259, 863], 0.75],
	["04_plano_medio", 0.25, -54, 680.0, -61.0, 990.0, [33, 186, 1774, 618], 1.0],
	["11_casa_lejana", 0.25, -53, 3480.0, -64.0, 260.0, [567, 286, 1207, 887], 1.0],
	["10_faro_lejano", 0.16, -64, 5240.0, -238.0, 380.0, [297, 42, 1764, 870], 0.75],
]
const SUB_ESC := 0.5                      # subsuelo (12, 13) y pared de la cueva (14): 1024 px de textura = 512
const SUB_BORDE := 256.0 * SUB_ESC        # alto de la orilla del subsuelo (13) en el mundo
const MARCO_ALTO := 330.0                 # puerta de regreso a la pintura (16_marco_pintura), en el arco
const CAER_DESDE := 560.0                 # al entrar desde la pintura, el lobo cae desde esta altura
const MASK_ORIGIN := Vector2(-200, -500)  # máscara de pintura: esquina superior izquierda en px de mundo
const MASK_SIZE := Vector2(10400, 2300)
const MASK_DIV := 4.0                     # px de mundo por px de máscara
const GROUND_Y := 600.0
const WIDTH := 10000.0
const SPAWN := Vector2(260, 600)
const TRACK := 5                          # canción: Camino
const GAP := Vector2(3950, 4110)          # hueco que hay que saltar (x de inicio, x de fin)
const HIGH_Y := 490.0                     # suelo de la plataforma alta, después del hueco (salto máx. ~175 px)
const BRUSH_X := 4560.0                   # la luz con el pincel
const EXIT_X := 5700.0                    # puerta de regreso al lienzo principal
const GATE_SCALE := 1.8
## Fila donde pisa el lobo en las piezas de suelo: [hoja, pieza, fila]. La superficie de la losa (05/4) va de la
## fila 56 (orilla de atrás) a la ~80 (de adelante); la de los bordes de los huecos (08/1 y 08/2), de la ~23 a la ~65.
const PISADAS := [["05_terreno_vegetacion", 4, 74.0], ["08_foso_espinas", 1, 44.0], ["08_foso_espinas", 2, 48.0],
	["05_terreno_vegetacion", 3, 28.0]]
const LOSA_ESCALA := 0.8                  # losa del suelo (antes 0.42: su superficie apenas tenía 10 px de fondo)
const MESETA_PISADA := 76.0               # fila de la superficie de la meseta en su pieza (hoja 05)
const PIE_HUNDIDO := 8.0                # árboles y matas: la base entra en la losa del suelo (si no, flotan)
const GROUND_LINE := 126.0               # fila de los módulos ground_a/b/c que queda bajo los pies
const WELL_X := 5980.0                    # pozo junto al arco; su tiro baja hasta el techo de la cueva
const WELL_HALF := 110.0
const STEP_X := Vector2(6700, 6870)       # escalón flotante
const STEP_Y := HIGH_Y - 150.0
const PLATEAU := Vector2(6900, 7500)      # meseta: sin el escalón no se sube (salto máx. ~225 px)
const PLATEAU_Y := HIGH_Y - 300.0
const PIT := Vector2(7850, 8050)          # foso con espinas en el fondo: se salta corriendo
const PIT_FLOOR := 760.0
const SPIKE_H := 46.0
const HOLE := Vector2(8450, 8610)         # boca de la cueva
const CAVE_TOP := 800.0                   # techo de la cueva (entre el suelo alto y aquí: roca)
const CAVE_Y := 1250.0                    # suelo de la cueva
const CAVE_X := Vector2(5000, 8750)
const CHAMBER := Vector2(6900, 7600)      # cámara de la paleta (plana, al nivel de la cueva)
const CHAMBER_Y := CAVE_Y
const ALTAR_X := 7390.0                   # altar con la paleta (a la derecha de la cámara; a la izquierda, la entrada)
const FALL_X := 5350.0                    # cascada de tinta (bajo tierra, a la izquierda)
const LAKE_R := 160.0                     # medio ancho del lago de tinta al pie de la cascada
## Repisas para subir saltando del suelo de la cueva por el tiro del pozo (salto máx. ~175 px), que está
## abierto por abajo. La de 660 es la más alta, bajo la losa de la boca: desde ahí se golpea la losa.
const WELL_LEDGES := [1110.0, 965.0, 810.0, 660.0]
const PLUG := Rect2(5870, HIGH_Y + 30.0, 220, 24)   # cara de abajo de la losa que cierra la boca del pozo
## Tramos: [desde x, velocidad máxima del lobo, velocidad de las sombras, distancia máxima de las sombras]
## La velocidad del lobo solo cuenta en el primer tramo (camina con miedo): con la primera mano pasa de una
## vez a correr (RUN_SPEED), sin caminata rápida. Las sombras sí siguen los tramos.
const STAGES := [
	[0.0, 127.0, 122.0, 520.0],           # miedo: solo camina (las sombras casi lo igualan)
	[1100.0, 215.0, 190.0, 560.0],        # se apuran las sombras
	[2200.0, 360.0, 320.0, 430.0],        # corren
]
const SHADOW_START_X := 380.0             # las sombras aparecen al poco de empezar a caminar
const RUN_SPEED := 360.0                  # con el pincel el lobo ya no camina: siempre corre
const INK := Color(0.07, 0.06, 0.07)
const STROKE_ANGLE := PI / 3.0            # pincelada de color: 60° sobre la horizontal
const STROKE_LEN := 1000.0                # largo de la pincelada (del suelo hasta arriba de la pantalla)
const HOME_X := 110.0                     # puerta de vuelta a la pintura, al principio
const COPISTA_X := 6480.0                 # puerta al taller del copista, en la cueva
## Por dónde se llega al volver del resto de Camino (main.gd pone «entrada»).
const ENTRADAS := {
	"fin": Vector2(WIDTH - 200.0, HIGH_Y), "arco": Vector2(EXIT_X + 120.0, HIGH_Y),
	"pozo": Vector2(WELL_X + 220.0, CAVE_Y), "cueva": Vector2(CAVE_X.x + 130.0, CAVE_Y),
	"copista": Vector2(COPISTA_X, CAVE_Y),
	# una por sala del mapa (Ñ / L en main.gd, para probar)
	"ca_despertar": SPAWN, "ca_barranco": Vector2(GAP.x - 700.0, GROUND_Y),
	"ca_altar": Vector2(BRUSH_X - 40.0, HIGH_Y), "ca_arco": Vector2(EXIT_X - 160.0, HIGH_Y),
	"ca_cascada": Vector2(FALL_X + 120.0, CAVE_Y), "ca_pozo": Vector2(WELL_X, CAVE_Y),
	"ca_cueva": Vector2(COPISTA_X - 150.0, CAVE_Y),
	"ca_paleta": Vector2(ALTAR_X - 220.0, CHAMBER_Y),
}

var walker: Player
var cur_exit := ""
var exit_hint := ""
var near_exit := false
var entrada := ""                         # punto de llegada (ENTRADAS); vacío = desde la pintura
var _leaving := false
var shadow_x := -INF                      # frente de las sombras (px de mundo); -INF = aún no aparecen
var has_brush := false
var brush := ""                           # restos del pincel: "color" (un trazo) o "seco"; la tinta sale del tintero
var barrier_x := -INF                     # -INF = sin barrera
var shadows_gone := false
var gate_open := false                    # la puerta ya se pintó
var well_open := false                    # la tapa del pozo ya se rompió

var _t := 0.0
var _gate_k := 0.0                        # 0..1: avance de la pintura de la puerta
var _gate_sketch: Sprite2D                # boceto gris de la puerta
var _gate_paint: Sprite2D                 # la puerta entintada, se revela de abajo hacia arriba
var _gate_glow: Sprite2D
var _at_gate := false
var _at_altar := false
var _at_lake := false
var _at_well := false                     # bajo la losa del pozo, en la repisa más alta del tiro
var _over_well := false
var _action_target := ""                  # qué pinta paint_up: "gate" o "well"
var _tapa_roca: Node2D                    # roca que tapa el tiro del pozo visto desde arriba
var _lid: StaticBody2D                    # losa del pozo en el suelo alto (luego, repisa de un solo sentido)
var _debris: Array[Dictionary] = []       # trozos de la tapa al romperse
var _terrain: Node2D                      # roca y pozo dibujados (provisional hasta tener arte)
var _sombras: Sombras
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
var _life: Array[ColorRect] = []
var _stage := 0
var _huye := false                        # ya salió la primera mano: corre y no vuelve a caminar
var _shadow_speed := 0.0
var _shadow_alpha := 1.0
var _barrier_k := 0.0                     # 0..1: crecimiento de la barrera
var _checkpoint := SPAWN
var _busy := false
var _moved := false
var _metrics := {}
var _env: Node2D
var _cam: Camera2D
var _cam_ahead := 0.0
var _hint: Label
var _fade: ColorRect
var _vignette: TextureRect
var _fondos_v002: Array[CanvasItem] = []  # papel y capas de fondo de ChatGPT (ESTADOS)
var _mats_dibujo: Array[ShaderMaterial] = []   # revelar_dibujo: boceto y definido, con y sin bordes fundidos
var _dibujo_r := 0.0                      # radio del frente de dibujo (0 = boceto, DIBUJO_FIN = definido)
var _fondos_v002_on := true
var _piezas := {}                          # hoja -> [[x, y, ancho, alto, fila de pisada], ...] (piezas.json)
var _arte_v1: Array[CanvasItem] = []      # módulos de bocetos v001 que reemplazan las piezas v002
var _arte_v2: Array[CanvasItem] = []      # piezas v002 (ChatGPT)
var _pozo_v2 := {}                        # "cerrado", "abierto", "losa", "tapa": sprites del pozo
var _rock_node: Node2D
var _nodos_tierra: Array[Node2D] = []    # roca y aire de la cueva: definido y, de hijo, su boceto
var _texturas := {}
var _back_node: Node2D


func _ready() -> void:
	Controls.ensure()
	for item in JSON.parse_string(FileAccess.get_file_as_string(ART + "/inventory.json")):
		_metrics[item.id] = item
	_env = (load(ART + "/Godot/Environment.tscn") as PackedScene).instantiate()
	_env.set("ground_y", GROUND_Y)
	_env.set("world_width", WIDTH)
	_env.set("show_modules", false)       # solo fondos: el terreno se arma aquí, con el hueco
	add_child(_env)
	_piezas = JSON.parse_string(FileAccess.get_file_as_string(ESTADOS + "/piezas.json"))
	# en piezas.json la pisada es la orilla de atrás de la superficie: con ella el lobo caminaba sobre el borde
	# y se veía encima del suelo. Se pisa más adelante, para que se vea un poco de suelo detrás de él.
	for k in PISADAS:
		var r: Array = (_piezas[k[0]][k[1]] as Array).duplicate()
		r[4] = k[2]
		_piezas[k[0]][k[1]] = r
	_build_fondos_v002()
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
	walker.attack_hit_frame.connect(_on_attack_hit)
	walker.hurt_taken.connect(func(_v: int) -> void: _update_life_ui())
	walker.died.connect(func() -> void: _caught("se quedó sin vida"))

	_sombras = Sombras.new()
	add_child(_sombras)

	_cam = Camera2D.new()
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 5.0
	_cam.limit_left = 0
	_cam.limit_right = int(WIDTH)
	_cam.limit_bottom = int(CHAMBER_Y + 200.0)
	_cam.offset = Vector2(0, -70)
	walker.add_child(_cam)
	_build_ui()

	var auto := "--auto-nivel1" in OS.get_cmdline_user_args()
	if auto:
		Inventario.reiniciar()               # la prueba automática siempre empieza de cero
	else:
		Inventario.cargar()
	_restore_progress()
	if ENTRADAS.has(entrada):
		walker.position = ENTRADAS[entrada]
		_checkpoint = walker.position
		if entrada == "fin":
			walker.lobo.face(-1)
	elif entrada == "" and not auto:
		walker.position.y -= CAER_DESDE      # se llega a este mundo cayendo desde la pintura
	_update_life_ui()
	if Inventario.atajo >= 0:
		_apply_shortcut(Inventario.atajo)
		Inventario.atajo = -1
	elif _shortcuts_on() and not auto:
		_show_hint("Atajos:  0 reiniciar · 1 hueco · 2 pincel · 3 plataformas · 4 cascada · 5 arco · 6 pozo", 4.0)
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
		_unlock_abilities()
	if Inventario.hecho("n1_sombras"):
		shadows_gone = true
		barrier_x = Inventario.progreso.get("n1_trazo_x", BRUSH_X + 650.0)
		_barrier_k = 1.0
		for part in 3:
			_stroke_part(part)
		walker.can_jump = true
		walker.max_speed = RUN_SPEED
		_checkpoint = Vector2(BRUSH_X, HIGH_Y)
		walker.position = Vector2(BRUSH_X + 200.0, HIGH_Y)
	if Inventario.tintero:
		_inkwell.visible = false
	if Inventario.hecho("n1_pozo"):
		_open_well(false)
	if Inventario.hecho("n1_puerta"):
		gate_open = true
		_gate_k = 1.0
		_gate_paint.visible = true
		_dibujar_paisaje(false)
		walker.position = Vector2(EXIT_X + 120.0, HIGH_Y)   # vuelve del lienzo por la puerta
	_update_inventory_ui()


## Atajos solo en versiones de desarrollo (F6 / F5 en el editor) y cuando el nivel se corre solo.
func _shortcuts_on() -> bool:
	return OS.is_debug_build() and get_tree().current_scene == self


func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k == null or not k.pressed or k.echo:
		return
	if k.keycode == KEY_F3 and OS.is_debug_build():   # prueba: alterna fondos v002 (ChatGPT) y v001
		_set_fondos_v002(not _fondos_v002_on)
		get_viewport().set_input_as_handled()
		return
	if not _shortcuts_on():
		return
	var n := k.keycode - KEY_0
	if n < 0 or n > 6:
		return
	# cada atajo arma la partida que necesita y vuelve a cargar el nivel
	Inventario.reiniciar()
	if n >= 3:
		Inventario.pincel = true
		Inventario.progreso["n1_sombras"] = true
		Inventario.progreso["n1_trazo_x"] = BRUSH_X + 650.0
	if n >= 4:
		Inventario.tintero = true
	if n >= 5:
		Inventario.tinta = Inventario.TINTA_MAX
	if n == 5:
		Inventario.progreso["n1_pozo"] = true
	Inventario.guardar()
	Inventario.atajo = n
	get_tree().reload_current_scene()


func _apply_shortcut(n: int) -> void:
	var names := ["desde el principio (partida borrada)", "antes del hueco, corriendo", "junto al pincel",
		"sin sombras, antes de las plataformas", "en la cascada (cueva) con la paleta vacía",
		"en el arco con la paleta llena", "bajo el pozo con tinta, listo para romper la tapa"]
	match n:
		1:
			walker.position = Vector2(GAP.x - 700.0, GROUND_Y)
			_huir()
			shadow_x = walker.position.x - 430.0
			_shadow_speed = STAGES[2][2]
		2:
			walker.position = Vector2(BRUSH_X - 40.0, HIGH_Y)
			_huir()
			walker.can_jump = true
			shadow_x = BRUSH_X - 700.0
			_shadow_speed = 320.0
		3:
			walker.position = Vector2(STEP_X.x - 350.0, HIGH_Y)
		4:
			walker.position = Vector2(FALL_X + 120.0, CAVE_Y)
		5:
			walker.position = Vector2(EXIT_X - 160.0, HIGH_Y)
		6:
			walker.position = Vector2(WELL_X, CAVE_Y)
	print("[nivel1] atajo %d: %s" % [n, names[n]])
	_show_hint("Atajo %d: %s" % [n, names[n]], 2.5)


# --- terreno y decoración -------------------------------------------------------------------------

func _build_ground() -> void:
	# antes del hueco: suelo bajo; después, suelo alto con el pozo, el foso y la boca de la cueva
	_ground_strip(-160.0, GAP.x, GROUND_Y)
	_solid(Rect2(-200, GROUND_Y, GAP.x + 200, 400))
	for seg in [Vector2(GAP.y, WELL_X - WELL_HALF), Vector2(WELL_X + WELL_HALF, PIT.x), Vector2(PIT.y, HOLE.x), Vector2(HOLE.y, WIDTH + 200.0)]:
		_ground_strip(seg.x, seg.y, HIGH_Y)
		_solid(Rect2(seg.x, HIGH_Y, seg.y - seg.x, CAVE_TOP - HIGH_Y))
	_ground_strip(WELL_X - WELL_HALF, WELL_X + WELL_HALF, HIGH_Y)    # la losa del pozo, a lápiz
	_lid = _solid(Rect2(WELL_X - WELL_HALF, HIGH_Y, WELL_HALF * 2.0, 30))
	_solid(Rect2(GAP.y, CAVE_TOP, CAVE_X.x - GAP.y, 1000))          # roca maciza a la izquierda de la cueva
	_solid(Rect2(PIT.x, PIT_FLOOR, PIT.y - PIT.x, CAVE_TOP - PIT_FLOOR))
	_solid(Rect2(-240, GROUND_Y - 1200, 240, 1200))                  # bordes del mundo
	_solid(Rect2(WIDTH, GROUND_Y - 1200, 240, 2600))
	# pared de la plataforma alta y piedras en el borde del hueco
	var wb: Array = _metrics.wall.bounds
	_v1(_place("wall", Vector2(GAP.y + 30, GROUND_Y + 40), 170.0 / float(wb[3]), -9)).modulate.a = 0.8
	_place("stones", Vector2(GAP.x - 20, GROUND_Y + 8), 0.7, -8)
	_place("stones", Vector2(GAP.y + 40, HIGH_Y + 8), 0.6, -8)
	# escalón flotante y meseta: sin el escalón la meseta es demasiado alta para un salto
	_platform(Rect2(STEP_X.x, STEP_Y, STEP_X.y - STEP_X.x, 16), "platform_short")
	var plateau_top := PLATEAU_Y
	_ground_strip(PLATEAU.x, PLATEAU.y, plateau_top, false)
	_solid(Rect2(PLATEAU.x, plateau_top, PLATEAU.y - PLATEAU.x, HIGH_Y - plateau_top))
	for side in [PLATEAU.x + 20.0, PLATEAU.y - 20.0]:
		_v1(_place("wall", Vector2(side, HIGH_Y + 30), (HIGH_Y - PLATEAU_Y + 30.0) / float(wb[3]), -9)).modulate.a = 0.8
	# cueva: suelo, cámara honda con el tintero (se sale por una repisa) y paredes
	_ground_strip(CAVE_X.x, CHAMBER.x, CAVE_Y)
	_ground_strip(CHAMBER.x, CHAMBER.y, CHAMBER_Y)
	_ground_strip(CHAMBER.y, CAVE_X.y, CAVE_Y)
	_solid(Rect2(CAVE_X.x, CAVE_Y, CHAMBER.x - CAVE_X.x, 600))
	_solid(Rect2(CHAMBER.x, CHAMBER_Y, CHAMBER.y - CHAMBER.x, 400))
	_solid(Rect2(CHAMBER.y, CAVE_Y, CAVE_X.y - CHAMBER.y, 600))
	_solid(Rect2(CAVE_X.x - 400, CAVE_TOP, 400, 1200))
	_solid(Rect2(CAVE_X.y, CAVE_TOP, 400, 1200))
	# tiro del pozo: repisas para subir saltando desde la cueva; arriba lo cierra la losa (_lid) hasta romperla
	for i in WELL_LEDGES.size():
		var y: float = WELL_LEDGES[i]
		var x0 := WELL_X - 80.0 + (30.0 if i % 2 == 0 else -30.0)
		_platform(Rect2(x0, y, 160, 16), "platform_long")
	_build_piezas_v002()
	# subsuelo, pared de la cueva y roca sobre el tiro del pozo: mosaicos 12-14 (v001: relleno y rayas)
	_back_node = _nodo_tierra(-45, _draw_cave_back)    # delante del panorama: tapa sus bordes en los huecos
	_rock_node = _nodo_tierra(-3, _draw_rock)           # tapa el chorro de la cascada por encima del techo de la cueva
	# roca sobre el tiro del pozo: desde arriba no se ve el camino de abajo; se aparta al bajar a la cueva
	_tapa_roca = _nodo_tierra(2, _draw_tapa_roca)
	_terrain = Node2D.new()
	_terrain.z_index = -2
	_terrain.draw.connect(_draw_terrain)
	add_child(_terrain)


## Estructuras de ChatGPT (hojas 05-08) que no son tiras de suelo ni repisas: bordes de huecos, meseta,
## pozo, espinas, techo de la cueva, paso de la cueva, columna, árboles y matas. Las colisiones no cambian.
func _build_piezas_v002() -> void:
	# bordes de roca: el que tiene la cornisa a la derecha cierra un hueco por la izquierda, y al revés
	for e in [[GAP.x, GROUND_Y, GAP.y, HIGH_Y, 380.0], [PIT.x, HIGH_Y, PIT.y, HIGH_Y, 280.0], [HOLE.x, HIGH_Y, HOLE.y, HIGH_Y, 240.0]]:
		_pieza(T08, 1, (e[0] as float) - (e[4] as float) + 8.0, e[1] as float, e[4] as float, -1)
		_pieza(T08, 2, (e[2] as float) - 8.0, e[3] as float, e[4] as float, -1)
	# meseta: acantilado con cornisa, estirado en vertical para que su base llegue al suelo alto
	# la pisada de piezas.json (fila 56) es la cornisa de la derecha; la superficie donde camina el lobo baja
	# hacia la izquierda (fila ~76): con 56 el lobo flotaba sobre la roca
	var rm: Array = (_piezas[T05][0] as Array).duplicate()
	rm[4] = MESETA_PISADA
	_piezas[T05][0] = rm
	var alto_meseta := (HIGH_Y + 24.0 - PLATEAU_Y - 4.0) * float(rm[3]) / (float(rm[3]) - float(rm[4]))
	# la superficie pisable de la pieza va de la columna ~100 a la ~600: se estira para cubrir todo el piso
	var fx_meseta := (PLATEAU.y - PLATEAU.x) / 500.0
	_pieza(T05, 0, PLATEAU.x - 100.0 * fx_meseta, PLATEAU_Y + 4.0, float(rm[2]) * fx_meseta, -1, alto_meseta)
	# espinas del foso
	_pieza_pie(T08, 0, (PIT.x + PIT.y) * 0.5, PIT_FLOOR + 4.0, PIT.y - PIT.x + 10.0, -1, SPIKE_H + 24.0)
	# pozo: brocal (detrás del lobo), losa caída, tiro y tapa vista desde abajo
	_pozo_v2.cerrado = _pieza_pie(T07, 0, WELL_X, HIGH_Y + 14.0, WELL_HALF * 2.0 + 30.0, -11)
	_pozo_v2.abierto = _pieza_pie(T07, 1, WELL_X, HIGH_Y + 14.0, WELL_HALF * 2.0 + 30.0, -11)
	_pozo_v2.losa = _pieza_pie(T07, 2, WELL_X + WELL_HALF + 110.0, HIGH_Y + 6.0, 170.0, -9)
	_pozo_v2.tapa = _pieza_pie(T07, 5, WELL_X, PLUG.end.y + 30.0, PLUG.size.x + 30.0, -1)   # losa vista desde abajo
	var tiro: Node2D = _pieza(T07, 3, WELL_X - WELL_HALF + 6.0, HIGH_Y + 20.0, WELL_HALF * 2.0 - 12.0, -44, CAVE_TOP - HIGH_Y)
	tiro.modulate.a = 0.55
	_update_pozo_v2()
	# techo de la cueva con estalactitas, salvo bajo el pozo y la boca
	for seg in [Vector2(CAVE_X.x - 40.0, WELL_X - WELL_HALF), Vector2(WELL_X + WELL_HALF, HOLE.x), Vector2(HOLE.y, CAVE_X.y + 40.0)]:
		_tira_v2(T06, [1, 0], seg.x, seg.y, CAVE_TOP - 6.0, 0.42, -2)
	# paso hacia la Zona de enemigos (junto a la cascada) y columna como pared derecha de la cueva
	_pieza_pie(T06, 5, CAVE_X.x + 10.0, CAVE_Y + 8.0, 600.0, -1, 0.0, true)   # en espejo, del alto de la cueva
	_pieza_pie(T06, 6, CAVE_X.y + 30.0, CAVE_Y + 8.0, 260.0, -1, CAVE_Y - CAVE_TOP + 20.0)   # pared derecha
	# árboles y matas (sin óleo todavía: la pincelada solo revela color en juncos y piedras)
	for e in [[7, 760.0, 430.0], [9, 1900.0, 380.0], [7, 2900.0, 400.0], [9, 5100.0, 340.0],
			[7, 6450.0, 360.0], [9, 8100.0, 360.0], [7, 9300.0, 420.0]]:
		_pieza_pie(T05, e[0] as int, e[1] as float, _ground_at(e[1] as float) + PIE_HUNDIDO, e[2] as float, -18)
	for j in 14:
		var x := 620.0 + j * 690.0
		if absf(x - GAP.x) < 260.0 or absf(x - WELL_X) < 260.0 or absf(x - PIT.x) < 300.0 or absf(x - HOLE.x) < 300.0 \
				or (x > PLATEAU.x - 60.0 and x < PLATEAU.y + 60.0):
			continue
		var i: int = [10, 11, 12, 5, 6][j % 5]
		_pieza_pie(T05, i, x, _ground_at(x) + PIE_HUNDIDO, 110.0 if i >= 10 else 70.0, -12)


## Altura del suelo en x por arriba (lo que pisa el lobo antes de bajar a la cueva).
func _ground_at(x: float) -> float:
	if x < GAP.y:
		return GROUND_Y
	if x >= PLATEAU.x and x <= PLATEAU.y:
		return PLATEAU_Y
	return HIGH_Y


## Suelo para las manos de las sombras: NAN sobre el hueco (ahí se hunden).
func _hand_ground(x: float) -> float:
	if x > GAP.x - 10.0 and x < GAP.y + 10.0:
		return NAN
	return _ground_at(x)


## Repisa de un solo sentido (se atraviesa de abajo hacia arriba), con un módulo a lápiz encima.
func _platform(r: Rect2, art: String) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	cs.one_way_collision = true
	cs.position = r.get_center()
	body.add_child(cs)
	add_child(body)
	var b: Array = _metrics[art].bounds
	var f := r.size.x / float(b[2])
	var s := _sprite(art, -9)
	s.scale = Vector2.ONE * f
	s.position = Vector2(r.position.x - float(b[0]) * f, r.position.y - float(b[1]) * f - 6.0)
	_v1(s)
	if art == "platform_short":
		_pieza(T05, 3, r.position.x - 12.0, r.position.y + 4.0, r.size.x + 24.0, -9)   # piedra flotante
	elif art == "platform_long":
		_pieza(T07, 4, r.position.x - 12.0, r.position.y + 4.0, r.size.x + 24.0, -9)   # repisa del pozo


## Tira de suelo a lápiz entre x0 y x1 a la altura y (sin colisión: va aparte).
func _ground_strip(x0: float, x1: float, ground: float, v2 := true) -> void:
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
		_v1(s)
		x += maxf(60.0, float(b[2]) * f - 30.0)
		i += 1
	if not v2:
		return
	if ground >= CAVE_TOP:
		_tira_v2(T06, [3, 2, 4], x0, x1, ground + 4.0, 0.55, -10)    # pisos de cueva
	else:
		_tira_v2(T05, [4], x0, x1, ground + 4.0, LOSA_ESCALA, -10)   # losa larga


func _solid(r: Rect2) -> StaticBody2D:
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
	return body


func _build_decor() -> void:
	# self_modulate: el grafito se atenúa, pero el óleo de debajo (hijo) conserva su color al pintarse
	for e in [["tree_left", 760.0, 2.4], ["tree_right", 1900.0, 2.8], ["tree_left", 2900.0, 2.6], ["tree_right", 5100.0, 2.6],
			["tree_left", 6450.0, 2.2], ["tree_right", 8100.0, 2.4], ["tree_left", 9300.0, 2.6]]:
		_v1(_place(e[0], Vector2(e[1], _ground_at(e[1]) + 4), e[2], -18)).self_modulate.a = 0.38
	var skip := [Vector2(GAP.x - 120, GAP.y + 120), Vector2(EXIT_X - 200, WELL_X + WELL_HALF + 60),
		Vector2(STEP_X.x - 60, PLATEAU.y + 60), Vector2(PIT.x - 80, PIT.y + 80), Vector2(HOLE.x - 80, HOLE.y + 80)]
	for j in 29:
		var x := 420.0 + j * 330.0
		if skip.any(func(r: Vector2) -> bool: return x > r.x and x < r.y):
			continue
		_place("reeds" if j % 2 == 0 else "stones", Vector2(x, _ground_at(x) + 5), 0.55, -8).self_modulate.a = 0.6
	# piedras en la cueva
	for x in [5600.0, 6550.0, 7900.0, 8300.0]:
		_place("stones", Vector2(x, CAVE_Y + 6), 0.6, -8).self_modulate.a = 0.7
	_place("pedestal", Vector2(BRUSH_X, HIGH_Y + 5), 0.6, -8)
	# puerta: boceto gris apagado; encima, su versión entintada (gate_tinta, mismo lienzo), oculta hasta que se pinta
	# v003: la puerta es el marco con la pintura (16_marco_pintura): boceto blanco y, al pintarlo, el marco
	# definido con el lienzo a color; detrás, un halo con su misma silueta
	var fm := MARCO_ALTO / 768.0
	var esq := Vector2(EXIT_X - 256.0 * fm, HIGH_Y + 8.0 - MARCO_ALTO)
	_gate_sketch = _sprite("gate", -18)
	_gate_sketch.texture = _tex_v3("boceto", "16_marco_camino")
	_gate_sketch.scale = Vector2.ONE * fm
	_gate_sketch.position = esq
	_gate_glow = _sprite("gate", -19)
	_gate_glow.texture = _tex_v3("definido", "16_marco_camino")
	_gate_glow.scale = Vector2.ONE * fm * 1.08
	_gate_glow.position = esq - Vector2(256.0, 384.0) * fm * 0.08
	_gate_glow.modulate = Color(1.6, 1.35, 0.9, 0.0)
	_gate_paint = _sprite("gate", -17)
	_gate_paint.texture = _tex_v3("definido", "16_marco_camino")
	_gate_paint.scale = Vector2.ONE * fm
	_gate_paint.position = esq
	_gate_paint.region_enabled = true
	_gate_paint.visible = false


## Pieza de la cueva de la paleta (boceto y definido) apoyada por su base: esquina izquierda de abajo en «pie».
func _cueva_paleta(hoja: String, box: Array, pie: Vector2, ancho: float, z: int, alto := 0.0) -> void:
	var r := Rect2(box[0], box[1], box[2] - box[0], box[3] - box[1])
	var f := ancho / r.size.x
	var fy := alto / r.size.y if alto > 0.0 else f
	for k in 2:
		var sp := Sprite2D.new()
		sp.texture = _tex_v3(["boceto", "definido"][k], "cueva_paleta/" + hoja)
		sp.region_enabled = true
		sp.region_rect = r
		sp.centered = false
		sp.scale = Vector2(f, fy)
		sp.position = pie - Vector2(0, r.size.y * fy)
		sp.z_index = z
		sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sp.material = _mats_dibujo[k]
		add_child(sp)
		_v2(sp)


## Arte de color de Codex: pincel en la luz, la paleta en la cueva y la cascada de tinta con su lago.
func _build_color_props() -> void:
	_brush_pickup = _color_sprite("Objects/brush_pickup.png", -6)
	_brush_pickup.centered = true
	_brush_pickup.scale = Vector2.ONE * 0.42
	# altar (en la cámara honda de la cueva): el mismo pedestal a lápiz que el del pincel; encima, el tintero vacío,
	# aclarado para que se lea transparente (pie del frasco en y=236 de su celda)
	# cueva de la paleta (fondos_unificados_v001/cueva_paleta): fondo de la cámara, arco y altar; la paleta encima
	# la cámara es plana: el fondo la cubre toda, del techo al suelo; techo con raíces, arco de entrada a la
	# izquierda y el arco grande con el altar
	_cueva_paleta("02_fondo", [32, 81, 1750, 771], Vector2(CHAMBER.x - 70.0, CHAMBER_Y + 30.0), CHAMBER.y - CHAMBER.x + 140.0, -44, CHAMBER_Y + 30.0 - CAVE_TOP + 40.0)
	_cueva_paleta("03_modulos", [10, 10, 990, 320], Vector2(CHAMBER.x - 40.0, CAVE_TOP + 200.0), CHAMBER.y - CHAMBER.x + 80.0, -43)
	_cueva_paleta("03_modulos", [60, 500, 370, 862], Vector2(CHAMBER.x + 10.0, CHAMBER_Y + 8.0), 230.0, -43)
	_cueva_paleta("03_modulos", [480, 430, 979, 861], Vector2(ALTAR_X - 165.0, CHAMBER_Y + 8.0), 330.0, -43)
	_cueva_paleta("03_modulos", [1453, 653, 1723, 851], Vector2(CHAMBER.x + 300.0, CHAMBER_Y + 8.0), 120.0, -9)
	_cueva_paleta("03_modulos", [1062, 703, 1280, 853], Vector2(ALTAR_X - 90.0, CHAMBER_Y + 8.0), 180.0, -8)
	var top := CHAMBER_Y + 8.0 - 150.0 * 180.0 / 218.0       # cara de arriba del altar
	_inkwell = Sprite2D.new()
	_inkwell.texture = _tex_v3("definido", "cueva_paleta/04_paleta")
	_inkwell.region_enabled = true
	_inkwell.region_rect = Rect2(84, 187, 1069, 835)
	_inkwell.centered = false
	_inkwell.scale = Vector2.ONE * 130.0 / 1069.0
	_inkwell.rotation = -0.18
	_inkwell.position = Vector2(ALTAR_X - 70.0, top - 835.0 * 130.0 / 1069.0 + 30.0)
	_inkwell.z_index = -7
	add_child(_inkwell)
	# cascada: chorro 160x720 en (112,0) y charco 384x128 en (0,676) de un lienzo 384x804; el agua del
	# charco (y≈100 de su celda) queda a ras del suelo de la cueva; la roca tapa lo que sobra arriba
	var origin := Vector2(FALL_X - 192.0, CAVE_Y + 8.0 - 776.0)
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
	layer.z_index = -25                    # detrás del arco, los árboles y el suelo: colorea el fondo
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
	for i in Player.MAX_VIDA:
		var d := ColorRect.new()
		d.size = Vector2(13, 13)
		d.pivot_offset = d.size * 0.5
		d.rotation = PI / 4.0
		d.position = Vector2(1180 - i * 26, 24)
		ui.add_child(d)
		_life.append(d)


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
		icon.atlas = _tex_v3("definido", "cueva_paleta/04_paleta")
		icon.region = Rect2(84, 187, 1069, 835)
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
				print("[nivel1] %.1f s: tramo %d (sombras %d px/s)" % [_t, i, st[2]])
	if not _huye and (_sombras.hands_spawned > 0 or has_brush or shadows_gone):
		_huir()
	walker.max_speed = RUN_SPEED if _huye else STAGES[0][1]

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

	_check_pogo()
	if x < GAP.y + 60.0 and walker.position.y > GROUND_Y + 450.0:
		_hazard("cayó al hueco")
	elif x > PIT.x and x < PIT.y and walker.position.y > PIT_FLOOR - SPIKE_H and walker.position.y < CAVE_TOP:
		_hazard("cayó en las espinas")
	elif walker.position.y > CHAMBER_Y + 400.0:
		_hazard("cayó fuera del mundo")
	if shadows_gone and x > PIT.x - 400.0 and x < PIT.x and absf(walker.position.y - HIGH_Y) < 8.0:
		_checkpoint = Vector2(PIT.x - 120.0, HIGH_Y)
	# si cruza la mitad del arco sin haber dado la pincelada, las sombras lo alcanzan
	if has_brush and brush == "color" and barrier_x == -INF and not _acting and not _busy and x > EXIT_X:
		shadow_x = x
		_caught("cruzó el arco sin dar la pincelada")
		_show_hint("Las sombras te alcanzaron: da la pincelada (F) antes de llegar al arco", 4.0)
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
		elif _at_well:
			if Inventario.gastar(Inventario.COSTO_TRAZO):
				_strike_well()
			else:
				_show_hint("El pincel está seco: hace falta tinta para romper la tapa", 2.0)
		elif _at_gate and not gate_open and _gate_k == 0.0:
			if Inventario.gastar(Inventario.COSTO_PUERTA):
				_paint_gate()
			else:
				_show_hint("No hay tinta suficiente", 1.5)
		elif brush == "seco":
			_show_hint("El pincel está seco" if Inventario.tinta <= 0.0 else "Aquí no hay nada que pintar", 1.2)
	_update_gate_paint()
	_update_dibujo()
	_update_tapa_roca(delta)
	if _mask_dirty:
		_mask_dirty = false
		_mask_tex.update(_mask_img)

	_update_debris(delta)
	_update_camera(delta)
	_update_exits()
	_check_exit()
	queue_redraw()
	_terrain.queue_redraw()


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
			_sombras.recoil()
			_shadow_alpha = maxf(0.0, _shadow_alpha - delta / 2.5)
			if _shadow_alpha <= 0.0:
				shadows_gone = true
				_sombras.set_front(-INF, 0.0)
				_vignette.modulate.a = 0.0
				Inventario.progreso["n1_trazo_x"] = barrier_x
				Inventario.marcar("n1_sombras")
				walker.can_jump = true
				_show_hint("Las sombras se quedaron atrás… pero el pincel quedó seco", 4.0)
				return
	var near := walker.position.x - shadow_x
	_vignette.modulate.a = clampf(1.0 - (near - 120.0) / 650.0, 0.0, 1.0) * _shadow_alpha
	_sombras.set_front(shadow_x, _shadow_alpha)
	_sombras.hands_on = barrier_x == -INF and not _busy and not _acting
	_sombras.hand_every = [Vector2(1.4, 2.2), Vector2(0.9, 1.5), Vector2(0.6, 1.1)][_stage]
	_sombras.chase_speed = walker.max_speed * 0.9      # casi tan rápidas como él: si se detiene, lo alcanzan
	var grabbed := _sombras.update_hands(delta, walker.position, shadow_x, _hand_ground)
	if grabbed and not _busy and walker.hurt(walker.position.x - 60.0):
		print("[nivel1] %.1f s: lo golpeó una mano (vida %d)" % [_t, walker.vida])
	if near < 30.0 and not _busy:
		_caught("lo alcanzaron las sombras")


## Desde la primera mano (o con el pincel) el lobo corre de una vez y ya no vuelve a la caminata tímida.
func _huir() -> void:
	_huye = true
	walker.max_speed = RUN_SPEED
	walker.lobo.solo_correr = true
	print("[nivel1] %.1f s: sale la primera mano: corre" % _t)


## Caída al hueco o a las espinas: pierde una vida y reaparece en el último punto seguro (sin recuperarla).
func _hazard(why: String) -> void:
	if _busy:
		return
	walker.hurt(walker.position.x)
	if walker.is_dead():
		return                             # la animación de muerte termina en _caught (died)
	_caught(why, false)


## Lo alcanzaron (o murió): fundido y vuelta al punto de control. revive=true devuelve la vida completa.
func _caught(why: String, revive := true) -> void:
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
	walker.reset_physics_interpolation()   # sin esto se ve un barrido de un cuadro
	walker.max_speed = RUN_SPEED if _huye else STAGES[0][1]
	if revive or walker.is_dead():
		walker.revive()
	_update_life_ui()
	if shadow_x != -INF:
		shadow_x = _checkpoint.x - (STAGES[_stage][3] as float) - 150.0
		_shadow_speed = 0.0
	_sombras.clear_hands()
	_cam.reset_smoothing()
	tw = create_tween()
	tw.tween_property(_fade, "color:a", 0.0, 0.6)
	await tw.finished
	walker.enabled = true
	_busy = false


## Con el pincel llegan el tajo (J), el dash (Shift) y la pared (deslizarse y saltar desde ella).
func _unlock_abilities() -> void:
	walker.can_attack = true
	walker.can_dash = true
	walker.can_wall = true


## Cuadros de golpe de un tajo: con tinta en el pincel deshace las manos que toque (gasta tinta por mano);
## la estocada hacia abajo rebota en las manos y en las espinas.
func _on_attack_hit(anim: StringName, area: Rect2) -> void:
	var bounced := false
	if Inventario.tinta >= Inventario.COSTO_GOLPE:
		var n := _sombras.hit_hands(area)
		if n > 0:
			Inventario.gastar(Inventario.COSTO_GOLPE * n)
			_update_inventory_ui()
			print("[nivel1] %.1f s: el pincel deshizo %d mano(s) (tinta %d)" % [_t, n, Inventario.tinta])
			bounced = true
			walker.golpe_conectado(area.get_center(), n > 1)
	var spikes := Rect2(PIT.x, PIT_FLOOR - SPIKE_H, PIT.y - PIT.x, SPIKE_H + 10.0)
	if area.intersects(spikes):
		bounced = true
	if anim == &"slash_down" and bounced:
		walker.pogo()


## Rebote sobre las espinas: se revisa en cada cuadro de física (antes de la caída), con la estocada hacia
## abajo alargada 60 px y desde su primer cuadro, para que el pogo sea generoso como en los metroidvania de acción.
func _check_pogo() -> void:
	var lobo := walker.lobo
	if not lobo.attacking or lobo.sprite.animation != &"slash_down" or walker.velocity.y <= 0.0:
		return
	var f := maxi(2, lobo.sprite.frame + 1)        # el cuadro 1 (preparación) ya cuenta, como el 2
	if f > 4:
		return
	var hb := lobo.hitbox_global(&"slash_down", f).grow_side(SIDE_BOTTOM, 60.0)
	if hb.intersects(Rect2(PIT.x, PIT_FLOOR - SPIKE_H, PIT.y - PIT.x, SPIKE_H + 10.0)):
		walker.pogo()
		print("[nivel1] %.1f s: rebota sobre las espinas" % _t)


## Vida: rombos arriba a la izquierda, bajo el pincel y el tintero.
func _update_life_ui() -> void:
	for i in _life.size():
		_life[i].color = Color(0.96, 0.92, 0.82) if i < walker.vida else Color(0.96, 0.92, 0.82, 0.18)


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
	_unlock_abilities()
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
				if _action_target == "well":
					_open_well(true)
				else:
					_reveal_gate()
		&"dip":
			if frame == 4:
				_splash.position = Vector2(tip.x, CAVE_Y + 4.0) - Vector2(64, 112)
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
	_sombras.dissolve_hands()              # al girarse con el pincel, las manos retroceden
	_start_action(&"paint_rise", -1.0)


## Pincelada de color: una estocada diagonal (~60°) sobre el fondo, del suelo delante del lobo (que mira
## a las sombras) hacia arriba y atrás, por donde sube la punta de la varita en paint_rise (cuadros 4–6).
## No es un muro: es color sobre el lienzo, y las sombras no lo cruzan. barrier_x es el pie del trazo.
func _start_stroke(tip: Vector2) -> void:
	barrier_x = tip.x
	_sombras.dissolve_hands()
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


## Avisos al llegar a la puerta, al altar, al lago o al pozo (solo una vez por visita).
func _update_places(x: float) -> void:
	var y := walker.position.y
	var floor_ok := walker.is_on_floor()
	var at_gate := absf(x - EXIT_X) < 170.0 and absf(y - HIGH_Y) < 20.0 and shadows_gone and not gate_open
	if at_gate and not _at_gate:
		if Inventario.tinta >= Inventario.COSTO_PUERTA:
			_show_hint("F: pintar la puerta con tinta")
		else:
			_show_hint("La puerta es solo un boceto. Hace falta tinta para pintarla…", 3.5)
	_at_gate = at_gate
	var at_altar := absf(x - ALTAR_X) < 110.0 and absf(y - CHAMBER_Y) < 20.0 and has_brush and not Inventario.tintero
	if at_altar and not _at_altar:
		_show_hint("Una paleta sobre el altar.  F: tomarla")
	_at_altar = at_altar
	var at_lake := absf(x - FALL_X) < LAKE_R and absf(y - CAVE_Y) < 20.0 and Inventario.tintero
	if at_lake and not _at_lake and Inventario.tinta < Inventario.TINTA_MAX:
		_show_hint("El lago de tinta.  F: cargar la paleta")
	_at_lake = at_lake
	# bajo la losa del pozo (repisa más alta del tiro): con tinta en el pincel se rompe de un golpe
	var at_well := not well_open and absf(x - WELL_X) < 100.0 and absf(y - WELL_LEDGES[3]) < 12.0 and floor_ok
	if at_well and not _at_well:
		if Inventario.tinta >= Inventario.COSTO_TRAZO:
			_show_hint("Una losa de piedra cierra el pozo.  F: golpearla con el pincel")
		else:
			_show_hint("Una losa de piedra cierra el pozo… con tinta en el pincel podrías romperla", 3.5)
	_at_well = at_well
	var over_well := not well_open and absf(x - WELL_X) < WELL_HALF and absf(y - HIGH_Y) < 10.0 and shadows_gone
	if over_well and not _over_well:
		_show_hint("Un pozo tapado con una losa. Por arriba no se abre…", 3.0)
	_over_well = over_well


## Golpe hacia arriba con el pincel entintado (paint_up): en su cuadro 4 la tapa se rompe (_open_well).
func _strike_well() -> void:
	print("[nivel1] %.1f s: golpea la tapa del pozo (tinta restante %d)" % [_t, Inventario.tinta])
	_update_inventory_ui()
	_action_target = "well"
	_start_action(&"paint_up", walker.lobo.facing)


## Rompe la losa que cierra la boca del pozo (golpe desde la repisa más alta del tiro): se sale junto al arco.
## En su lugar queda una repisa de un solo sentido, para salir por arriba y volver a bajar.
func _open_well(effects: bool) -> void:
	if well_open:
		return
	well_open = true
	_update_pozo_v2()
	_lid.queue_free()
	_platform(Rect2(WELL_X - WELL_HALF, HIGH_Y, WELL_HALF * 2.0, 16), "bridge")
	if effects:
		for i in 14:
			_debris.append({"p": Vector2(WELL_X + randf_range(-100, 100), PLUG.position.y + randf_range(0, 20)),
				"v": Vector2(randf_range(-160, 160), randf_range(-260, 40)), "r": randf_range(4, 11)})
		Inventario.marcar("n1_pozo")
		print("[nivel1] %.1f s: se rompe la tapa del pozo" % _t)
		_show_hint("La losa se rompió: sal por el pozo", 3.0)


func _update_debris(delta: float) -> void:
	for d in _debris.duplicate():
		d.v.y += 1400.0 * delta
		d.p += d.v * delta
		if d.p.y > CAVE_Y:
			_debris.erase(d)


func _take_inkwell() -> void:
	Inventario.tintero = true
	Inventario.tinta = 0.0
	Inventario.guardar()
	_inkwell.visible = false
	print("[nivel1] %.1f s: toma el tintero (vacío)" % _t)
	_update_inventory_ui()
	_show_hint("Tomaste la paleta. Está vacía: cárgala en el lago de tinta, junto a la cascada", 4.0)


## Moja el pincel en el lago: la tinta entra en los cuadros 4–5 del dip (ver _on_action_frame).
func _fill_inkwell() -> void:
	if Inventario.tinta >= Inventario.TINTA_MAX:
		_show_hint("La paleta ya está cargada", 1.2)
		return
	_start_action(&"dip", signf(FALL_X - walker.position.x))


func _paint_gate() -> void:
	print("[nivel1] %.1f s: pinta la puerta (tinta restante %d)" % [_t, Inventario.tinta])
	_update_inventory_ui()
	_action_target = "gate"
	_start_action(&"paint_up", signf(EXIT_X - walker.position.x))


## La tinta sube por la puerta desde el pie del trazo (cuadro 4 de paint_up).
func _reveal_gate() -> void:
	_gate_paint.visible = true
	_dibujar_paisaje(true)
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
	var fm := MARCO_ALTO / 768.0
	var h := 768.0 * _gate_k
	_gate_paint.region_rect = Rect2(0, 768.0 - h, 512, h)
	_gate_paint.position = Vector2(EXIT_X - 256.0 * fm, HIGH_Y + 8.0 - h * fm)
	_gate_sketch.modulate.a = 1.0 - _gate_k
	_gate_glow.modulate.a = _gate_k * (0.35 + sin(_t * 3.0) * 0.1)


func _update_camera(delta: float) -> void:
	# mira hacia adelante cuando corre, para ver lo que viene
	var ahead := clampf(walker.velocity.x * 0.45, -60.0, 200.0)
	_cam_ahead = move_toward(_cam_ahead, ahead, 220.0 * delta)
	_cam.offset = Vector2(_cam_ahead, -70.0) + Efectos.temblor_ahora()


func _update_exits() -> void:
	# puertas (con E): al principio y el arco pintado llevan a la pintura; en la cueva, el taller del copista
	var p := walker.position
	var above := p.y < CAVE_TOP
	var found := ""
	var h := ""
	# (ya no hay puerta al principio: se llega cayendo; el taller del copista está en la Zona de enemigos)
	if above and gate_open and absf(p.x - EXIT_X) < 90.0:
		found = "camino"
		h = "E: entrar a la pintura"
	cur_exit = found
	var now_near := found != "" and _moved
	if now_near != near_exit or h != exit_hint:
		exit_hint = h
		near_exit = now_near
		near_exit_changed.emit(near_exit)
		if near_exit and exit_requested.get_connections().is_empty():
			_show_hint(h + "  (en el juego completo)")
	# pasos sin puerta hacia el resto de Camino: el extremo derecho y el fondo izquierdo de la cueva
	if above and p.x > WIDTH - 70.0:
		_leave("mundo:ca_sello")
	elif not above and p.x < CAVE_X.x + 50.0:
		_leave("mundo:ca_enemigos")


func _check_exit() -> void:
	if near_exit and not _busy and InputMap.has_action("interact") and Input.is_action_just_pressed("interact"):
		_leave(cur_exit)


func _leave(to: String) -> void:
	if _leaving or _busy or exit_requested.get_connections().is_empty():
		return
	_leaving = true
	Inventario.guardar()
	print("[nivel1] %.1f s: sale hacia «%s»" % [_t, to])
	exit_requested.emit(to)


## Sala del mapa en la que está el lobo (main.gd la marca como recorrida).
func map_room() -> String:
	return MapaDatos.nivel1_sala(walker.position)


func map_pos() -> Vector2:
	return MapaDatos.nivel1_mapa(walker.position)


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


## Roca maciza (corte del terreno a lápiz) entre el suelo alto y la cueva, y bajo el suelo de la cueva.
## Provisional hasta tener arte de cueva; se dibuja una sola vez.
## Rectángulos de roca: [rect, lleva orilla (13) arriba, y donde empieza la orilla del mosaico]. La roca bajo un
## suelo lleva orilla; la de abajo continúa el mosaico de la de arriba para que no se vea la unión.
func _rock_rects() -> Array:
	var band := HIGH_Y + 26.0
	var deep := CHAMBER_Y + 420.0
	var r: Array = []
	r.append([Rect2(-240.0, GROUND_Y + 26.0, GAP.x + 240.0, deep - GROUND_Y - 26.0), true, GROUND_Y + 26.0])   # bajo el inicio
	# franja entre el suelo alto y el techo de la cueva, con los huecos del pozo, el foso y la boca
	for seg in [Vector2(GAP.y, WELL_X - WELL_HALF), Vector2(WELL_X + WELL_HALF, PIT.x), Vector2(PIT.y, HOLE.x), Vector2(HOLE.y, WIDTH + 200.0)]:
		r.append([Rect2(seg.x, band, seg.y - seg.x, CAVE_TOP - band), true, band])
	r.append([Rect2(PIT.x, PIT_FLOOR, PIT.y - PIT.x, CAVE_TOP - PIT_FLOOR), true, PIT_FLOOR])
	r.append([Rect2(GAP.y, CAVE_TOP, CAVE_X.x - GAP.y, deep - CAVE_TOP), false, band])
	r.append([Rect2(CAVE_X.y, CAVE_TOP, WIDTH + 200.0 - CAVE_X.y, deep - CAVE_TOP), false, band])
	r.append([Rect2(CAVE_X.x, CAVE_Y + 26.0, CHAMBER.x - CAVE_X.x, deep - CAVE_Y), true, CAVE_Y + 26.0])
	r.append([Rect2(CHAMBER.x, CHAMBER_Y + 26.0, CHAMBER.y - CHAMBER.x, deep - CHAMBER_Y), true, CHAMBER_Y + 26.0])
	r.append([Rect2(CHAMBER.y, CAVE_Y + 26.0, CAVE_X.y - CHAMBER.y, deep - CAVE_Y), true, CAVE_Y + 26.0])
	return r


func _draw_rock(ci: CanvasItem, estado: String) -> void:
	for e in _rock_rects():
		var r: Rect2 = e[0]
		_rock_rect(ci, r, estado, e[1], e[2])
		if not _fondos_v002_on:
			ci.draw_line(r.position, Vector2(r.end.x, r.position.y), Color(0.30, 0.28, 0.26, 0.35), 1.5)
	# estalactitas en el techo de la cueva (v002: las pone el techo de ChatGPT)
	if _fondos_v002_on or estado == "boceto":
		return
	var x := CAVE_X.x + 90.0
	while x < CAVE_X.y - 60.0:
		if absf(x - WELL_X) > WELL_HALF + 30.0 and (x < HOLE.x - 40.0 or x > HOLE.y + 40.0):
			var h := 26.0 + fmod(x * 0.37, 38.0)
			var pts := PackedVector2Array([Vector2(x - 14, CAVE_TOP), Vector2(x + 14, CAVE_TOP), Vector2(x + 2, CAVE_TOP + h)])
			ci.draw_colored_polygon(pts, Color(0.84, 0.82, 0.78))   # estalactitas v001
			ci.draw_polyline(PackedVector2Array([pts[0], pts[2], pts[1]]), Color(0.30, 0.28, 0.26, 0.55), 1.5, true)
		x += 140.0 + fmod(x * 0.61, 90.0)


## Mosaico de una textura que se repite, alineado al mundo: x desde 0, y desde oy.
func _mosaico(ci: CanvasItem, tex: Texture2D, r: Rect2, esc: float, oy: float) -> void:
	if r.size.y <= 0.0 or r.size.x <= 0.0:
		return
	var src := Rect2(r.position.x / esc, (r.position.y - oy) / esc, r.size.x / esc, r.size.y / esc)
	ci.draw_texture_rect_region(tex, r, src, Color.WHITE, false, false)


## Las texturas que solo se usan al dibujar por código se guardan: si no, se liberan tras el dibujo y salen en blanco.
func _tex_v3(estado: String, nombre: String) -> Texture2D:
	var ruta := FONDOS + "/" + estado + "/" + nombre + ".png"
	if not _texturas.has(ruta):
		_texturas[ruta] = load(ruta)
	return _texturas[ruta]


## Nodo dibujado por código en dos estados: él mismo es el definido y su hijo «boceto» lo tapa hasta que pasa el
## frente de dibujo. Con F3 (v001) dibuja el relleno de antes con el material que solo aclara.
func _nodo_tierra(z: int, dibujar: Callable) -> Node2D:
	var n := Node2D.new()
	n.z_index = z
	n.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	n.set_meta("mat_v1", _mat_tierra())
	n.material = _mats_dibujo[1]
	n.draw.connect(dibujar.bind(n, "definido"))
	add_child(n)
	var b := Node2D.new()
	b.name = "boceto"
	b.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	b.material = _mats_dibujo[0]
	b.draw.connect(dibujar.bind(b, "boceto"))
	n.add_child(b)
	_nodos_tierra.append(n)
	return n


## Un rectángulo de roca: relleno y rayado de lápiz irregular (determinista, continuo entre rectángulos).
func _rock_rect(ci: CanvasItem, r: Rect2, estado := "definido", orilla := false, oy := 0.0) -> void:
	if _fondos_v002_on:                    # v003: subsuelo de ChatGPT, con su orilla bajo el suelo
		if orilla:
			_mosaico(ci, _tex_v3(estado, "13_subsuelo_borde"), Rect2(r.position.x, r.position.y, r.size.x, minf(SUB_BORDE, r.size.y)), SUB_ESC, r.position.y)
			var abajo := r.position.y + SUB_BORDE
			_mosaico(ci, _tex_v3(estado, "12_subsuelo"), Rect2(r.position.x, abajo, r.size.x, r.end.y - abajo), SUB_ESC, abajo)
		else:
			_mosaico(ci, _tex_v3(estado, "12_subsuelo"), r, SUB_ESC, oy + SUB_BORDE)
		return
	if estado == "boceto":
		return
	var fill := Color(0.84, 0.82, 0.78)
	var hatch := Color(0.42, 0.40, 0.37, 0.30)
	if _fondos_v002_on:                    # tono del relleno de las piezas de ChatGPT
		fill = Color(0.85, 0.79, 0.73)
		hatch = Color(0.45, 0.37, 0.30, 0.22)
	ci.draw_rect(r, fill)
	var y := r.position.y + 14.0
	while y < r.end.y - 6.0:
		var x := r.position.x + fmod(y * 7.3, 37.0)
		while x < r.end.x - 20.0:
			var n := sin(x * 0.013 + y * 0.071) * 0.5 + 0.5
			ci.draw_line(Vector2(x, y), Vector2(x + 14.0 + n * 10.0, y - 9.0 - n * 6.0), hatch, 1.2, true)
			x += 30.0 + n * 26.0
		y += 22.0


## Aire de la cueva, del tiro del pozo y de la boca: papel un poco más oscuro, detrás de todo.
func _draw_cave_back(ci: CanvasItem, estado: String) -> void:
	if _fondos_v002_on:                    # v003: pared de la cueva de ChatGPT (14), en mosaico
		var t := _tex_v3(estado, "14_cueva_pared")
		_mosaico(ci, t, Rect2(CAVE_X.x, CAVE_TOP, CAVE_X.y - CAVE_X.x, CHAMBER_Y + 40.0 - CAVE_TOP), SUB_ESC, 0.0)
		_mosaico(ci, t, Rect2(WELL_X - WELL_HALF, HIGH_Y, WELL_HALF * 2.0, CAVE_TOP - HIGH_Y), SUB_ESC, 0.0)
		_mosaico(ci, t, Rect2(HOLE.x, HIGH_Y, HOLE.y - HOLE.x, CAVE_TOP - HIGH_Y), SUB_ESC, 0.0)
		# fondo del hueco y del foso: sin esto se veían los bordes de abajo de las franjas del panorama
		_mosaico(ci, t, Rect2(GAP.x, GROUND_Y + 30.0, GAP.y - GAP.x, CHAMBER_Y + 420.0 - GROUND_Y), SUB_ESC, 0.0)
		_mosaico(ci, t, Rect2(PIT.x, HIGH_Y + 30.0, PIT.y - PIT.x, PIT_FLOOR - HIGH_Y), SUB_ESC, 0.0)
		return
	if estado == "boceto":
		return
	var air := Color(0.79, 0.74, 0.68) if _fondos_v002_on else Color(0.88, 0.86, 0.82)
	ci.draw_rect(Rect2(CAVE_X.x, CAVE_TOP, CAVE_X.y - CAVE_X.x, CHAMBER_Y + 40.0 - CAVE_TOP), air)
	ci.draw_rect(Rect2(WELL_X - WELL_HALF, HIGH_Y, WELL_HALF * 2.0, CAVE_TOP - HIGH_Y), air)
	ci.draw_rect(Rect2(HOLE.x, HIGH_Y, HOLE.y - HOLE.x, CAVE_TOP - HIGH_Y), air)


## Lo que cambia: el brocal y la losa del pozo, la tapa del fondo, sus trozos, y las espinas del foso.
func _draw_terrain() -> void:
	var line := Color(0.30, 0.28, 0.26, 0.85)
	var stone := Color(0.80, 0.78, 0.74)
	# puerta de vuelta a la pintura (marco de cuadro) y puerta del copista en la cueva (provisional)
	if not _fondos_v002_on:                # v003: el marco de ChatGPT (_marco_v3)
		var frame := Rect2(HOME_X - 60.0, GROUND_Y - 190.0, 120.0, 190.0)
		_terrain.draw_rect(frame, Color(0.55, 0.42, 0.28))
		_terrain.draw_rect(frame.grow(-14.0), Color(0.93, 0.89, 0.80))
		_terrain.draw_rect(frame, line, false, 2.0)
	if _fondos_v002_on:                    # pozo y espinas: piezas de ChatGPT
		for d in _debris:
			_terrain.draw_circle(d.p, d.r, Color(0.62, 0.55, 0.48))
		return
	# brocal del pozo (sobre el suelo alto)
	var l := WELL_X - WELL_HALF - 14.0
	var r := WELL_X + WELL_HALF + 14.0
	for side in [l, r - 22.0]:
		_terrain.draw_rect(Rect2(side, HIGH_Y - 46.0, 22.0, 48.0), stone)
		_terrain.draw_rect(Rect2(side, HIGH_Y - 46.0, 22.0, 48.0), line, false, 1.5)
	if not well_open:
		_terrain.draw_rect(Rect2(l - 6.0, HIGH_Y - 58.0, r - l + 12.0, 14.0), stone)            # losa
		_terrain.draw_rect(Rect2(l - 6.0, HIGH_Y - 58.0, r - l + 12.0, 14.0), line, false, 2.0)
		# tapa del fondo, vista desde la cueva
		_terrain.draw_rect(PLUG, Color(0.45, 0.43, 0.40))
		_terrain.draw_rect(PLUG, line, false, 2.0)
		for k in 3:
			var cx := PLUG.position.x + 50.0 + k * 60.0
			_terrain.draw_polyline(PackedVector2Array([Vector2(cx, PLUG.position.y + 2), Vector2(cx + 9, PLUG.position.y + 12), Vector2(cx + 2, PLUG.end.y - 2)]), line, 1.2)
	else:
		# losa caída en el suelo, junto al brocal
		_terrain.draw_set_transform(Vector2(r + 20.0, HIGH_Y - 9.0), 0.08, Vector2.ONE)
		_terrain.draw_rect(Rect2(0, -7, 150.0, 14.0), stone)
		_terrain.draw_rect(Rect2(0, -7, 150.0, 14.0), line, false, 2.0)
		_terrain.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for d in _debris:
		_terrain.draw_circle(d.p, d.r, Color(0.45, 0.43, 0.40))
	# espinas en el fondo del foso (provisional hasta tener arte)
	var x := PIT.x + 4.0
	while x < PIT.y - 10.0:
		var h := SPIKE_H - fmod(x * 0.37, 12.0)
		var tri := PackedVector2Array([Vector2(x, PIT_FLOOR + 2), Vector2(x + 22.0, PIT_FLOOR + 2), Vector2(x + 11.0, PIT_FLOOR - h)])
		_terrain.draw_colored_polygon(tri, Color(0.20, 0.19, 0.20))
		_terrain.draw_polyline(PackedVector2Array([tri[0], tri[2], tri[1]]), Color(0.08, 0.08, 0.09), 1.5, true)
		x += 24.0


## Fondos de ChatGPT: papel fijo detrás de todo, capas con parallax e hitos lejanos (cabeza y faro), cada uno
## en boceto y definido. Los de v001 (Environment) se quedan armados pero ocultos, para comparar con F3.
func _build_fondos_v002() -> void:
	for k in 4:                                  # 0 boceto, 1 definido, 2 boceto con bordes, 3 definido con bordes
		var m := ShaderMaterial.new()
		m.shader = load("res://zones/revelar_dibujo.gdshader")
		m.set_shader_parameter("invertir", k % 2 == 0)
		m.set_shader_parameter("borde", 0.12 if k >= 2 else 0.0)
		_mats_dibujo.append(m)
	var paper_layer := CanvasLayer.new()
	paper_layer.layer = -99
	add_child(paper_layer)
	for hoja in ["01_papel", "01_papel_boceto"]:     # papel cálido; encima, el blanco del boceto que se va
		var paper := TextureRect.new()
		paper.texture = load(FONDOS + "/" + hoja + ".png")
		paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		paper.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if hoja == "01_papel_boceto":
			paper.material = _mats_dibujo[0]
		paper_layer.add_child(paper)
		_fondos_v002.append(paper)
	_build_panorama_v003()
	for c in CAPAS_V002:
		var hito := false
		var bordes := true
		var tex := load(FONDOS + "/definido/" + (c[0] as String) + ".png") as Texture2D
		var f: float = ((c[4] as float) / tex.get_width()) if hito else ((c[4] as float) / tex.get_height())
		var par := Parallax2D.new()
		par.name = "v002_" + (c[0] as String)
		par.scroll_scale = Vector2(c[1] as float, 1.0)
		if not hito:
			par.repeat_size = Vector2(tex.get_width() * f, 0)
			par.repeat_times = 3
		par.z_index = c[2] as int
		add_child(par)
		for estado in ["boceto", "definido"]:
			var sp := Sprite2D.new()
			sp.texture = load(FONDOS + "/" + estado + "/" + (c[0] as String) + ".png")
			sp.centered = false
			sp.scale = Vector2.ONE * f
			sp.position = Vector2(c[5] as float, GROUND_Y + (c[6] as float)) if hito else Vector2(-150, GROUND_Y + (c[5] as float))
			sp.modulate.a = c[3] as float
			sp.flip_h = c[6] as bool
			sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			sp.material = _mats_dibujo[(0 if estado == "boceto" else 1) + (2 if bordes else 0)]
			par.add_child(sp)
		_fondos_v002.append(par)
	_set_fondos_v002(true)


## Panorama del montaje de ChatGPT: franjas que se repiten (horizonte, colinas, laderas, costa) y las partes de
## la pintura (cabeza, puentes, casa, faro), cada una en boceto y definido. Y el marco de la puerta del inicio.
func _build_panorama_v003() -> void:
	var e := MONTAJE_ESCALA
	var arriba := GROUND_Y + MONTAJE_ABAJO - 1000.0 * e
	for c in FRANJAS_V003 + HITOS_V003:
		var hito: bool = (c as Array).size() > 4
		var s: float = c[1]
		var par := Parallax2D.new()
		par.name = "v003_" + (c[0] as String)
		par.scroll_scale = Vector2(s, 1.0)
		par.z_index = c[2] as int
		var dx := MONTAJE_X + MONTAJE_CAM * (s - MONTAJE_REF)   # alineado con los hitos en MONTAJE_CAM
		if not hito:
			par.repeat_size = Vector2(3548.0 * e, 0)
			par.repeat_times = 3
		add_child(par)
		for k in 2:
			var sp := Sprite2D.new()
			sp.texture = _tex_v3(["boceto", "definido"][k], c[0] as String)
			sp.centered = false
			sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			sp.material = _mats_dibujo[k]
			if hito:
				var box: Array = c[6]
				sp.region_enabled = true
				sp.region_rect = Rect2(box[0], box[1], box[2] - box[0], box[3] - box[1])
				var f: float = (c[5] as float) / sp.region_rect.size.x
				sp.scale = Vector2.ONE * f
				# en una capa con parallax s, lo que está en x se ve al centro de la pantalla cuando la cámara está
				# en (x - 640 (1 - s)) / s: Parallax2D cuenta desde la esquina izquierda de la pantalla, no del centro
				sp.position = Vector2((c[3] as float) * s + 640.0 * (1.0 - s) - (c[5] as float) * 0.5, GROUND_Y + (c[4] as float) - sp.region_rect.size.y * f)
				sp.modulate.a = c[7] as float
			else:
				sp.scale = Vector2.ONE * e
				sp.position = Vector2(dx, arriba + (c[3] as float) * e)
			par.add_child(sp)
		_fondos_v002.append(par)

## Al pintar la puerta: el frente de dibujo sale de la puerta y cubre el paisaje (boceto -> definido).
func _dibujar_paisaje(efecto: bool) -> void:
	if not efecto:
		_dibujo_r = DIBUJO_FIN
		return
	var tw := create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(self, "_dibujo_r", DIBUJO_FIN, DIBUJO_DURA).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


## Material de la roca y el aire dibujados por código: blanco de boceto hasta que llega el frente de dibujo.
func _mat_tierra() -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = load("res://zones/revelar_dibujo.gdshader")
	m.set_shader_parameter("aclarar", true)
	m.set_shader_parameter("radio", _dibujo_r)
	_mats_dibujo.append(m)
	return m


## Pasa a los shaders dónde está la puerta en pantalla y cuánto ha avanzado el frente.
func _update_dibujo() -> void:
	if _mats_dibujo.is_empty():
		return
	var centro := get_viewport().get_canvas_transform() * Vector2(EXIT_X, HIGH_Y - 150.0)
	var r := _dibujo_r if _dibujo_r < DIBUJO_FIN else 100000.0
	for m in _mats_dibujo:
		m.set_shader_parameter("centro", centro)
		m.set_shader_parameter("radio", r)


func _set_fondos_v002(on: bool) -> void:
	_fondos_v002_on = on
	for n in _fondos_v002:
		n.visible = on
	for child in _env.get_children():
		if child is CanvasLayer:
			(child as CanvasLayer).visible = not on
		elif child is Parallax2D:
			(child as Parallax2D).visible = not on
	for n in _arte_v1:
		if is_instance_valid(n):
			n.visible = not on
	for n in _arte_v2:
		if is_instance_valid(n):
			n.visible = on
	_update_pozo_v2()
	for n in _nodos_tierra:
		n.material = _mats_dibujo[1] if on else n.get_meta("mat_v1")
		var b := n.get_node("boceto") as CanvasItem
		b.visible = on
		b.queue_redraw()
	for n in [_rock_node, _back_node, _terrain, _tapa_roca]:
		if n:
			n.queue_redraw()


## Registra arte de una sola versión: queda visible según la versión activa (F3).
func _v1(n: CanvasItem) -> CanvasItem:
	_arte_v1.append(n)
	n.visible = not _fondos_v002_on
	return n


func _v2(n: CanvasItem) -> CanvasItem:
	_arte_v2.append(n)
	n.visible = _fondos_v002_on
	return n


## Pieza i de una hoja de ChatGPT (región de la hoja original, sin recortar el PNG), escalada a «ancho».
## Se coloca con su borde izquierdo en x y su fila de pisada en pisada_y; «alto» > 0 la estira en vertical.
## Devuelve un nodo con dos sprites en el mismo lugar: boceto y definido (los cambia _update_dibujo).
func _pieza(hoja: String, i: int, x: float, pisada_y: float, ancho: float, z: int, alto := 0.0, espejo := false) -> Node2D:
	var r: Array = _piezas[hoja][i]
	var n := Node2D.new()
	n.z_index = z
	var fx := ancho / float(r[2])
	var fy := fx if alto <= 0.0 else alto / float(r[3])
	n.scale = Vector2(fx, fy)
	n.position = Vector2(x, pisada_y - float(r[4]) * fy)
	for k in 2:
		var at := AtlasTexture.new()
		at.atlas = load(FONDOS + "/" + ["boceto", "definido"][k] + "/" + hoja + ".png")
		at.region = Rect2(r[0], r[1], r[2], r[3])
		var sp := Sprite2D.new()
		sp.texture = at
		sp.centered = false
		sp.flip_h = espejo
		sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sp.material = _mats_dibujo[k]
		n.add_child(sp)
	add_child(n)
	_v2(n)
	return n


## Pieza apoyada por su base: centrada en cx, con el borde de abajo en base_y.
func _pieza_pie(hoja: String, i: int, cx: float, base_y: float, ancho: float, z: int, alto := 0.0, espejo := false) -> Node2D:
	var n := _pieza(hoja, i, cx - ancho * 0.5, 0.0, ancho, z, alto, espejo)
	var r: Array = _piezas[hoja][i]
	n.position.y = base_y - float(r[3]) * n.scale.y
	return n


## Repite piezas de una hoja entre x0 y x1 (se solapan un poco); la última se recorta para no pasarse.
func _tira_v2(hoja: String, ids: Array, x0: float, x1: float, pisada_y: float, f: float, z: int) -> void:
	var x := x0                            # sin pasarse: lo que asomaba al hueco se veía bajo el borde de roca
	var k := 0
	while x < x1 - 30.0:
		var i: int = ids[k % ids.size()]
		var r: Array = _piezas[hoja][i]
		var n := _pieza(hoja, i, x, pisada_y, float(r[2]) * f, z)
		var room := (x1 - x) / f
		if room < float(r[2]):
			for sp in n.get_children():
				((sp as Sprite2D).texture as AtlasTexture).region.size.x = room
		x += float(r[2]) * f - maxf(34.0, 110.0 * f)   # traslape: las puntas redondeadas no deben verse como uniones
		k += 1


## El pozo de ChatGPT: brocal cerrado o abierto, losa caída y tapa vista desde la cueva.
func _update_pozo_v2() -> void:
	if _pozo_v2.is_empty():
		return
	var on := _fondos_v002_on
	_pozo_v2.cerrado.visible = on and not well_open
	_pozo_v2.tapa.visible = on and not well_open
	_pozo_v2.abierto.visible = on and well_open
	_pozo_v2.losa.visible = on and well_open


## La roca sobre el tiro se ve mientras el lobo está arriba y se desvanece cuando baja (bajo el suelo alto).
func _update_tapa_roca(delta: float) -> void:
	var abajo := walker.position.y > HIGH_Y + 40.0 and walker.position.x > GAP.y
	_tapa_roca.modulate.a = move_toward(_tapa_roca.modulate.a, 0.0 if abajo else 1.0, delta * 3.0)
	_tapa_roca.visible = _tapa_roca.modulate.a > 0.0


func _draw_tapa_roca(ci: CanvasItem, estado: String) -> void:
	var r := Rect2(WELL_X - WELL_HALF - 2.0, HIGH_Y + 26.0, WELL_HALF * 2.0 + 4.0, CAVE_TOP - HIGH_Y - 26.0)
	_rock_rect(ci, r, estado, true, HIGH_Y + 26.0)


## Lleva al lobo al punto de una sala (Ñ / L en main.gd, para probar).
func ir_a_sala(id: String) -> void:
	if not ENTRADAS.has(id):
		return
	walker.position = ENTRADAS[id]
	walker.velocity = Vector2.ZERO
	walker.reset_physics_interpolation()   # sin esto se ve un barrido de un cuadro
	_checkpoint = walker.position
	_cam.reset_smoothing()


func track() -> int:
	return TRACK


func zone_title() -> String:
	return "Camino"
