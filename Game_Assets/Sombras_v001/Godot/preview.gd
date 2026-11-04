extends Node2D
# Isolated asset review only; not loaded by the game.
var hand_resources:SpriteFrames
var mist_resources:SpriteFrames
var hands=[]
var fog:AnimatedSprite2D
var title=Label.new()
var selected="reach"
func animated(resource,animation,where,scaling=Vector2.ONE):
 var sprite=AnimatedSprite2D.new()
 sprite.sprite_frames=resource;sprite.centered=false;sprite.position=where;sprite.scale=scaling
 add_child(sprite);sprite.play(animation)
 return sprite
func _ready():
 hand_resources=load("res://Godot/Sombras_Manos.tres")
 mist_resources=load("res://Godot/Sombras_Bruma.tres")
 var background=Sprite2D.new();background.texture=load("res://References/camino_graphite.png");background.centered=false;background.scale=Vector2(0.62,0.62);background.position=Vector2(0,30);add_child(background)
 fog=animated(mist_resources,"front_loop",Vector2(-70,10),Vector2(0.55,0.55))
 for i in range(3):animated(mist_resources,"eyes_%02d"%(i+1),Vector2(15+(i%2)*65,120+i*140),Vector2(0.7,0.7))
 var registration=JSON.parse_string(FileAccess.get_file_as_string("res://Source/registration.json"))
 var validation=JSON.parse_string(FileAccess.get_file_as_string("res://VALIDACION.json"))
 for i in range(3):
  var letter=["A","B","C"][i]
  var anchor=registration[letter].anchor_xy
  hands.append(animated(hand_resources,letter+"_reach",Vector2(350+i*220-anchor[0],550-anchor[1])))
  animated(hand_resources,"puddle_loop",Vector2(350+i*220-192,550-validation.puddle_anchor_xy[1]))
 var wolf=Sprite2D.new();wolf.texture=load("res://References/wolf_style.png");wolf.centered=false;wolf.position=Vector2(865,312);add_child(wolf)
 title.position=Vector2(15,590);title.modulate=Color(0.15,0.15,0.15);add_child(title);update_title()
func update_title():title.text="A delgada | B garras | C rápida — "+selected+" | 1 emerge, 2 reach, 3 grab, 4 sink, 5 dissolve, R recoil"
func _unhandled_key_input(event):
 if not event.is_pressed():return
 var actions={KEY_1:"emerge",KEY_2:"reach",KEY_3:"grab",KEY_4:"sink",KEY_5:"dissolve"}
 if actions.has(event.keycode):
  selected=actions[event.keycode]
  for i in range(3):hands[i].frame=0;hands[i].play(["A","B","C"][i]+"_"+selected)
  update_title()
 elif event.keycode==KEY_R:fog.frame=0;fog.play("recoil")
 elif event.keycode==KEY_F:fog.play("front_loop")
