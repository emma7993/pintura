extends SceneTree

# Technical atlas packing only: no painted pixels, masks or pose deformation.
func _initialize() -> void:
	var src := Image.load_from_file('res://Source/walk_upright_original.png')
	var cw := src.get_width() / 4
	var ch := src.get_height() / 2
	var crops: Array[Image] = []
	var max_height := 0
	var max_width := 0
	for i in 8:
		var cell := src.get_region(Rect2i((i % 4) * cw, (i / 4) * ch, cw, ch))
		var lo := Vector2i(cw, ch)
		var hi := Vector2i(-1, -1)
		for y in ch:
			for x in cw:
				if cell.get_pixel(x, y).a >= 0.1:
					lo = lo.min(Vector2i(x, y))
					hi = hi.max(Vector2i(x, y))
		var bounds := Rect2i(lo, hi - lo + Vector2i.ONE)
		print('Source frame ', i + 1, ': ', bounds)
		assert(bounds.has_area(), 'Empty generated frame')
		if not (bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < cw and bounds.end.y < ch):
			push_error('Source touches cell edge; inspect generated framing')
			quit(1)
			return
		var crop := cell.get_region(bounds)
		max_height = maxi(max_height, crop.get_height())
		max_width = maxi(max_width, crop.get_width())
		crops.append(crop)
	var factor := minf(220.0 / max_height, 226.0 / max_width)
	var atlas := Image.create(2048, 256, false, Image.FORMAT_RGBA8)
	var metrics := []
	for i in 8:
		var crop := crops[i]
		crop.resize(roundi(crop.get_width() * factor), roundi(crop.get_height() * factor), Image.INTERPOLATE_LANCZOS)
		var cell := Image.create(256, 256, false, Image.FORMAT_RGBA8)
		var at := Vector2i((256 - crop.get_width()) / 2, 239 - crop.get_height())
		cell.blit_rect(crop, Rect2i(Vector2i.ZERO, crop.get_size()), at)
		assert(cell.get_used_rect().position.x > 0 and cell.get_used_rect().position.y > 0)
		cell.save_png('res://Individual_Frames/walk/walk_%02d.png' % (i + 1))
		atlas.blit_rect(cell, Rect2i(0, 0, 256, 256), Vector2i(i * 256, 0))
		metrics.append({'frame': i + 1, 'bounds': str(cell.get_used_rect()), 'ground_y': 238})
	atlas.save_png('res://SpriteSheets/walk_v004.png')
	var out := FileAccess.open('res://Source/packing_metrics.json', FileAccess.WRITE)
	out.store_string(JSON.stringify({'source_size': str(src.get_size()), 'common_scale': factor, 'frames': metrics}, '\t'))
	print('PACK PASS: 8 frames, shared scale, RGBA atlas 2048x256, ground y=238')
	quit()
