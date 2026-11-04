extends Node2D
var _walk: AnimatedSprite2D
var _look: AnimatedSprite2D
var _elapsed := 0.0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color('#f0eee6'))
	var frames:SpriteFrames=preload('Wolf.tres')
	for i in 3:
		var sprite:=AnimatedSprite2D.new()
		sprite.sprite_frames=frames
		sprite.position=Vector2(190+i*290,490)
		sprite.scale=Vector2.ONE*1.1
		sprite.offset=Vector2(0,-110)
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(sprite)
		sprite.play(['walk','idle','look_around'][i])
		if i==0:
			_walk=sprite
			_walk.speed_scale=0.8
		if i==2:
			_look=sprite
		var label:=Label.new()
		label.position=Vector2(100+i*290,525)
		label.add_theme_color_override('font_color',Color('#333333'))
		label.text=['walk · 12 cuadros · 0.8 ciclos/s','idle · postura compartida','look_around · 6 cuadros'][i]
		add_child(label)
	var line:=Line2D.new()
	line.points=PackedVector2Array([Vector2(30,490),Vector2(930,490)])
	line.width=1
	line.default_color=Color('#b6b0a2')
	add_child(line)
	var title:=Label.new()
	title.position=Vector2(30,25)
	title.add_theme_color_override('font_color',Color('#333333'))
	title.text='LOBO v005 · preview de assets\nAtlas walk 3072×256 · apoyo y=238 · 176 px/ciclo medidos\nEspacio: pausar caminata · Flechas: inspeccionar cuadros\nEste proyecto independiente no cambia el juego.'
	add_child(title)

func _process(delta:float) -> void:
	_elapsed+=delta
	if _elapsed>4.0:
		_elapsed=0
		_look.play('look_around')

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_SPACE:
			if _walk.is_playing():
				_walk.pause()
			else:
				_walk.play('walk')
		if event.keycode==KEY_LEFT or event.keycode==KEY_RIGHT:
			_walk.pause()
			_walk.frame=posmod(_walk.frame+(1 if event.keycode==KEY_RIGHT else -1),12)
