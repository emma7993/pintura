extends SceneTree

const SETS := {
	'terrain': {'folder': 'Terrain', 'cols': 4, 'rows': 4, 'size': Vector2i(512, 256), 'names': ['ground_a', 'ground_b', 'ground_c', 'ground_d', 'cliff_left', 'cliff_right', 'platform_short', 'platform_long', 'wall', 'arch_support', 'step_up', 'step_down', 'bridge_sketch', 'bridge_complete', 'platform_sketch', 'platform_complete']},
	'props': {'folder': 'Props', 'cols': 4, 'rows': 4, 'size': Vector2i(256, 256), 'names': ['tree_left', 'tree_right', 'stump', 'hanging_branch', 'reeds', 'grass', 'stones', 'rock', 'ruined_arch', 'pillar', 'fallen_stone', 'roots', 'leaves', 'smudge', 'erased_arch', 'shrub']},
	'interactables': {'folder': 'Interactables', 'cols': 4, 'rows': 2, 'size': Vector2i(256, 256), 'names': ['pencil', 'pencil_ghost', 'pedestal_empty', 'pedestal_active', 'gate_sketch', 'gate_complete', 'anchor_sketch', 'anchor_complete']},
	'fx': {'folder': 'FX', 'cols': 4, 'rows': 2, 'size': Vector2i(256, 256), 'names': ['draw_01', 'draw_02', 'draw_03', 'draw_04', 'draw_05', 'draw_06', 'draw_07', 'draw_08']},
	'ui': {'folder': 'UI', 'cols': 4, 'rows': 2, 'size': Vector2i(128, 128), 'names': ['pencil', 'pencil_acquired', 'incomplete', 'complete', 'gate', 'return', 'sound', 'anchor']}
}

func _initialize() -> void:
	var inventory := []
	for key in SETS:
		var spec: Dictionary = SETS[key]
		var source := Image.load_from_file('res://Source/%s_original.png' % key)
		if source == null or source.is_empty():
			push_error('Missing source: ' + key)
			quit(1)
			return
		source.convert(Image.FORMAT_RGBA8)
		var cell_size: Vector2i = spec.size
		var atlas := Image.create(cell_size.x * spec.cols, cell_size.y * spec.rows, false, Image.FORMAT_RGBA8)
		for i in spec.names.size():
			var col: int = i % spec.cols
			var row: int = i / spec.cols
			var x0 := roundi(float(col) * source.get_width() / spec.cols)
			var x1 := roundi(float(col + 1) * source.get_width() / spec.cols)
			var y0 := roundi(float(row) * source.get_height() / spec.rows)
			var y1 := roundi(float(row + 1) * source.get_height() / spec.rows)
			var crop := source.get_region(Rect2i(x0, y0, x1 - x0, y1 - y0))
			var factor := minf(float(cell_size.x) / crop.get_width(), float(cell_size.y) / crop.get_height())
			crop.resize(maxi(1, roundi(crop.get_width() * factor)), maxi(1, roundi(crop.get_height() * factor)), Image.INTERPOLATE_LANCZOS)
			var cell := Image.create(cell_size.x, cell_size.y, false, Image.FORMAT_RGBA8)
			cell.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), (cell_size - crop.get_size()) / 2)
			var path := '%s/%s.png' % [spec.folder, spec.names[i]]
			cell.save_png('res://' + path)
			atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell_size), Vector2i(col, row) * cell_size)
			var box := significant_bounds(cell)
			var border := box.position.x <= 0 or box.position.y <= 0 or box.end.x >= cell_size.x or box.end.y >= cell_size.y
			inventory.append({'id': key + '/' + spec.names[i], 'path': path, 'size': [cell_size.x, cell_size.y], 'source_cell': i, 'bounds_alpha_10pct': [box.position.x, box.position.y, box.size.x, box.size.y], 'touches_cell_edge': border, 'has_transparency': cell.is_invisible() == false and cell.detect_alpha() != Image.ALPHA_NONE})
		atlas.save_png('res://%s/%s_atlas.png' % [spec.folder, key])
	var out := FileAccess.open('res://inventory.json', FileAccess.WRITE)
	out.store_string(JSON.stringify(inventory, '\t'))
	print('PACK: ', inventory.size(), ' individual assets exported; originals preserved')
	quit()

func significant_bounds(im: Image) -> Rect2i:
	var lo := im.get_size()
	var hi := Vector2i(-1, -1)
	for y in im.get_height():
		for x in im.get_width():
			if im.get_pixel(x, y).a >= 0.1:
				lo = lo.min(Vector2i(x, y))
				hi = hi.max(Vector2i(x, y))
	if hi.x < 0:
		return Rect2i()
	return Rect2i(lo, hi - lo + Vector2i.ONE)
