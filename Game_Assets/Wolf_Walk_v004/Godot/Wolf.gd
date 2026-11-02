extends Node2D
## Interfaz compatible con animate(delta, speed01, vel_x, air, vy).
## Las miradas espontaneas solo empiezan al estar quieto; mover cancela al instante.
const BASE_SCALE := 0.65
@export var minimum_interval := 7.0
@export var maximum_interval := 14.0
var facing := 1.0
var sprite: AnimatedSprite2D
var cooldown := 0.0
var idle_time := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
 rng.randomize()
 sprite = AnimatedSprite2D.new()
 sprite.sprite_frames = preload("Wolf.tres")
 sprite.offset = Vector2(0, -110)
 sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
 add_child(sprite)
 sprite.animation_finished.connect(_finished)
 sprite.play(&"idle")
 _reschedule()

func _reschedule() -> void:
 cooldown = rng.randf_range(maxf(minimum_interval, 1.0), maxf(maximum_interval, minimum_interval))

func _finished() -> void:
 if sprite.animation == &"look_around":
  sprite.play(&"idle")
  _reschedule()

func trigger_look() -> void:
 if sprite.animation != &"look_around":
  sprite.speed_scale = 1.0
  sprite.play(&"look_around")

func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, _vy: float = 0.0) -> void:
 cooldown = maxf(0.0, cooldown - delta)
 if absf(vel_x) > 0.1:
  facing = signf(vel_x)
  sprite.flip_h = facing < 0.0
 if speed01 > 0.05 or air:
  idle_time = 0.0
  if sprite.animation == &"look_around":
   _reschedule()
  sprite.speed_scale = lerpf(0.65, 1.35, clampf(speed01, 0.0, 1.0))
  sprite.play(&"idle" if air else &"walk")
 else:
  idle_time += delta
  sprite.speed_scale = 1.0
  if sprite.animation != &"look_around":
   sprite.play(&"idle")
   if cooldown <= 0.0 and idle_time >= 0.4:
    trigger_look()
