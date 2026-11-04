extends SceneTree
func _initialize():
 var paths=["res://Godot/Sombras_Manos.tres","res://Godot/Sombras_Bruma.tres"] if ResourceLoader.exists("res://Godot/Sombras_Manos.tres") else ["res://Godot/Wolf_body.tres","res://Godot/Wolf_brush_base.tres","res://Godot/Wolf_tip_color.tres","res://Godot/Wolf_tip_dry.tres","res://Godot/Wolf_tip_ink.tres"]
 var total=0
 for path in paths:
  var frames=load(path) as SpriteFrames
  assert(frames!=null,"SpriteFrames missing "+path)
  var count=0
  for animation in frames.get_animation_names():
   assert(frames.get_frame_count(animation)>0)
   for i in range(frames.get_frame_count(animation)):
    var texture=frames.get_frame_texture(animation,i)
    assert(texture!=null and texture.get_width()>0 and texture.get_height()>0)
    count+=1
  print("RESOURCE_OK ",path," animations=",frames.get_animation_names().size()," frames=",count)
  total+=count
 print("ALL_ASSET_RESOURCES_OK ",total)
 quit()
