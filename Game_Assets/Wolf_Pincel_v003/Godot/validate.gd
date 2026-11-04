extends SceneTree
func _initialize():
 var total=0
 for layer in ["body","brush_back","brush_base","tip_color","tip_dry","tip_ink","smear"]:
  var resource=load("res://Godot/Wolf_"+layer+".tres") as SpriteFrames
  assert(resource!=null)
  assert(resource.get_animation_names().size()==18)
  var count=0
  for name in resource.get_animation_names():
   for i in range(resource.get_frame_count(name)):
    var texture=resource.get_frame_texture(name,i)
    assert(texture!=null and texture.get_size()==Vector2(384,384))
    count+=1
  assert(count==101)
  total+=count
  print("LAYER_OK ",layer," frames=",count)
 print("WOLF_PINCEL_V003_RESOURCES_OK ",total)
 quit()
