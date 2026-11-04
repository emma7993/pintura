extends SceneTree
var failures:=0

func check(ok:bool,label:String) -> void:
	print(('PASS: ' if ok else 'FAIL: ')+label)
	if not ok:
		failures+=1

func _initialize() -> void:
	var frames:SpriteFrames=load('res://Godot/Wolf.tres')
	if frames==null:
		quit(1)
		return
	check(frames.get_frame_count('walk')==12,'walk:12frames')
	check(frames.get_animation_loop('walk'),'walk loops')
	check(is_equal_approx(frames.get_animation_speed('walk'),12.0),'walk:12FPS base')
	check(frames.get_frame_count('idle')==1,'idle:1frame')
	check(frames.get_frame_count('look_around')==6,'look:6frames')
	check(not frames.get_animation_loop('look_around'),'look does not loop')
	for anim in frames.get_animation_names():
		for i in frames.get_frame_count(anim):
			var texture:=frames.get_frame_texture(anim,i)
			check(texture!=null and texture.get_size()==Vector2(256,256),'%s/%02d:texture256x256'%[anim,i+1])
	var atlas:AtlasTexture=frames.get_frame_texture('walk',11)
	check(atlas.region==Rect2(2816,0,256,256),'frame12 region correct')
	check(atlas.atlas.get_size()==Vector2(3072,256),'walk atlas3072x256')
	var idle_image:Image=frames.get_frame_texture('idle',0).get_image()
	check(idle_image.get_data()==frames.get_frame_texture('look_around',0).get_image().get_data(),'look begins at exact idle')
	check(idle_image.get_data()==frames.get_frame_texture('look_around',5).get_image().get_data(),'look ends at exact idle')
	check(is_equal_approx(frames.get_animation_speed('walk')*0.8/12.0,0.8),'0.8 speed_scale gives0.8cycles/s')
	print('RESULT: '+('PASS' if failures==0 else 'FAIL'))
	quit(0 if failures==0 else 1)
