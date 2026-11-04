"""Restore the provided tail pixels, without generating or repainting artwork."""
from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np
import hashlib
from common import cells,preview,save_atlas,write_json
r=Path(__file__).resolve().parents[1]
base=Image.open(r/'Source/referencia_usuario.png').convert('RGBA')
donor=Image.open(r/'Source/referencia_cola_original.png').convert('RGBA')
assert base.size==donor.size
original=np.array(base);out=original.copy();d=np.array(donor)
mask=Image.new('L',base.size);draw=ImageDraw.Draw(mask)
# Distal tails only. Stop before both versions' hands and the hind-leg roots.
# Separate y bounds follow the tail height of each of the eight poses.
boxes=[(94,275,191,335),(94,277,191,337),(94,269,191,329),(94,262,191,320),
       (94,276,191,336),(94,278,191,338),(94,270,191,330),(94,263,191,320)]
for i,b in enumerate(boxes):
    x=round(i%4*base.width/4);y=round(i//4*base.height/2)
    draw.rectangle((x+b[0],y+b[1],x+b[2]-1,y+b[3]-1),fill=255)
    # Include the old tip's lower edge in compressed/passing poses, avoiding
    # the leg and hand roots on the right.
    if i in [1,5]:draw.rectangle((x+112,y+333,x+180,y+343),fill=255)
    if i in [2,6]:draw.rectangle((x+112,y+326,x+180,y+333),fill=255)
weights=np.array(mask,dtype=np.float32)/255
for i in range(8):
    x=round(i%4*base.width/4);y=round(i//4*base.height/2)
    for lx in range(184,191):
        weights[y:y+round(base.height/2),x+lx] *= (191-lx)/7
m=weights>0
# A narrow transition at the tail root avoids a rectangular pasted edge.
blend=np.round(original*(1-weights[:,:,None])+d*weights[:,:,None]).astype(np.uint8)
out[m]=blend[m]
mask=Image.fromarray(np.round(weights*255).astype(np.uint8))
assert np.array_equal(out[~m],original[~m])
corrected=Image.fromarray(out)
corrected.save(r/'Wolf_Run_cola_restaurada.png');mask.save(r/'Source/mascara_cola.png')
plate=Image.new('RGBA',base.size,(231,226,214,255));plate.alpha_composite(corrected)
plate.convert('RGB').save(r/'Previews/hoja_detalle.png')
original_frames=cells(r/'Wolf_Run_cola_restaurada.png',4,2)
for folder in ['Sprites','Godot']:(r/folder).mkdir(exist_ok=True)
# Shared fixed scaling/placement only for game-sized copies; master is exact.
frames=[]
for i,im in enumerate(original_frames):
    scale=.78
    im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.LANCZOS)
    frame=Image.new('RGBA',(384,384));frame.paste(im,(0,55))
    frame.save(r/f'Sprites/run_{i+1:02}.png');frames.append(frame)
save_atlas(frames,r/'run_atlas.png')
preview(frames,r/'Previews/run.gif',50)
plates=[]
for im in frames:
    p=Image.new('RGBA',(384,384),(231,226,214,255));p.alpha_composite(im);plates.append(p)
plates[0].save(r/'Previews/run_detalle.apng',save_all=True,append_images=plates[1:],duration=50,loop=0,disposal=0,blend=0)
from common import spriteframes
spriteframes(r/'Godot/Wolf_Run.tres',[{'name':'run','fps':20,'loop':True,'files':[f'../Sprites/run_{i+1:02}.png' for i in range(8)]}])
changed=np.any(out!=original,axis=2)
write_json(r/'VALIDACION.json',{'method':'Copy original tail pixels from latest user attachment; no new generation used',
 'master_size':list(base.size),'changed_pixels':int(changed.sum()),
 'changed_pixels_outside_tail_mask':int((changed&~m).sum()),
 'outside_tail_pixels_identical':bool(np.array_equal(out[~m],original[~m])),
 'hand_modified':False,'brush_added':False,
 'source_sha256':hashlib.sha256(original.tobytes()).hexdigest(),
 'master_sha256':hashlib.sha256(out.tobytes()).hexdigest(),
 'mask':'Source/mascara_cola.png','frames':8,'cell':[384,384]})
print({'changed_pixels':int(changed.sum()),'outside_tail_changes':int((changed&~m).sum())})
