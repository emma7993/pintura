extends SceneTree
var failures := 0

func check(ok: bool, label: String) -> void:
	print(('PASS: ' if ok else 'FAIL: ') + label)
	if not ok:
		failures += 1

func _initialize() -> void:
	call_deferred('verify')

func verify() -> void:
	var inventory = JSON.parse_string(FileAccess.get_file_as_string('res://inventory.json'))
	check(inventory.size() == 16, '16 individual modules')
	for item in inventory:
		var texture := load('res://' + item.path) as Texture2D
		check(texture != null and texture.get_size() == Vector2(256, 256), item.id + ' imported at 256x256')
		check(item.transparent_fraction > 0.5 and not item.touches_border, item.id + ' transparent background and intact framing')
	var backgrounds := []
	for id in ['01_cielo_lejano', '02_acueducto_faro', '03_bosque_orilla']:
		var im := Image.load_from_file('res://Fondos/' + id + '.png')
		var marks := 0
		var transparent := 0
		for y in im.get_height():
			for x in im.get_width():
				var a := im.get_pixel(x, y).a
				if a > 0.02:
					marks += 1
				if a < 0.01:
					transparent += 1
		var coverage := float(marks) / (im.get_width() * im.get_height())
		check(coverage > 0.0002 and coverage < 0.35, id + ' sparse non-empty drawing: ' + str(coverage))
		check(float(transparent) / (im.get_width() * im.get_height()) > 0.65, id + ' real alpha between marks')
		backgrounds.append({'id': id, 'size': [im.get_width(), im.get_height()], 'mark_fraction_alpha_2pct': coverage, 'transparent_fraction_alpha_1pct': float(transparent) / (im.get_width() * im.get_height())})
	var environment = load('res://Godot/Environment.tscn').instantiate()
	root.add_child(environment)
	var cam := Camera2D.new()
	cam.position = Vector2(640, 530)
	root.add_child(cam)
	cam.make_current()
	await process_frame
	await process_frame
	var names := ['01_cielo_lejano', '02_acueducto_faro', '03_bosque_orilla', '04_trazos_cercanos']
	var before := []
	for id in names:
		var layer = environment.get_node(id)
		before.append(layer.get_child(0).get_global_transform_with_canvas().origin.x)
	cam.position.x += 400
	await process_frame
	await process_frame
	var deltas := []
	for i in names.size():
		var layer = environment.get_node(names[i])
		deltas.append(layer.get_child(0).get_global_transform_with_canvas().origin.x - before[i])
		check(layer is Parallax2D, names[i] + ' uses Parallax2D')
	check(absf(deltas[0]) < absf(deltas[1]) and absf(deltas[1]) < absf(deltas[2]) and absf(deltas[2]) < absf(deltas[3]), 'camera movement produces depth ordering: ' + str(deltas))
	var file := FileAccess.open('res://Source/qa_metrics.json', FileAccess.WRITE)
	file.store_string(JSON.stringify({'backgrounds': backgrounds, 'camera_delta_x': 400, 'parallax_screen_deltas': deltas, 'failures': failures}, '\t'))
	cam.free()
	environment.free()
	print('RESULT: ' + ('PASS' if failures == 0 else 'FAIL'))
	quit(0 if failures == 0 else 1)
