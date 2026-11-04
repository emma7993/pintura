from pathlib import Path
import sys,math,json
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parents[1]
C=R.parent/'Nivel_01_Camino/Color_v001'
sys.path.insert(0,str(C/'Source'))
from common import box,cells,preview,save_atlas,write_json,spriteframes

def normalize(name,cols,rows):
    frames=cells(R/'Source'/f'{name}_original.png',cols,rows)
    # Remove only diffuse generated alpha haze. Never deform/rebuild body parts.
    cleaned=[]
    for im in frames:
        a=np.array(im);a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);cleaned.append(Image.fromarray(a))
    bbs=[box(im,190) for im in cleaned]
    scale=218/max(b[3]-b[1] for b in bbs)
    result=[]
    for im,b in zip(cleaned,bbs):
        crop=im.crop(b); crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.LANCZOS)
        out=Image.new('RGBA',(256,256));out.paste(crop,(round(128-crop.width/2),239-crop.height))
        result.append(out)
    return result

anims={
 'idle_pincel':normalize('idle_pincel',1,1),
 'walk_pincel':[Image.open(R/'References'/f'walk_{i:02}.png').convert('RGBA') for i in range(1,13)],
 'run':normalize('run',4,2),
 'run_pincel':normalize('run_pincel',4,2),
 'paint_slash':normalize('paint_slash',4,2),
 'paint_up':normalize('paint_up',4,2),
 'dip':normalize('dip',3,2),
}
for name,frames in anims.items():
    folder=R/'Animations'/name/'body';folder.mkdir(parents=True,exist_ok=True)
    for i,im in enumerate(frames): im.save(folder/f'{i+1:02}.png')
    preview(frames,R/'Previews'/f'{name}_body.gif',100,R/'Previews'/f'{name}_body_contact.png')
if '--body-only' in sys.argv:sys.exit()

# Canonical rigid brush, separated from the complete character drawings.
brushes=cells(C/'Source/brush_master_original.png',1,3)
canonical=[]
for im in brushes:
    crop=im.crop(box(im)).resize((224,18),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(256,64));out.paste(crop,(16,23));canonical.append(out)
base=canonical[1].copy();base.paste((0,0,0,0),(202,0,256,64));base.save(R/'Brush/brush_base.png')
tips={}
for name,im in zip(['color','dry','ink'],canonical):
    tip=im.copy();tip.paste((0,0,0,0),(0,0,202,64));tip.save(R/'Brush/Tips'/f'tip_{name}.png');tips[name]=tip

config=json.loads((R/'Source/grips.json').read_text())
resources={layer:[] for layer in ['body','brush_base','brush','tip_color','tip_dry','tip_ink']}
metadata=[]
for name,frames in anims.items():
    cfg=config[name]
    sheets={layer:[] for layer in resources}
    previews=[]
    for i,body in enumerate(frames):
        if name=='run':
            layers={'body':body}
            row={'animation':name,'frame':i+1,'paints':False,'receives_ink':False,'tip_xy':None}
        else:
            gx,gy,angle=cfg['grips'][i]
            rad=math.radians(angle);c,s=math.cos(rad),math.sin(rad);q=.8
            matrix=(c/q,s/q,170-(c*gx+s*gy)/q,-s/q,c/q,32+(s*gx-c*gy)/q)
            transform=lambda im:im.transform((256,256),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
            layers={'body':body,'brush_base':transform(base)}
            for state,tip in tips.items():layers['tip_'+state]=transform(tip)
            whole=layers['brush_base'].copy();whole.alpha_composite(layers['tip_dry']);layers['brush']=whole
            contacts={}
            for state in tips:
                a=np.array(layers['tip_'+state])[:,:,3];ys,xs=np.nonzero(a>64)
                projection=xs*c+ys*s;keep=projection>=projection.max()-1
                contacts[state]=[round(float(xs[keep].mean()),2),round(float(ys[keep].mean()),2)]
            row={'animation':name,'frame':i+1,'grip_xy':[gx,gy],'angle_degrees_clockwise':angle,'tip_xy':[round(gx+.8*69*c,2),round(gy+.8*69*s,2)],'contact_by_state_xy':contacts,'paints':i+1 in cfg.get('paint_frames',[]),'receives_ink':i+1 in cfg.get('dip_frames',[])}
        metadata.append(row)
        plate=Image.new('RGBA',(256,256))
        if 'brush_base' in layers:
            plate.alpha_composite(layers['brush_base']);plate.alpha_composite(layers['tip_color' if name.startswith('paint') else 'tip_dry'])
        plate.alpha_composite(body);previews.append(plate)
        for layer,im in layers.items():
            folder=R/'Animations'/name/layer;folder.mkdir(exist_ok=True,parents=True)
            im.save(folder/f'{i+1:02}.png');sheets[layer].append(im)
    fps=12 if name=='walk_pincel' else (16 if name.startswith('run') else 10)
    for layer,images in sheets.items():
        if not images:continue
        save_atlas(images,R/'Animations'/name/f'{layer}_atlas.png')
        resources[layer].append({'name':name,'fps':fps,'loop':name in ['idle_pincel','walk_pincel','run','run_pincel'],'files':[f'../Animations/{name}/{layer}/{i+1:02}.png' for i in range(len(images))]})
    duration=([100,100,110,100,100,110,100,100,110,100,100,120] if name=='walk_pincel' else round(1000/fps))
    preview(previews,R/'Previews'/f'{name}.gif',duration,R/'Previews'/f'{name}_contact.png')
for layer,animations in resources.items():spriteframes(R/'Godot'/f'Wolf_{layer}.tres',animations)
write_json(R/'brush_contacts.json',metadata)
print('WOLF_OK:51 body frames; separate aligned brush/base/3tips; 7 animations')
