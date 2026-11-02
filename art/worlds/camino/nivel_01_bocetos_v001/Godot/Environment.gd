extends Node2D
## Reusable artwork assembly. Gameplay and collisions belong to the level controller.
@export var ground_y := 600.0
@export var world_width := 4200.0
@export var show_modules := true
var _base: String
var _metrics := {}

func _ready() -> void:
	_base = get_script().resource_path.get_base_dir().get_base_dir()
	for item in JSON.parse_string(FileAccess.get_file_as_string(_base + '/inventory.json')):
		_metrics[item.id] = item
	var paper_layer := CanvasLayer.new()
	paper_layer.layer = -100
	add_child(paper_layer)
	var paper := ColorRect.new()
	paper.color = Color(0.977, 0.975, 0.964)
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	paper_layer.add_child(paper)
	_layer('01_cielo_lejano', 0.08, -70, 0.30, ground_y - 690)
	_layer('02_acueducto_faro', 0.23, -50, 0.50, ground_y - 650)
	_layer('03_bosque_orilla', 0.48, -30, 0.52, ground_y - 620)
	if show_modules:
		_build_modules()

func _layer(id: String, speed: float, depth: int, opacity: float, y: float) -> void:
	var texture := load(_base + '/Fondos/' + id + '.png') as Texture2D
	var factor := 720.0 / texture.get_height()
	var parallax := Parallax2D.new()
	parallax.name = id
	parallax.scroll_scale = Vector2(speed, 1.0)
	parallax.repeat_size = Vector2(texture.get_width() * factor, 0)
	parallax.repeat_times = 3
	parallax.z_index = depth
	add_child(parallax)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.scale = Vector2.ONE * factor
	sprite.position = Vector2(-150, y)
	sprite.modulate = Color(0.92, 0.92, 0.92, opacity)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parallax.add_child(sprite)

func _build_modules() -> void:
	var x := -160.0
	var i := 0
	while x < world_width + 250:
		var id := 'ground_%s' % ['a', 'b', 'c'][i % 3]
		var bounds: Array = _metrics[id].bounds
		var factor := 2.0
		var sprite := _sprite(id, self, -10)
		sprite.scale = Vector2.ONE * factor
		sprite.position = Vector2(x - float(bounds[0]) * factor, ground_y - float(bounds[1]) * factor)
		x += maxf(60, float(bounds[2]) * factor - 30)
		i += 1
	for entry in [['tree_left', 700.0, 2.4], ['tree_right', 1850.0, 2.8], ['gate', 3470.0, 1.8]]:
		place_bottom(entry[0], Vector2(entry[1], ground_y + 4), entry[2], -18).modulate.a = 0.38
	for j in 12:
		place_bottom('reeds' if j % 2 == 0 else 'stones', Vector2(400 + j * 310, ground_y + 5), 0.55, -8).modulate.a = 0.6
	# A visual landmark only: no pickup or inventory logic is implied here.
	place_bottom('pedestal', Vector2(2250, ground_y + 5), 0.6, -8)
	place_bottom('pencil', Vector2(2250, ground_y - 38), 0.30, -7)
	var foreground := Parallax2D.new()
	foreground.name = '04_trazos_cercanos'
	foreground.scroll_scale = Vector2(1.10, 1.0)
	foreground.z_index = 3
	add_child(foreground)
	for j in 7:
		var sprite := _sprite('reeds', foreground, 0)
		var b: Array = _metrics.reeds.bounds
		sprite.scale = Vector2.ONE * 0.8
		sprite.position = Vector2(j * 720 + 240, ground_y + 32 - float(b[1] + b[3]) * 0.8)
		sprite.modulate.a = 0.20

func place_bottom(id: String, at: Vector2, factor: float, depth: int) -> Sprite2D:
	var sprite := _sprite(id, self, depth)
	var b: Array = _metrics[id].bounds
	sprite.position = at - Vector2(float(b[0]) + float(b[2]) * 0.5, float(b[1]) + float(b[3])) * factor
	sprite.scale = Vector2.ONE * factor
	return sprite

func _sprite(id: String, parent: Node, depth: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = load(_base + '/Modulos/' + id + '.png')
	sprite.centered = false
	sprite.z_index = depth
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(sprite)
	return sprite
