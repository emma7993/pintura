class_name LoboSprite
extends Node2D
## Lobo con sprites (characters/lobo/pincel_v003). El origen del nodo queda en los pies; las hojas miran
## a la derecha. Interfaz: animate(delta, speed01, vel_x, air, vy).
## Capas, en orden de dibujo: pincel guardado (espalda), pincel en la mano, punta (color / dry / ink),
## estela del golpe (se tiñe con la carga) y cuerpo. Sin pincel (brush == "") solo se ve el cuerpo.
## Estados: reposo, caminata, carrera, salto (despegue, subida, caída, aterrizaje) y los especiales que pide
## Player (dash, wall_slide, wall_jump, hurt, death). Acciones del nivel con play_action (el lobo se
## detiene: paint_rise, paint_up, dip) y ataques con play_attack (se puede mover: slash_side/up/down).

signal action_frame(anim: StringName, frame: int)   # frame empieza en 1, como en brush_contacts.json
signal action_finished(anim: StringName)
signal attack_frame(anim: StringName, frame: int)

const BASE_SCALE := 0.60          # tamaño en la zona de la pintura (scale = BASE_SCALE * profundidad)
const ART := "res://characters/lobo/pincel_v003"
## Locomoción con el modelo elegido (Wolf_Run_v014 y Wolf_Jump_Fall_v001): reemplaza esas animaciones de
## pincel_v003. Sin pincel: el pincel solo aparece al usarlo (acciones y tajos).
const LOCO := "res://characters/lobo/locomocion_v014"
const JUMP_APEX := &"jump_apex"
const APEX_VY := 140.0                 # |vy| bajo esto, en el aire: pose de la cima
const LAND_BOUNCE := 5.0               # rebote visual al aterrizar (px de celda) ...
const LAND_BOUNCE_T := 0.18            # ... y su duración
const IDLE := &"idle"
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
const RUN_STRIDE := 390.0           # carrera v014: el pie apoyado retrocede ~49 px de celda por cuadro
## Corre cuando avanza más de RUN_FROM px de celda por segundo; vuelve a caminar bajo RUN_TO.
const RUN_FROM := 380.0
const RUN_TO := 330.0
const SMEAR_TINT := {"color": Color(1.0, 0.72, 0.35), "ink": Color(0.10, 0.10, 0.14), "dry": Color(0.85, 0.83, 0.80, 0.45)}

var facing := 1.0
var sprite: AnimatedSprite2D      # el cuerpo
var brush := ""                   # "" sin pincel; "color", "dry" o "ink": punta que se ve
var acting := false               # acción del nivel (el lobo no se mueve)
var attacking := false            # tajo en curso (el lobo sí se mueve)
var special := ""                 # estado especial que pide Player ("dash", "wall_slide", ...); "" = ninguno
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
	_last_pos = global_position
	for c in JSON.parse_string(FileAccess.get_file_as_string(ART + "/brush_contacts.json")):
		_contacts["%s:%d" % [c.animation, int(c.frame)]] = c
	_sync_layers()


## Cuerpo de pincel_v003 con la carrera, el salto y la caída del modelo nuevo.
func _body_frames() -> SpriteFrames:
	var f: SpriteFrames = (load(ART + "/Godot/Wolf_body.tres") as SpriteFrames).duplicate()
	var run: Array[String] = []
	for i in 8:
		run.append(LOCO + "/run/%02d.png" % (i + 1))
	_set_anim(f, RUN, run, 20.0, true)
	_set_anim(f, JUMP_START, [LOCO + "/jump_fall/jump_start.png"], 12.0, false)
	_set_anim(f, JUMP_UP, [LOCO + "/jump_fall/jump_up.png"], 5.0, true)
	_set_anim(f, JUMP_APEX, [LOCO + "/jump_fall/jump_apex.png"], 5.0, true)
	_set_anim(f, FALL, [LOCO + "/jump_fall/fall.png"], 5.0, true)
	_set_anim(f, LAND, [LOCO + "/jump_fall/land.png"], 1.0 / LAND_BOUNCE_T, false)
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
	var c := _contact(anim, frame)
	if c.is_empty() or not c.get("hits", false) or c.get("hitbox") == null:
		return Rect2()
	var hb: Array = c.hitbox
	var t := _flip.get_global_transform()
	var a := t * (Vector2(hb[0], hb[1]) - CELL_FEET)
	var b := t * (Vector2(hb[0] + hb[2], hb[1] + hb[3]) - CELL_FEET)
	return Rect2(Vector2(minf(a.x, b.x), minf(a.y, b.y)), (b - a).abs()).grow(margin)


func _on_finished() -> void:
	var anim := sprite.animation
	if acting:
		acting = false
		_play(IDLE, true)
		_sync_layers()
		action_finished.emit(anim)
	elif attacking:
		attacking = false
		_play(IDLE, true)
		_sync_layers()
	elif anim == JUMP_START:
		_play(JUMP_UP, true)
	elif anim == LAND:
		_landing = false
		_play(IDLE, true)


## speed01: 0 = quieto, 1 = a toda velocidad. El ritmo de caminata y carrera sale del avance real en
## pantalla, para que los pies no patinen. En el aire: despegue, subida y caída según vy; al tocar suelo, aterriza.
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, vy: float = 0.0) -> void:
	var ground := global_position.distance_to(_last_pos) / maxf(delta, 0.001)
	_last_pos = global_position
	# rebote visual del aterrizaje: sube unos px y vuelve (la colisión sigue en el suelo)
	_bounce = maxf(0.0, _bounce - delta)
	_flip.position.y = -sin((1.0 - _bounce / LAND_BOUNCE_T) * PI) * LAND_BOUNCE if _bounce > 0.0 else 0.0
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
		if not _air:
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
		_running = cell > (RUN_TO if _running else RUN_FROM)
		var anim := RUN if _running else WALK
		# ciclos por segundo que pide el avance / ciclos por segundo de la animación a speed_scale 1
		var ciclos := cell / (RUN_STRIDE if _running else STRIDE)
		var rate := sprite.sprite_frames.get_animation_speed(anim) / sprite.sprite_frames.get_frame_count(anim)
		sprite.speed_scale = clampf(ciclos / rate, 0.3, 4.5)
		_play(anim)
	else:
		_running = false
		sprite.speed_scale = 1.0
		_play(IDLE)
