extends SceneTree

func _initialize() -> void:
	call_deferred('verify')

func verify() -> void:
	var script = load('res://characters/lobo/lobo_sprite.gd')
	var wolf = script.new()
	root.add_child(wolf)
	var frames: SpriteFrames = wolf.sprite.sprite_frames
	var texture: AtlasTexture = frames.get_frame_texture('walk', 0)
	if texture.atlas.resource_path != 'res://characters/lobo/v004/SpriteSheets/walk_v004.png':
		push_error('Active wolf is not using V4')
		quit(1)
		return
	wolf.animate(0.1, 1.0, 100.0)
	if wolf.sprite.animation != &'walk' or frames.get_frame_count('walk') != 8:
		quit(1)
		return
	wolf.animate(0.1, 0.0)
	if wolf.sprite.animation != &'idle':
		quit(1)
		return
	print('PASS: active LoboSprite uses V4 walk; 8 frames, walk and idle work')
	wolf.free()
	quit(0)
