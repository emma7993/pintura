class_name LoboSprite
extends Node2D
## Lobo con sprites (characters/lobo/varita_v002). El origen del nodo queda en los pies; las hojas miran
## a la derecha. Interfaz: animate(delta, speed01, vel_x, air, vy).
## Estados: reposo, caminata, carrera, salto (despegue, subida, caída, aterrizaje). Con pincel (set_brush)
## se usan las versiones *_varita y detrás del cuerpo se dibujan el mango y la punta (color / dry / ink),
## sincronizados cuadro a cuadro; las acciones paint_rise, paint_slash, paint_up y dip van con play_action.

signal action_frame(anim: StringName, frame: int)   # frame empieza en 1, como en brush_contacts.json
signal action_finished(anim: StringName)

const BASE_SCALE := 0.60          # tamaño en la zona de la pintura (scale = BASE_SCALE * profundidad)
const VARITA := "res://characters/lobo/varita_v002"
const CAMINATA := "res://characters/lobo/caminata_v005"
## La caminata v005 tiene dos cuadros corridos: el 2 (cuerpo ~8 px atrás) y el 8 (~9 px adelante); se
## corrigen a medias para que el torso no tiemble sin que los pies patinen. Índices desde 0.
const WALK_FIX := {1: 5.0, 7: -6.0}
const IDLE_WALK_FRAME := 2        # reposo sin pincel: cuadro 3 de la caminata (pies juntos)
const IDLE := &"idle"
const WALK := &"walk"
const RUN := &"run"
const JUMP_START := &"jump_start"
const JUMP_UP := &"jump_up"
const FALL := &"fall"
const LAND := &"land"
const SPRITE_OFFSET := Vector2(0, -110)   # celdas 256x256, suelo en y=238
const CELL_FEET := Vector2(128, 238)      # pies dentro de la celda (para la punta del pincel)
## px de celda que avanza un ciclo (2 pasos). Medido por Codex: caminata 146, carrera 311. La caminata
## usa un poco más para un paso algo más largo sin que se note el deslizamiento.
const STRIDE := 152.0
const RUN_STRIDE := 311.0
const STRIDE_V005 := 145.0         # caminata sin pincel (v005, zancada medida ~132)
## Corre cuando avanza más de RUN_FROM px de celda por segundo; vuelve a caminar bajo RUN_TO.
const RUN_FROM := 380.0
const RUN_TO := 330.0

var facing := 1.0
var sprite: AnimatedSprite2D
var brush := ""                   # "" sin pincel; "color", "dry" o "ink": punta que se ve
var acting := false               # reproduciendo una acción (paint_rise, paint_slash, paint_up, dip)
var _running := false
var _air := false
var _landing := false
var _flip := Node2D.new()         # voltea a izquierda/derecha alrededor de los pies
var _base: AnimatedSprite2D       # mango del pincel
var _tip: AnimatedSprite2D        # punta del pincel
var _tips := {}
var _contacts := {}               # "anim:frame" -> registro de brush_contacts.json
var _last_pos := Vector2.ZERO


func _ready() -> void:
	add_child(_flip)
	_base = _layer(load(VARITA + "/Godot/Wolf_brush_base.tres"))
	for state in ["color", "dry", "ink"]:
		_tips[state] = load(VARITA + "/Godot/Wolf_tip_%s.tres" % state)
	_tip = _layer(_tips.dry)
	sprite = _layer(_body_frames())
	sprite.animation = IDLE
	sprite.play(IDLE)
	sprite.animation_finished.connect(_on_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_changed.connect(_sync_layers)
	_last_pos = global_position
	for c in JSON.parse_string(FileAccess.get_file_as_string(VARITA + "/brush_contacts.json")):
		_contacts["%s:%d" % [c.animation, int(c.frame)]] = c
	_sync_layers()


## Cuadros del cuerpo de varita_v002, pero sin pincel camina y reposa con las manos encogidas al pecho
## (caminata v005, elegida por Emma): la mano adelantada de v002 parecía en guardia, como para pelear.
func _body_frames() -> SpriteFrames:
	var f := (load(VARITA + "/Godot/Wolf_body.tres") as SpriteFrames).duplicate() as SpriteFrames
	var walk: Array[Texture2D] = []
	for i in 12:
		walk.append(load(CAMINATA + "/walk_%02d.png" % (i + 1)))
	f.clear(WALK)
	for t in walk:
		f.add_frame(WALK, t)
	f.clear(IDLE)
	f.add_frame(IDLE, walk[IDLE_WALK_FRAME])
	return f


## Corrección horizontal (px de celda) de los cuadros de la caminata v005 que quedaron corridos.
func _frame_fix() -> float:
	return WALK_FIX.get(sprite.frame, 0.0) if sprite.animation == WALK else 0.0


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
	if not acting:
		_play(_base_name(sprite.animation), false)
	_sync_layers()


## Mango y punta siguen al cuerpo cuadro a cuadro (solo existen en las animaciones con varita).
func _sync_layers() -> void:
	if _base == null or sprite == null:
		return
	var shown := brush != "" and _base.sprite_frames.has_animation(sprite.animation)
	sprite.offset = SPRITE_OFFSET + Vector2(_frame_fix(), 0.0)
	for s in [_base, _tip]:
		s.visible = shown
		if shown:
			s.animation = sprite.animation
			s.frame = sprite.frame


func _on_frame_changed() -> void:
	_sync_layers()
	if acting:
		action_frame.emit(sprite.animation, sprite.frame + 1)


## Nombre base de una animación (sin "_varita").
func _base_name(anim: StringName) -> StringName:
	return StringName(String(anim).trim_suffix("_varita"))


## Reproduce el estado `base` en su versión con o sin varita. restart=false no reinicia si ya suena.
func _play(base: StringName, restart := false) -> void:
	var anim := base
	if brush != "" and sprite.sprite_frames.has_animation(StringName(String(base) + "_varita")):
		anim = StringName(String(base) + "_varita")
	if restart or sprite.animation != anim:
		sprite.play(anim)
		sprite.frame = 0
	elif not sprite.is_playing():
		sprite.play(anim)


## Reproduce una acción de pincel una vez; avisa por action_frame y action_finished.
func play_action(anim: StringName) -> void:
	acting = true
	_landing = false
	sprite.speed_scale = 1.0
	sprite.play(anim)
	sprite.frame = 0
	_on_frame_changed()


## Gira al lobo hacia dir (-1 izquierda, 1 derecha).
func face(dir: float) -> void:
	facing = signf(dir) if dir != 0.0 else facing
	_flip.scale.x = facing


## Punta del pincel en coordenadas globales para un cuadro (1..n) de una animación con varita.
func tip_global(anim: StringName, frame: int) -> Vector2:
	var c: Dictionary = _contacts.get("%s:%d" % [anim, frame], {})
	if c.is_empty():
		return global_position
	var state := brush if brush != "" else "dry"
	var p: Array = c.contact_by_state_xy[state]
	return _flip.get_global_transform() * (Vector2(p[0], p[1]) - CELL_FEET)


func _on_finished() -> void:
	var base := _base_name(sprite.animation)
	if acting:
		var anim := sprite.animation
		acting = false
		_play(IDLE, true)
		action_finished.emit(anim)
	elif base == JUMP_START:
		_play(JUMP_UP, true)
	elif base == LAND:
		_landing = false
		_play(IDLE, true)


## speed01: 0 = quieto, 1 = a toda velocidad. El ritmo de caminata y carrera sale del avance real en
## pantalla, para que los pies no patinen. En el aire: despegue, subida y caída según vy; al tocar suelo, aterriza.
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, vy: float = 0.0) -> void:
	var ground := global_position.distance_to(_last_pos) / maxf(delta, 0.001)
	_last_pos = global_position
	if acting:
		return
	if absf(vel_x) > 6.0:
		face(vel_x)
	if air:
		sprite.speed_scale = 1.0
		_landing = false
		if not _air:
			_play(JUMP_START if vy < 0.0 else FALL, true)
		elif vy >= 0.0 and _base_name(sprite.animation) != FALL:
			_play(FALL, true)
		_air = true
		return
	if _air:
		_air = false
		if speed01 < 0.5:
			_landing = true
			sprite.speed_scale = 1.0
			_play(LAND, true)
			return
	if _landing and speed01 < 0.05:
		return
	_landing = false
	if speed01 > 0.05:
		var cell := ground / absf(global_scale.y)          # px de celda por segundo
		_running = cell > (RUN_TO if _running else RUN_FROM)
		var base := RUN if _running else WALK
		# ciclos por segundo que pide el avance / ciclos por segundo de la animación a speed_scale 1
		var walk_stride := STRIDE if brush != "" else STRIDE_V005
		var ciclos := cell / (RUN_STRIDE if _running else walk_stride)
		var fps := sprite.sprite_frames.get_animation_speed(base)
		var rate := fps / sprite.sprite_frames.get_frame_count(base)
		sprite.speed_scale = clampf(ciclos / rate, 0.3, 4.5)
		_play(base)
	else:
		_running = false
		sprite.speed_scale = 1.0
		_play(IDLE)
