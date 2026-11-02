extends Node
## Prueba automática del nivel 1 (Camino): corre a la derecha, salta el hueco, toma el pincel, pinta la
## barrera cuando las sombras se acercan y sale. Se activa con `-- --auto-nivel1` (probar_nivel1.bat).
## El nivel escribe en el log cada momento del guion ([nivel1]); aquí se anota lo que hace el "jugador".

const LIMITE := 65.0              # segundos: si no terminó, algo falló

var _t := 0.0
var _salto := -1.0                # momento en que se pulsó el salto
var _pinto := false
var _ultimo_log := 0.0
var _nivel: Node


func _ready() -> void:
	_nivel = get_parent()
	Input.action_press("move_right")


func _process(delta: float) -> void:
	_t += delta
	var w: Player = _nivel.walker
	var x := w.position.x
	# salto: al llegar al borde del hueco
	if _salto < 0.0 and w.can_jump and w.is_on_floor() and x > _nivel.GAP.x - 45.0 and x < _nivel.GAP.x:
		Input.action_press("jump")
		_salto = _t
		print("[auto] %.1f s: salta en x=%d (velocidad %d)" % [_t, x, w.velocity.x])
	if _salto >= 0.0 and _t - _salto > 0.4:
		Input.action_release("jump")
		if w.is_on_floor() and x < _nivel.GAP.x:
			_salto = -1.0          # volvió al punto de control: puede intentar de nuevo
	# pintar: cuando las sombras están a menos de 380 px
	if not _pinto and _nivel.has_brush and x - _nivel.shadow_x < 380.0:
		_pinto = true
		Input.action_press("paint")
		print("[auto] %.1f s: pinta (sombras a %d px)" % [_t, x - _nivel.shadow_x])
	elif _pinto:
		Input.action_release("paint")
	if _t - _ultimo_log >= 2.0:
		_ultimo_log = _t
		var dist := "-" if _nivel.shadow_x == -INF else str(int(x - _nivel.shadow_x))
		print("[auto] %.1f s: x=%d vel=%d max=%d sombras a %s px  ritmo %.2f" % [_t, x, w.velocity.x, w.max_speed, dist, w.lobo.sprite.speed_scale])
	if _nivel.shadows_gone and x > _nivel.EXIT_X - 60.0:
		Input.action_release("move_right")
		print("[auto] %.1f s: llegó a la salida. FIN OK" % _t)
		get_tree().quit()
	elif _t > LIMITE:
		print("[auto] %.1f s: tiempo agotado en x=%d. FIN SIN TERMINAR" % [_t, x])
		get_tree().quit()
