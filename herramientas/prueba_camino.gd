extends SceneTree
## Prueba de Camino unido dentro del juego (main.tscn), sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_camino.gd
## Pintura -> Nivel 1 -> (extremo derecho) resto de Camino -> (vuelta por el sello) Nivel 1 -> (fondo de la
## cueva) Zona de enemigos -> banca -> pintura; de la cueva se cae a la Zona de enemigos, de ahí al taller
## del copista, y subiendo por el hueco se vuelve a la cueva; mapa (M) que pausa y marca lo recorrido.

var _t := 0.0
var _paso := 0
var _fallas := 0
var main: Node


func _initialize() -> void:
	Inventario.reiniciar()
	Inventario.pincel = true
	Inventario.tintero = true
	Inventario.tinta = 60.0
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
			z.walker.enabled = true
			_check("arranca en la pintura", main.zone.get_script().resource_path.ends_with("zone_camino.gd"))
			main._on_exit_requested("z_camino")
		1:
			_check("entra al Nivel 1", _is(z, "nivel_01_camino.gd"))
			z.walker.position = Vector2(z.WIDTH - 40.0, z.HIGH_Y)          # extremo derecho
		2:
			_check("del extremo derecho pasa al Sello musical", _is(z, "mundo.gd") and z.map_room() == "ca_sello")
			z._teleport(Vector2(MapaDatos.rect("ca_sello").position.x - 30.0, MapaDatos.rect("ca_sello").end.y - 50.0))
		3:
			_check("del sello vuelve al final del Nivel 1", _is(z, "nivel_01_camino.gd") and z.walker.position.x > z.WIDTH - 400.0)
			z.walker.position = Vector2(z.CAVE_X.x + 20.0, z.CAVE_Y)       # fondo izquierdo de la cueva
		4:
			_check("de la cueva pasa a la Zona de enemigos", _is(z, "mundo.gd") and z.map_room() == "ca_enemigos")
			var r := MapaDatos.rect("ca_descanso")
			z._teleport(Vector2(r.position.x + 330.0, r.end.y - 44.0))
		5:
			_check("llega a la banca de la Zona de descanso", z.map_room() == "ca_descanso" and z.exit_hint != "")
			_pulsar("interact")
		6:
			_check("desde la banca vuelve a la pintura", _is(z, "zone_camino.gd"))
			main._on_exit_requested("z_camino")
		7:
			_check("de la pintura entra al Nivel 1", _is(z, "nivel_01_camino.gd"))
			z.walker.position = Vector2(z.CAVE_X.x + 20.0, z.CAVE_Y)       # fondo izquierdo de la cueva
		8:
			_check("cae a la Zona de enemigos por el hueco del techo", _is(z, "mundo.gd") and z.map_room() == "ca_enemigos")
			for q in z._portals:
				if q.room == "ca_enemigos" and q.to == "ca_copista":
					z._teleport((q.rect as Rect2).get_center() + Vector2(0, 100))
		9:
			_check("junto a la puerta del copista (Zona de enemigos)", z.exit_hint.contains("copista"))
			_pulsar("interact")
		10:
			_check("entra al taller del copista", _is(z, "mundo.gd") and z.map_room() == "ca_copista")
			z._teleport(MapaDatos.rect("ca_enemigos").get_center())
		11:
			z._teleport(MapaDatos.rect("ca_paleta").get_center())       # sube por el hueco del techo
		12:
			_check("subiendo vuelve a la cueva, donde cayó", _is(z, "nivel_01_camino.gd") and absf(z.walker.position.x - z.CAVE_X.x) < 300.0)
			main._toggle_map()
		13:
			_check("el mapa pausa el juego y marca al lobo", paused and main.map.pos != Vector2.INF)
			main._toggle_map()
			var want := ["ca_arco", "ca_sello", "ca_enemigos", "ca_descanso", "ca_copista", "ca_cascada"]
			var missing := want.filter(func(id: String) -> bool: return not Inventario.visitadas.has(id))
			_check("salas recorridas guardadas %s" % str(missing), missing.is_empty())
			Inventario.reiniciar()
			print("[camino] FIN: %s" % ("OK" if _fallas == 0 else "%d fallas" % _fallas))
			quit(1 if _fallas else 0)
			return true
	_paso += 1
	return false


func _is(z: Node, file: String) -> bool:
	return z != null and z.get_script().resource_path.ends_with(file)


func _check(what: String, ok: bool) -> void:
	print("[camino] %s: %s" % ["ok" if ok else "FALLA", what])
	if not ok:
		_fallas += 1


func _pulsar(action: String) -> void:
	Input.action_press(action)
	await create_timer(0.15).timeout
	Input.action_release(action)
