from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np
import math,hashlib
from common import cells,box,preview,save_atlas,spriteframes,write_json
r=Path(__file__).resolve().parents[1]
for d in ['Formas','Transiciones','Godot','Previews']:(r/d).mkdir(exist_ok=True)
raw=cells(r/'Source/original.png',4,3)
def ring_center(im):
    a=np.array(im);h,w=a.shape[:2]
    m=(a[:,:,3]>190);m[:int(h*.65)]=False;m[:,int(w*.5):]=False
    yy,xx=np.nonzero(m);bottom=yy.max()
    m[:bottom-14]=False;yy,xx=np.nonzero(m)
    return np.array([(xx.min()+xx.max())/2,bottom-7.])
anchors=[ring_center(im) for im in raw]
a=np.array(raw[0]);yy,xx=np.nonzero(a[:,:,3]>190)
tip=np.array([np.mean(xx[yy<=yy.min()+3]),float(yy.min()+1)])
vector=tip-anchors[0];scale=215/np.linalg.norm(vector)
target=np.array([140.,323.]);angle=math.atan2(vector[1],vector[0]);c=math.cos(angle);s=math.sin(angle)
packed=[]
for im,anchor in zip(raw,anchors):
    a=np.array(im);a[a[:,:,3]<32]=0;im=Image.fromarray(a)
    im=im.resize((round(im.width*scale),round(im.height*scale)),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(384,384));out.paste(im,tuple(np.round(target-anchor*scale).astype(int)))
    packed.append(out)
# The principal form reuses the existing brush pixels; it is not redesigned.
brush=Image.open(r/'Source/pincel_base_original.png').convert('RGBA')
brush.alpha_composite(Image.open(r/'Source/punta_original.png').convert('RGBA'))
matrix=(c,s,20-c*target[0]-s*target[1],-s,c,24+s*target[0]-c*target[1])
principal=brush.transform((384,384),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
states={'lanza':principal,'arco':packed[3],'arpa':packed[7]}
for name,im in states.items():im.save(r/f'Formas/pincel_{name}.png')
transitions={'lanza_a_arco':[states['lanza'],packed[1],packed[2],states['arco']],
             'arco_a_arpa':[states['arco'],packed[5],packed[6],states['arpa']],
             'arpa_a_lanza':[states['arpa'],packed[9],packed[10],states['lanza']]}
for name,seq in list(transitions.items()):
    start,end=name.split('_a_');transitions[f'{end}_a_{start}']=list(reversed(seq))
resources=[]
for name,seq in transitions.items():
    folder=r/f'Transiciones/{name}';folder.mkdir(exist_ok=True)
    for i,im in enumerate(seq):im.save(folder/f'{i+1:02}.png')
    save_atlas(seq,r/f'Transiciones/{name}_atlas.png')
    # Paused endpoints in design GIF; four spriteframes themselves stay uniform.
    preview(seq,r/f'Previews/{name}.gif',[500,120,120,650])
    resources.append({'name':name,'fps':16,'loop':False,
                      'files':[f'../Transiciones/{name}/{i+1:02}.png' for i in range(4)]})
for name in states:
    resources.append({'name':name,'fps':1,'loop':False,'files':[f'../Formas/pincel_{name}.png']})
spriteframes(r/'Godot/Pincel_Formas.tres',resources)
combo=transitions['lanza_a_arco']+transitions['arco_a_arpa'][1:]+transitions['arpa_a_lanza'][1:]
durations=[650,120,120,650,120,120,650,120,120,650]
preview(combo,r/'Previews/ciclo_formas.gif',durations)
plates=[]
for im in combo:
    p=Image.new('RGBA',(384,384),(231,226,214,255));p.alpha_composite(im);plates.append(p)
plates[0].save(r/'Previews/ciclo_formas.apng',save_all=True,append_images=plates[1:],duration=durations,loop=0,disposal=0,blend=0)
try:font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',23)
except OSError:font=ImageFont.load_default()
sheet=Image.new('RGB',(1152,430),(231,226,214));draw=ImageDraw.Draw(sheet)
for i,(name,im) in enumerate(states.items()):
    plate=Image.new('RGBA',(384,384),(231,226,214,255));plate.alpha_composite(im)
    sheet.paste(plate.convert('RGB'),(i*384,35));draw.text((i*384+24,8),'Pincel-'+name,font=font,fill=(30,30,30))
sheet.save(r/'Previews/tres_formas.png')
def digest(im):return hashlib.sha256(im.tobytes()).hexdigest()
matching={name: digest(seq[0])==digest(states[name.split('_a_')[0]]) and digest(seq[-1])==digest(states[name.split('_a_')[1]]) for name,seq in transitions.items()}
assert all(matching.values())
clear=all(not any(np.array(im)[:,:,3][edge].any() for edge in [(0,slice(None)),(-1,slice(None)),(slice(None),0),(slice(None),-1)]) for seq in transitions.values() for im in seq)
assert clear
write_json(r/'VALIDACION.json',{'states':3,'transitions':6,'frames_per_transition':4,'endpoints_included':True,
 'cell':[384,384],'atlas':[1536,384],'fps':16,'transition_seconds':.25,
 'origin':'Ring base registered at (140,323); proposed pivot, not hand contact validation',
 'generated_sheet_scale_shared':scale,'ring_target':list(target),'principal_existing_asset_reused':True,
 'identical_endpoints':matching,'borders_transparent':clear,'state_bounds':{n:box(im) for n,im in states.items()},
 'generation_calls':1,'reverse_animations':'Same frames reversed; no additional generation',
 'status':'Design sprites for review; weapon-hand grips and use animations not integrated'})
