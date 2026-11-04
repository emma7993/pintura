extends Node
## Prueba automática del nivel 1 (Camino), de principio a fin:
##   1) huye de las sombras (camina, se apura, corre), salta el hueco, toma el pincel y da la pincelada;
##   2) sube el escalón y la meseta, salta el foso de espinas y baja por la boca de la cueva;
##   3) en la cámara honda toma el tintero, sale por la repisa y va a la izquierda hasta la cascada;
##   4) vuelve bajo el pozo, sube a la repisa, rompe la tapa, sube por el tiro hasta el arco, lo pinta y entra.
## Se activa con `-- --auto-nivel1` (probar_nivel1.bat). El nivel escribe en el log su guion ([nivel1]).

const LIMITE := 150.0             # segundos: si no terminó, algo falló
const SALTO := 0.45               # mantener el salto para llegar alto

var _t := 0.0
var _fase := 0
var _salto := -1.0
var _sostiene := false
var _pinto_barrera := false
var _pulso := -1.0                # momento del último F (para no repetirlo)
var _entro := -1.0
var _ultimo_log := 0.0
var _nivel: Node
var _w: Player


func _ready() -> void:
	_nivel = get_parent()
	_w = _nivel.walker


func _process(delta: float) -> void:
	_t += delta
	for a in ["paint", "interact"]:
		Input.action_release(a)
	# suelta el salto una sola vez (soltarlo en el mismo cuadro de otro salto lo cortaría)
	if _sostiene and _t - _salto > SALTO:
		_sostiene = false
		Input.action_release("jump")
	if not _nivel.shadows_gone:
		_huir()
	else:
		_explorar()
	if _t - _ultimo_log >= 2.0:
		_ultimo_log = _t
		print("[auto] %.1f s: fase %d  x=%d y=%d vel=%d" % [_t, _fase, _w.position.x, _w.position.y, _w.velocity.x])
	if _entro >= 0.0 and _t - _entro > 1.5:
		print("[auto] %.1f s: FIN OK" % _t)
		get_tree().quit()
	elif _t > LIMITE:
		print("[auto] %.1f s: tiempo agotado en fase %d, x=%d y=%d. FIN SIN TERMINAR" % [_t, _fase, _w.position.x, _w.position.y])
		get_tree().quit()


# --- parte 1: las sombras ------------------------------------------------------------------------------

func _huir() -> void:
	var x := _w.position.x
	_mover(1.0)
	if _w.can_jump and _w.is_on_floor() and x > _nivel.GAP.x - 45.0 and x < _nivel.GAP.x:
		_saltar("el hueco")
	if not _pinto_barrera and _nivel.has_brush and (x - _nivel.shadow_x < 380.0 or x > _nivel.EXIT_X - 350.0):
		_pinto_barrera = true
		_f("pincelada (sombras a %d px)" % (x - _nivel.shadow_x))


# --- parte 2: plataformas, cueva, tintero, cascada, pozo y arco --------------------------------------

func _explorar() -> void:
	var x := _w.position.x
	var y := _w.position.y
	# en el suelo, sin pintar y no en el mismo instante de un salto (aún no despega)
	var suelo: bool = _w.is_on_floor() and not _nivel._acting and (_salto < 0.0 or _t - _salto > 0.3)
	var n: Node = _nivel
	match _fase:
		0:  # hasta el escalón; salta encima
			_mover(1.0)
			if suelo and x >= n.STEP_X.x - 130.0 and x < n.STEP_X.x - 40.0 and _cerca(y, n.HIGH_Y) and _w.velocity.x > 100.0:
				_saltar("al escalón")
				_fase = 1
			elif suelo and x >= n.STEP_X.x - 40.0 and _cerca(y, n.HIGH_Y) and _retro == -INF:
				_retroceder(n.STEP_X.x - 320.0)      # se pasó: vuelve para tomar impulso
		1:  # del escalón a la meseta
			_mover(1.0)
			if suelo and _cerca(y, n.STEP_Y) and x >= n.STEP_X.y - 40.0:
				_saltar("a la meseta")
				_fase = 2
			elif suelo and _cerca(y, n.HIGH_Y):
				_fase = 0                  # no llegó: vuelve a intentar
				_retroceder(n.STEP_X.x - 160.0)
		2:  # por la meseta y abajo, hacia el foso
			_mover(1.0)
			if suelo and _cerca(y, n.STEP_Y):
				_saltar("a la meseta (otra vez)")
			if suelo and _cerca(y, n.HIGH_Y) and x > n.PLATEAU.y:
				_fase = 3
			elif suelo and _cerca(y, n.HIGH_Y) and x < n.PLATEAU.x:
				_fase = 0
		3:  # salta el foso de espinas
			_mover(1.0, true)
			if suelo and x >= n.PIT.x - 40.0 and x < n.PIT.x:
				_saltar("el foso")
				_fase = 4
		4:
			_mover(1.0, true)
			if suelo and x > n.PIT.y:
				_fase = 5
			elif suelo and x < n.PIT.x:
				_fase = 3                  # cayó y volvió antes del foso
		5:  # a la boca de la cueva
			_ir((n.HOLE.x + n.HOLE.y) * 0.5, false)
			if suelo and y > n.CAVE_TOP:
				_fase = 6
		6:  # a la cámara y al tintero
			if _ir(n.ALTAR_X, false) and suelo and _cerca(y, n.CHAMBER_Y):
				if not Inventario.tintero:
					_f("toma el tintero")
				else:
					_fase = 7
		7:  # sale de la cámara por la repisa
			_mover(-1.0)
			if suelo and _cerca(y, n.CHAMBER_Y) and x <= n.CHAMBER.x + 340.0:
				_saltar("a la repisa de la cámara")
				_fase = 8
		8:
			_mover(-1.0)
			if suelo and _cerca(y, n.CHAMBER_LEDGE_Y):
				_saltar("fuera de la cámara")
			elif suelo and _cerca(y, n.CAVE_Y) and x < n.CHAMBER.x:
				_fase = 9
			elif suelo and _cerca(y, n.CHAMBER_Y) and x < n.CHAMBER.x + 200.0:
				_fase = 7
				_retroceder(n.CHAMBER.x + 330.0)
		9:  # a la cascada y llena el tintero
			if _ir(n.FALL_X + 60.0, false) and suelo:
				if Inventario.tinta <= 0.0:
					_f("llena el tintero")
				else:
					_fase = 10
		10:  # bajo el pozo: sube a la repisa de 965
			if _ir(n.WELL_X, false) and suelo:
				if _cerca(y, n.WELL_LEDGES[1]):
					_fase = 11
				else:
					_saltar("repisa del pozo")
		11:  # rompe la tapa
			_mover(0.0)
			if n.well_open:
				_fase = 12
			elif suelo:
				_f("golpea la tapa")
		12:  # sube por el tiro hasta el suelo alto
			_ir(n.WELL_X, false)
			if suelo and _cerca(y, n.HIGH_Y):
				_fase = 13
			elif suelo:
				_saltar("tiro del pozo")
		13:  # al arco: lo pinta y entra
			if _ir(n.EXIT_X, false) and suelo:
				if not n.gate_open and n._gate_k == 0.0:
					_f("pinta el arco")
				elif n.gate_open and n.near_exit and _entro < 0.0:
					_entro = _t
					Input.action_press("interact")
					print("[auto] %.1f s: pulsa E en la puerta" % _t)


# --- ayudas --------------------------------------------------------------------------------------------

## Camina hacia `meta`; devuelve true al llegar (a menos de 22 px).
func _ir(meta: float, correr: bool) -> bool:
	var dx := meta - _w.position.x
	if absf(dx) < 22.0:
		_mover(0.0)
		return true
	_mover(signf(dx), correr)
	return false


var _retro := -INF


func _retroceder(hasta: float) -> void:
	_retro = hasta


func _mover(dir: float, correr := false) -> void:
	if _retro != -INF:
		# vuelve atrás para tomar impulso antes de repetir un salto
		if absf(_w.position.x - _retro) < 25.0:
			_retro = -INF
		else:
			dir = signf(_retro - _w.position.x)
	Input.action_release("move_left")
	Input.action_release("move_right")
	if dir > 0.0:
		Input.action_press("move_right")
	elif dir < 0.0:
		Input.action_press("move_left")


func _saltar(que: String) -> void:
	if _salto >= 0.0 and _t - _salto < SALTO + 0.15:
		return
	Input.action_press("jump")
	_salto = _t
	_sostiene = true
	print("[auto] %.1f s: salta (%s) en x=%d y=%d" % [_t, que, _w.position.x, _w.position.y])


func _f(que: String) -> void:
	if _t - _pulso < 0.6:
		return
	_pulso = _t
	Input.action_press("paint")
	print("[auto] %.1f s: F — %s" % [_t, que])


func _cerca(y: float, nivel: float) -> bool:
	return absf(y - nivel) < 10.0
