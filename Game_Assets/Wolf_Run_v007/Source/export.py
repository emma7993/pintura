from pathlib import Path
import numpy as np
from PIL import Image
from common import cells,box,preview,save_atlas,spriteframes,write_json
r=Path(__file__).resolve().parents[1]
for d in ['Sprites','Previews','Godot']: (r/d).mkdir(exist_ok=True)
raw=[]
for im in cells(r/'Source/original.png',4,2):
    a=np.array(im);a[a[:,:,3]<190]=0;raw.append(Image.fromarray(a))
b=box(raw[0]); scale=216/(b[3]-b[1]); frames=[]
# One shared scale and registration: no per-frame opaque-area recentering.
for i,im in enumerate(raw):
    im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(384,384));out.paste(im,(round(242-310*scale),round(352-b[3]*scale)))
    out.save(r/f'Sprites/run_{i+1:02}.png');frames.append(out)
save_atlas(frames,r/'run_atlas.png')
preview(frames,r/'Previews/run.gif',[60,60,60,70,60,60,60,70],r/'Previews/contact.png')
preview(frames,r/'Previews/run_slow.gif',140)
spriteframes(r/'Godot/Wolf_Run.tres',[{'name':'run','fps':16,'loop':True,'files':[f'../Sprites/run_{i+1:02}.png' for i in range(8)]}])
write_json(r/'VALIDACION.json',{'frames':8,'cell':[384,384],'atlas':[3072,384],'rgba':True,'shared_scale':scale,'bounds':[box(f) for f in frames],'status':'Revisión visual; velocidad y continuidad pendientes de prueba en el juego. Pincel integrado.'})
