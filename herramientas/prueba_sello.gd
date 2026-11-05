extends SceneTree
## Prueba de la sala del Sello musical, de Ñ / L y del combo, dentro del juego (main.tscn), sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_sello.gd
## La entrada no tiene barrera; al fondo, una repisa alta (se sube saltando) con la puerta sellada, que no
## abre sin la Melodía 1 y con ella lleva a la Zona de descanso. Ñ adelanta y L regresa salas.

var _t := 0.0
var _paso := 0
var _fallas := 0
var main: Node


func _initialize() -> void:
	Inventario.reiniciar()
	Inventario.pincel = true
	Inventario.progreso = {"n1_sombras": true, "n1_trazo_x": 5210.0}
	Inventario.guardar()
	change_scene_to_file("res://main.tscn")


func _process(delta: float) -> bool:
	_t += delta
	if _t < 2.4:
		return false
	_t = 0.0
	main = current_scene
	var z: Node = main.zone
	match _paso:
		0:
			main._choosing = false
			main._on_exit_requested("mundo:ca_sello")
		1:
			_check("llega al Sello musical", _is(z, "mundo.gd") and z.map_room() == "ca_sello")
			_check("la entrada del Sello no tiene barrera", z.rooms()["ca_sello"].gates.is_empty())
			var r: Rect2 = z.rooms()["ca_sello"].rect
			z._teleport(Vector2(r.end.x - z.WALL - z.LEDGE.x - 220.0, r.end.y - z.WALL - 4.0))
			z.walker.enabled = true
			Input.action_press("move_right")
			_suelta_luego("jump", 0.05, 0.5)
		2:
			Input.action_release("move_right")
			var r: Rect2 = z.rooms()["ca_sello"].rect
			var top: float = r.end.y - z.WALL - z.LEDGE.y
			_check("saltando sube a la repisa alta (y=%.0f, repisa %.0f)" % [z.walker.position.y, top], absf(z.walker.position.y - top) < 6.0)
			z._teleport(Vector2(r.end.x - z.WALL - 255.0, top - 4.0))
		3:
			_check("junto a la puerta sellada: avisa qué la abre", z.exit_hint.begins_with("Puerta sellada"))
			_pulsa("interact")
		4:
			_check("sin la Melodía 1 no abre", z.map_room() == "ca_sello")
			Inventario.marcar("melodia_1")
			_pulsa("interact")
		5:
			_check("con la Melodía 1 lleva a la Zona de descanso", z.map_room() == "ca_descanso")
			Inventario.progreso.erase("melodia_1")
			main._saltar_sala(-1)                    # descanso -> copista
		6:
			_check("L regresa una sala (copista)", z.map_room() == "ca_copista")
			main._saltar_sala(-1)                    # copista -> cueva (Nivel 1)
		7:
			_check("L entra al Nivel 1 (cueva)", _is(z, "nivel_01_camino.gd") and z.map_room() == "ca_cueva")
			main._saltar_sala(1)
		8:
			_check("Ñ adelanta una sala (copista)", _is(z, "mundo.gd") and z.map_room() == "ca_copista")
			main._saltar_sala(-1)
		9:
			main._saltar_sala(-1)                    # cueva (Nivel 1) -> paleta (mundo)
		10:
			_check("L sigue en orden (paleta)", z.map_room() == "ca_paleta")
			# combo: tres golpes de lado seguidos
			z.walker.can_attack = true
			_combo(z.walker)
		11:
			Inventario.reiniciar()
			print("[sello] FIN: %s" % ("OK" if _fallas == 0 else "%d fallas" % _fallas))
			quit(1 if _fallas else 0)
			return true
	_paso += 1
	return false


func _combo(w: Player) -> void:
	var seen: Array[StringName] = []
	for i in 3:
		Input.action_press("attack")
		await physics_frame
		await physics_frame
		Input.action_release("attack")
		seen.append(w.lobo.sprite.animation)
		await create_timer(0.3).timeout
	_check("combo de lado: %s" % str(seen), seen == LoboSprite.ATTACKS)


func _is(z: Node, file: String) -> bool:
	return z != null and z.get_script().resource_path.ends_with(file)


func _check(what: String, ok: bool) -> void:
	print("[sello] %s: %s" % ["ok" if ok else "FALLA", what])
	if not ok:
		_fallas += 1


func _pulsa(action: String) -> void:
	Input.action_press(action)
	await create_timer(0.15).timeout
	Input.action_release(action)


func _suelta_luego(action: String, start: float, hold: float) -> void:
	await create_timer(start).timeout
	Input.action_press(action)
	await create_timer(hold).timeout
	Input.action_release(action)
