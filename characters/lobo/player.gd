class_name Player
extends CharacterBody2D
## Lobo jugable en vista lateral (sprites en characters/lobo/, ver lobo_sprite.gd).
## Los números de abajo son el "tacto" del juego: se pueden ajustar.
## Habilidades (las desbloquea el nivel): salto, tajos con el pincel (lado, arriba y abajo con rebote en
## el aire), dash y pared (deslizarse y saltar desde ella). Vida: golpes con retroceso e invulnerabilidad;
## a cero, animación de muerte y aviso al nivel (died).

signal attack_started(anim: StringName)
signal attack_hit_frame(anim: StringName, area: Rect2)   # cuadros de golpe de un tajo, en coordenadas de mundo
signal hurt_taken(vida: int)
signal died

const SPRITE_SCALE := 0.60        # tamaño del lobo en pantalla (~130 px de alto)

## Tacto de metroidvania de acción precisa: arranca y frena casi al instante (sin patinar), control total
## en el aire, salto alto y vivo con un instante de "flote" en la cima y caída rápida con tope.
## Salto medido de una grabación de Silksong (nov 2026), escalado por altura del personaje (Hornet ~70 px
## en el video, el lobo ~130 px): sube a velocidad constante mientras se mantiene el botón (~0.15 s),
## frena hasta la cima (~0.42 s en total), flota un instante y cae acelerando hasta el tope (~0.52 s).
## Salto completo ~1.8 veces el lobo (~240 px, ~0.95 s en el aire).
## Control total (pedido de Emma): soltar el salto lo para en seco, en el aire se mueve igual que en el suelo,
## voltea al instante y ninguna pulsación de salto, tajo o dash se pierde (se guarda un instante). Cada error
## debe sentirse evitable.
const ACCEL := 7000.0             # llega a la velocidad tope en ~0.05 s (en el video: casi instantáneo)
const AIR_ACCEL := 7000.0         # en el aire, el mismo control que en el suelo
const FRICTION := 8000.0          # se detiene casi en seco al soltar
const AIR_FRICTION := 8000.0
const RISE_GRAVITY := 3000.0      # al subir, cuando ya no se sostiene el impulso
const FALL_GRAVITY := 2700.0      # al caer
const MAX_FALL := 1150.0
const JUMP_VELOCITY := -780.0
const JUMP_HOLD := 0.15           # con el botón apretado, sube sin gravedad este tiempo
const JUMP_MIN := 0.05            # un toque sube al menos esto antes de cortarse (~40 px)
const JUMP_CUT := 0.0             # al soltar en el ascenso se para en seco y empieza a caer
const APEX_SPEED := 110.0         # cerca de la cima, con el botón apretado...
const APEX_GRAVITY := 0.45        # ...la gravedad baja: un instante de flote para apuntar el aterrizaje
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.12
## Dash: impulso horizontal corto, sin gravedad; uno por salto (se recupera al tocar suelo o pared).
const DASH_SPEED := 1000.0
const DASH_TIME := 0.22
const DASH_COOLDOWN := 0.35
## Pared: al caer pegado a una pared (empujando hacia ella) resbala despacio; saltar lo despega.
const WALL_SLIDE_SPEED := 160.0
const WALL_JUMP := Vector2(520.0, -980.0)
const WALL_JUMP_LOCK := 0.10      # tras saltar de la pared, un instante sin control horizontal
## Tajos y rebote: la estocada hacia abajo que da en algo rebota hacia arriba (pogo).
const ATTACK_COOLDOWN := 0.22
const COMBO_WINDOW := 0.55        # golpe de lado dentro de este tiempo desde el anterior: sigue el combo
const ACTION_BUFFER := 0.15       # un tajo o dash pulsado un poco antes de poder hacerlo sale en cuanto se puede
const POGO_VELOCITY := -880.0
## Vida
const MAX_VIDA := 5
const INVULNERABLE := 1.0
const KNOCKBACK := Vector2(420.0, -420.0)

## Velocidad máxima. Zona Camino: caminata lenta (120). Carrera: 360 (medida de Silksong, escalada al lobo).
var max_speed := 360.0
## El lobo empieza sin poder saltar; se desbloquea más adelante en el juego.
var can_jump := true
var can_attack := false
var can_dash := false
var can_wall := false
var enabled := true
var vida := MAX_VIDA

var lobo: LoboSprite
var _coyote := 0.0
var _buffer := 0.0
var _jumping := false             # salto desde el suelo en curso (para el impulso sostenido y el corte)
var _jump_t := 0.0
var _jump_hold := 0.0
var _cut_pending := false        # ya se cortó este salto
var _drop_timer := 0.0
var _on_one_way := false
var _dash_t := 0.0
var _dash_cd := 0.0
var _dash_ready := true
var _dash_dir := 1.0
var _wall_lock := 0.0
var _wall_dir := 0.0              # -1 pared a la izquierda, 1 a la derecha, 0 ninguna
var _attack_cd := 0.0
var _attack_anim := &""
var _combo := -1                  # golpe del combo que se dio último (-1 ninguno)
var _combo_t := 99.0
var _attack_buffer := 0.0
var _dash_buffer := 0.0
var _invulnerable := 0.0
var _hurt_t := 0.0
var _dead := false
## Efectos de respuesta (efectos.gd): aplastar y estirar al lobo, polvo de los pasos y del aterrizaje.
var _squash := Vector2.ONE
var _paso_t := 0.0
var _en_suelo_antes := true
var _vy_caida := 0.0


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
	lobo.attack_frame.connect(_on_attack_frame)
	lobo.sprite.animation_finished.connect(_on_body_anim_finished)


func _physics_process(delta: float) -> void:
	var active := enabled and not _dead
	var dir := Input.get_axis("move_left", "move_right") if active and _hurt_t <= 0.0 else 0.0
	var on_floor := is_on_floor()
	_dash_cd = maxf(0.0, _dash_cd - delta)
	_attack_cd = maxf(0.0, _attack_cd - delta)
	_combo_t += delta
	if active and Input.is_action_just_pressed("attack"):
		_attack_buffer = ACTION_BUFFER
	else:
		_attack_buffer = maxf(0.0, _attack_buffer - delta)
	if active and Input.is_action_just_pressed("dash"):
		_dash_buffer = ACTION_BUFFER
	else:
		_dash_buffer = maxf(0.0, _dash_buffer - delta)
	_wall_lock = maxf(0.0, _wall_lock - delta)
	_hurt_t = maxf(0.0, _hurt_t - delta)
	_invulnerable = maxf(0.0, _invulnerable - delta)
	lobo.modulate.a = 0.45 if _invulnerable > 0.0 and fmod(_invulnerable, 0.16) < 0.08 else 1.0
	if on_floor or _wall_dir != 0.0:
		_dash_ready = true

	# --- dash
	if active and can_dash and _dash_ready and _dash_cd <= 0.0 and _dash_t <= 0.0 and _dash_buffer > 0.0:
		_dash_buffer = 0.0
		_dash_t = DASH_TIME
		_dash_cd = DASH_COOLDOWN
		_dash_ready = on_floor
		_dash_dir = signf(dir) if dir != 0.0 else lobo.facing
		lobo.face(_dash_dir)
		Efectos.polvo(get_parent(), global_position + Vector2(-_dash_dir * 20.0, -4.0), 7,
			Vector2(-_dash_dir, -0.25), 0.9, 260.0, 9.0)
		_squash = Vector2(1.18, 0.86)
	if _dash_t > 0.0:
		_dash_t -= delta
		velocity = Vector2(_dash_dir * DASH_SPEED, 0.0)
		move_and_slide()
		if is_on_wall():
			_dash_t = 0.0
		lobo.special = "dash" if _dash_t > 0.0 else ""
		_animate(delta)
		return

	# --- horizontal
	if _wall_lock <= 0.0 and _hurt_t <= 0.0:
		if absf(dir) > 0.01:
			if velocity.x * dir < 0.0:
				velocity.x = 0.0               # voltea al instante, sin derrapar
			velocity.x = move_toward(velocity.x, dir * max_speed, (ACCEL if on_floor else AIR_ACCEL) * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, (FRICTION if on_floor else AIR_FRICTION) * delta)

	# --- gravedad (sin gravedad mientras se sostiene el impulso del salto)
	var held := Input.is_action_pressed("jump") and active
	if _jumping:
		_jump_t += delta
		if velocity.y >= 0.0 or (on_floor and _jump_t > 0.05):
			_jumping = false
		elif not held and not _cut_pending and _jump_t >= JUMP_MIN:
			velocity.y *= JUMP_CUT             # soltó el botón (o fue un toque): se corta una sola vez
			_cut_pending = true
			_jump_hold = 0.0
	var g := FALL_GRAVITY if velocity.y > 0.0 else RISE_GRAVITY
	if _jumping and _jump_hold > 0.0 and (held or _jump_t < JUMP_MIN):
		_jump_hold -= delta
		g = 0.0
	else:
		_jump_hold = 0.0
	if not on_floor and absf(velocity.y) < APEX_SPEED and held:
		g *= APEX_GRAVITY
	velocity.y = minf(velocity.y + g * delta, MAX_FALL)

	# --- pared: empujando hacia ella mientras cae, resbala despacio
	_wall_dir = 0.0
	if can_wall and not on_floor and is_on_wall() and velocity.y > 0.0:
		var n := get_wall_normal().x
		if n != 0.0 and dir == -signf(n):
			_wall_dir = -signf(n)
			velocity.y = minf(velocity.y, WALL_SLIDE_SPEED)

	# --- salto (coyote time + buffer), solo si ya está desbloqueado
	_coyote = COYOTE_TIME if on_floor else maxf(0.0, _coyote - delta)
	if active and can_jump and Input.is_action_just_pressed("jump"):
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
		_jumping = true
		_jump_t = 0.0
		_jump_hold = JUMP_HOLD
		_cut_pending = false
		Efectos.polvo(get_parent(), global_position, 6, Vector2.UP, PI * 0.9, 140.0, 8.0)
		_squash = Vector2(0.86, 1.16)
	elif _buffer > 0.0 and _wall_dir != 0.0:
		velocity = Vector2(-_wall_dir * WALL_JUMP.x, WALL_JUMP.y)
		_wall_lock = WALL_JUMP_LOCK
		_buffer = 0.0
		lobo.face(-_wall_dir)
		Efectos.polvo(get_parent(), global_position + Vector2(_wall_dir * 26.0, -60.0), 6,
			Vector2(-_wall_dir, 0.2), 1.2, 180.0, 8.0)
		_squash = Vector2(0.88, 1.14)
		_wall_dir = 0.0
		lobo.special = "wall_jump"

	if can_jump and Input.is_action_just_released("jump") and velocity.y < 0.0 and _wall_lock <= 0.0:
		if not _jumping:                   # el salto desde el suelo se corta arriba, en la gravedad
			velocity.y *= JUMP_CUT
			_jump_hold = 0.0

	# --- tajos: arriba + J hacia arriba, abajo + J en el aire hacia abajo, si no hacia el frente
	if active and can_attack and _attack_cd <= 0.0 and not lobo.acting and _attack_buffer > 0.0:
		_attack_buffer = 0.0
		_attack_cd = ATTACK_COOLDOWN
		if Input.is_action_pressed("move_up"):
			_attack_anim = LoboSprite.ATTACK_UP
			_combo = -1
		elif not on_floor and Input.is_action_pressed("move_down"):
			_attack_anim = &"slash_down"
			_combo = -1
		else:
			# combo: corte ascendente, barrido y remate si se encadenan a tiempo
			_combo = (_combo + 1) % LoboSprite.ATTACKS.size() if _combo_t < COMBO_WINDOW else 0
			_attack_anim = LoboSprite.ATTACKS[_combo]
		_combo_t = 0.0
		lobo.play_attack(_attack_anim)
		attack_started.emit(_attack_anim)

	_vy_caida = velocity.y
	move_and_slide()
	_efectos_suelo(delta)

	_on_one_way = false
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var body := c.get_collider() as CollisionObject2D
		if body and (body.collision_layer & 2) != 0 and c.get_normal().y < -0.5:
			_on_one_way = true

	if not _dead and _hurt_t <= 0.0:
		if _wall_dir != 0.0:
			lobo.special = "wall_slide"
			lobo.face(-_wall_dir)          # de espaldas a la pared
		elif lobo.special == "wall_slide" or (lobo.special == "wall_jump" and (on_floor or velocity.y > 0.0)):
			lobo.special = ""
	_animate(delta)


func _on_attack_frame(anim: StringName, frame: int) -> void:
	var area := lobo.hitbox_global(anim, frame)
	if area.has_area():
		attack_hit_frame.emit(anim, area)


## El nivel la llama cuando la estocada hacia abajo dio en algo (enemigo, espinas): rebote.
func pogo() -> void:
	velocity.y = POGO_VELOCITY
	_dash_ready = true
	Efectos.golpe(get_parent(), global_position + Vector2(0, 30))
	_squash = Vector2(0.88, 1.14)


## El nivel la llama cuando un tajo dio en algo: chispas en el punto, micro-pausa y temblor.
func golpe_conectado(pos: Vector2, fuerte := false) -> void:
	Efectos.golpe(get_parent(), pos, fuerte)


## Polvo al aterrizar (según la fuerza de la caída) y a cada paso de la carrera.
func _efectos_suelo(delta: float) -> void:
	var suelo := is_on_floor()
	if suelo and not _en_suelo_antes and _vy_caida > 300.0:
		var k := clampf((_vy_caida - 300.0) / 800.0, 0.0, 1.0)
		var n := 4 + int(k * 6.0)
		Efectos.polvo(get_parent(), global_position + Vector2(-10, 0), n, Vector2.LEFT, 0.7, 120.0 + k * 140.0, 8.0)
		Efectos.polvo(get_parent(), global_position + Vector2(10, 0), n, Vector2.RIGHT, 0.7, 120.0 + k * 140.0, 8.0)
		_squash = Vector2(1.0 + 0.22 * k + 0.06, 1.0 - 0.18 * k - 0.05)
		if k > 0.85:
			Efectos.temblar(2.0, 0.10)
		_paso_t = 0.1
	_en_suelo_antes = suelo
	if suelo and absf(velocity.x) > 250.0 and _dash_t <= 0.0:
		_paso_t -= delta
		if _paso_t <= 0.0:
			_paso_t = 0.2
			var atras := -signf(velocity.x)
			Efectos.polvo(get_parent(), global_position + Vector2(atras * 14.0, -2.0), 2,
				Vector2(atras, -0.5), 0.8, 70.0, 6.0)
	else:
		_paso_t = 0.0


## Recibe un golpe desde from_x: pierde una vida, sale despedido y queda invulnerable un momento.
## Devuelve false si estaba invulnerable (no pasó nada).
func hurt(from_x: float, amount := 1) -> bool:
	if _invulnerable > 0.0 or _dead:
		return false
	vida = maxi(0, vida - amount)
	_invulnerable = INVULNERABLE
	Efectos.chispas(get_parent(), global_position + Vector2(0, -60), 10)
	Efectos.temblar(8.0, 0.25)
	Efectos.pausa(get_tree(), 0.10)
	_dash_t = 0.0
	var away := signf(global_position.x - from_x) if global_position.x != from_x else -lobo.facing
	velocity = Vector2(away * KNOCKBACK.x, KNOCKBACK.y)
	hurt_taken.emit(vida)
	if vida <= 0:
		_dead = true
		lobo.attacking = false
		lobo.special = "death"
	else:
		_hurt_t = 0.25
		lobo.attacking = false
		lobo.special = "hurt"
	return true


## Vuelve a la vida completa (al reaparecer en un punto de control).
func revive() -> void:
	vida = MAX_VIDA
	_dead = false
	_hurt_t = 0.0
	_invulnerable = 0.0
	_dash_t = 0.0
	lobo.special = ""
	lobo.modulate.a = 1.0


func is_dead() -> bool:
	return _dead


func _on_body_anim_finished() -> void:
	var anim := lobo.sprite.animation
	if anim == &"death":
		died.emit()
	elif anim == &"hurt" and lobo.special == "hurt":
		lobo.special = ""


func _animate(delta: float) -> void:
	_squash = _squash.lerp(Vector2.ONE, 1.0 - exp(-16.0 * delta))
	lobo.scale = _squash * SPRITE_SCALE
	lobo.animate(delta, absf(velocity.x) / maxf(max_speed, 1.0), velocity.x, not is_on_floor(), velocity.y)
