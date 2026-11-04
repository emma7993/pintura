extends SceneTree
## Prueba del mundo explorable (mundo/mundo.tscn), sin ventana:
##   Godot --headless --path . -s res://herramientas/prueba_mundo.gd
## 1) todas las salas se alcanzan desde el inicio por conexiones y portales;
## 2) cruzar una puerta lateral caminando; 3) subir por un hueco del techo saltando de repisa en repisa;
## 4) bajar por un hueco del piso (↓ + salto); 5) usar un portal del hub.

var _t := 0.0
var _salto := -1.0
var _piso_y := 0.0
var _paso := 0
var _m: Node
var _w: Player


func _initialize() -> void:
	change_scene_to_file("res://mundo/mundo.tscn")


func _suelta() -> void:
	for a in ["move_left", "move_right", "move_down", "jump", "interact"]:
		Input.action_release(a)


func _alcanzables() -> int:
	var adj := {}
	for c in MapaDatos.CONEXIONES + MapaDatos.PORTALES:
		adj.get_or_add(c[0], []).append(c[1])
		adj.get_or_add(c[1], []).append(c[0])
	var seen := {MapaDatos.INICIO: true}
	var cola := [MapaDatos.INICIO]
	while not cola.is_empty():
		var id: String = cola.pop_back()
		for n in adj.get(id, []):
			if not seen.has(n):
				seen[n] = true
				cola.append(n)
	return seen.size()


func _physics_process(delta: float) -> bool:
	_t += delta
	if _t < 0.5:
		return false
	_m = current_scene
	_w = _m.walker
	var sala: String = _m.room_at(_w.position + Vector2(0, -40))
	match _paso:
		0:
			print("[mundo] salas alcanzables desde el inicio: %d de %d" % [_alcanzables(), MapaDatos.SALAS.size()])
			Input.action_press("move_right")
			_paso = 1
			_t = 0.5
		1:  # Despertar -> Barranco por la puerta lateral
			if sala == "ca_barranco":
				print("[mundo] puerta lateral: OK (Despertar → Barranco)")
				_suelta()
				_m._go_to("ca_cueva", 0.5)
				_paso = 2
				_t = 0.5
			elif _t > 8.0:
				print("[mundo] puerta lateral: FALLA (sala %s, x=%d)" % [sala, _w.position.x])
				_paso = 99
		2:  # Entrada a la cueva -> Altar subiendo por las repisas
			if sala == "ca_altar":
				print("[mundo] subir por el hueco del techo: OK (Entrada a la cueva → Altar)")
				_suelta()
				_paso = 3
				_t = 0.5
			elif _t > 20.0:
				print("[mundo] subir: FALLA (sala %s, y=%d)" % [sala, _w.position.y])
				_suelta()
				_paso = 3
				_t = 0.5
			else:
				# salta en cada aterrizaje (manteniendo el botón) y se acomoda bajo la siguiente repisa
				var r: Rect2 = _m.rooms()["ca_cueva"].rect
				var cx := r.position.x + r.size.x * 0.5
				var target := cx
				if _w.is_on_floor():
					_piso_y = _w.position.y
				for p in _m.rooms()["ca_cueva"].plat:
					var pr: Rect2 = p
					if pr.position.y < _piso_y - 20.0 and pr.position.y > _piso_y - 200.0 and absf(pr.get_center().x - cx) < 300.0:
						target = pr.get_center().x
				Input.action_release("move_left")
				Input.action_release("move_right")
				if absf(_w.position.x - target) > 30.0:
					Input.action_press("move_right" if target > _w.position.x else "move_left")
				if _salto >= 0.0 and _t - _salto > 0.45 and Input.is_action_pressed("jump"):
					Input.action_release("jump")
				elif _w.is_on_floor() and (_salto < 0.0 or _t - _salto > 0.7):
					Input.action_press("jump")
					_salto = _t
		3:  # bajar del Altar a la cueva: ↓ + salto sobre la repisa del hueco
			var r2: Rect2 = _m.rooms()["ca_altar"].rect
			_m._teleport(Vector2(r2.position.x + r2.size.x * 0.5, r2.end.y - 50.0))
			_paso = 4
			_t = 0.5
		4:
			if _t > 0.8 and _t < 0.9:
				Input.action_press("move_down")
				Input.action_press("jump")
			if sala == "ca_cueva":
				print("[mundo] bajar por el hueco del piso: OK (Altar → Entrada a la cueva)")
				_suelta()
				_m._go_to("pintura", 0.15)
				_paso = 5
				_t = 0.5
			elif _t > 4.0:
				print("[mundo] bajar: FALLA (sala %s)" % sala)
				_suelta()
				_m._go_to("pintura", 0.15)
				_paso = 5
				_t = 0.5
		5:  # portal del hub
			var p: Dictionary = _m._portals[0]
			_m._teleport((p.rect as Rect2).get_center() + Vector2(0, 120))
			_paso = 6
			_t = 0.5
		6:
			if _t > 0.8 and _t < 0.85:
				Input.action_press("interact")
			if _t > 1.2:
				print("[mundo] portal desde La Pintura: llegó a %s" % _m.room_at(_w.position + Vector2(0, -40)))
				_paso = 99
		99:
			print("[mundo] FIN")
			quit()
			return true
	return false
