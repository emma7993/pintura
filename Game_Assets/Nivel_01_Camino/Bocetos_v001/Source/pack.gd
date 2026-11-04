extends SceneTree
const NAMES := ['ground_a', 'ground_b', 'ground_c', 'ground_d', 'platform_short', 'platform_long', 'bridge', 'wall', 'tree_left', 'tree_right', 'reeds', 'stones', 'pencil', 'pedestal', 'gate', 'anchor']

func _initialize() -> void:
	var source := Image.load_from_file('res://Source/modulos_original.png')
	if source == null or source.is_empty():
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	var inventory := []
	var atlas := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	for i in 16:
		var col := i % 4
		var row := i / 4
		var x0 := roundi(float(col) * source.get_width() / 4)
		var x1 := roundi(float(col + 1) * source.get_width() / 4)
		var y0 := roundi(float(row) * source.get_height() / 4)
		var y1 := roundi(float(row + 1) * source.get_height() / 4)
		var im := source.get_region(Rect2i(x0, y0, x1 - x0, y1 - y0))
		im.resize(256, 256, Image.INTERPOLATE_LANCZOS)
		im.save_png('res://Modulos/' + NAMES[i] + '.png')
		atlas.blit_rect(im, Rect2i(0, 0, 256, 256), Vector2i(col * 256, row * 256))
		var lo := Vector2i(256, 256)
		var hi := Vector2i(-1, -1)
		var transparent := 0
		var solid := 0
		for y in 256:
			for x in 256:
				var alpha := im.get_pixel(x, y).a
				if alpha < 0.01:
					transparent += 1
				if alpha >= 0.1:
					lo = lo.min(Vector2i(x, y))
					hi = hi.max(Vector2i(x, y))
					solid += 1
		if hi.x < 0:
			push_error('Empty module ' + NAMES[i])
			quit(1)
			return
		inventory.append({'id': NAMES[i], 'path': 'Modulos/' + NAMES[i] + '.png', 'size': [256, 256], 'bounds': [lo.x, lo.y, hi.x - lo.x + 1, hi.y - lo.y + 1], 'transparent_fraction': transparent / 65536.0, 'marked_fraction': solid / 65536.0, 'touches_border': lo.x == 0 or lo.y == 0 or hi.x == 255 or hi.y == 255})
	atlas.save_png('res://Modulos/modulos_atlas.png')
	var out := FileAccess.open('res://inventory.json', FileAccess.WRITE)
	out.store_string(JSON.stringify(inventory, '\t'))
	print('PASS: 16 graphite modules packed; source preserved')
	quit()
