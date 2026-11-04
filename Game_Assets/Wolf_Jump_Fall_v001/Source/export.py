from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np
import math,hashlib
from common import cells,box,preview,save_atlas,spriteframes,write_json
r=Path(__file__).resolve().parents[1]
for d in ['Animations/jump','Animations/fall','Atlases','Godot','Previews']:(r/d).mkdir(exist_ok=True,parents=True)
raw=cells(r/'Source/original.png',3,2)[:5]
raw[3]=Image.open(r/'Source/fall_selected.png').convert('RGBA').resize(raw[3].size,Image.Resampling.LANCZOS)
for i,im in enumerate(raw):
    a=np.array(im);a[a[:,:,3]<190]=0;raw[i]=Image.fromarray(a)
fb=box(raw[3]);scale=216/(fb[3]-fb[1])
resized=[im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.LANCZOS) for im in raw]
def planted_anchor(im):
    a=np.array(im);b=box(im)
    mask=a[:,:,3]>32;mask[:b[3]-3]=False
    ys,xs=np.nonzero(mask)
    return ((xs.min()+xs.max())/2,b[3])
row_anchors=[planted_anchor(resized[0]),planted_anchor(resized[4])]
paths=['Animations/jump/01_impulso.png','Animations/jump/02_ascenso.png','Animations/jump/03_cima.png',
       'Animations/fall/01_cayendo.png','Animations/fall/02_aterrizaje_rebote.png']
labels=['Impulso','Ascenso','Cima','Cayendo','Aterrizaje / rebote']
frames=[];mapping=[]
for i,(im,path,label) in enumerate(zip(resized,paths,labels)):
    anchor=row_anchors[0 if i<3 else 1]
    xy=(round(192-anchor[0]),352-anchor[1])
    out=Image.new('RGBA',(384,384));out.paste(im,xy);out.save(r/path);frames.append(out)
    mapping.append({'id':i+1,'name':label,'file':path,'bounds':box(out),'paste_xy':xy})
save_atlas(frames[:3],r/'Atlases/jump.png');save_atlas(frames[3:],r/'Atlases/fall.png')
save_atlas(frames,r/'Atlases/jump_fall.png')
preview(frames,r/'Previews/poses.gif',250)
board=Image.new('RGBA',(1152,812),(231,226,214,255));bd=ImageDraw.Draw(board)
try:bf=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',18)
except OSError:bf=ImageFont.load_default()
for i,(im,label) in enumerate(zip(frames,labels)):
    at=(i%3*384,i//3*406);board.alpha_composite(im,at)
    bd.text((at[0]+12,at[1]+385),label,font=bf,fill=(40,40,40))
board.convert('RGB').save(r/'Previews/hoja_poses.png')
animations=[]
for name,indices,fps,loop in [('jump',[0,1,2],12,False),('fall_and_land',[3,4],10,False),
 ('jump_start',[0],12,False),('jump_up',[1],10,True),('jump_apex',[2],10,True),('fall',[3],10,True),('land',[4],12,False)]:
    animations.append({'name':name,'files':['../'+paths[i] for i in indices],'fps':fps,'loop':loop})
spriteframes(r/'Godot/Wolf_Jump_Fall.tres',animations)
scene=[];timeline=[]
try:font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',17)
except OSError:font=ImageFont.load_default()
for k in range(36):
    t=k*.04;h=0;pose=0;stage='Impulso'
    if .12<=t<.82:
        u=(t-.12)/.70;h=4*100*u*(1-u)
        pose=1 if u<.42 else 2 if u<.58 else 3;stage=labels[pose]
    elif t>=.82:
        pose=4;stage='Aterrizaje'
        if .94<=t<1.12:h=6*math.sin(math.pi*(t-.94)/.18);stage='Rebote visual'
    p=Image.new('RGBA',(384,512),(231,226,214,255));d=ImageDraw.Draw(p)
    d.text((12,12),'Vista de 5 poses · trayectoria ilustrativa',font=font,fill=(45,45,45))
    d.text((12,39),stage,font=font,fill=(45,45,45));d.line((55,461,330,461),fill=(150,145,134),width=1)
    p.alpha_composite(frames[pose],(0,108-round(h)));scene.append(p)
    timeline.append({'t':round(t,2),'pose':pose+1,'preview_height_px':round(h,2)})
preview(scene,r/'Previews/salto_caida.gif',40)
scene[0].save(r/'Previews/salto_caida.apng',save_all=True,append_images=scene[1:],duration=40,loop=0,disposal=0,blend=0)
write_json(r/'ASSETS.json',{'character':'Lobito','package':'Wolf_Jump_Fall_v001','reference':'Wolf_Run_v013',
 'cell':[384,384],'origin':[192,352],'offset':[-192,-352],'facing':'right','weapon':False,
 'poses':mapping,'animations':[{'name':a['name'],'frames':len(a['files']),'fps':a['fps'],'loop':a['loop']} for a in animations],
 'atlases':{'jump':[1152,384],'fall':[768,384],'jump_fall':[1920,384]},
 'integration_notes':'Use phases by vertical velocity/ground contact. Rebound is visual only, not an automatic gameplay jump.'})
write_json(r/'Previews/timeline.json',timeline)
clear=all(not any(np.array(im)[:,:,3][edge].any() for edge in [(0,slice(None)),(-1,slice(None)),(slice(None),0),(slice(None),-1)]) for im in frames)
assert len(frames)==5 and clear and box(frames[0])[3]==352 and box(frames[4])[3]==352
unique=len(set(hashlib.sha256(im.tobytes()).hexdigest() for im in frames));assert unique==5
write_json(r/'VALIDACION.json',{'poses':5,'unique':unique,'jump_frames':3,'fall_frames':2,'cell':[384,384],
 'shared_scale':scale,'planted_ground_bottom':{'impulso':box(frames[0])[3],'aterrizaje':box(frames[4])[3]},
 'borders_transparent':clear,'weapon':False,'pose_bounds':[box(im) for im in frames],
 'note':'Flexion changes silhouette height at a shared scale. Preview displacement is illustrative, not baked into exported sprites.'})
print({'poses':5,'scale':scale,'bounds':[box(im) for im in frames],'borders_transparent':clear})
