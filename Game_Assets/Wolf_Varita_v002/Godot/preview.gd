extends Node2D
var names=["idle","idle_varita","walk","walk_varita","run","run_varita","jump_start","jump_start_varita","jump_up","jump_up_varita","fall","fall_varita","land","land_varita","paint_rise","paint_slash","paint_up","dip"]
var index=14
var state="color"
var body=AnimatedSprite2D.new()
var shaft=AnimatedSprite2D.new()
var tip=AnimatedSprite2D.new()
var title=Label.new()
func _ready():
 for pair in [[shaft,"brush_base"],[tip,"tip_color"],[body,"body"]]:
  var sprite:AnimatedSprite2D=pair[0]
  sprite.sprite_frames=load("res://Godot/Wolf_"+pair[1]+".tres")
  sprite.centered=false;sprite.position=Vector2(144,45);sprite.scale=Vector2(2,2)
  add_child(sprite)
 title.position=Vector2(15,570);title.modulate=Color(0.15,0.15,0.15);add_child(title)
 select()
func select():
 var anim=names[index]
 body.play(anim);body.speed_scale=0.8 if anim.begins_with("walk") else 1.0
 shaft.visible=shaft.sprite_frames.has_animation(anim);tip.visible=shaft.visible
 if shaft.visible:
  shaft.animation=anim;tip.sprite_frames=load("res://Godot/Wolf_tip_"+state+".tres");tip.animation=anim
 title.text=anim+" | ← → animación | 1 color / 2 seca / 3 tinta | Espacio repite"
func _process(_delta):
 if shaft.visible:shaft.frame=body.frame;tip.frame=body.frame
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
