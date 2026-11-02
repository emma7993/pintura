extends SceneTree

var failures := 0

func check(ok: bool, label: String) -> void:
	print(('PASS: ' if ok else 'FAIL: ') + label)
	if not ok:
		failures += 1

func _initialize() -> void:
	call_deferred('verify')

func verify() -> void:
	var frames = load('res://Godot/Wolf.tres') as SpriteFrames
	check(frames != null, 'SpriteFrames loads')
	if frames == null:
		quit(1)
		return
	check(frames.get_frame_count('walk') == 8 and frames.get_animation_loop('walk'), 'walk: 8 frames, loop')
	check(is_equal_approx(frames.get_animation_speed('walk'), 8.0), 'walk: 8 FPS')
	check(frames.get_frame_count('look_around') == 6 and not frames.get_animation_loop('look_around'), 'look: 6 frames, no loop')
	check(frames.get_frame_count('idle') == 1, 'idle: static pose')
	for anim in frames.get_animation_names():
		for i in frames.get_frame_count(anim):
			var texture = frames.get_frame_texture(anim, i)
			check(texture != null and texture.get_size() == Vector2(256, 256), '%s frame %d texture loads at 256x256' % [anim, i])
	var wolf = Node2D.new()
	wolf.set_script(load('res://Godot/Wolf.gd'))
	root.add_child(wolf)
	check(wolf.cooldown >= 7.0 and wolf.cooldown <= 14.0, 'interval: 7–14 seconds')
	wolf.animate(0.1, 1.0, -100.0)
	check(wolf.sprite.animation == &'walk' and wolf.sprite.flip_h, 'walk and face left')
	wolf.cooldown = 0.0
	wolf.animate(0.5, 0.0)
	check(wolf.sprite.animation == &'look_around', 'look starts at rest')
	wolf.animate(0.1, 1.0, 100.0)
	check(wolf.sprite.animation == &'walk' and not wolf.sprite.flip_h, 'movement interrupts look; face right')
	wolf.trigger_look()
	wolf.animate(0.1, 0.0, 0.0, true)
	check(wolf.sprite.animation == &'idle', 'air interrupts look')
	wolf.trigger_look()
	await create_timer(1.2).timeout
	check(wolf.sprite.animation == &'idle', 'look finishes at idle')
	wolf.free()
	print('RESULT: ' + ('PASS' if failures == 0 else 'FAIL'))
	quit(0 if failures == 0 else 1)
