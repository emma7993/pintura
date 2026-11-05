extends SceneTree
## Prueba del flujo de partida del juego completo, sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_partida.gd
## 1) con partida guardada, arranca jugando (sin detener al lobo); 0 la borra y empieza de cero;
## 2) entra al Nivel 1 desde la pintura y empieza al principio del nivel;
## 3) con el pincel ya ganado, al volver a la pintura el lobo lo lleva.

var _t := 0.0
var _paso := 0


func _initialize() -> void:
	Inventario.reiniciar()
	Inventario.pincel = true
	Inventario.marcar("n1_sombras")
	change_scene_to_file("res://main.tscn")


func _process(delta: float) -> bool:
	_t += delta
	if _t < 1.5:
		return false
	_t = 0.0
	var main := current_scene
	match _paso:
		0:
			print("[partida] con partida guardada arranca jugando: ", main.zone.walker.enabled)
			_tecla(KEY_0)
		1:
			print("[partida] tras 0: jugando=%s pincel=%s marcas=%s" % [main.zone.walker.enabled, Inventario.pincel, Inventario.progreso])
			main._on_exit_requested("z_camino")
		2:
			pass
		3:
			var lvl: Node = main.zone
			print("[partida] Nivel 1 desde la pintura: x=%d pincel=%s sombras_vencidas=%s" % [lvl.walker.position.x, lvl.has_brush, lvl.shadows_gone])
			Inventario.pincel = true
			Inventario.tinta = 80.0
			main._on_exit_requested("camino")
		4:
			pass
		5:
			print("[partida] de vuelta en la pintura, punta del pincel: '%s'" % main.zone.walker.wolf.brush)
			Inventario.reiniciar()
			print("[partida] FIN")
			quit()
			return true
	_paso += 1
	return false


func _tecla(k: Key) -> void:
	var ev := InputEventKey.new()
	ev.keycode = k
	ev.pressed = true
	root.push_input(ev)
