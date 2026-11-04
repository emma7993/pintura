extends Node2D
var _environment: Node2D
var _camera: Camera2D
var _wolf: AnimatedSprite2D
var _progress := 0.0
var _base: String

func _ready() -> void:
	_base = get_script().resource_path.get_base_dir().get_base_dir()
	_environment = load(_base + '/Godot/Environment.tscn').instantiate()
	add_child(_environment)
	_camera = Camera2D.new()
	_camera.position = Vector2(700, 520)
	add_child(_camera)
	_wolf = AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation('walk')
	frames.set_animation_speed('walk', 8)
	for i in 8:
		var frame := AtlasTexture.new()
		frame.atlas = load(_base + '/Previews/wolf_walk_v004.png')
		frame.region = Rect2(i * 256, 0, 256, 256)
		frames.add_frame('walk', frame)
	_wolf.sprite_frames = frames
	_wolf.animation = &'walk'
	_wolf.offset = Vector2(0, -110)
	_wolf.scale = Vector2.ONE * 0.6
	_wolf.position = Vector2(620, 600)
	add_child(_wolf)
	var ui := CanvasLayer.new()
	add_child(ui)
	var label := Label.new()
	label.position = Vector2(24, 20)
	label.add_theme_color_override('font_color', Color('#393a36'))
	label.text = 'CAMINO · montaje de arte v001\nFlechas: recorrer · Espacio: muestra de trazado · R: reiniciar\nPreview visual; recogida, colisiones y progreso por integrar.'
	ui.add_child(label)
	if '--capture' in OS.get_cmdline_user_args():
		capture.call_deferred()

func _process(delta: float) -> void:
	var axis := Input.get_axis('ui_left', 'ui_right')
	_wolf.position.x = clampf(_wolf.position.x + axis * 260 * delta, 160, 4100)
	_camera.position.x = clampf(_wolf.position.x + 100, 640, 3560)
	if absf(axis) > 0.1:
		_wolf.flip_h = axis < 0
		_wolf.play('walk')
	else:
		_wolf.pause()
	if Input.is_key_pressed(KEY_SPACE):
		_progress = minf(_progress + delta / 0.8, 1.0)
	if Input.is_key_pressed(KEY_R):
		_progress = 0
	_environment.set_restore_progress(_progress)

func capture() -> void:
	for i in 4:
		_camera.position.x = [700.0, 1600.0, 2250.0, 3180.0][i]
		_wolf.position.x = _camera.position.x - 80
		set_process(false)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(_base + '/Previews/scene_%02d.png' % (i + 1))
	get_tree().quit()
