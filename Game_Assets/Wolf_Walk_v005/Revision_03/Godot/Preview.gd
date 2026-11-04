extends Node2D
var sprite:AnimatedSprite2D

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color('#f2f0e8'))
	sprite=AnimatedSprite2D.new()
	sprite.sprite_frames=preload('Wolf.tres')
	sprite.position=Vector2(384,465)
	sprite.offset=Vector2(0,-110)
	sprite.scale=Vector2.ONE*1.5
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	sprite.speed_scale=0.8
	sprite.play('walk')
	var line:=Line2D.new()
	line.points=PackedVector2Array([Vector2(90,465),Vector2(678,465)])
	line.width=1
	line.default_color=Color('#b4aea2')
	add_child(line)
	var label:=Label.new()
	label.position=Vector2(24,24)
	label.add_theme_color_override('font_color',Color('#333333'))
	label.text='V004 · caminata suavizada a 12 cuadros\nDibujos completos · manos negras · zancada original\nEspacio: pausar/reanudar · Flechas: cuadro anterior/siguiente\n0.8 ciclos/s · revisión artística pendiente'
	add_child(label)

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_SPACE:
			if sprite.is_playing():
				sprite.pause()
			else:
				sprite.play('walk')
		if event.keycode==KEY_LEFT or event.keycode==KEY_RIGHT:
			sprite.pause()
			sprite.frame=posmod(sprite.frame+(1 if event.keycode==KEY_RIGHT else -1),12)
