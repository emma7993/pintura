"""Pack eight drawn run poses and a rigid brush carried across the body."""
from pathlib import Path
import math, hashlib
import numpy as np
from PIL import Image
from common import cells, box, preview, save_atlas, spriteframes, write_json

ROOT = Path(__file__).resolve().parents[1]

def eye_center(im):
    a=np.array(im); h,w=a.shape[:2]
    mask=(a[:,:,:3].min(2)>180)&(a[:,:,3]>190)
    roi=np.zeros((h,w),bool);roi[int(h*.28):int(h*.46),int(w*.65):int(w*.83)]=True
    mask &= roi; groups=[]
    for yy,xx in zip(*np.nonzero(mask)):
        if not mask[yy,xx]:continue
        todo=[(int(xx),int(yy))];pts=[];mask[yy,xx]=False
        while todo:
            x,y=todo.pop();pts.append((x,y))
            for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
                if 0<=nx<w and 0<=ny<h and mask[ny,nx]:
                    mask[ny,nx]=False;todo.append((nx,ny))
        if len(pts)>=8:
            mean=np.array(pts).mean(0)
            groups.append((np.linalg.norm(mean-[w*.7,h*.405]),mean))
    if not groups:raise ValueError('White eye not found')
    return min(groups,key=lambda g:g[0])[1]

for folder in ['Sprites','Layers/body','Layers/brush_carry','Previews','Godot']:
    (ROOT/folder).mkdir(parents=True,exist_ok=True)
raw=[]
for im in cells(ROOT/'Source/body_original.png',4,2):
    a=np.array(im);a[a[:,:,3]<190]=0;raw.append(Image.fromarray(a))
b=box(raw[0]);scale=216/(b[3]-b[1]);eyes=[eye_center(im) for im in raw]
eye_target=np.array([242.,352-(b[3]-eyes[0][1])*scale])
grip=eye_target+[-85,92]
angle=20.;c=math.cos(math.radians(angle));s=math.sin(math.radians(angle))
canonical=Image.open(ROOT/'Source/Brush/brush_base.png').convert('RGBA')
canonical.alpha_composite(Image.open(ROOT/'Source/Brush/tip_dry.png').convert('RGBA'))
# All frames share this one rigid, full-length object; no generated bending.
pivot=105
matrix=(c,s,pivot-c*grip[0]-s*grip[1],-s,c,24+s*grip[0]-c*grip[1])
brush=canonical.transform((384,384),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
frames=[];bodies=[];brushes=[];stats=[]
for i,(im,eye) in enumerate(zip(raw,eyes)):
    im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.LANCZOS)
    offset=np.round(eye_target-eye*scale).astype(int)
    body=Image.new('RGBA',(384,384));body.paste(im,tuple(offset))
    body.save(ROOT/f'Layers/body/{i+1:02}.png');bodies.append(body)
    brush.save(ROOT/f'Layers/brush_carry/{i+1:02}.png');brushes.append(brush)
    out=brush.copy();out.alpha_composite(body);frames.append(out)
    out.save(ROOT/f'Sprites/run_{i+1:02}.png')
    stats.append({'frame':i+1,'body_bounds':box(body),'eye_xy':list(np.round(eye*scale+offset,3))})
save_atlas(frames,ROOT/'run_atlas.png')
save_atlas(bodies,ROOT/'Layers/run_body_atlas.png')
save_atlas(brushes,ROOT/'Layers/run_brush_carry_atlas.png')
preview(frames,ROOT/'Previews/run.gif',50,ROOT/'Previews/contact.png')
preview(frames,ROOT/'Previews/run_16fps.gif',[60,60,60,70,60,60,60,70])
preview(frames,ROOT/'Previews/run_20fps.gif',50)
preview(frames,ROOT/'Previews/run_slow.gif',130)
for fps in [16,20]:
    plates=[]
    for im in frames:
        p=Image.new('RGBA',(384,384),(231,226,214,255));p.alpha_composite(im);plates.append(p)
    plates[0].save(ROOT/f'Previews/run_{fps}fps.apng',save_all=True,append_images=plates[1:],
                   duration=1000/fps,loop=0,disposal=0,blend=0)
for name,files in [('Wolf_Run',[f'../Sprites/run_{i+1:02}.png' for i in range(8)]),
                   ('Wolf_Run_body',[f'../Layers/body/{i+1:02}.png' for i in range(8)]),
                   ('Wolf_Run_brush_carry',[f'../Layers/brush_carry/{i+1:02}.png' for i in range(8)])]:
    spriteframes(ROOT/f'Godot/{name}.tres',[{'name':'run','fps':20,'loop':True,'files':files}])
spriteframes(ROOT/'Godot/Wolf_Run_20fps.tres',[{'name':'run','fps':20,'loop':True,
              'files':[f'../Sprites/run_{i+1:02}.png' for i in range(8)]}])
spriteframes(ROOT/'Godot/Wolf_Run_16fps.tres',[{'name':'run','fps':16,'loop':True,
              'files':[f'../Sprites/run_{i+1:02}.png' for i in range(8)]}])
hashes=[hashlib.sha256(im.tobytes()).hexdigest() for im in frames]
border_clear=all(not any(np.array(im)[:,:,3][edge].any() for edge in [(0,slice(None)),(-1,slice(None)),(slice(None),0),(slice(None),-1)]) for im in frames)
assert len(set(hashes))==8 and border_clear
metrics={'frames':8,'unique_frames':len(set(hashes)),'cell':[384,384],'atlas':[3072,384],
         'fps_default':20,'fps_alternative':16,'cycle_seconds':.4,'offset':[-192,-352],
         'shared_scale':scale,'registration':'Whole-frame translation using white-eye centroid',
         'eye_range_xy':list(np.round(np.ptp([f['eye_xy'] for f in stats],axis=0),3)),
         'borders_transparent':border_clear,'per_frame':stats,
         'brush':{'draw_order':['brush_carry','body'],'angle_clockwise':angle,
                  'rigid_layer_identical_all_frames':True,'grip_xy':list(grip),
                  'ring_xy':list(grip-85*np.array([c,s])),
                  'tip_xy':list(grip+129*np.array([c,s])), 'nominal_length_px':215},
         'review':'Image uniqueness and alignment do not prove fluid motion. Check normal and slow previews; game not integrated.'}
log=ROOT/'Source/godot_validation.log'
if log.exists() and 'VALIDATION_OK:' in log.read_text(encoding='utf-8'):
    metrics['godot_validation']={'version':'4.7.2','resources_loaded':5,'scene_loaded':True,'log':'Source/godot_validation.log'}
write_json(ROOT/'VALIDACION.json',metrics)
print({'frames':8,'eye_range_xy':metrics['eye_range_xy'],'body_bounds':[s['body_bounds'] for s in stats]})
