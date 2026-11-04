extends Node2D
# Independent art preview. Not referenced by the main game.
var names=["idle_pincel","walk_pincel","run","run_pincel","paint_slash","paint_up","dip"]
var index=1
var state="color"
var body=AnimatedSprite2D.new()
var shaft=AnimatedSprite2D.new()
var tip=AnimatedSprite2D.new()
var title=Label.new()
func _ready():
 for pair in [[shaft,"brush_base"],[tip,"tip_color"],[body,"body"]]:
  var sprite:AnimatedSprite2D=pair[0]
  sprite.sprite_frames=load("res://Godot/Wolf_"+pair[1]+".tres")
  sprite.centered=false
  sprite.position=Vector2(144,60)
  sprite.scale=Vector2(2,2)
  add_child(sprite)
 title.position=Vector2(24,570)
 add_child(title)
 select()
func select():
 var animation=names[index]
 body.play(animation)
 body.speed_scale=0.8 if animation=="walk_pincel" else 1.0
 shaft.visible=animation!="run"
 tip.visible=animation!="run"
 if animation!="run":
  shaft.animation=animation
  tip.sprite_frames=load("res://Godot/Wolf_tip_"+state+".tres")
  tip.animation=animation
 title.text=animation+" | ← → animación | 1 color / 2 seca / 3 tinta | Espacio repetir"
func _process(_delta):
 if shaft.visible:
  shaft.frame=body.frame
  tip.frame=body.frame
func _unhandled_key_input(event):
 if not event.is_pressed():return
 if event.keycode==KEY_RIGHT:index=(index+1)%names.size()
 elif event.keycode==KEY_LEFT:index=posmod(index-1,names.size())
 elif event.keycode==KEY_1:state="color"
 elif event.keycode==KEY_2:state="dry"
 elif event.keycode==KEY_3:state="ink"
 elif event.keycode==KEY_SPACE:body.frame=0
 else:return
 select()
