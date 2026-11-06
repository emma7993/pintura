class_name Efectos
extends Node2D
## Efectos de respuesta del lobo (el "jugo" de la grabación de Silksong): polvo al despegar, aterrizar,
## correr, saltar de la pared y hacer dash; chispas y micro-pausa al golpear; temblor de cámara.
## Cada ráfaga es un Efectos que se dibuja solo y se borra al terminar. La pausa y el temblor son estáticos:
## las zonas suman Efectos.temblor_ahora() al offset de su cámara.

const POLVO := Color(0.42, 0.40, 0.38, 0.42)     # polvo de grafito: se lee sobre el papel claro de la pintura
const CHISPA := Color(0.10, 0.09, 0.09, 1.0)     # chispas de tinta (salpicaduras del pincel)

static var _temblor_fuerza := 0.0
static var _temblor_dur := 0.0
static var _temblor_inicio := 0
static var _pausas := 0
static var _ultimo_golpe := -1000

var _parts: Array = []     # cada una: {p, v, r, crece, vida, total, chispa}
var _gravedad := 0.0


## Nube de polvo en pos (coordenadas de mundo). dir: hacia dónde sale; abre: ángulo de dispersión (rad).
static func polvo(padre: Node, pos: Vector2, n: int, dir: Vector2, abre: float, rapidez: float, tam: float) -> void:
	if padre == null:
		return
	var e := Efectos.new()
	e.position = pos
	e._gravedad = -40.0                          # el polvo sube un poco y se frena
	for i in n:
		var ang := dir.angle() + randf_range(-abre, abre) * 0.5
		var vel := Vector2.from_angle(ang) * rapidez * randf_range(0.45, 1.0)
		var total := randf_range(0.30, 0.55)
		e._parts.append({"p": Vector2(randf_range(-6, 6), randf_range(-3, 1)), "v": vel,
			"r": tam * randf_range(0.6, 1.1), "crece": tam * randf_range(0.8, 1.6),
			"vida": total, "total": total, "chispa": false})
	padre.add_child(e)


## Chispas de impacto: salpicaduras de tinta que salen en todas direcciones y caen un poco.
static func chispas(padre: Node, pos: Vector2, n: int = 9) -> void:
	if padre == null:
		return
	var e := Efectos.new()
	e.position = pos
	e.z_index = 5
	e._gravedad = 900.0
	for i in n:
		var vel := Vector2.from_angle(randf() * TAU) * randf_range(260.0, 620.0)
		var total := randf_range(0.12, 0.26)
		e._parts.append({"p": Vector2.ZERO, "v": vel, "r": randf_range(1.6, 2.6), "crece": 0.0,
			"vida": total, "total": total, "chispa": true})
	padre.add_child(e)


## Micro-pausa del juego (hitstop): el tiempo casi se detiene unos milisegundos reales.
static func pausa(arbol: SceneTree, segundos: float) -> void:
	if arbol == null or segundos <= 0.0:
		return
	_pausas += 1
	Engine.time_scale = 0.03
	await arbol.create_timer(segundos, true, false, true).timeout
	_pausas -= 1
	if _pausas <= 0:
		_pausas = 0
		Engine.time_scale = 1.0


## Temblor de cámara: fuerza en px, se apaga en dur segundos (tiempo real).
static func temblar(fuerza: float, dur: float) -> void:
	var queda := _temblor_restante()
	if fuerza * dur < queda:
		return                                   # ya hay un temblor más fuerte en curso
	_temblor_fuerza = fuerza
	_temblor_dur = dur
	_temblor_inicio = Time.get_ticks_msec()


static func temblor_ahora() -> Vector2:
	var t := (Time.get_ticks_msec() - _temblor_inicio) / 1000.0
	if t >= _temblor_dur:
		return Vector2.ZERO
	var k := _temblor_fuerza * (1.0 - t / _temblor_dur)
	return Vector2(randf_range(-k, k), randf_range(-k, k)).round()


static func _temblor_restante() -> float:
	var t := (Time.get_ticks_msec() - _temblor_inicio) / 1000.0
	return maxf(0.0, _temblor_dur - t) * _temblor_fuerza


## Golpe que conectó (enemigo, espinas, objeto): chispas, pausa y temblor. Ignora repeticiones del mismo
## golpe (dos avisos en menos de 0.1 s).
static func golpe(padre: Node, pos: Vector2, fuerte := false) -> void:
	var ahora := Time.get_ticks_msec()
	if ahora - _ultimo_golpe < 100:
		return
	_ultimo_golpe = ahora
	chispas(padre, pos, 12 if fuerte else 8)
	temblar(6.0 if fuerte else 3.0, 0.18 if fuerte else 0.12)
	if padre:
		pausa(padre.get_tree(), 0.08 if fuerte else 0.05)


func _process(delta: float) -> void:
	var vivas := 0
	for q in _parts:
		if q.vida <= 0.0:
			continue
		q.vida -= delta
		q.v *= exp(-(2.0 if q.chispa else 5.0) * delta)
		q.v.y += _gravedad * delta
		q.p += q.v * delta
		q.r += q.crece * delta
		vivas += 1
	if vivas == 0:
		queue_free()
	queue_redraw()


func _draw() -> void:
	for q in _parts:
		if q.vida <= 0.0:
			continue
		var k: float = q.vida / q.total
		if q.chispa:
			var c := CHISPA
			c.a = k
			draw_line(q.p, q.p - (q.v as Vector2) * 0.03, c, q.r, true)
		else:
			var c := POLVO
			c.a = POLVO.a * k * k
			draw_circle(q.p, q.r * 1.35, Color(c, c.a * 0.35))
			draw_circle(q.p, q.r, c)
