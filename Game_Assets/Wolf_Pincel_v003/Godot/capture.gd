extends SceneTree
func _initialize():call_deferred("capture")
func capture():
 var scene=load("res://Godot/Preview.tscn").instantiate();root.add_child(scene)
 await process_frame
 await RenderingServer.frame_post_draw
 var error=root.get_texture().get_image().save_png("res://Previews/godot_preview.png")
 print("WOLF_V003_CAPTURE ",error);quit(error)
