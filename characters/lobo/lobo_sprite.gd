class_name LoboSprite
extends Node2D
## Lobo con sprites (hoja de 8 cuadros). El origen del nodo queda en los pies; la hoja mira a la derecha.
## Interfaz: animate(delta, speed01, vel_x, air, vy). Sustituye al lobo dibujado por código.

const BASE_SCALE := 0.60          # tamaño en la zona de la pintura (scale = BASE_SCALE * profundidad)
const FRAMES_PATH := "res://characters/lobo/v004/Godot/Wolf.tres"
const WALK := &"walk"
const IDLE := &"idle"
const LOOK := &"look_around"
const SPRITE_OFFSET := Vector2(0, -110)   # celdas v004 256x256, suelo en y=238
const LOOK_MIN := 7.0
const LOOK_MAX := 14.0

var facing := 1.0
var sprite: AnimatedSprite2D
var _cooldown := 0.0
var _idle_time := 0.0
var _rng := RandomNumberGenerator.new()
var _flip := Node2D.new()         # voltea a izquierda/derecha alrededor de los pies


func _ready() -> void:
	add_child(_flip)
	_add_shadow()
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = load(FRAMES_PATH) as SpriteFrames
	sprite.animation = WALK
	sprite.offset = SPRITE_OFFSET
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.animation = IDLE
	_flip.add_child(sprite)
	sprite.animation_finished.connect(_on_finished)
	_rng.randomize()
	_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)


func _add_shadow() -> void:
	var sh := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		pts.append(Vector2(cos(a) * 95.0 + 18.0, sin(a) * 13.0))
	sh.polygon = pts
	sh.color = Color(0, 0, 0, 0.28)
	sh.z_index = -1
	_flip.add_child(sh)


func _on_finished() -> void:
	if sprite.animation == LOOK:
		sprite.play(IDLE)
		_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)


## speed01: 0 = quieto, 1 = a toda velocidad. Caminata; quieto = idle con miradas ocasionales; aire = idle.
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, _vy: float = 0.0) -> void:
	if absf(vel_x) > 6.0:
		facing = signf(vel_x)
		_flip.scale.x = facing
	_cooldown = maxf(0.0, _cooldown - delta)
	if air or speed01 > 0.05:
		_idle_time = 0.0
		if sprite.animation == LOOK:
			_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)
		if air:
			sprite.speed_scale = 1.0
			sprite.play(IDLE)
		else:
			sprite.speed_scale = lerpf(0.6, 1.5, clampf(speed01, 0.0, 1.0))
			sprite.play(WALK)
	else:
		_idle_time += delta
		sprite.speed_scale = 1.0
		if sprite.animation == WALK:
			sprite.play(IDLE)
		if sprite.animation == IDLE and _cooldown <= 0.0 and _idle_time >= 0.4:
			sprite.play(LOOK)
