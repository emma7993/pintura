class_name Sombras
extends Node2D
## Las sombras que persiguen al lobo (arte de art/enemigos/sombras_v001): una pared de bruma negra que avanza
## desde la izquierda (borde animado + relleno repetido, ojos y jirones) y manos que brotan de charcos en el
## suelo para atraparlo. La lógica de persecución (dónde está el frente, velocidad, la pincelada que las
## detiene) la lleva el nivel; aquí solo se dibujan y se resuelve si una mano lo agarró.

const ART := "res://art/enemigos/sombras_v001"
const MIST_TOP := -280.0                  # y de mundo del borde superior de la bruma (1024 px de alto)
const FRONT_TIP := 506.0                  # x de la celda del frente donde terminan los jirones
const FRONT_OPAQUE := 352.0               # x de la celda hasta donde el frente es negro opaco
const HAND_SCALE := 0.55                  # manos de ~170–210 px frente a un lobo de ~130
const ANCHORS := {"A": Vector2(128, 480), "B": Vector2(64, 480), "C": Vector2(128, 480)}
const PUDDLE_ANCHOR := Vector2(192, 47)

const MAX_HANDS := 7
const SPEEDS := {"A": 1.0, "B": 0.85, "C": 1.2}   # la pesada es más lenta; la pequeña, más rápida

## Intervalo entre manos (s): [mínimo, máximo]. El nivel lo ajusta según el tramo.
var hand_every := Vector2(1.2, 2.0)
## Velocidad con la que se arrastran tras el lobo (px/s); el nivel la pone un poco por debajo de la del lobo.
var chase_speed := 110.0
var hands_on := false

var _mist := Node2D.new()
var _front: AnimatedSprite2D
var _mist_frames: SpriteFrames
var _hand_frames: SpriteFrames
var _contacts := {}                       # "A_grab:3" -> contacto (px de celda)
var _hands: Array[Dictionary] = []
var _next_hand := 2.0
var _next_wisp := 0.5
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	z_index = 20                           # cubren al lobo cuando lo alcanzan
	_mist_frames = load(ART + "/Godot/Sombras_Bruma.tres")
	_hand_frames = load(ART + "/Godot/Sombras_Manos.tres")
	for c in JSON.parse_string(FileAccess.get_file_as_string(ART + "/hand_contacts.json")):
		if c.hits:
			_contacts["%s:%d" % [c.animation, int(c.frame)]] = Vector2(c.contact_xy[0], c.contact_xy[1])
	add_child(_mist)
	# relleno: body.png repetido hacia la izquierda; su borde derecho empalma con el lado opaco del frente
	var body := Sprite2D.new()
	body.texture = load(ART + "/Bruma/body.png")
	body.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	body.region_enabled = true
	body.region_rect = Rect2(0, 0, 4096, 1024)
	body.centered = false
	body.position = Vector2(-4096, 0)
	_mist.add_child(body)
	_front = _anim(_mist_frames, "front_loop", Vector2.ZERO, _mist)
	for e in [["eyes_01", Vector2(190, 300)], ["eyes_02", Vector2(70, 470)], ["eyes_03", Vector2(240, 610)]]:
		var eye := _anim(_mist_frames, e[0], e[1], _mist)
		eye.frame = _rng.randi() % 4
	_mist.visible = false


func _anim(frames: SpriteFrames, anim: String, at: Vector2, parent: Node) -> AnimatedSprite2D:
	var a := AnimatedSprite2D.new()
	a.sprite_frames = frames
	a.centered = false
	a.position = at
	a.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(a)
	a.play(anim)
	return a


## Coloca la pared de bruma: `front_x` es el frente lógico (el lobo cae si queda a menos de 30 px).
## Los jirones asoman ~80 px por delante de él.
func set_front(front_x: float, alpha: float) -> void:
	_mist.visible = front_x != -INF and alpha > 0.0
	if not _mist.visible:
		return
	_mist.position = Vector2(front_x + 80.0 - FRONT_TIP, MIST_TOP)
	_mist.modulate.a = alpha


## Al chocar con la pincelada de color: el borde se desgarra y retrocede.
func recoil() -> void:
	if _front.animation == &"recoil":
		return
	_front.play("recoil")
	var tw := create_tween()
	tw.tween_property(_front, "position:x", -140.0, 0.6).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	if not _mist.visible:
		return
	# jirones sueltos que se adelantan desde el borde y se disipan
	_next_wisp -= delta
	if _next_wisp <= 0.0 and _front.animation == &"front_loop":
		_next_wisp = _rng.randf_range(0.5, 1.1)
		var w := _anim(_mist_frames, "wisp_%02d" % _rng.randi_range(1, 6),
			Vector2(_rng.randf_range(300, 420), _rng.randf_range(420, 900)), _mist)
		w.animation_finished.connect(w.queue_free)


# --- manos ------------------------------------------------------------------------------------------

## Avanza las manos: brotan detrás del lobo, se arrastran tras él por el suelo (cada vez más), y cuando
## alguna lo tiene al alcance da el zarpazo. Devuelve true si una lo agarró.
## ground_at(x) da el suelo bajo una mano; NAN si ahí no hay suelo (un hueco): la mano se hunde.
func update_hands(delta: float, wolf: Vector2, front_x: float, ground_at: Callable) -> bool:
	if hands_on:
		_next_hand -= delta
		if _next_hand <= 0.0:
			_next_hand = _rng.randf_range(hand_every.x, hand_every.y)
			var hx := wolf.x - _rng.randf_range(60.0, 240.0)
			var gy: float = ground_at.call(hx)
			if hx > front_x + 60.0 and _hands.size() < MAX_HANDS and not is_nan(gy):
				_spawn_hand(hx, gy)
	var hit := false
	for h in _hands.duplicate():
		var spr: AnimatedSprite2D = h.sprite
		var node: Node2D = h.node
		var anim := String(spr.animation)
		h.t += delta
		var dx := wolf.x - node.position.x
		var moving := anim.ends_with("_emerge") or anim.ends_with("_reach")
		if moving:
			# se arrastran hacia el lobo, sin encimarse unas con otras
			var dir := signf(dx) if absf(dx) > 4.0 else float(h.dir)
			var push := 0.0
			for o in _hands:
				if o != h:
					var d: float = node.position.x - (o.node as Node2D).position.x
					if absf(d) < 46.0:
						push += signf(d) * (46.0 - absf(d)) * 4.0
			var speed: float = chase_speed * SPEEDS[h.design] * (0.5 if anim.ends_with("_emerge") else 1.0)
			node.position.x += (dir * speed + push) * delta
			var gy: float = ground_at.call(node.position.x)
			if is_nan(gy):
				spr.play(h.design + "_sink")
				continue
			node.position.y = gy + 6.0
			if dir != h.dir:
				h.dir = dir
				spr.scale.x = HAND_SCALE * dir
			if absf(dx) > 950.0:
				spr.play(h.design + "_sink")            # se quedó muy atrás
			elif anim.ends_with("_reach") and h.t >= h.reach_until and absf(dx) < 105.0 and absf(wolf.y - node.position.y) < 120.0:
				spr.play(h.design + "_grab")
		elif anim.ends_with("_grab") and (spr.frame == 2 or spr.frame == 3):
			var c: Vector2 = _contacts.get("%s_grab:%d" % [h.design, spr.frame + 1], ANCHORS[h.design])
			var anchor: Vector2 = ANCHORS[h.design]
			var local: Vector2 = (c - anchor) * HAND_SCALE * Vector2(h.dir, 1.0)
			var p: Vector2 = node.position + local
			if absf(wolf.x - p.x) < 46.0 and absf((wolf.y - 60.0) - p.y) < 90.0:
				hit = true
	return hit


func _spawn_hand(x: float, ground_y: float) -> void:
	var design: String = ["A", "B", "C"][_rng.randi() % 3]
	var node := Node2D.new()
	node.position = Vector2(x, ground_y + 6.0)
	node.z_index = -1                      # por detrás de la bruma
	add_child(node)
	var puddle := _anim(_hand_frames, "puddle_loop", -PUDDLE_ANCHOR * HAND_SCALE, node)
	puddle.scale = Vector2.ONE * HAND_SCALE
	var spr := _anim(_hand_frames, design + "_emerge", Vector2.ZERO, node)
	spr.offset = -ANCHORS[design]
	spr.scale = Vector2(HAND_SCALE, HAND_SCALE)
	if design == "C":
		spr.speed_scale = 1.25             # la pequeña es más rápida
	var h := {"node": node, "sprite": spr, "puddle": puddle, "design": design, "dir": 1.0, "t": 0.0,
		"reach_until": _rng.randf_range(0.25, 0.6)}
	_hands.append(h)
	spr.animation_finished.connect(_on_hand_finished.bind(h))


func _on_hand_finished(h: Dictionary) -> void:
	var spr: AnimatedSprite2D = h.sprite
	var anim := String(spr.animation)
	if anim.ends_with("_emerge"):
		spr.play(h.design + "_reach")
	elif anim.ends_with("_grab"):
		spr.play(h.design + "_sink")
	elif anim.ends_with("_sink") or anim.ends_with("_dissolve"):
		_remove(h)


func _remove(h: Dictionary) -> void:
	_hands.erase(h)
	var tw := create_tween()
	tw.tween_property(h.puddle, "modulate:a", 0.0, 0.4)
	tw.tween_callback((h.node as Node).queue_free)


## Todas las manos se deshacen (tocan el color, o las sombras se van).
func dissolve_hands() -> void:
	for h in _hands:
		var spr: AnimatedSprite2D = h.sprite
		if not String(spr.animation).ends_with("_dissolve"):
			spr.play(h.design + "_dissolve")


## Quita las manos sin animación (al volver al punto de control).
func clear_hands() -> void:
	for h in _hands:
		(h.node as Node).queue_free()
	_hands.clear()
	_next_hand = 1.5
