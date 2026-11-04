extends SceneTree
# Offline raster VFX production. Not referenced by game code.
var code="""
shader_type canvas_item;
render_mode unshaded;
uniform int kind=0;
uniform float phase=0.0;
uniform float progress=0.0;
uniform sampler2D smoke_tex;
float hash2(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){
 vec2 i=floor(p);vec2 f=fract(p);f=f*f*(3.0-2.0*f);
 return mix(mix(hash2(i),hash2(i+vec2(1.0,0.0)),f.x),mix(hash2(i+vec2(0.0,1.0)),hash2(i+vec2(1.0,1.0)),f.x),f.y);
}
void fragment(){
 vec2 uv=UV;
 vec4 col=texture(TEXTURE,uv);
 if(kind==0){
  vec2 flow=vec2(uv.x+0.012*sin(6.283185*phase+uv.y*18.0)*smoothstep(0.1,0.5,uv.x),uv.y+0.003*sin(6.283185*phase+uv.x*12.0));
  col=texture(TEXTURE,clamp(flow,vec2(0.0),vec2(1.0)));
  float edge=smoothstep(0.0,0.14,uv.x);
  col.rgb=mix(vec3(5.0,7.0,10.0)/255.0,col.rgb,edge);
  col.a=mix(1.0,col.a,edge);
 }else if(kind==1){
  vec4 ripple=texture(TEXTURE,vec2(uv.x+0.004*sin(6.283185*phase+uv.y*11.0),uv.y));
  col.rgb=ripple.rgb*(0.90+0.10*cos(6.283185*phase-uv.x*20.0));
 }else if(kind==2){
  vec2 flow=vec2(uv.x+progress*0.42+0.018*sin(uv.y*39.0)*progress,uv.y);
  col=texture(TEXTURE,clamp(flow,vec2(0.0),vec2(1.0)));
  col.a*=step(flow.x,1.0)*(1.0-progress*0.6);
  col.a*=smoothstep(progress*0.7-0.15,progress*0.7+0.15,noise(uv*4.0));
 }else if(kind==3){
  vec2 shifted=(uv-vec2(0.15*progress,0.04*progress)-0.5)/(1.0+progress*0.18)+0.5;
  col=texture(TEXTURE,shifted);
  col.a*=sin(3.14159265*min(progress+0.10,1.0));
  if(progress>0.999)col.a=0.0;
 }else{
  vec2 drift=vec2(uv.x-progress*0.10*(1.0-uv.y),uv.y+progress*0.015);
  col=texture(TEXTURE,clamp(drift,vec2(0.0),vec2(1.0)));
  float grain=noise(uv*12.0)*0.47+noise(uv*60.0)*0.13+uv.y*0.4;
  float erase=smoothstep(progress-0.07,progress+0.07,grain);
  col.a*=erase*(1.0-progress*0.2);
  col.rgb=mix(col.rgb,vec3(0.15,0.17,0.20),progress*0.5);
  vec2 smoke_uv=(uv-vec2(0.22+progress*0.12,0.18-progress*0.08))/vec2(0.75,0.48);
  vec4 smoke=texture(smoke_tex,clamp(smoke_uv,vec2(0.0),vec2(1.0)));
  smoke.a*=step(0.0,smoke_uv.x)*step(smoke_uv.x,1.0)*step(0.0,smoke_uv.y)*step(smoke_uv.y,1.0)*sin(3.14159265*progress)*0.55;
  float combined_alpha=col.a+smoke.a*(1.0-col.a);
  col.rgb=(col.rgb*col.a+smoke.rgb*smoke.a*(1.0-col.a))/max(0.0001,combined_alpha);
  col.a=combined_alpha;
  if(progress<0.001)col=texture(TEXTURE,uv);
  if(progress>0.999)col.a=0.0;
 }
 COLOR=col;
}
"""
func _initialize():call_deferred("produce")
func produce():
 var jobs=[
  {"src":"Bruma/front_master.png","dest":"Bruma/Front","kind":0,"size":Vector2i(512,1024),"count":8,"loop":true},
  {"src":"Manos/puddle_master.png","dest":"Manos/Puddle","kind":1,"size":Vector2i(384,96),"count":8,"loop":true},
  {"src":"Bruma/front_master.png","dest":"Bruma/Recoil","kind":2,"size":Vector2i(512,1024),"count":6,"loop":false}]
 for i in range(6):jobs.append({"src":"Bruma/Wisps/%02d/master.png"%(i+1),"dest":"Bruma/Wisps/%02d"%(i+1),"kind":3,"size":Vector2i(128,128),"count":6,"loop":false})
 for letter in ["A","B","C"]:jobs.append({"src":"Manos/"+letter+"/dissolve_master.png","dest":"Manos/"+letter+"/dissolve","kind":4,"size":Vector2i(256,512),"count":8,"loop":false})
 for job in jobs:
  DirAccess.make_dir_recursive_absolute("res://"+job.dest)
  var viewport=SubViewport.new();viewport.size=job.size;viewport.transparent_bg=true
  viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(viewport)
  var sprite=Sprite2D.new();sprite.centered=false
  sprite.texture=ImageTexture.create_from_image(Image.load_from_file("res://"+job.src))
  var shader=Shader.new();shader.code=code
  var mat=ShaderMaterial.new();mat.shader=shader;mat.set_shader_parameter("kind",job.kind);sprite.material=mat;viewport.add_child(sprite)
  if job.kind==4:mat.set_shader_parameter("smoke_tex",ImageTexture.create_from_image(Image.load_from_file("res://Bruma/Wisps/01/master.png")))
  for i in range(job.count+(1 if job.loop else 0)):
   mat.set_shader_parameter("phase",float(i%job.count)/job.count)
   mat.set_shader_parameter("progress",float(min(i,job.count-1))/(job.count-1))
   await process_frame
   await RenderingServer.frame_post_draw
   var image=viewport.get_texture().get_image()
   var filename="closure_test.png" if i==job.count else "%02d.png"%(i+1)
   var error=image.save_png("res://"+job.dest+"/"+filename)
   if error!=OK:push_error("PNG_SAVE_ERROR "+job.dest);quit(1);return
  viewport.queue_free();await process_frame
 print("SOMBRAS_VFX_RENDER_OK");quit()
