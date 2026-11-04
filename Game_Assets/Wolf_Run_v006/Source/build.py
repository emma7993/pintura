from pathlib import Path
import sys, math, shutil, csv
from PIL import Image
import numpy as np
from common import cells,box,save_atlas,preview,write_json,spriteframes
root=Path(__file__).resolve().parents[1]
old=root.parent/'Wolf_Pincel_v003'
for d in ['Sprites','Atlases','Previews','Godot','Brush','Layers/body','Layers/brush_base','Layers/tip_color','Layers/tip_dry','Layers/tip_ink']:
    (root/d).mkdir(parents=True,exist_ok=True)
shutil.copy2(old/'Brush/brush_base.png',root/'Brush/brush_base.png')
for state in ['color','dry','ink']:
    shutil.copy2(old/f'Brush/Tips/{state}.png',root/f'Brush/tip_{state}.png')
raw=cells(root/'Source/original.png',4,2)
# Source fist centers, measured in each original grid cell (0..1).
fists=[(.380,.600),(.385,.600),(.380,.577),(.380,.542),(.380,.605),(.380,.590),(.380,.578),(.380,.548)]
layers={k:[] for k in ['body','brush_base','tip_color','tip_dry','tip_ink']}
composites=[]; contacts=[]
for i,im in enumerate(raw):
    a=np.array(im); a[a[:,:,3]<190]=0; im=Image.fromarray(a)
    b=box(im); crop=im.crop(b); scale=216/crop.height
    crop=crop.resize((round(crop.width*scale),216),Image.Resampling.LANCZOS)
    x=round(192-crop.width/2); y=352-216
    body=Image.new('RGBA',(384,384)); body.paste(crop,(x,y))
    gx=x+(fists[i][0]*im.width-b[0])*scale
    gy=y+(fists[i][1]*im.height-b[1])*scale
    angle=160+2*math.sin(i*math.pi/4); c=math.cos(math.radians(angle)); s=math.sin(math.radians(angle))
    pivot=105
    matrix=(c,s,pivot-c*gx-s*gy,-s,c,24+s*gx-c*gy)
    layers['body'].append(body)
    for name in ['brush_base','tip_color','tip_dry','tip_ink']:
        canonical=Image.open(root/f'Brush/{name}.png').convert('RGBA')
        layers[name].append(canonical.transform((384,384),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC))
    merged=Image.new('RGBA',(384,384))
    for name in ['brush_base','tip_color','body']: merged.alpha_composite(layers[name][-1])
    merged.save(root/f'Sprites/run_{i+1:02}.png'); composites.append(merged)
    contacts.append({'frame':i+1,'grip_xy':[round(gx,2),round(gy,2)],'angle_degrees_clockwise':round(angle,2),'tip_xy':[round(gx+(234-pivot)*c,2),round(gy+(234-pivot)*s,2)],'paints':False,'receives_ink':False})
for name,frames in layers.items():
    for i,im in enumerate(frames): im.save(root/f'Layers/{name}/{i+1:02}.png')
    save_atlas(frames,root/f'Atlases/run_{name}.png')
    spriteframes(root/f'Godot/run_{name}.tres',[{'name':'run','fps':16,'loop':True,'files':[f'../Layers/{name}/{i+1:02}.png' for i in range(8)]}])
save_atlas(composites,root/'Atlases/run.png')
preview(composites,root/'Previews/run.gif',60,root/'Previews/run_contact.png')
spriteframes(root/'Godot/Wolf_Run.tres',[{'name':'run','fps':16,'loop':True,'files':[f'../Sprites/run_{i+1:02}.png' for i in range(8)]}])
write_json(root/'brush_contacts.json',contacts)
write_json(root/'VALIDACION.json',{'frames':8,'cell':[384,384],'atlas':[3072,384],'offset':[-192,-352],'fps':16,'rgba':True,'body_bounds':[list(box(im)) for im in layers['body']],'note':'Solo carrera. Las fases de vuelo quedan alineadas al mismo origen; revisión artística pendiente del usuario.'})
