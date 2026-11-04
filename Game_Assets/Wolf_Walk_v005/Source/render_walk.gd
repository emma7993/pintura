extends SceneTree
## Asset-production rig only. Renders generated raster cutouts in an isolated viewport.
const CELL := 256
const SUPER := 4
const HIP := Vector2(128,166)
const STEP := 87.5
var _vp: SubViewport
var _stage: Node2D
var _textures := {}
var _parts: Dictionary
var _landmarks := []

func _initialize() -> void:
	call_deferred('render_all')

func render_all() -> void:
	_parts=JSON.parse_string(FileAccess.get_file_as_string('res://Source/parts_metrics.json'))
	for key in _parts:
		_textures[key]=ImageTexture.create_from_image(Image.load_from_file('res://Source/Parts/'+key+'.png'))
	_vp=SubViewport.new()
	_vp.size=Vector2i(CELL*SUPER,CELL*SUPER)
	_vp.transparent_bg=true
	_vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	_vp.world_2d=World2D.new()
	root.add_child(_vp)
	_stage=Node2D.new()
	_stage.scale=Vector2.ONE*SUPER
	_vp.add_child(_stage)
	var atlas:=Image.create(3072,256,false,Image.FORMAT_RGBA8)
	for i in 13:
		for child in _stage.get_children():
			child.free()
		pose(float(i)/12.0,i)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var image:=_vp.get_texture().get_image()
		image.resize(256,256,Image.INTERPOLATE_LANCZOS)
		if i<12:
			image.save_png('res://Individual_Frames/walk/walk_%02d.png'%(i+1))
			atlas.blit_rect(image,Rect2i(0,0,256,256),Vector2i(i*256,0))
		else:
			image.save_png('res://Source/loop_virtual_13.png')
	atlas.save_png('res://SpriteSheets/walk_v005.png')
	var look_atlas:=Image.create(1536,256,false,Image.FORMAT_RGBA8)
	for i in 6:
		for child in _stage.get_children():
			child.free()
		pose(0.0,i,'look')
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var image:=_vp.get_texture().get_image()
		image.resize(256,256,Image.INTERPOLATE_LANCZOS)
		image.save_png('res://Individual_Frames/look_around/look_around_%02d.png'%(i+1))
		look_atlas.blit_rect(image,Rect2i(0,0,256,256),Vector2i(i*256,0))
		if i==0:
			image.save_png('res://Individual_Frames/idle/idle_01.png')
			image.save_png('res://SpriteSheets/idle_v005.png')
	look_atlas.save_png('res://SpriteSheets/look_around_v005.png')
	var out:=FileAccess.open('res://Source/rig_landmarks.json',FileAccess.WRITE)
	out.store_string(JSON.stringify({'step_px':STEP,'cycle_px':STEP*2,'stance_delta_px':STEP/6.0,'cell':[256,256],'ground_y':238,'super_sampling':SUPER,'body_height':148,'frames':_landmarks},'\t'))
	print('RENDER PASS: 12 RGBA frames; 3072x256 atlas; independent virtual frame13 for closure QA')
	quit()

func pose(phase: float,index: int,mode: String='walk') -> void:
	phase=fposmod(phase,1.0)
	var half:=phase*2.0
	var t:=fposmod(half,1.0)
	var first:=phase<0.5
	var stance:=Vector2(172.0-STEP*t,238)
	var swing:=Vector2(84.5+STEP*t,238-16.0*sin(PI*t))
	var right:=stance if first else swing
	var left:=swing if first else stance
	var bob:=0.8*sin(TAU*phase*2.0)
	if mode!='walk':
		right=Vector2(140,238)
		left=Vector2(119,238)
		bob=0.0
	var hip:=HIP+Vector2(0,bob)
	var tail:=piece('tail',Vector2(120,166+bob),Vector2(86,66),Vector2(-84,-16),-3)
	tail.rotation=0.025*sin(TAU*phase)
	cloth(phase,bob,mode!='walk')
	leg(left,hip,'far',0)
	leg(right,hip,'near',2)
	var sf:=80.0/float(_parts.torso.size[1])
	var body_size:=Vector2(48,80)
	var torso_root:=float(_parts.torso.root_x)/float(_parts.torso.size[0])*body_size.x
	piece('torso',hip,body_size,Vector2(-torso_root,-80),3)
	var head_id: String='head_front'
	if mode=='look':
		head_id=['head_front','head_front','head_quarter','head_back','head_quarter','head_front'][index]
	var head_sf:=78.0/float(_parts.head_front.size[1])
	var head_size:=Vector2(float(_parts[head_id].size[0]),float(_parts[head_id].size[1]))*head_sf
	var root_ratio:=0.32 if head_id=='head_front' else 0.68
	var head:=piece(head_id,Vector2(138,91+bob),head_size,Vector2(-head_size.x*root_ratio,-head_size.y*0.93),4)
	if mode=='look' and index==1:
		head.rotation=-0.035
	if mode=='walk':
		_landmarks.append({'frame':index+1,'phase':phase,'right_sole_center':[right.x,right.y],'left_sole_center':[left.x,left.y],'hip':[hip.x,hip.y],'stance':'right' if first else 'left','scarf_phase':phase,'tail_phase':phase})

func leg(sole: Vector2,hip: Vector2,side: String,depth: int) -> void:
	var ankle:=sole+Vector2(-5,-7)
	var d:=ankle-hip
	var distance:=d.length()
	var bend:=sqrt(maxf(0.0,43.0*43.0-pow(distance*0.5,2)))
	var knee:Vector2=(hip+ankle)*0.5+Vector2(d.y,-d.x).normalized()*bend
	# Continuous raster skin through the knee avoids the gray cap seams of cutout bones.
	var skin:=Polygon2D.new()
	skin.texture=_textures['thigh_'+side]
	skin.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	skin.z_index=depth
	var points:=PackedVector2Array()
	var uv:=PackedVector2Array()
	var faces: Array[PackedInt32Array]=[]
	var joint_a:=knee-(knee-hip).normalized()*4.0
	var joint_b:=knee+(ankle-knee).normalized()*4.0
	for row in 17:
		var t:=row/16.0
		var center:Vector2
		var tangent:Vector2
		if t<0.45:
			center=hip.lerp(joint_a,t/0.45)
			tangent=joint_a-hip
		elif t>0.55:
			center=joint_b.lerp(ankle,(t-0.55)/0.45)
			tangent=ankle-joint_b
		else:
			var f:float=(t-0.45)/0.1
			center=pow(1-f,2)*joint_a+2.0*(1-f)*f*knee+f*f*joint_b
			tangent=2.0*((1-f)*(knee-joint_a)+f*(joint_b-knee))
		var normal:=Vector2(-tangent.y,tangent.x).normalized()
		var width:=12.5-2.0*t
		for col in 3:
			var u:=col/2.0
			points.append(center+normal*(u-0.5)*width)
			uv.append(Vector2(u,t)*skin.texture.get_size())
	for row in 16:
		for col in 2:
			var a:=row*3+col
			faces.append(PackedInt32Array([a,a+1,a+4,a+3]))
	skin.polygon=points
	skin.uv=uv
	skin.polygons=faces
	_stage.add_child(skin)
	# Flat foot texture translates; it never rotates during support.
	piece('foot',sole,Vector2(27,12),Vector2(-13.5,-11),depth+1)

func segment(id: String,a: Vector2,b: Vector2,width: float,depth: int) -> void:
	var delta:=b-a
	var sprite:=piece(id,a,Vector2(width,delta.length()+7),Vector2(-width*0.5,-3.5),depth)
	sprite.rotation=delta.angle()-PI*0.5

func piece(id: String,at: Vector2,size: Vector2,offset: Vector2,depth: int) -> Node2D:
	var holder:=Node2D.new()
	holder.position=at
	holder.z_index=depth
	_stage.add_child(holder)
	var sprite:=Sprite2D.new()
	sprite.texture=_textures[id]
	sprite.centered=false
	sprite.position=offset
	sprite.scale=size/sprite.texture.get_size()
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	holder.add_child(sprite)
	return holder

func cloth(phase: float,bob: float,resting: bool=false) -> void:
	var mesh:=Polygon2D.new()
	mesh.texture=_textures.scarf
	mesh.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	mesh.position=Vector2(131,94+bob)
	mesh.z_index=-1
	var vertices:=PackedVector2Array()
	var uv:=PackedVector2Array()
	var polygons: Array[PackedInt32Array]=[]
	for row in 5:
		for col in 9:
			var u:=col/8.0
			var v:=row/4.0
			var wave:=12.0*pow(1-u,1.5) if resting else 2.5*pow(1-u,1.5)*sin(TAU*phase-4*u)
			vertices.append(Vector2((u-1)*68,(v-0.12)*53+wave))
			uv.append(Vector2(u,v)*mesh.texture.get_size())
	for row in 4:
		for col in 8:
			var a:=row*9+col
			polygons.append(PackedInt32Array([a,a+1,a+10,a+9]))
	mesh.polygon=vertices
	mesh.uv=uv
	mesh.polygons=polygons
	_stage.add_child(mesh)
