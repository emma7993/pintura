from pathlib import Path
import json, math, shutil, time
import numpy as np
from PIL import Image, ImageFilter, ImageDraw, ImageOps, ImageFont

BASE=Path('/Users/l03123318/Documents/Codex/2026-11-05/referenced-chatgpt-conversation-this-is-an')
SRC=Path('/Users/l03123318/Documents/pintura/Game_Assets/Nivel_01_Camino')
OUT=BASE/'outputs/Game_Assets/Nivel_01_Camino/fondos_unificados_v001'
QA=OUT/'comparativas'
QA.mkdir(parents=True,exist_ok=True)
PAPER=np.array([247.,237.,223.])
INK=np.array([139.,119.,96.])
RNG=np.random.default_rng(1106)
SOURCES=json.loads((BASE/'work/seis_piezas_fuentes.json').read_text())
SOURCES={x['id']:x for x in SOURCES}
records=[]

def u8(x):return np.uint8(np.clip(np.round(x),0,255))
def lum(rgb):return np.asarray(rgb,dtype=np.float32)[...,:3]@np.array([.299,.587,.114],np.float32)
def composite_luma(im):
 a=np.asarray(im.convert('RGBA'),np.float32); t=a[...,3:4]/255
 return lum(a[...,:3]*t+255*(1-t))
def filt(a,kind,r):
 im=Image.fromarray(u8(a))
 return np.asarray(im.filter(ImageFilter.GaussianBlur(r) if kind=='blur' else ImageFilter.MaxFilter(r) if kind=='max' else ImageFilter.MinFilter(r)),np.float32)
def filled_alpha(im):
 a=np.asarray(im.convert('RGBA'))[...,3]
 if np.min(a)==255:return np.full(a.shape,255,np.uint8)
 # Remove near-zero residual RGB/alpha, close one-pixel gaps, and fill paper interiors.
 m=Image.fromarray(np.uint8(a>22)*255).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.MinFilter(3))
 ar=np.asarray(m);h,w=ar.shape
 for x,y in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]+[(x,0) for x in range(0,w,128)]+[(x,h-1) for x in range(0,w,128)]+[(0,y) for y in range(0,h,128)]+[(w-1,y) for y in range(0,h,128)]:
  if m.getpixel((x,y))==0:ImageDraw.floodfill(m,(x,y),128,thresh=0)
 inside=np.asarray(m)!=128
 return np.uint8(inside)*255

def darkness(im,mask):
 l=composite_luma(im)
 valid=mask>128
 high=np.percentile(l[valid],96) if np.any(valid) else 255
 low=np.percentile(l[valid],3) if np.any(valid) else 130
 # Retain source pencil detail, but suppress deep black masses.
 d=np.clip((high-l)/max(75,high-low)*.72,0,.80)
 d[~valid]=0
 return d.astype(np.float32)

def roughness(im,mask,source_sketch=None,texture=False):
 l=composite_luma(source_sketch if source_sketch is not None else im)
 if l.shape!=mask.shape:l=np.asarray(Image.fromarray(u8(l)).resize((mask.shape[1],mask.shape[0]),Image.Resampling.LANCZOS),np.float32)
 l=np.where(mask>128,l,255)
 # A broad soft pencil study: retain structural lines while discarding fine hatching.
 small=filt(l,'blur',.65 if texture else 1.0)
 broad=filt(l,'blur',3.8 if texture else 5.5)
 high=np.maximum(0,broad-small)
 positive=high[(mask>128)&(high>.7)]
 cutoff=float(np.percentile(positive,55 if source_sketch is not None else 70)) if positive.size else 2
 line=np.clip((high-cutoff*.55)/max(6,cutoff*2.4),0,1)*.32
 if source_sketch is not None:
  # Existing loose cloud/face sketches are the drawing reference; remove their washes.
  tone=np.clip((253-small)/120,0,1)
  line=np.maximum(line,tone*.23)
 # Subtle broken parallel exploratory lines, anchored to the same geometry.
 y,x=np.indices(mask.shape)
 grain=.85+.15*np.sin(x*.71+y*.17)*np.sin(x*.11-y*.43)
 line*=grain
 ghost=np.roll(line,1,axis=1)*.15
 line=np.maximum(line,ghost)
 er=np.asarray(Image.fromarray(mask).filter(ImageFilter.MinFilter(3)),np.float32)/255
 outer=(mask/255-er)
 interrupted=.72+.28*np.sin(x*.13+y*.19)**2
 line=np.maximum(line,outer*.25*interrupted)
 line[mask==0]=0
 return np.clip(line,0,.48)

def rgba_from(d,mask,sketch=False):
 if sketch:
  v=255-d*210
  rgb=np.repeat(v[...,None],3,axis=2)
 else:rgb=PAPER[None,None,:]-d[...,None]*(PAPER-INK)[None,None,:]
 rgb[mask==0]=0
 return Image.fromarray(np.dstack([u8(rgb),mask]),'RGBA')

def periodic(a,horizontal=True,vertical=True):
 a=np.asarray(a,np.float64);h,w=a.shape
 v=np.zeros_like(a)
 if vertical:
  delta=a[-1]-a[0];v[0]+=delta;v[-1]-=delta
 if horizontal:
  delta=a[:,-1]-a[:,0];v[:,0]+=delta;v[:,-1]-=delta
 yy=np.arange(h)[:,None];xx=np.arange(w)[None,:]
 den=2*np.cos(2*np.pi*xx/w)+2*np.cos(2*np.pi*yy/h)-4;den[0,0]=1
 f=np.fft.fft2(v)/den;f[0,0]=0
 p=a-np.fft.ifft2(f).real
 # Match endpoint pixels and gently distribute remaining boundary discrepancy.
 for axis,on in [(1,horizontal),(0,vertical)]:
  if not on:continue
  arr=p if axis==1 else p.T
  left=arr[:,0].copy();right=arr[:,-1].copy();mid=(left+right)/2
  band=min(32,arr.shape[1]//8)
  for k in range(band):
   t=(1-k/band)**2
   arr[:,k]+=(mid-left)*t;arr[:,-1-k]+=(mid-right)*t
  arr[:,0]=mid;arr[:,-1]=mid
  p=arr if axis==1 else arr.T
 return p.astype(np.float32)

def paired(im,sketch_src=None,texture=False,mask=None):
 im=im.convert('RGBA');mask=filled_alpha(im) if mask is None else mask
 d=darkness(im,mask);b=roughness(im,mask,sketch_src,texture)
 # Defined outlines must remain at least as legible as the approved rough study.
 d=np.maximum(d,np.minimum(.82,b*1.6))
 return rgba_from(b,mask,True),rgba_from(d,mask),d,b,mask

def flatten_view(im,size,bg):
 canvas=Image.new('RGB',size,bg)
 fit=im.copy();fit.thumbnail((size[0]-28,size[1]-28),Image.Resampling.LANCZOS)
 canvas.paste(fit,((size[0]-fit.width)//2,(size[1]-fit.height)//2),fit if fit.mode=='RGBA' else None)
 return canvas
def save_pair(rel,b,d,source,extra=None):
 for state,im in [('boceto',b),('definido',d)]:
  p=OUT/state/rel;p.parent.mkdir(parents=True,exist_ok=True);im.save(p)
 ba=np.asarray(b.convert('RGBA'))[...,3];da=np.asarray(d.convert('RGBA'))[...,3]
 assert b.size==d.size and np.array_equal(ba,da),rel
 rgb=np.asarray(b.convert('RGBA'))
 white=np.all(rgb[...,:3]>=252,axis=2)&(ba==255)
 rec={'archivo':str(rel),'dimensiones':list(b.size),'misma_mascara_alfa':True,'pixeles_blanco_opaco':int(white.sum()),'fuente':str(source)}
 if extra:rec.update(extra)
 records.append(rec)
 pair=Image.new('RGB',(1200,420),'white');dr=ImageDraw.Draw(pair)
 dr.text((20,12),str(rel)+'  |  BOCETO',fill=(65,65,65));dr.text((620,12),'DEFINIDO',fill=(102,78,54))
 pair.paste(flatten_view(b,(600,380),(255,255,255)),(0,35))
 pair.paste(flatten_view(d,(600,380),(247,237,223)),(600,35))
 qp=QA/(str(rel).replace('/','__'));qp.parent.mkdir(parents=True,exist_ok=True);pair.save(qp)
 print('OK',rel,b.size,flush=True)

def place_asset(im,size,width=None,padding=0):
 a=np.asarray(im.convert('RGBA'))[...,3];ys,xs=np.where(a>22)
 box=(int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1))
 crop=im.crop(box).convert('RGBA')
 if width is None:s=min((size[0]-2*padding)/crop.width,(size[1]-2*padding)/crop.height)
 else:s=min(width/crop.width,(size[1]-padding)/crop.height)
 wh=(round(crop.width*s),round(crop.height*s));crop=crop.resize(wh,Image.Resampling.LANCZOS)
 pos=((size[0]-wh[0])//2,size[1]-padding-wh[1])
 canvas=Image.new('RGBA',size);canvas.paste(crop,pos)
 return canvas,box,s,pos

def six_new():
 # 11 house occupies exactly 640px across on the specified full canvas.
 src=Image.open(SOURCES[11]['path']);im,_,_,_=place_asset(src,(1774,887),640)
 b,d,_,_,_=paired(im);save_pair(Path('camino/11_casa_lejana.png'),b,d,SOURCES[11]['path'],{'ancho_objeto_px':640})
 # 12 and 14 are true opaque periodic textures, with a shared sepia palette.
 tiles={}
 for n,name,level in [(12,'12_subsuelo.png',.08),(14,'14_cueva_pared.png',.19)]:
  im=Image.open(SOURCES[n]['path']).convert('RGB').resize((1024,1024),Image.Resampling.LANCZOS)
  l=periodic(lum(np.asarray(im)))
  d0=np.clip((np.percentile(l,98)-l)/max(90,np.ptp(l))*.45,0,.45)+level
  if n==14:d0=np.clip((d0-level)*.55+level,0,.5)
  d0=periodic(d0)
  mask=np.full((1024,1024),255,np.uint8)
  raw=Image.fromarray(u8(np.repeat((255-d0*200)[...,None],3,axis=2)))
  b0=roughness(raw,mask,texture=True)
  b0=periodic(b0)*(.65 if n==12 else .36)
  b=rgba_from(b0,mask,True).convert('RGB');d=rgba_from(d0,mask).convert('RGB')
  # identical endpoint rows and columns, including after RGB quantization.
  tiles[n]=(b,d)
  save_pair(Path('camino')/name,b,d,SOURCES[n]['path'],{'repetible':'xy'})
 # 13 joins 12 using exactly its final32 rows at lower boundary.
 im=Image.open(SOURCES[13]['path']).convert('RGBA');a=np.asarray(im)[...,3]
 ys,xs=np.where(a>50);top=max(0,int(ys.min())-16)
 im=im.crop((0,top,im.width,im.height)).resize((1024,256),Image.Resampling.LANCZOS)
 b,d,dd,bb,mask=paired(im)
 # Top envelope is irregular; below the first solid pixel each column is opaque.
 for x in range(1024):
  yy=np.where(mask[:,x]>0)[0]
  if yy.size:mask[yy[0]:,x]=255
 dd=periodic(dd,True,False);bb=periodic(bb,True,False)
 b=rgba_from(bb,mask,True);d=rgba_from(dd,mask)
 for image,tile in [(b,tiles[12][0]),(d,tiles[12][1])]:
  arr=np.asarray(image).copy();ta=np.asarray(tile)
  for y in range(112,256):
   t=(y-112)/143;t=t*t*(3-2*t)
   target=ta[(1024-256+y)%1024,:,:3]
   arr[y,:,:3]=u8(arr[y,:,:3]*(1-t)+target*t);arr[y,:,3]=255
  arr[-32:,:,:3]=ta[-32:,:,:3];arr[-32:,:,3]=255
  # Match alpha and content at left/right, no cap.
  edge=u8((arr[:,0].astype(float)+arr[:,-1])/2)
  arr[:,0]=edge;arr[:,-1]=edge
  if image is b:b=Image.fromarray(arr,'RGBA')
  else:d=Image.fromarray(arr,'RGBA')
 save_pair(Path('camino/13_subsuelo_borde.png'),b,d,SOURCES[13]['path'],{'repetible':'x','empalme_con':'12_subsuelo.png'})
 # 15 mist has a shared alpha fade, solid paper inside hill and sea forms.
 src=Image.open(SOURCES[15]['path']).convert('RGBA');a=np.asarray(src)[...,3]
 ys,xs=np.where(a>90);top=max(0,int(ys.min())-22);bottom=min(src.height,int(ys.max()+1))
 im=src.crop((0,top,src.width,bottom)).resize((3548,500),Image.Resampling.LANCZOS)
 mm=filled_alpha(im);dd=darkness(im,mm)*.22;bb=roughness(im,mm)*.55
 dd=periodic(dd,True,False);bb=periodic(bb,True,False)
 topcurve=[]
 for x in range(mm.shape[1]):
  yy=np.where(mm[:,x]>0)[0];topcurve.append(int(yy[0]) if yy.size else 45)
 curve=np.array(topcurve,float);curve=periodic(curve[None,:],True,False)[0]
 yy=np.arange(500)[:,None];mask=np.clip((yy-curve[None,:])/3,0,1)
 fade=np.where(yy<250,1,(.5+.5*np.cos(np.pi*np.minimum(1,(yy-250)/249))))
 mask=u8(mask*fade*255);mask[:,0]=mask[:,-1]=u8((mask[:,0].astype(float)+mask[:,-1])/2)
 dd*=np.clip((420-yy)/200,0,1);bb*=np.clip((420-yy)/200,0,1)
 b=rgba_from(bb,mask,True);d=rgba_from(dd,mask)
 for image in [b,d]:
  ar=np.asarray(image).copy();mid=u8((ar[:,0].astype(float)+ar[:,-1])/2);ar[:,0]=mid;ar[:,-1]=mid
  if image is b:b=Image.fromarray(ar,'RGBA')
  else:d=Image.fromarray(ar,'RGBA')
 save_pair(Path('camino/15_horizonte.png'),b,d,SOURCES[15]['path'],{'repetible':'x','bruma':'desvanecimiento alfa solo periferia inferior'})
 # 16 standing frame; insert actual artwork, not a generative imitation.
 raw=Image.open(SOURCES[16]['path']).convert('RGBA')
 im,box,scale,pos=place_asset(raw,(512,768),padding=12)
 b,d,_,_,mask=paired(im)
 # Inner blank canvas corners in the generated1024x1536 source.
 rx=raw.width/1024;ry=raw.height/1536
 inner=(round(pos[0]+(174*rx-box[0])*scale),round(pos[1]+(285*ry-box[1])*scale),round(pos[0]+(851*rx-box[0])*scale),round(pos[1]+(962*ry-box[1])*scale))
 x0,y0,x1,y1=inner;ww=x1-x0;hh=y1-y0
 original=Image.open('/Users/l03123318/Desktop/Contexto_Camino_ChatGPT/portada_immix.jpg').convert('RGB').crop((150,132,1435,1437))
 art=ImageOps.fit(original,(ww,hh),method=Image.Resampling.LANCZOS)
 d.paste(art,inner)
 # Only a few light lines suggest the painting before drawing.
 mini=art.convert('L').filter(ImageFilter.GaussianBlur(2))
 edge=np.asarray(mini.filter(ImageFilter.FIND_EDGES),np.float32)
 edge[:3]=0;edge[-3:]=0;edge[:,:3]=0;edge[:,-3:]=0
 val=255-np.clip((edge-5)/35,0,1)*32
 roughmini=Image.fromarray(u8(val)).convert('RGB');b.paste(roughmini,inner)
 # Canvas is intentionally opaque in both states.
 save_pair(Path('camino/16_marco_pintura.png'),b,d,SOURCES[16]['path'],{'lienzo_rect':list(inner),'color_unicamente_lienzo':True})

def existing():
 groups=[('Cueva_v002/estados_v001','camino'),('zona_enemigos_v001','zona_enemigos'),('cueva_paleta_v001','cueva_paleta')]
 for family,group in groups:
  for p in sorted((SRC/family/'definido').glob('*.png')):
   if p.name=='00_papel.png':continue
   im=Image.open(p);sp=SRC/family/'boceto'/p.name
   sk=Image.open(sp) if sp.exists() else None
   b,d,*_=paired(im,sk)
   save_pair(Path(group)/p.name,b,d,p,{'boceto_fuente':str(sp)})
 # Earlier level modules and scenic layers also get the same pair/color treatment.
 for folder,group in [('Bocetos_v001/Fondos','originales/fondos'),('Bocetos_v001/Modulos','originales/modulos')]:
  for p in sorted((SRC/folder).glob('*.png')):
   if p.name in ['anchor.png','pencil.png']:continue
   im=Image.open(p);b,d,*_=paired(im,im)
   save_pair(Path(group)/p.name,b,d,p)

def validate():
 checks=[]
 for rec in records:
  rel=Path(rec['archivo']);b=Image.open(OUT/'boceto'/rel).convert('RGBA');d=Image.open(OUT/'definido'/rel).convert('RGBA')
  ba=np.asarray(b);da=np.asarray(d);alpha=np.array_equal(ba[...,3],da[...,3])
  assert alpha and b.size==d.size,rel
  visible=da[...,3]>128
  color=da[...,:3]
  # The single colored canvas is exempt; every other defined pixel follows same sepia ramp.
  if rel.name!='16_marco_pintura.png':assert np.all(color[...,0][visible]>=color[...,1][visible]) and np.all(color[...,1][visible]>=color[...,2][visible]),rel
  assert np.all(ba[...,0]==ba[...,1]) and np.all(ba[...,1]==ba[...,2]),rel
  check={'archivo':str(rel),'misma_silueta_y_posicion':alpha,'boceto_grises':True,'definido_sepia':True}
  if rec.get('repetible'):
   for state,arr in [('boceto',ba),('definido',da)]:
    assert np.array_equal(arr[:,0],arr[:,-1]),(rel,state,'x')
    if rec['repetible']=='xy':assert np.array_equal(arr[0],arr[-1]),(rel,state,'y')
   check['bordes_repetibles_exactos']=rec['repetible']
  checks.append(check)
 # exact lower seam13 -> upper seam12 (12 itself has equal first/last rows).
 for state in ['boceto','definido']:
  border=np.asarray(Image.open(OUT/state/'camino/13_subsuelo_borde.png').convert('RGBA'))
  tile=np.asarray(Image.open(OUT/state/'camino/12_subsuelo.png').convert('RGBA'))
  assert np.array_equal(border[-1],tile[0]),('empalme13_12',state)
 (OUT/'manifest.json').write_text(json.dumps({'pares':records,'validacion':checks,'paleta_definido':{'papel':PAPER.tolist(),'grafito_mas_oscuro':INK.tolist()},'autorizacion':'Usuario autorizo acabado tecnico Python'},ensure_ascii=False,indent=2))
 (OUT/'lista_de_entrega.txt').write_text('\n'.join('Game_Assets/Nivel_01_Camino/fondos_unificados_v001/'+state+'/'+r['archivo'] for r in records for state in ['boceto','definido'])+'\n')
 print('VALIDADOS',len(checks),'PARES',flush=True)

if __name__=='__main__':
 six_new();existing();validate()
