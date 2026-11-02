class_name Wolf
extends Node2D
## Lobo como muñeco articulado de papel recortado.
## Está dibujado mirando a la derecha; el origen del nodo queda entre los pies.
## Las piezas usan las coordenadas de la imagen de referencia (WolfData).
## Las piernas se doblan en la rodilla deformando su polígono (un solo contorno continuo),
## y la cola y la bufanda ondean con movimiento secundario.

const BASE_SCALE := 0.18          # tamaño de la referencia -> píxeles del mundo
const OUTLINE := 11.0             # grosor del contorno gris (en px de referencia)
const KNEE := Vector2(330, 684)   # rodilla (coords de referencia)
const ANKLE := Vector2(330, 752)  # tobillo

var facing := 1.0                 # 1 = derecha, -1 = izquierda
var _t := 0.0
var _phase := 0.0
var _sp := 0.0                    # velocidad suavizada 0..1
var _blink := 0.0
var _next_blink := 3.0
var _lean := 0.0
var _flip := Node2D.new()
var _body: Node2D
var _head: Node2D
var _torso: Node2D
var _arm_f: Node2D
var _tail: Node2D
var _scarf: Node2D
var _band: Node2D
var _eye: Polygon2D
var _leg_f: Node2D
var _leg_b: Node2D
var _leg_f_base := PackedVector2Array()
var _leg_b_base := PackedVector2Array()
var _tail_pts := PackedVector2Array()
var _scarf_pts := PackedVector2Array()
var _fringe_nodes: Array[Line2D] = []
var _fringe_base: Array = []


func _ready() -> void:
	add_child(_flip)
	_build_shadow()
	_body = Node2D.new()
	_flip.add_child(_body)

	_tail = _part(WolfData.P_TAIL, WolfData.C_TAILGRAY, WolfData.J_TAIL)
	var tail_base := _part(WolfData.P_TAIL_BASE, WolfData.C_BLACK, WolfData.J_TAIL)
	tail_base.position = Vector2.ZERO
	_tail.add_child(tail_base)
	_body.add_child(_tail)
	# la cola es negra y solo la punta es gris (degradado por vértice)
	var tip := Vector2(88, 508)
	var vc := PackedColorArray()
	for p in WolfData.P_TAIL:
		var k := smoothstep(35.0, 120.0, p.distance_to(tip))
		vc.append(WolfData.C_TAILGRAY.lerp(WolfData.C_BLACK, k))
	var tf := _tail.get_node("Fill") as Polygon2D
	tf.color = Color.WHITE
	tf.vertex_colors = vc

	_leg_b = _leg(WolfData.P_LEG_BACK)
	_leg_b_base = _local_pts(_densify(WolfData.P_LEG_BACK, 14.0), WolfData.J_HIP)
	_body.add_child(_leg_b)

	_scarf = _part(_densify(WolfData.P_SCARF_TAIL, 16.0), WolfData.C_RED, WolfData.J_SCARF)
	_body.add_child(_scarf)
	for f in WolfData.FRINGE:
		var l := Line2D.new()
		l.width = OUTLINE
		l.default_color = WolfData.C_GRAY
		l.begin_cap_mode = Line2D.LINE_CAP_ROUND
		l.end_cap_mode = Line2D.LINE_CAP_ROUND
		l.antialiased = true
		var pts := PackedVector2Array([f[0] - WolfData.J_SCARF, f[1] - WolfData.J_SCARF])
		l.points = pts
		_scarf.add_child(l)
		_fringe_nodes.append(l)
		_fringe_base.append(pts)

	_torso = _part(WolfData.P_TORSO, WolfData.C_BLACK, WolfData.J_HIP)
	_body.add_child(_torso)

	_leg_f = _leg(WolfData.P_LEG_FRONT)
	_leg_f_base = _local_pts(_densify(WolfData.P_LEG_FRONT, 14.0), WolfData.J_HIP)
	_body.add_child(_leg_f)

	_head = _part(WolfData.P_HEAD, WolfData.C_BLACK, WolfData.J_NECK)
	_body.add_child(_head)
	_add_flat(_head, WolfData.P_EAR_BACK_IN, WolfData.C_GRAY, WolfData.J_NECK)
	_add_flat(_head, WolfData.P_EAR_FRONT_IN, WolfData.C_GRAY, WolfData.J_NECK)
	_add_flat(_head, WolfData.P_NOSE, WolfData.C_GRAY, WolfData.J_NECK)
	_eye = Polygon2D.new()
	var eye := PackedVector2Array()
	for i in 20:
		var a := TAU * i / 20.0
		eye.append(Vector2(cos(a) * WolfData.EYE_R.x, sin(a) * WolfData.EYE_R.y))
	_eye.polygon = eye
	_eye.color = WolfData.C_WHITE
	_eye.antialiased = true
	_eye.position = WolfData.EYE_C - WolfData.J_NECK
	_head.add_child(_eye)

	_band = _part(WolfData.P_BAND, WolfData.C_RED, WolfData.J_NECK)
	_body.add_child(_band)

	_arm_f = _part(WolfData.P_ARM_FRONT, WolfData.C_BLACK, WolfData.J_SHOULDER)
	_body.add_child(_arm_f)

	_tail_pts = _local_pts(WolfData.P_TAIL, WolfData.J_TAIL)
	_scarf_pts = _local_pts(_densify(WolfData.P_SCARF_TAIL, 16.0), WolfData.J_SCARF)

	scale = Vector2.ONE * BASE_SCALE
	_apply_legs(0.0, 0.0, 0.0, 0.0)


# ---------- construcción ----------

func _local_pts(pts: PackedVector2Array, joint: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p - joint)
	return out


## Inserta puntos en las aristas largas para que la pierna se doble con suavidad.
func _densify(pts: PackedVector2Array, max_len: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in pts.size():
		var a := pts[i]
		var b := pts[(i + 1) % pts.size()]
		out.append(a)
		var n := int(a.distance_to(b) / max_len)
		for k in range(1, n + 1):
			out.append(a.lerp(b, float(k) / float(n + 1)))
	return out


func _part(pts: PackedVector2Array, fill: Color, joint: Vector2) -> Node2D:
	var n := Node2D.new()
	n.position = joint - WolfData.ROOT
	var local := _local_pts(pts, joint)
	var poly := Polygon2D.new()
	poly.polygon = local
	poly.color = fill
	poly.antialiased = true
	poly.name = "Fill"
	n.add_child(poly)
	var line := Line2D.new()
	line.points = local
	line.closed = true
	line.width = OUTLINE
	line.default_color = WolfData.C_GRAY
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true
	line.name = "Outline"
	n.add_child(line)
	return n


func _leg(pts: PackedVector2Array) -> Node2D:
	return _part(_densify(pts, 14.0), WolfData.C_BLACK, WolfData.J_HIP)


func _add_flat(parent: Node2D, pts: PackedVector2Array, fill: Color, joint: Vector2) -> void:
	var poly := Polygon2D.new()
	poly.polygon = _local_pts(pts, joint)
	poly.color = fill
	poly.antialiased = true
	parent.add_child(poly)


func _build_shadow() -> void:
	var sh := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		pts.append(Vector2(cos(a) * 120.0 + 20.0, sin(a) * 22.0))
	sh.polygon = pts
	sh.color = Color(0, 0, 0, 0.30)
	sh.z_index = -1
	add_child(sh)


# ---------- animación ----------

## Llamar cada frame. speed01: 0 = quieto, 1 = caminando a toda velocidad.
## vel_x: velocidad horizontal (solo para decidir hacia dónde mira).
func animate(delta: float, speed01: float, vel_x: float = 0.0, air: bool = false, vy: float = 0.0) -> void:
	_t += delta
	if absf(vel_x) > 6.0:
		facing = signf(vel_x)
	_flip.scale.x = lerpf(_flip.scale.x, facing, 1.0 - exp(-18.0 * delta))

	_sp = lerpf(_sp, clampf(speed01, 0.0, 1.0), 1.0 - exp(-7.0 * delta))
	var sp := _sp
	var amp := smoothstep(0.02, 0.55, sp)

	# la zancada avanza más rápido al ir más rápido (siempre continua, sin saltos)
	_phase += delta * TAU * lerpf(0.75, 1.45, sp) * amp
	var ph := _phase

	# ---- piernas: muslo + rodilla + pie plano
	var thigh_f := -0.42 * amp * sin(ph)
	var thigh_b := -0.42 * amp * sin(ph + PI)
	var knee_f := amp * 0.95 * pow(maxf(0.0, cos(ph + 0.6)), 1.3)
	var knee_b := amp * 0.95 * pow(maxf(0.0, cos(ph + PI + 0.6)), 1.3)
	if air:
		thigh_f = -0.5
		thigh_b = 0.35
		knee_f = 0.5
		knee_b = 0.2
	_apply_legs(thigh_f, knee_f, thigh_b, knee_b)

	# ---- cuerpo: sube y baja suave, se inclina hacia adelante al avanzar
	var bob := -cos(ph * 2.0) * 5.0 * amp
	var breathe := sin(_t * 2.1) * 1.6 * (1.0 - amp)
	_body.position.y = bob + breathe
	_lean = lerpf(_lean, 0.07 * sp, 1.0 - exp(-6.0 * delta))
	_torso.rotation = _lean + sin(ph) * 0.012 * amp
	_head.rotation = -_lean * 0.5 + sin(ph * 2.0 - 0.9) * 0.018 * amp + sin(_t * 1.5) * 0.012
	_band.rotation = _head.rotation * 0.7

	# ---- brazo: se mueve poco, con un pequeño retraso
	_arm_f.rotation = 0.05 + amp * 0.13 * sin(ph - 0.5) + _lean * 0.5

	# ---- parpadeo
	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink = 0.14
		_next_blink = randf_range(2.5, 5.5)
	if _blink > 0.0:
		_blink -= delta
		_eye.scale.y = 0.12
	else:
		_eye.scale.y = 1.0

	# ---- cola y bufanda: movimiento secundario (se estiran y se elevan al correr)
	_tail.rotation = lerpf(_tail.rotation, -0.10 * sp + sin(_t * 1.3) * 0.04 + sin(ph) * 0.05 * amp, 1.0 - exp(-8.0 * delta))
	var up := -sp * 9.0 - (clampf(vy * 0.04, -16.0, 16.0) if air else 0.0)
	var stretch := 1.0 + 0.16 * sp
	var amp_s := 9.0 + 16.0 * sp
	var spd_s := 4.5 + 3.5 * sp
	_wave(_scarf, _scarf_pts, amp_s, 3.2, spd_s, up, stretch)
	for i in _fringe_nodes.size():
		var base: PackedVector2Array = _fringe_base[i]
		var out := PackedVector2Array()
		for p in base:
			out.append(_deform(p, amp_s, 3.2, spd_s, up, stretch))
		_fringe_nodes[i].points = out
	_wave(_tail, _tail_pts, 4.0 + 7.0 * sp, 2.4, 2.6 + 1.6 * sp, 0.0, 1.0)


func _apply_legs(thigh_f: float, knee_f: float, thigh_b: float, knee_b: float) -> void:
	_bend(_leg_f, _leg_f_base, thigh_f, knee_f)
	_bend(_leg_b, _leg_b_base, thigh_b, knee_b)


## Gira la pierna en la cadera y dobla la rodilla deformando el polígono.
func _bend(leg: Node2D, base: PackedVector2Array, thigh: float, knee: float) -> void:
	leg.rotation = thigh
	var k := KNEE - WolfData.J_HIP
	var a := ANKLE - WolfData.J_HIP
	var ankle2 := k + (a - k).rotated(knee)
	var foot_angle := -(thigh + knee) * 0.85         # el pie se mantiene casi plano
	var out := PackedVector2Array()
	for p in base:
		var w := smoothstep(k.y - 16.0, k.y + 16.0, p.y)
		var q := p
		if w > 0.0:
			q = k + (p - k).rotated(knee * w)
		var wf := smoothstep(a.y - 26.0, a.y - 4.0, p.y)
		if wf > 0.0:
			q = ankle2 + (q - ankle2).rotated(foot_angle * wf)
		out.append(q)
	if Geometry2D.triangulate_polygon(out).is_empty():
		return
	(leg.get_node("Fill") as Polygon2D).polygon = out
	(leg.get_node("Outline") as Line2D).points = out


func _deform(p: Vector2, amp: float, freq: float, speed: float, up: float, stretch: float) -> Vector2:
	var d := clampf(absf(p.x) / 190.0, 0.0, 1.6)
	var q := Vector2(p.x * stretch, p.y)
	return q + Vector2(0.0, sin(_t * speed - d * freq * 1.6) * amp * d * d * 0.55 + up * d)


func _wave(node: Node2D, base: PackedVector2Array, amp: float, freq: float, speed: float, up: float, stretch: float) -> void:
	var out := PackedVector2Array()
	for p in base:
		out.append(_deform(p, amp, freq, speed, up, stretch))
	# si la deformación produjera un polígono inválido (no se podría rellenar), se conserva el anterior
	if Geometry2D.triangulate_polygon(out).is_empty():
		return
	(node.get_node("Fill") as Polygon2D).polygon = out
	(node.get_node("Outline") as Line2D).points = out
