extends SceneTree

func _initialize():
	for suffix in ["", "_body", "_brush_carry", "_20fps", "_16fps"]:
		var path = "res://Godot/Wolf_Run%s.tres" % suffix
		var frames = load(path) as SpriteFrames
		assert(frames != null, path)
		assert(frames.has_animation(&"run"))
		assert(frames.get_frame_count(&"run") == 8)
		assert(frames.get_animation_loop(&"run"))
		assert(frames.get_animation_speed(&"run") == (16.0 if suffix == "_16fps" else 20.0))
		for index in range(8):
			assert(frames.get_frame_texture(&"run", index).get_size() == Vector2(384,384))
	var packed = load("res://Godot/Preview.tscn") as PackedScene
	assert(packed != null)
	var scene = packed.instantiate()
	assert(scene.get_node("Wolf").sprite_frames.get_frame_count(&"run") == 8)
	scene.free()
	print("VALIDATION_OK: five resources, eight frames each, default 20 FPS, alternative 16 FPS, preview scene.")
	quit()
