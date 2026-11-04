extends Node2D
# Independent art review. No main-game dependency.
var names=["idle","walk","run","jump_start","jump_up","fall","land","dash","wall_slide","wall_jump","slash_side","slash_up","slash_down","paint_rise","paint_up","dip","hurt","death"]
var index=0
var tip_state="color"
var sprites={}
var body:AnimatedSprite2D
var label=Label.new()
var debug=false
var contacts={}
var art_origin=Vector2(162,20)
var art_scale=1.5
func _ready():
 for row in JSON.parse_string(FileAccess.get_file_as_string("res://brush_contacts.json")):
  if not contacts.has(row.animation):contacts[row.animation]=[]
  contacts[row.animation].append(row)
 for layer in ["brush_back","brush_base","tip_color","smear","body"]:
  var sprite=AnimatedSprite2D.new();sprite.centered=false;sprite.position=art_origin;sprite.scale=Vector2(art_scale,art_scale)
  sprite.sprite_frames=load("res://Godot/Wolf_"+layer+".tres");add_child(sprite);sprites[layer]=sprite
 body=sprites.body
 label.position=Vector2(18,610);label.modulate=Color(0.15,0.15,0.15);add_child(label)
 select()
func select():
 var animation=names[index]
 body.play(animation);body.speed_scale=0.8 if animation=="walk" else 1.0
 sprites.tip_color.sprite_frames=load("res://Godot/Wolf_tip_"+tip_state+".tres")
 for layer in sprites:
  if layer!="body":sprites[layer].animation=animation
 label.text=animation+" | ← → animación | 1 color / 2 seca / 3 tinta\nEspacio repite | H: contactos e hitbox | origen común (-192,-352)"
func _process(_delta):
 for layer in sprites:
  if layer!="body":sprites[layer].frame=body.frame
 queue_redraw()
func _draw():
 if not debug or not contacts.has(names[index]):return
 var row=contacts[names[index]][body.frame]
 if row.opacity<=0:return
 var grip=Vector2(row.grip_xy[0],row.grip_xy[1]);var tip=Vector2(row.tip_xy[0],row.tip_xy[1])
 draw_line(art_origin+grip*art_scale,art_origin+tip*art_scale,Color(0.1,0.5,0.9,0.6),1.0)
 draw_circle(art_origin+tip*art_scale,3,Color(0.2,0.5,0.9))
 if row.hitbox!=null:
  var h=row.hitbox
  draw_rect(Rect2(art_origin+Vector2(h[0],h[1])*art_scale,Vector2(h[2],h[3])*art_scale),Color(0.9,0.1,0.1,0.7),false,2)
func _unhandled_key_input(event):
 if not event.is_pressed():return
 if event.keycode==KEY_RIGHT:index=(index+1)%names.size()
 elif event.keycode==KEY_LEFT:index=posmod(index-1,names.size())
 elif event.keycode==KEY_1:tip_state="color"
 elif event.keycode==KEY_2:tip_state="dry"
 elif event.keycode==KEY_3:tip_state="ink"
 elif event.keycode==KEY_H:debug=not debug;return
 elif event.keycode==KEY_SPACE:body.frame=0
 else:return
 select()
