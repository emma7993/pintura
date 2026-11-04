extends SceneTree
const PARTS := ['body', 'thigh_far', 'shin_far', 'foot', 'tail', 'scarf', 'thigh_near', 'shin_near']

func bounds(im: Image, threshold: float = 0.10) -> Rect2i:
	var lo := im.get_size()
	var hi := Vector2i(-1,-1)
	for y in im.get_height():
		for x in im.get_width():
			if im.get_pixel(x,y).a >= threshold:
				lo = lo.min(Vector2i(x,y))
				hi = hi.max(Vector2i(x,y))
	return Rect2i(lo,hi-lo+Vector2i.ONE)

func cell(im: Image, i: int, cols: int, rows: int) -> Image:
	var col := i % cols
	var row := i / cols
	var x0 := roundi(float(col)*im.get_width()/cols)
	var x1 := roundi(float(col+1)*im.get_width()/cols)
	var y0 := roundi(float(row)*im.get_height()/rows)
	var y1 := roundi(float(row+1)*im.get_height()/rows)
	return im.get_region(Rect2i(x0,y0,x1-x0,y1-y0))

func _initialize() -> void:
	var original := Image.load_from_file('res://Source/parts_original.png')
	var metrics := {}
	for i in 8:
		var c := cell(original,i,4,2)
		var b := bounds(c)
		var cropped := c.get_region(b)
		cropped.save_png('res://Source/Parts/'+PARTS[i]+'.png')
		var anchor_x := cropped.get_width()*0.5
		if i == 0:
			var total := 0.0
			var count := 0
			for y in range(roundi(cropped.get_height()*0.91),roundi(cropped.get_height()*0.98)):
				for x in cropped.get_width():
					if cropped.get_pixel(x,y).a >= 0.5:
						total += x
						count += 1
			anchor_x = total/maxi(1,count)
		metrics[PARTS[i]]={'size':[cropped.get_width(),cropped.get_height()],'root_x':anchor_x,'source_bounds':str(b)}
	var out := FileAccess.open('res://Source/parts_metrics.json',FileAccess.WRITE)
	out.store_string(JSON.stringify(metrics,'\t'))
	_pack_look()
	print('PREPARE PASS: raster cutout parts and upright look/idle exported')
	quit()

func _pack_look() -> void:
	var original := Image.load_from_file('res://Source/look_original.png')
	var crops: Array[Image]=[]
	var anchors := []
	var max_height := 0
	for i in 6:
		var c := cell(original,i,3,2)
		var b := bounds(c,0.5)
		var cropped := c.get_region(b)
		crops.append(cropped)
		max_height=maxi(max_height,cropped.get_height())
		# Rightmost dark run through the pelvis; exclude the tail to its left.
		var centers := []
		for y in range(roundi(cropped.get_height()*0.59),roundi(cropped.get_height()*0.67)):
			var run := -1
			var candidates := []
			for x in cropped.get_width()+1:
				var solid := false
				if x < cropped.get_width():
					var color := cropped.get_pixel(x,y)
					solid=color.a>0.5 and color.r<0.3 and color.g<0.3 and color.b<0.3
				if solid and run<0:
					run=x
				if not solid and run>=0:
					if x-run>8:
						candidates.append((run+x-1)*0.5)
					run=-1
			if not candidates.is_empty():
				centers.append(candidates[-1])
		var total := 0.0
		for x in centers:
			total+=x
		anchors.append(total/maxi(1,centers.size()))
	var factor := 220.0/max_height
	var atlas := Image.create(1536,256,false,Image.FORMAT_RGBA8)
	var idle: Image
	for i in 6:
		var im := crops[i]
		im.resize(roundi(im.get_width()*factor),roundi(im.get_height()*factor),Image.INTERPOLATE_LANCZOS)
		var frame := Image.create(256,256,false,Image.FORMAT_RGBA8)
		frame.blit_rect(im,Rect2i(Vector2i.ZERO,im.get_size()),Vector2i(roundi(128-anchors[i]*factor),239-im.get_height()))
		if i == 0:
			idle=frame.duplicate()
		if i == 5:
			frame=idle.duplicate()
		frame.save_png('res://Individual_Frames/look_around/look_around_%02d.png'%(i+1))
		atlas.blit_rect(frame,Rect2i(0,0,256,256),Vector2i(i*256,0))
	idle.save_png('res://Individual_Frames/idle/idle_01.png')
	idle.save_png('res://SpriteSheets/idle_v005.png')
	atlas.save_png('res://SpriteSheets/look_around_v005.png')
	var out := FileAccess.open('res://Source/look_draft_packing_metrics.json',FileAccess.WRITE)
	out.store_string(JSON.stringify({'common_scale':factor,'height_target':220,'idle_matches_frames':[1,6],'pelvis_anchors_source':anchors},'\t'))
