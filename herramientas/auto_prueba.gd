extends Node
## Prueba automática: mueve al lobo con un guion fijo y cierra el juego al terminar.
## Se activa con `-- --auto-prueba` (lo usa probar_juego.bat). Escribe en el log cada cambio de animación.

## [segundo de inicio, acciones pulsadas, nota para el log]
const GUION := [
	[0.0, [], "reposo inicial (fundido)"],
	[2.0, ["move_right"], "camina a la derecha"],
	[4.5, [], "se detiene"],
	[5.3, ["move_left"], "camina a la izquierda (giro)"],
	[7.3, [], "se detiene"],
	[7.8, ["move_right", "move_down"], "diagonal hacia abajo"],
	[9.3, [], "reposo largo: debe mirar alrededor"],
	[18.0, null, "fin"],
]

var _t := 0.0
var _paso := -1
var _lobo: LoboSprite
var _anim := &""


func _process(delta: float) -> void:
	_t += delta
	while _paso + 1 < GUION.size() and _t >= GUION[_paso + 1][0]:
		_paso += 1
		_aplicar(GUION[_paso])
	_vigilar_lobo()


func _aplicar(p: Array) -> void:
	print("[auto] %.1f s: %s" % [_t, p[2]])
	for a in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(a)
	if p[1] == null:
		get_tree().quit()
		return
	for a in p[1]:
		Input.action_press(a)


func _vigilar_lobo() -> void:
	if not is_instance_valid(_lobo):
		_lobo = _buscar(get_tree().root)
		if not _lobo:
			return
	if _lobo.sprite and _lobo.sprite.animation != _anim:
		_anim = _lobo.sprite.animation
		print("[auto] %.1f s: animación %s (mira %s, escala %.2f)" % [_t, _anim, "derecha" if _lobo.facing > 0 else "izquierda", _lobo.global_scale.x])


func _buscar(n: Node) -> LoboSprite:
	if n is LoboSprite:
		return n
	for c in n.get_children():
		var r := _buscar(c)
		if r:
			return r
	return null
