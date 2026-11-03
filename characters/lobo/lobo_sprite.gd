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
## La mirada disponible es de v003: más baja y encogida que la caminata v004, y al reproducirla el lobo
## parecía crecer y encogerse. Queda apagada hasta tener una mirada en la postura v004.
const LOOK_ENABLED := false
## px de celda que avanza un ciclo de caminata (2 pasos). La zancada medida en v004 es ~132; se usa
## ~10 % más para un paso más pausado a cambio de un deslizamiento casi imperceptible.
const STRIDE := 145.0

var facing := 1.0
var sprite: AnimatedSprite2D
var _cooldown := 0.0
var _idle_time := 0.0
var _rng := RandomNumberGenerator.new()
var _flip := Node2D.new()         # voltea a izquierda/derecha alrededor de los pies
var _last_pos := Vector2.ZERO


func _ready() -> void:
	add_child(_flip)
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = load(FRAMES_PATH) as SpriteFrames
	sprite.offset = SPRITE_OFFSET
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.animation = IDLE
	_last_pos = global_position
	_flip.add_child(sprite)
	sprite.animation_finished.connect(_on_finished)
	_rng.randomize()
	_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)


func _on_finished() -> void:
	if sprite.animation == LOOK:
		sprite.play(IDLE)
		_cooldown = _rng.randf_range(LOOK_MIN, LOOK_MAX)


## speed01: 0 = quieto, 1 = a toda velocidad. Caminata; quieto = idle con miradas ocasionales; aire = idle.
## El ritmo de la caminata sale del avance real en pantalla, para que los pies no patinen.
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, _vy: float = 0.0) -> void:
	var ground := global_position.distance_to(_last_pos) / maxf(delta, 0.001)
	_last_pos = global_position
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
			# ciclos por segundo que pide el avance / ciclos por segundo de la animación a speed_scale 1
			var ciclos := ground / (STRIDE * absf(global_scale.y))
			var base := sprite.sprite_frames.get_animation_speed(WALK) / sprite.sprite_frames.get_frame_count(WALK)
			sprite.speed_scale = clampf(ciclos / base, 0.3, 4.5)
			sprite.play(WALK)
	else:
		_idle_time += delta
		sprite.speed_scale = 1.0
		if sprite.animation == WALK:
			sprite.play(IDLE)
		if LOOK_ENABLED and sprite.animation == IDLE and _cooldown <= 0.0 and _idle_time >= 0.4:
			sprite.play(LOOK)
