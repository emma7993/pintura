from pathlib import Path
import numpy as np
from PIL import Image
from common import cells,box,preview,save_atlas,spriteframes,write_json
r=Path(__file__).resolve().parents[1]
for d in ['Sprites','Previews','Godot']: (r/d).mkdir(exist_ok=True)
frames=[]
for i,im in enumerate(cells(r/'Source/original.png',4,2)):
    a=np.array(im); a[a[:,:,3]<190]=0; im=Image.fromarray(a)
    crop=im.crop(box(im)); scale=216/crop.height
    crop=crop.resize((round(crop.width*scale),216),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(384,384));out.paste(crop,(round(192-crop.width/2),136))
    out.save(r/f'Sprites/run_{i+1:02}.png');frames.append(out)
save_atlas(frames,r/'run_atlas.png')
preview(frames,r/'Previews/run.gif',60,r/'Previews/contact.png')
spriteframes(r/'Godot/Wolf_Run.tres',[{'name':'run','fps':16,'loop':True,'files':[f'../Sprites/run_{i+1:02}.png' for i in range(8)]}])
write_json(r/'VALIDACION.json',{'frames':8,'cell':[384,384],'atlas':[3072,384],'rgba':True,'bounds':[box(f) for f in frames],'status':'Revisión visual; pincel integrado en el sprite, sin capas separadas.'})
