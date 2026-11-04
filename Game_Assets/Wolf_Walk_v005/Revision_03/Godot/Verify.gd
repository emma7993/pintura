extends SceneTree

func _initialize() -> void:
	var frames:SpriteFrames=load('res://Godot/Wolf.tres')
	if frames==null:
		quit(1)
		return
	assert(frames.get_frame_count('walk')==12)
	assert(frames.get_animation_loop('walk'))
	assert(is_equal_approx(frames.get_animation_speed('walk'),12.0))
	for i in 12:
		var frame:AtlasTexture=frames.get_frame_texture('walk',i)
		assert(frame.region==Rect2(i*256,0,256,256))
		assert(frame.atlas.get_size()==Vector2(3072,256))
		assert(frame.get_image()!=null)
	print('PASS: Godot loads all12 frames from3072x256 atlas;12FPS;loop')
	quit()
