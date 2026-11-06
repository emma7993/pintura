from pathlib import Path
import importlib.util,json
import numpy as np
from PIL import Image,ImageDraw
R=Path(__file__).resolve().parents[1];A=R.parent
s=importlib.util.spec_from_file_location('common',A/'Wolf_Pincel_v003/Source/common.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
raw=Image.open(R/'Source/edicion.png').convert('RGBA')
# Un único remuestreo de toda la hoja: no normalizar tamaños por cuadro.
sheet=raw.resize((1536,768),Image.Resampling.LANCZOS)
frames=[sheet.crop((i%4*384,i//4*384,(i%4+1)*384,(i//4+1)*384)) for i in range(8)]
bottom=[int(np.where(np.array(im)[...,3]>128)[0].max()) for im in frames]
dy=351-int(np.median([bottom[i] for i in [0,1,2,4,5,6]]))
out=[];stats=[]
for i,im in enumerate(frames):
 p=Image.new('RGBA',(384,384));p.alpha_composite(im,(0,dy));p.save(R/f'Sprites/run/{i+1:02}.png');out.append(p)
 a=np.array(p);yy,xx=np.nonzero(a[...,3]>128)
 stats.append({'frame':i+1,'opaque_bbox':[int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)],'bottom_opaque_y':int(yy.max())})
c.preview(out,R/'Previews/run.gif',50,R/'Previews/run_crema.png')
c.save_atlas(out,R/'Previews/sprite_sheet.png',4);c.save_atlas(out,R/'Atlases/run.png')
c.spriteframes(R/'Godot/Wolf_Run.tres',[{'name':'run','files':[f'../Sprites/run/{i:02}.png' for i in range(1,9)],'fps':20,'loop':True}])
refs=[Image.open(A/'Wolf_Pincel_v003/Animations/walk/body/01.png').convert('RGBA'),Image.open(A/'Wolf_Salto_v004/Sprites/02_jump_up.png').convert('RGBA')]
cmp=Image.new('RGBA',(1536,1218),(231,226,214,255));d=ImageDraw.Draw(cmp)
for j,im in enumerate([refs[0],refs[1],out[0],out[4]]):
 cmp.alpha_composite(im,(j*384,0));d.text((j*384+6,387),['Caminado aprobado','Salto aprobado','Carrera 01','Carrera 05'][j],fill=(30,30,30))
for i,im in enumerate(out):
 x=i%4*384;y=406+i//4*406;cmp.alpha_composite(im,(x,y));d.text((x+6,y+387),f'Carrera {i+1:02}',fill=(30,30,30))
cmp.save(R/'Previews/comparacion_modelo.png')
report={'status':'aprobado_artisticamente_para_pruebas','cell':[384,384],'fps':20,'frames':stats,'shared_source_scale':[1536/raw.width,768/raw.height],'common_translation_y':dy,'logical_origin_xy':[192,352],'individual_rescaling':False,'generation_calls':1,'pixel_identity_with_v026_claimed':False,'constant_foot_speed_verified':False}
(R/'VALIDACION.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report))
