extends Node
## Prueba automática del nivel 1 (Camino): corre a la derecha, salta a la plataforma alta, toma el pincel,
## pinta la barrera cuando las sombras se acercan, moja el pincel en el tintero, vuelve a la puerta, la pinta
## y entra.
## Se activa con `-- --auto-nivel1` (probar_nivel1.bat).
## El nivel escribe en el log cada momento del guion ([nivel1]); aquí se anota lo que hace el "jugador".

const LIMITE := 95.0              # segundos: si no terminó, algo falló

var _t := 0.0
var _salto := -1.0                # momento en que se pulsó el salto
var _pinto_barrera := false
var _pinto_puerta := false
var _mojo := false
var _entro := -1.0
var _ultimo_log := 0.0
var _nivel: Node


func _ready() -> void:
	_nivel = get_parent()


func _process(delta: float) -> void:
	_t += delta
	var w: Player = _nivel.walker
	var x := w.position.x
	for a in ["paint", "interact"]:
		Input.action_release(a)

	# caminar: a la derecha; sin sombras, al tintero y luego de vuelta a la puerta
	var dir := 1.0
	if _nivel.shadows_gone:
		var meta: float = _nivel.EXIT_X if _nivel.brush == "tinta" or _pinto_puerta else _nivel.ALTAR_X
		var dx: float = meta - x
		dir = 0.0 if absf(dx) < 30.0 else signf(dx)
	_mover(dir)

	# salto: al llegar al borde del hueco
	if _salto < 0.0 and w.can_jump and w.is_on_floor() and x > _nivel.GAP.x - 45.0 and x < _nivel.GAP.x:
		Input.action_press("jump")
		_salto = _t
		print("[auto] %.1f s: salta en x=%d (velocidad %d)" % [_t, x, w.velocity.x])
	if _salto >= 0.0 and _t - _salto > 0.4:
		Input.action_release("jump")
		if w.is_on_floor() and x < _nivel.GAP.x:
			_salto = -1.0          # volvió al punto de control: puede intentar de nuevo
	if _salto >= 0.0 and _t - _salto > 0.4 and _t - _salto < 0.6 and w.is_on_floor():
		print("[auto] %.1f s: aterriza en x=%d y=%d" % [_t, x, w.position.y])

	# pintar la barrera: cuando las sombras están a menos de 380 px
	if not _pinto_barrera and _nivel.has_brush and x - _nivel.shadow_x < 380.0:
		_pinto_barrera = true
		Input.action_press("paint")
		print("[auto] %.1f s: pinta la barrera (sombras a %d px)" % [_t, x - _nivel.shadow_x])
	# mojar el pincel, pintar la puerta y entrar
	if _nivel.shadows_gone and dir == 0.0 and not _mojo and _nivel.brush != "tinta" and w.is_on_floor():
		_mojo = true
		Input.action_press("paint")
		print("[auto] %.1f s: moja el pincel" % _t)
	elif _nivel.shadows_gone and dir == 0.0 and _nivel.brush == "tinta" and not _pinto_puerta and w.is_on_floor():
		_pinto_puerta = true
		Input.action_press("paint")
		print("[auto] %.1f s: pinta la puerta" % _t)
	if _nivel.gate_open and _nivel.near_exit and _entro < 0.0:
		_entro = _t
		Input.action_press("interact")
		print("[auto] %.1f s: pulsa E en la puerta" % _t)

	if _t - _ultimo_log >= 2.0:
		_ultimo_log = _t
		var dist := "-" if _nivel.shadow_x == -INF else str(int(x - _nivel.shadow_x))
		print("[auto] %.1f s: x=%d y=%d vel=%d max=%d sombras a %s px  ritmo %.2f" % [_t, x, w.position.y, w.velocity.x, w.max_speed, dist, w.lobo.sprite.speed_scale])
	if _entro >= 0.0 and _t - _entro > 1.5:
		print("[auto] %.1f s: FIN OK" % _t)
		get_tree().quit()
	elif _t > LIMITE:
		print("[auto] %.1f s: tiempo agotado en x=%d. FIN SIN TERMINAR" % [_t, x])
		get_tree().quit()


func _mover(dir: float) -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	if dir > 0.0:
		Input.action_press("move_right")
	elif dir < 0.0:
		Input.action_press("move_left")
