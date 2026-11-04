extends Node2D
# Independent art preview, no game integration.
func _ready():
 var resources=load("res://Godot/Color_Effects.tres")
 for spec in [["ink_stream",Vector2(690,20),Vector2(0.7,0.7)],["ink_base",Vector2(612,493),Vector2(0.7,0.7)],["barrier",Vector2(320,40),Vector2.ONE],["dip_splash",Vector2(80,400),Vector2.ONE]]:
  var sprite=AnimatedSprite2D.new()
  sprite.sprite_frames=resources
  sprite.centered=false
  sprite.position=spec[1];sprite.scale=spec[2]
  add_child(sprite);sprite.play(spec[0])
 for spec in [["Altar/altar_small.png",Vector2(30,300)],["Altar/inkwell_full.png",Vector2(30,174)],["Gate/gate_tinta.png",Vector2(20,40)]]:
  var sprite=Sprite2D.new()
  sprite.texture=load("res://"+spec[0])
  sprite.centered=false;sprite.position=spec[1];add_child(sprite)
 var label=Label.new();label.position=Vector2(20,600)
 label.text="Puerta / altar / salpicadura    |    barrera    |    cascada: 8 cuadros sincronizados"
 add_child(label)
