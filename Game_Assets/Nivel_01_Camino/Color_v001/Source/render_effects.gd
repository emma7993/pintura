extends SceneTree

# Offline asset production only. No dependency from the game.
const ROOT = "res://Game_Assets/Nivel_01_Camino/Color_v001/"
var shader_code = """
shader_type canvas_item;
render_mode unshaded;
uniform float phase = 0.0;
uniform int kind = 0;
uniform float progress = 1.0;
void fragment() {
 vec2 uv = UV;
 vec4 original = texture(TEXTURE, uv);
 if (kind == 0) {
  float t = fract(uv.y - phase);
  vec4 moving = texture(TEXTURE, vec2(uv.x, t));
  float seam = smoothstep(0.0,0.08,t)*smoothstep(0.0,0.08,1.0-t);
  vec3 ink = mix(vec3(0.008,0.012,0.018),moving.rgb,seam);
  COLOR = vec4(ink,original.a);
 } else if (kind == 1) {
  vec2 flow = vec2(uv.x + 0.005*sin(6.283185*(phase+uv.y*2.0)),uv.y);
  vec4 ripple = texture(TEXTURE,flow);
  COLOR = vec4(ripple.rgb*(0.93+0.07*cos(6.283185*(phase-uv.x*2.0))),original.a);
 } else {
  float edge = 1.0-progress + (0.012*sin(uv.x*97.0)+0.008*sin(uv.x*231.0))*(1.0-progress);
  float reveal = smoothstep(edge-0.012,edge+0.012,uv.y);
  if(progress>=0.999) reveal=1.0;
  COLOR=vec4(original.rgb,original.a*reveal);
 }
}
"""

func _initialize():
 call_deferred("produce")

func produce():
 for job in [
  {"name":"Stream","master":"Inkfall/stream_master.png","size":Vector2i(160,720),"kind":0},
  {"name":"Base","master":"Inkfall/base_master.png","size":Vector2i(384,128),"kind":1},
  {"name":"Barrier","master":"Barrier/barrier_master.png","size":Vector2i(256,512),"kind":2}]:
  var viewport=SubViewport.new()
  viewport.size=job.size
  viewport.transparent_bg=true
  viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
  root.add_child(viewport)
  var sprite=Sprite2D.new()
  sprite.centered=false
  var img=Image.load_from_file(ROOT+job.master)
  sprite.texture=ImageTexture.create_from_image(img)
  var shader=Shader.new()
  shader.code=shader_code
  var mat=ShaderMaterial.new()
  mat.shader=shader
  mat.set_shader_parameter("kind",job.kind)
  sprite.material=mat
  viewport.add_child(sprite)
  for i in range(9):
   mat.set_shader_parameter("phase",float(i%8)/8.0)
   mat.set_shader_parameter("progress",float(min(i+1,8))/8.0)
   await process_frame
   await RenderingServer.frame_post_draw
   var rendered=viewport.get_texture().get_image()
   var dest=ROOT+("Barrier/" if job.kind==2 else "Inkfall/"+job.name+"/")
   var filename=("barrier_%02d.png" if job.kind==2 else "ink_%02d.png") % (i+1)
   if i==8:
    filename="rest.png" if job.kind==2 else "closure_test.png"
   var err=rendered.save_png(dest+filename)
   if err!=OK:
    push_error("Save failed "+dest+filename)
    quit(1)
    return
  viewport.queue_free()
  await process_frame
 print("EFFECTS_OK: 8 stream +8 base +8 barrier +closure/rest")
 quit()
