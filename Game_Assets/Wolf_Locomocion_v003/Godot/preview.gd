extends Node2D
func _ready():
 var frames=load("res://Godot/Wolf.tres") as SpriteFrames
 for i in range(2):
  var sprite=AnimatedSprite2D.new();sprite.sprite_frames=frames;sprite.centered=false;sprite.scale=Vector2(1.7,1.7);sprite.position=Vector2(5+i*445,80);add_child(sprite)
  sprite.play("walk" if i==0 else "run");sprite.speed_scale=0.8 if i==0 else 1.0
  var label=Label.new();label.position=Vector2(70+i*445,540);label.modulate=Color(0.15,0.15,0.15);label.text="CAMINAR · cautela" if i==0 else "CORRER · ojos abiertos";add_child(label)
