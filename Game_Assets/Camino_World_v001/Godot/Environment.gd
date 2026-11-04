extends Node2D
## Visual assembly only. No collisions, inventory, player movement or save state.
@export var world_width := 4200.0
@export var ground_y := 600.0
@export var show_pencil_landmark := true
var _base: String
var _metrics := {}
var _graphite: ShaderMaterial
var _bridge_reveal: ShaderMaterial
var _pencil: Sprite2D

func _ready() -> void:
	_base = get_script().resource_path.get_base_dir().get_base_dir()
	var items = JSON.parse_string(FileAccess.get_file_as_string(_base + '/inventory.json'))
	for item in items:
		_metrics[item.path] = item
	_graphite = ShaderMaterial.new()
	_graphite.shader = load(_base + '/Godot/Graphite.gdshader')
	_build_paper()
	_build_parallax()
	_build_ground()
	_build_landmarks()

func _build_paper() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -100
	add_child(layer)
	var paper := TextureRect.new()
	paper.texture = load(_base + '/Backgrounds/canvas.png')
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper.stretch_mode = TextureRect.STRETCH_SCALE
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := _graphite.duplicate() as ShaderMaterial
	mat.set_shader_parameter('paper_mix', 1.0)
	paper.material = mat
	layer.add_child(paper)

func _build_parallax() -> void:
	var far := Parallax2D.new()
	far.scroll_scale = Vector2(0.18, 1.0)
	far.z_index = -60
	add_child(far)
	var bridge := Sprite2D.new()
	bridge.texture = load(_base + '/Backgrounds/aqueduct.png')
	bridge.centered = false
	bridge.position = Vector2(-200, ground_y - 620)
	bridge.scale = Vector2(1.6, 0.85)
	bridge.modulate.a = 0.14
	bridge.material = _graphite
	far.add_child(bridge)
	var middle := Parallax2D.new()
	middle.scroll_scale = Vector2(0.45, 1.0)
	middle.z_index = -40
	add_child(middle)
	for x in [-350.0, 1400.0, 3150.0]:
		var trees := Sprite2D.new()
		trees.texture = load(_base + '/Backgrounds/trees.png')
		trees.centered = false
		trees.position = Vector2(x, ground_y - 560)
		trees.scale = Vector2(0.75, 0.65)
		trees.modulate.a = 0.16
		trees.material = _graphite
		middle.add_child(trees)

func _build_ground() -> void:
	# Each illustrated segment overlaps its neighbor. Existing gameplay owns collisions.
	var index := 0
	var x := -200.0
	while x < world_width + 300:
		var path := 'Terrain/ground_%s.png' % ['a', 'b', 'c', 'd'][index % 4]
		var box: Array = _metrics[path].bounds_alpha_10pct
		var factor := 1.0
		var width := float(box[2]) * factor
		var s := _raw_sprite(path, self, -10)
		s.position = Vector2(x - float(box[0]) * factor, ground_y - float(box[1]) * factor)
		s.scale = Vector2.ONE * factor
		x += maxf(60.0, width - 28.0)
		index += 1
	for entry in [
		['Props/tree_left.png', 630.0, 2.0, 0.35],
		['Props/stump.png', 1080.0, 0.85, 0.7],
		['Props/tree_right.png', 1850.0, 2.3, 0.28],
		['Props/ruined_arch.png', 2640.0, 1.8, 0.4],
		['Props/pillar.png', 3550.0, 1.7, 0.35]]:
		var s := place_bottom(entry[0], Vector2(entry[1], ground_y + 6), entry[2], -22)
		s.modulate.a = entry[3]
	for i in 14:
		var path := 'Props/%s.png' % ['grass', 'stones', 'roots', 'reeds'][i % 4]
		var s := place_bottom(path, Vector2(380 + i * 270, ground_y + 10), 0.42, -8)
		s.modulate.a = 0.5

func _build_landmarks() -> void:
	if show_pencil_landmark:
		place_bottom('Interactables/pedestal_empty.png', Vector2(2150, ground_y + 10), 0.55, -8)
		_pencil = place_bottom('Interactables/pencil.png', Vector2(2150, ground_y - 45), 0.26, -7)
	# A sample restoration is shown in the background, never presented as a colliding path.
	place_bottom('Terrain/bridge_sketch.png', Vector2(3170, ground_y - 140), 1.2, -28).modulate.a = 0.3
	var complete := place_bottom('Terrain/bridge_complete.png', Vector2(3170, ground_y - 140), 1.2, -27)
	_bridge_reveal = _graphite.duplicate() as ShaderMaterial
	_bridge_reveal.set_shader_parameter('reveal', 0.0)
	complete.material = _bridge_reveal
	complete.modulate.a = 0.5

func set_restore_progress(value: float) -> void:
	if _bridge_reveal:
		_bridge_reveal.set_shader_parameter('reveal', clampf(value, 0.0, 1.0))

func place_bottom(path: String, at: Vector2, factor: float, depth: int) -> Sprite2D:
	var s := _raw_sprite(path, self, depth)
	var box: Array = _metrics[path].bounds_alpha_10pct
	s.scale = Vector2.ONE * factor
	s.position = at - Vector2(float(box[0]) + float(box[2]) * 0.5, float(box[1]) + float(box[3])) * factor
	return s

func _raw_sprite(path: String, parent: Node, depth: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(_base + '/' + path)
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	s.material = _graphite
	s.z_index = depth
	parent.add_child(s)
	return s
