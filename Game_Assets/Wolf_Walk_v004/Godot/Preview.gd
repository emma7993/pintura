extends Node2D
var wolf: Node2D
var auto_demo := true
var next_event := 8.0
var demo_looking := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
 rng.randomize()
 wolf = Node2D.new()
 wolf.set_script(preload("Wolf.gd"))
 wolf.position = Vector2(480, 500)
 wolf.scale = Vector2(2, 2)
 add_child(wolf)
 next_event = rng.randf_range(7.0, 14.0)

func _process(delta: float) -> void:
 var direction := Input.get_axis("ui_left", "ui_right")
 if absf(direction) > 0.0:
  auto_demo = false
 if Input.is_action_just_pressed("ui_accept"):
  auto_demo = not auto_demo
  demo_looking = false
  next_event = rng.randf_range(7.0, 14.0)
 if auto_demo:
  next_event -= delta
  if not demo_looking and next_event <= 0.0:
   wolf.trigger_look()
   demo_looking = true
  if demo_looking:
   wolf.animate(delta, 0.0)
   if wolf.sprite.animation != &"look_around":
    demo_looking = false
    next_event = rng.randf_range(7.0, 14.0)
  else:
   wolf.animate(delta, 0.5, 1.0)
 else:
  wolf.animate(delta, absf(direction), direction)
  wolf.position.x = clampf(wolf.position.x + direction * 100.0 * delta, 180.0, 780.0)
