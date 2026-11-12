class_name LoboSprite
extends Node2D
## Lobo con sprites (characters/lobo/pincel_v003). El origen del nodo queda en los pies; las hojas miran
## a la derecha. Interfaz: animate(delta, speed01, vel_x, air, vy).
## Capas, en orden de dibujo: pincel guardado (espalda), pincel en la mano, punta (color / dry / ink),
## estela del golpe (se tiñe con la carga) y cuerpo. Sin pincel (brush == "") solo se ve el cuerpo.
## Estados: reposo, caminata, carrera, salto (despegue, subida, caída, aterrizaje) y los especiales que pide
## Player (dash, wall_slide, wall_jump, hurt, death). Acciones del nivel con play_action (el lobo se
## detiene: paint_rise, paint_up, dip) y ataques con play_attack (se puede mover: combo attack_01..03,
## attack_up y slash_down, el tajo hacia abajo con rebote).

signal action_frame(anim: StringName, frame: int)   # frame empieza en 1, como en brush_contacts.json
signal action_finished(anim: StringName)
signal attack_frame(anim: StringName, frame: int)

const BASE_SCALE := 0.60          # tamaño en la zona de la pintura (scale = BASE_SCALE * profundidad)
const ART := "res://characters/lobo/pincel_v003"
## Carrera con el modelo de Wolf_Run_v014: reemplaza esa animación de
## pincel_v003. Sin pincel: el pincel solo aparece al usarlo (acciones y tajos).
## Carrera v027, aprobada por Emma (Game_Assets/MODELOS_LOBITO_APROBADOS.md): copia sin retoques de Wolf_Run_v027.
const RUN_ART := "res://characters/lobo/run_v027"
## Salto con el estilo del lobo original (Wolf_Salto_v004, copia directa).
const SALTO := "res://characters/lobo/salto_v004"
## El lobo del salto v004 está dibujado ~6.5 % más chico que el de la carrera v027 (masa del cuerpo 6122 contra
## 7080 px de celda; cola y bufanda en la misma proporción): se agranda desde los pies para que no cambie de
## tamaño al saltar. El arte no se toca.
const SALTO_ESCALA := 1.065
const SALTO_ANIMS: Array[StringName] = [&"jump_start", &"jump_up", &"jump_apex", &"fall", &"land"]
## Ataques del combo de Codex (Wolf_Combo_v001, poses clave pasadas a celdas de 384 con
## herramientas/ajustar_combo_v001.py): el pincel y la tinta vienen dibujados en el cuerpo.
const COMBO := "res://characters/lobo/combo_v001"
const ATTACKS: Array[StringName] = [&"attack_01", &"attack_02", &"attack_03"]   # corte ascendente, barrido, remate
const ATTACK_UP := &"attack_up"        # mismo corte ascendente, con la zona de golpe sobre la cabeza
const COMBO_FPS := 16.0
const COMBO_DX := 36.0                 # el cuerpo del combo está más atrás en su celda: se corre para no retroceder
## Zonas de golpe por cuadro (x, y, ancho, alto en px de celda), medidas del alcance del pincel y la tinta.
const COMBO_HITS := {
	&"attack_01": {2: Rect2(225, 141, 117, 207), 3: Rect2(215, 38, 123, 175)},
	&"attack_02": {2: Rect2(225, 195, 115, 80), 3: Rect2(225, 205, 132, 85)},
	&"attack_03": {2: Rect2(225, 166, 127, 184), 3: Rect2(225, 240, 118, 119)},
	&"attack_up": {2: Rect2(140, 40, 200, 300), 3: Rect2(120, 0, 220, 215)},
}
const JUMP_APEX := &"jump_apex"
const APEX_VY := 140.0                 # |vy| bajo esto, en el aire: pose de la cima
const LAND_BOUNCE := 5.0               # rebote visual al aterrizar (px de celda) ...
const LAND_BOUNCE_T := 0.18            # ... y su duración
const IDLE := &"idle"
## Reposo relajado (Wolf_Idle_Relajado_v001, copia sin retoques): ojos abiertos, brazos sueltos, respiración;
## 12 cuadros a 6 FPS. Se usa al quedarse quieto una vez vencidas las sombras de Camino (n1_sombras); antes,
## el reposo tímido de pincel_v003. Dibujado ~6 % más chico que la carrera, como el salto: se agranda igual.
const IDLE_RELAX := &"idle_relaxed"
const RELAX_ART := "res://characters/lobo/idle_relajado_v001"
const WALK := &"walk"
const RUN := &"run"
const JUMP_START := &"jump_start"
const JUMP_UP := &"jump_up"
const FALL := &"fall"
const LAND := &"land"
const SPRITE_OFFSET := Vector2(0, -160)   # celdas 384x384, suelo en y=352
const CELL_FEET := Vector2(192, 352)      # pies dentro de la celda
## px de celda que avanza un ciclo (2 pasos). Medido por Codex: caminata 153, carrera 302.5. La caminata
## usa más para que la animación vaya más pausada (pedido de Emma), a cambio de un leve deslizamiento.
const STRIDE := 175.0
const RUN_STRIDE := 446.0           # carrera v027: el pie apoyado retrocede ~55 px de celda por cuadro (como v016)
## Corre cuando avanza más de RUN_FROM px de celda por segundo; vuelve a caminar bajo RUN_TO.
const RUN_FROM := 380.0
const RUN_TO := 330.0
## Sprint (provisional, sin arte propio todavía): la carrera v027 más rápida y con el cuerpo inclinado hacia
## adelante, como Hornet. Derrape: la pose de aterrizaje, echado hacia atrás. Voltereta del salto en sprint:
## la pose de la cima girando una vuelta sobre el centro del cuerpo.
const SPRINT_LEAN := 0.20             # rad de inclinación hacia adelante
const SPRINT_STRIDE := 620.0          # px de celda por ciclo en sprint (zancada más larga que la carrera)
const SKID := &"skid"
const SKID_LEAN := -0.16
const CUERPO_CENTRO := Vector2(0, -105)   # centro del cuerpo respecto a los pies, en px de celda
const SMEAR_TINT := {"color": Color(1.0, 0.72, 0.35), "ink": Color(0.10, 0.10, 0.14), "dry": Color(0.85, 0.83, 0.80, 0.45)}

var facing := 1.0
var sprite: AnimatedSprite2D      # el cuerpo
var brush := ""                   # "" sin pincel; "color", "dry" o "ink": punta que se ve
var acting := false               # acción del nivel (el lobo no se mueve)
var attacking := false            # tajo en curso (el lobo sí se mueve)
## Ya no camina: cualquier avance usa la carrera (desde que lo persiguen las manos; Emma decide si vuelve).
var solo_correr := false
var special := ""                 # estado especial que pide Player ("dash", "wall_slide", ...); "" = ninguno
var sprinting := false            # lo pone Player: sprint en el suelo
var _lean := 0.0                  # inclinación actual (se suaviza)
var _volt := 0.0                  # tiempo que queda de la voltereta
var _volt_dur := 0.0
var _running := false
var _air := false
var _landing := false
var _flip := Node2D.new()         # voltea a izquierda/derecha alrededor de los pies
var _layers: Array[AnimatedSprite2D] = []     # back, base, tip, smear (siguen al cuerpo cuadro a cuadro)
var _tip: AnimatedSprite2D
var _smear: AnimatedSprite2D
var _tips := {}
var _contacts := {}               # "anim:frame" -> registro de brush_contacts.json
var _last_pos := Vector2.ZERO
var _bounce := 0.0                # tiempo que queda del rebote de aterrizaje


func _ready() -> void:
	add_child(_flip)
	for state in ["color", "dry", "ink"]:
		_tips[state] = load(ART + "/Godot/Wolf_tip_%s.tres" % state)
	_layers.append(_layer(load(ART + "/Godot/Wolf_brush_back.tres")))
	_layers.append(_layer(load(ART + "/Godot/Wolf_brush_base.tres")))
	_tip = _layer(_tips.dry)
	_layers.append(_tip)
	_smear = _layer(load(ART + "/Godot/Wolf_smear.tres"))
	_layers.append(_smear)
	sprite = _layer(_body_frames())
	sprite.play(IDLE)
	sprite.animation_finished.connect(_on_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_changed.connect(_sync_layers)
	sprite.animation_changed.connect(func() -> void:
		sprite.offset = SPRITE_OFFSET + (Vector2(COMBO_DX, 0) if COMBO_HITS.has(sprite.animation) else Vector2.ZERO)
		sprite.scale = Vector2.ONE * (SALTO_ESCALA if sprite.animation in SALTO_ANIMS or sprite.animation in [IDLE_RELAX, SKID] else 1.0))
	_last_pos = global_position
	for c in JSON.parse_string(FileAccess.get_file_as_string(ART + "/brush_contacts.json")):
		_contacts["%s:%d" % [c.animation, int(c.frame)]] = c
	_sync_layers()


## Cuerpo de pincel_v003 con la carrera, el salto y la caída del modelo nuevo.
func _body_frames() -> SpriteFrames:
	var f: SpriteFrames = (load(ART + "/Godot/Wolf_body.tres") as SpriteFrames).duplicate()
	var run: Array[String] = []
	for i in 8:
		run.append(RUN_ART + "/%02d.png" % (i + 1))
	_set_anim(f, RUN, run, 20.0, true)
	var relax: Array[String] = []
	for i in 12:
		relax.append(RELAX_ART + "/%02d.png" % (i + 1))
	_set_anim(f, IDLE_RELAX, relax, 6.0, true)
	_set_anim(f, JUMP_START, [SALTO + "/jump_start.png"], 12.0, false)
	_set_anim(f, JUMP_UP, [SALTO + "/jump_up.png"], 5.0, true)
	_set_anim(f, JUMP_APEX, [SALTO + "/jump_apex.png"], 5.0, true)
	_set_anim(f, FALL, [SALTO + "/fall.png"], 5.0, true)
	_set_anim(f, LAND, [SALTO + "/land.png"], 1.0 / LAND_BOUNCE_T, false)
	_set_anim(f, SKID, [SALTO + "/land.png"], 5.0, true)
	for i in ATTACKS.size():
		var files: Array[String] = []
		for k in 4:
			files.append(COMBO + "/attack_%02d/%02d.png" % [i + 1, k + 1])
		_set_anim(f, ATTACKS[i], files, COMBO_FPS, false)
		if i == 0:
			_set_anim(f, ATTACK_UP, files, COMBO_FPS, false)
	return f


func _set_anim(f: SpriteFrames, anim: StringName, files: Array, fps: float, loop: bool) -> void:
	if f.has_animation(anim):
		f.remove_animation(anim)
	f.add_animation(anim)
	f.set_animation_speed(anim, fps)
	f.set_animation_loop(anim, loop)
	for path in files:
		f.add_frame(anim, load(path))


func _layer(frames: SpriteFrames) -> AnimatedSprite2D:
	var s := AnimatedSprite2D.new()
	s.sprite_frames = frames
	s.offset = SPRITE_OFFSET
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_flip.add_child(s)
	return s


## Cambia la punta del pincel ("color", "dry", "ink") o lo quita ("").
func set_brush(state: String) -> void:
	brush = state
	if state != "":
		_tip.sprite_frames = _tips[state]
		_smear.modulate = SMEAR_TINT[state]
	_sync_layers()


## Las capas del pincel siguen al cuerpo cuadro a cuadro (las 18 animaciones existen en todas).
func _sync_layers() -> void:
	if _layers.is_empty() or sprite == null:
		return
	var shown := brush != "" and (acting or attacking)     # el pincel aparece solo al usarlo
	for s in _layers:
		s.visible = shown and s.sprite_frames.has_animation(sprite.animation)
		if s.visible:
			s.animation = sprite.animation
			s.frame = sprite.frame


func _on_frame_changed() -> void:
	_sync_layers()
	if acting:
		action_frame.emit(sprite.animation, sprite.frame + 1)
	elif attacking:
		attack_frame.emit(sprite.animation, sprite.frame + 1)


func _play(anim: StringName, restart := false) -> void:
	if restart or sprite.animation != anim:
		sprite.play(anim)
		sprite.frame = 0
	elif not sprite.is_playing():
		sprite.play(anim)


## Acción del nivel (el lobo queda quieto); avisa por action_frame y action_finished.
func play_action(anim: StringName) -> void:
	acting = true
	attacking = false
	_landing = false
	sprite.speed_scale = 1.0
	_play(anim, true)
	_sync_layers()
	_on_frame_changed()


## Tajo: se reproduce encima de la locomoción; avisa por attack_frame en cada cuadro.
func play_attack(anim: StringName) -> void:
	attacking = true
	_landing = false
	sprite.speed_scale = 1.0
	_play(anim, true)
	_sync_layers()
	_on_frame_changed()


## Gira al lobo hacia dir (-1 izquierda, 1 derecha).
func face(dir: float) -> void:
	facing = signf(dir) if dir != 0.0 else facing
	_flip.scale.x = facing


func _contact(anim: StringName, frame: int) -> Dictionary:
	return _contacts.get("%s:%d" % [anim, frame], {})


## Punta del pincel en coordenadas globales para un cuadro (1..n).
func tip_global(anim: StringName, frame: int) -> Vector2:
	var c := _contact(anim, frame)
	if c.is_empty():
		return global_position
	var p: Array = c.contact_by_state_xy[brush if brush != "" else "dry"]
	return _flip.get_global_transform() * (Vector2(p[0], p[1]) - CELL_FEET)


## Zona de golpe (global) de un cuadro de tajo, o un Rect2 vacío si ese cuadro no golpea.
func hitbox_global(anim: StringName, frame: int, margin := 14.0) -> Rect2:
	var hb: Rect2
	if COMBO_HITS.has(anim):
		if not COMBO_HITS[anim].has(frame):
			return Rect2()
		hb = COMBO_HITS[anim][frame]
		hb.position.x += COMBO_DX
	else:
		var c := _contact(anim, frame)
		if c.is_empty() or not c.get("hits", false) or c.get("hitbox") == null:
			return Rect2()
		hb = Rect2(c.hitbox[0], c.hitbox[1], c.hitbox[2], c.hitbox[3])
	var t := _flip.get_global_transform()
	var a := t * (hb.position - CELL_FEET)
	var b := t * (hb.end - CELL_FEET)
	return Rect2(Vector2(minf(a.x, b.x), minf(a.y, b.y)), (b - a).abs()).grow(margin)


## Voltereta (salto en sprint): una vuelta completa hacia adelante sobre el centro del cuerpo.
func voltereta(dur: float) -> void:
	_volt = dur
	_volt_dur = dur


## Inclinación del cuerpo (sprint, derrape) y giro de la voltereta, alrededor de los pies o del centro.
func _pose(delta: float, air: bool) -> void:
	var meta := 0.0
	if special == "skid":
		meta = SKID_LEAN
	elif sprinting and not air:
		meta = SPRINT_LEAN
	_lean = lerpf(_lean, meta, 1.0 - exp(-18.0 * delta))
	var ang := _lean * facing
	var pos := Vector2(0, _flip.position.y)
	if _volt > 0.0:
		_volt = maxf(0.0, _volt - delta) if air else 0.0
		var k := 1.0 - _volt / _volt_dur
		ang = facing * TAU * smoothstep(0.0, 1.0, k)
		pos = CUERPO_CENTRO - CUERPO_CENTRO.rotated(ang)
	_flip.rotation = ang
	_flip.position = pos


## Reposo que toca: relajado una vez vencidas las sombras de Camino; antes, el tímido.
func _reposo() -> StringName:
	return IDLE_RELAX if Inventario.hecho("n1_sombras") else IDLE


func _on_finished() -> void:
	var anim := sprite.animation
	if acting:
		acting = false
		_play(_reposo(), true)
		_sync_layers()
		action_finished.emit(anim)
	elif attacking:
		attacking = false
		_play(_reposo(), true)
		_sync_layers()
	elif anim == JUMP_START:
		_play(JUMP_UP, true)
	elif anim == LAND:
		_landing = false
		_play(_reposo(), true)


## speed01: 0 = quieto, 1 = a toda velocidad. El ritmo de caminata y carrera sale del avance real en
## pantalla, para que los pies no patinen. En el aire: despegue, subida y caída según vy; al tocar suelo, aterriza.
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, vy: float = 0.0) -> void:
	var ground := global_position.distance_to(_last_pos) / maxf(delta, 0.001)
	_last_pos = global_position
	# rebote visual del aterrizaje: sube unos px y vuelve (la colisión sigue en el suelo)
	_bounce = maxf(0.0, _bounce - delta)
	_flip.position.y = -sin((1.0 - _bounce / LAND_BOUNCE_T) * PI) * LAND_BOUNCE if _bounce > 0.0 else 0.0
	_pose(delta, air)
	if acting:
		return
	if absf(vel_x) > 6.0 and special != "wall_slide":
		face(vel_x)
	if attacking:
		return
	if special != "":
		sprite.speed_scale = 1.0
		_play(StringName(special))
		_air = air
		return
	if air:
		sprite.speed_scale = 1.0
		_landing = false
		if _volt > 0.0:
			_play(JUMP_APEX)                # voltereta: pose recogida de la cima mientras gira
		elif not _air:
			_play(JUMP_START if vy < 0.0 else FALL, true)
		elif absf(vy) < APEX_VY and sprite.animation != JUMP_START:
			_play(JUMP_APEX)
		elif vy >= APEX_VY:
			_play(FALL)
		elif vy < 0.0 and sprite.animation != JUMP_START:
			_play(JUMP_UP)
		_air = true
		return
	if _air:
		_air = false
		if speed01 < 0.5:
			_landing = true
			sprite.speed_scale = 1.0
			_play(LAND, true)
			_bounce = LAND_BOUNCE_T
			return
	if _landing and speed01 < 0.05:
		return
	_landing = false
	if speed01 > 0.05:
		var cell := ground / absf(global_scale.y)          # px de celda por segundo
		_running = solo_correr or cell > (RUN_TO if _running else RUN_FROM)
		var anim := RUN if _running else WALK
		# ciclos por segundo que pide el avance / ciclos por segundo de la animación a speed_scale 1
		var ciclos := cell / ((SPRINT_STRIDE if sprinting else RUN_STRIDE) if _running else STRIDE)
		var rate := sprite.sprite_frames.get_animation_speed(anim) / sprite.sprite_frames.get_frame_count(anim)
		sprite.speed_scale = clampf(ciclos / rate, 0.3, 4.5)
		_play(anim)
	else:
		_running = false
		sprite.speed_scale = 1.0
		_play(_reposo())
