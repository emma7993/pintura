class_name Player
extends CharacterBody2D
## Lobo jugable en vista lateral (sprites en characters/lobo/, ver lobo_sprite.gd).
## Los números de abajo son el "tacto" del juego: se pueden ajustar.

const SPRITE_SCALE := 0.60        # tamaño del lobo en pantalla (~130 px de alto)

const ACCEL := 2600.0
const AIR_ACCEL := 1900.0
const FRICTION := 3000.0
const AIR_FRICTION := 1200.0
const GRAVITY := 2300.0
const FALL_MULT := 1.35           # cae un poco más rápido de lo que sube
const MAX_FALL := 1500.0
const JUMP_VELOCITY := -900.0     # altura máxima del salto ~175 px
const JUMP_CUT := 0.45            # soltar el botón en el ascenso corta el salto
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.12

## Velocidad máxima. Zona Camino: caminata lenta (120). Zona de prueba: 340.
var max_speed := 340.0
## El lobo empieza sin poder saltar; se desbloquea más adelante en el juego.
var can_jump := true
var enabled := true

var lobo: LoboSprite
var _coyote := 0.0
var _buffer := 0.0
var _drop_timer := 0.0
var _on_one_way := false


func _ready() -> void:
	Controls.ensure()
	collision_layer = 0
	collision_mask = 3                     # capa 1 = suelo, capa 2 = plataformas de un solo sentido
	var shape := CapsuleShape2D.new()
	shape.radius = 28.0
	shape.height = 124.0
	var cs := CollisionShape2D.new()
	cs.shape = shape
	cs.position = Vector2(0, -62)
	add_child(cs)
	floor_snap_length = 8.0
	_build_visual()


func _build_visual() -> void:
	lobo = LoboSprite.new()
	lobo.scale = Vector2.ONE * SPRITE_SCALE
	add_child(lobo)


func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right") if enabled else 0.0
	var on_floor := is_on_floor()

	# --- horizontal
	if absf(dir) > 0.01:
		velocity.x = move_toward(velocity.x, dir * max_speed, (ACCEL if on_floor else AIR_ACCEL) * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, (FRICTION if on_floor else AIR_FRICTION) * delta)

	# --- gravedad
	var g := GRAVITY * (FALL_MULT if velocity.y > 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, MAX_FALL)

	# --- salto (coyote time + buffer), solo si ya está desbloqueado
	_coyote = COYOTE_TIME if on_floor else maxf(0.0, _coyote - delta)
	if enabled and can_jump and Input.is_action_just_pressed("jump"):
		_buffer = JUMP_BUFFER
	else:
		_buffer = maxf(0.0, _buffer - delta)

	if _drop_timer > 0.0:
		_drop_timer -= delta
		if _drop_timer <= 0.0:
			collision_mask = 3
	if _buffer > 0.0 and on_floor and _on_one_way and Input.is_action_pressed("move_down"):
		collision_mask = 1                 # abajo + salto: atraviesa la plataforma
		_drop_timer = 0.25
		_buffer = 0.0
		velocity.y = 120.0
	elif _buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_buffer = 0.0
		_coyote = 0.0

	if can_jump and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	move_and_slide()

	_on_one_way = false
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var body := c.get_collider() as CollisionObject2D
		if body and (body.collision_layer & 2) != 0 and c.get_normal().y < -0.5:
			_on_one_way = true

	_animate(delta)


func _animate(delta: float) -> void:
	lobo.animate(delta, absf(velocity.x) / max_speed, velocity.x, not is_on_floor(), velocity.y)
