class_name LoboSprite
extends Node2D
## Lobo con sprites. El origen del nodo queda en los pies; las hojas miran a la derecha.
## Interfaz: animate(delta, speed01, vel_x, air, vy). Sustituye al lobo dibujado por código.
## Cuerpo: caminata de 12 cuadros (v005 r03) y carrera de characters/lobo/pincel_v001; reposo de v004.
## Con pincel (set_brush): detrás del cuerpo se dibujan el mango y la punta (color / dry / ink), sincronizados
## cuadro a cuadro, y se pueden reproducir las acciones paint_slash, paint_up y dip (play_action).

signal action_frame(anim: StringName, frame: int)   # frame empieza en 1, como en brush_contacts.json
signal action_finished(anim: StringName)

const BASE_SCALE := 0.60          # tamaño en la zona de la pintura (scale = BASE_SCALE * profundidad)
const IDLE_FRAMES := "res://characters/lobo/v004/Godot/Wolf.tres"
const PINCEL := "res://characters/lobo/pincel_v001"
const WALK := &"walk_pincel"      # el cuerpo de walk_pincel es la caminata v005 r03 (sin pincel también)
const IDLE := &"idle"
const RUN := &"run"
const LOOK := &"look_around"
const SPRITE_OFFSET := Vector2(0, -110)   # celdas 256x256, suelo en y=238
const CELL_FEET := Vector2(128, 238)      # pies dentro de la celda (para la punta del pincel)
const LOOK_MIN := 7.0
const LOOK_MAX := 14.0
## La mirada disponible es de v003: más baja y encogida que la caminata, y al reproducirla el lobo
## parecía crecer y encogerse. Queda apagada hasta tener una mirada en la postura nueva.
const LOOK_ENABLED := false
## px de celda que avanza un ciclo de caminata (2 pasos). La zancada medida es ~132; se usa
## ~10 % más para un paso más pausado a cambio de un deslizamiento casi imperceptible.
const STRIDE := 145.0
const RUN_STRIDE := 290.0
## La caminata v005 tiene dos cuadros corridos: el 2 (cuerpo ~8 px atrás) y el 8 (~9 px adelante); se
## corrigen a medias para que el torso no tiemble sin que los pies patinen. Índices desde 0.
const WALK_FIX := {1: 5.0, 7: -6.0}
const IDLE_WALK_FRAME := 2
## Corre cuando avanza más de RUN_FROM px de celda por segundo; vuelve a caminar bajo RUN_TO.
const RUN_FROM := 380.0
const RUN_TO := 330.0

var facing := 1.0
var sprite: AnimatedSprite2D
var brush := ""                   # "" sin pincel; "color", "dry" o "ink": punta que se ve
var acting := false               # reproduciendo una acción (paint_slash, paint_up, dip)
var _running := false
var _cooldown := 0.0
var _idle_time := 0.0
var _rng := RandomNumberGenerator.new()
var _flip := Node2D.new()         # voltea a izquierda/derecha alrededor de los pies
var _base: AnimatedSprite2D       # mango del pincel
var _tip: AnimatedSprite2D        # punta del pincel
var _tips := {}
var _contacts := {}               # "anim:frame" -> registro de brush_contacts.json
var _last_pos := Vector2.ZERO


func _ready() -> void:
	add_child(_flip)
	_base = _layer(load(PINCEL + "/Godot/Wolf_brush_base.tres"))
	for state in ["color", "dry", "ink"]:
		_tips[state] = load(PINCEL + "/Godot/Wolf_tip_%s.tres" % state)
	_tip = _layer(_tips.dry)
	sprite = _layer(_body_frames())
	sprite.animation = IDLE
	sprite.animation_finished.connect(_on_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_changed.connect(_sync_layers)
	_last_pos = global_position
	_rng.randomize()
	_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)
	for c in JSON.parse_string(FileAccess.get_file_as_string(PINCEL + "/brush_contacts.json")):
		_contacts["%s:%d" % [c.animation, int(c.frame)]] = c
	_sync_layers()


## Cuadros del cuerpo: los de pincel_v001; reposo sin pincel = cuadro 3 de la misma caminata (pies juntos),
## para que al soltar la tecla el lobo no cambie de postura ni "dé un paso atrás"; mirada de v004 (apagada).
func _body_frames() -> SpriteFrames:
	var f := (load(PINCEL + "/Godot/Wolf_body.tres") as SpriteFrames).duplicate() as SpriteFrames
	f.add_animation(IDLE)
	f.add_frame(IDLE, f.get_frame_texture(WALK, IDLE_WALK_FRAME))
	var old := load(IDLE_FRAMES) as SpriteFrames
	f.add_animation(LOOK)
	f.set_animation_speed(LOOK, old.get_animation_speed(LOOK))
	f.set_animation_loop(LOOK, false)
	for i in old.get_frame_count(LOOK):
		f.add_frame(LOOK, old.get_frame_texture(LOOK, i))
	return f


## Corrección horizontal (px de celda) de los cuadros que en el dibujo quedaron corridos respecto al resto.
func _frame_fix(anim: StringName, frame: int) -> float:
	match anim:
		WALK:
			return WALK_FIX.get(frame, 0.0)
		&"idle_pincel":
			return 3.0
	return 0.0


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
		sprite.play(_anim_for(sprite.animation))
	_sync_layers()


## Mango y punta siguen al cuerpo cuadro a cuadro (solo existen en las animaciones con pincel).
func _sync_layers() -> void:
	if _base == null or sprite == null:
		return
	var shown := brush != "" and _base.sprite_frames.has_animation(sprite.animation)
	var fix := Vector2(_frame_fix(sprite.animation, sprite.frame), 0.0)
	for s in [sprite, _base, _tip]:
		s.offset = SPRITE_OFFSET + fix
	for s in [_base, _tip]:
		s.visible = shown
		if shown:
			s.animation = sprite.animation
			s.frame = sprite.frame


func _on_frame_changed() -> void:
	_sync_layers()
	if acting:
		action_frame.emit(sprite.animation, sprite.frame + 1)


## Nombre de la animación según lleve o no el pincel.
func _anim_for(anim: StringName) -> StringName:
	var with := brush != ""
	match anim:
		IDLE, &"idle_pincel", LOOK:
			return &"idle_pincel" if with else IDLE
		RUN, &"run_pincel":
			return &"run_pincel" if with else RUN
		WALK:
			return WALK
	return anim


## Reproduce una acción de pincel una vez (paint_slash, paint_up, dip); avisa por action_frame y action_finished.
func play_action(anim: StringName) -> void:
	acting = true
	sprite.speed_scale = 1.0
	sprite.play(anim)
	sprite.frame = 0
	_on_frame_changed()


## Gira al lobo hacia dir (-1 izquierda, 1 derecha).
func face(dir: float) -> void:
	facing = signf(dir) if dir != 0.0 else facing
	_flip.scale.x = facing


## Punta del pincel en coordenadas globales para un cuadro (1..n) de una animación con pincel.
func tip_global(anim: StringName, frame: int) -> Vector2:
	var c: Dictionary = _contacts.get("%s:%d" % [anim, frame], {})
	if c.is_empty():
		return global_position
	var state := brush if brush != "" else "dry"
	var p: Array = c.contact_by_state_xy[state]
	return _flip.get_global_transform() * (Vector2(p[0], p[1]) - CELL_FEET)


func _on_finished() -> void:
	if acting:
		var anim := sprite.animation
		acting = false
		sprite.play(_anim_for(IDLE))
		action_finished.emit(anim)
	elif sprite.animation == LOOK:
		sprite.play(IDLE)
		_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)


## speed01: 0 = quieto, 1 = a toda velocidad. Caminata o carrera; quieto = reposo; aire = reposo.
## El ritmo sale del avance real en pantalla, para que los pies no patinen.
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, _vy: float = 0.0) -> void:
	var ground := global_position.distance_to(_last_pos) / maxf(delta, 0.001)
	_last_pos = global_position
	if acting:
		return
	if absf(vel_x) > 6.0:
		face(vel_x)
	_cooldown = maxf(0.0, _cooldown - delta)
	if air or speed01 > 0.05:
		_idle_time = 0.0
		if sprite.animation == LOOK:
			_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)
		if air:
			sprite.speed_scale = 1.0
			sprite.play(_anim_for(IDLE))
		else:
			var cell := ground / absf(global_scale.y)          # px de celda por segundo
			_running = cell > (RUN_TO if _running else RUN_FROM)
			var anim := _anim_for(RUN) if _running else WALK
			# ciclos por segundo que pide el avance / ciclos por segundo de la animación a speed_scale 1
			var ciclos := cell / (RUN_STRIDE if _running else STRIDE)
			var base := sprite.sprite_frames.get_animation_speed(anim) / sprite.sprite_frames.get_frame_count(anim)
			sprite.speed_scale = clampf(ciclos / base, 0.3, 4.5)
			sprite.play(anim)
	else:
		_idle_time += delta
		_running = false
		sprite.speed_scale = 1.0
		if sprite.animation != IDLE and sprite.animation != LOOK:
			sprite.play(_anim_for(IDLE))
		if LOOK_ENABLED and brush == "" and sprite.animation == IDLE and _cooldown <= 0.0 and _idle_time >= 0.4:
			sprite.play(LOOK)
