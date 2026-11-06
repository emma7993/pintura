from pathlib import Path
import json,sys,shutil,zipfile
import numpy as np
from PIL import Image,ImageDraw,ImageFilter
sys.path.insert(0,str(Path(__file__).parent))
try:
 import procesamiento as p
except ModuleNotFoundError:
 import procesar as p

root=p.OUT
sources=json.loads((p.BASE/'work/unificacion/enlaces_fuentes.json').read_text())
manifest=json.loads((root/'manifest.json').read_text())
newrecords=[]
for s in sources:
 im=Image.open(s['path']).convert('RGBA').resize((3548,600),Image.Resampling.LANCZOS)
 raw=p.filled_alpha(im)
 top=[]
 for x in range(im.width):
  ys=np.where(raw[:,x]>0)[0];top.append(float(ys[0]) if ys.size else 540)
 top=np.asarray(top,dtype=np.float32)
 top=p.periodic(top[None,:],True,False)[0]
 top=np.asarray(Image.fromarray(top[None,:],'F').resize((3548,5)).convert('L').filter(ImageFilter.GaussianBlur(1))) if False else top
 top=np.clip(top,6,580)
 # Create one opaque paper land silhouette shared by both states.
 yy=np.arange(600)[:,None]
 alpha=p.u8(np.clip((yy-top[None,:])+1,0,1)*255)
 b,d,dd,bb,_=p.paired(im,mask=alpha)
 dd=p.periodic(dd,True,False);bb=p.periodic(bb,True,False)*.65
 d=p.rgba_from(dd,alpha);b=p.rgba_from(bb,alpha,True)
 for name,image in [('boceto',b),('definido',d)]:
  ar=np.asarray(image).copy();edge=p.u8((ar[:,0].astype(float)+ar[:,-1])/2)
  ar[:,0]=edge;ar[:,-1]=edge
  # Avoid RGB fringe in transparent pixels.
  ar[ar[...,3]==0,:3]=0
  if name=='boceto':b=Image.fromarray(ar)
  else:d=Image.fromarray(ar)
 rel=Path('camino')/s['name']
 p.save_pair(rel,b,d,s['path'],{'repetible':'x','funcion':s['body']})
 ba=np.asarray(b);da=np.asarray(d)
 assert np.array_equal(ba[...,3],da[...,3])
 assert np.array_equal(ba[:,0],ba[:,-1]) and np.array_equal(da[:,0],da[:,-1])
 newrecords.append(p.records[-1])
 # Adjacent duplicates reveal wrap seams visually.
 panel=Image.new('RGB',(1400,300),'white');draw=ImageDraw.Draw(panel)
 for j,(state,im) in enumerate([('boceto',b),('definido',d)]):
  repeat=Image.new('RGBA',(7096,600),(255,255,255,255) if j==0 else (247,237,223,255))
  repeat.alpha_composite(im,(0,0));repeat.alpha_composite(im,(3548,0))
  repeat=repeat.convert('RGB').resize((1400,118),Image.Resampling.LANCZOS)
  panel.paste(repeat,(0,30+j*140));draw.text((10,8+j*140),s['name']+' | '+state,fill=(70,60,50))
 panel.save(root/'comparativas'/('mosaico_'+s['name']))

placements=[]
def paste_asset(canvas,state,name,x,bottom,width,layer):
 im=Image.open(root/state/'camino'/name).convert('RGBA');a=np.asarray(im)[...,3]
 ys,xs=np.where(a>20);box=(int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1))
 im=im.crop(box);h=round(width*im.height/im.width);im=im.resize((width,h),Image.Resampling.LANCZOS)
 canvas.alpha_composite(im,(x,bottom-h))
 if state=='definido':placements.append({'archivo':name,'x':x,'y_base':bottom,'ancho':width,'plano':layer,'recorte_origen':list(box)})
for state in ['boceto','definido']:
 bg=(255,255,255,255) if state=='boceto' else (247,237,223,255)
 world=Image.new('RGBA',(3548,1000),bg)
 sky=Image.open(root/state/'camino/02_cielo_nubes.png').convert('RGBA').resize((3548,1774),Image.Resampling.LANCZOS)
 world.alpha_composite(sky,(0,-80))
 world.alpha_composite(Image.open(root/state/'camino/15_horizonte.png').convert('RGBA'),(0,430))
 world.alpha_composite(Image.open(root/state/'camino/17_colinas_enlace.png').convert('RGBA'),(0,180))
 paste_asset(world,state,'09_cabeza_lejana.png',140,785,800,'hito_lejano')
 world.alpha_composite(Image.open(root/state/'camino/18_laderas_rocosas.png').convert('RGBA'),(0,480))
 paste_asset(world,state,'04_plano_medio.png',1070,825,1320,'puentes')
 paste_asset(world,state,'11_casa_lejana.png',2330,808,280,'casa')
 paste_asset(world,state,'10_faro_lejano.png',2600,825,850,'faro')
 world.alpha_composite(Image.open(root/state/'camino/19_costa_enlace.png').convert('RGBA'),(0,290))
 world.convert('RGB').save(root/'comparativas'/('montaje_parallax_'+state+'.png'))
pair=Image.new('RGB',(1774,1040),'white');draw=ImageDraw.Draw(pair)
for j,state in enumerate(['boceto','definido']):
 im=Image.open(root/'comparativas'/('montaje_parallax_'+state+'.png')).resize((1774,500),Image.Resampling.LANCZOS)
 pair.paste(im,(0,j*520+20));draw.text((12,j*520+4),state.upper()+' — MONTAJE DE REFERENCIA',fill=(70,60,50))
pair.save(root/'comparativas/montaje_parallax_comparado.jpg',quality=95)
(root/'montaje_parallax.json').write_text(json.dumps({'lienzo_referencia':[3548,1000],'capas':placements,'factores_sugeridos':{'cielo':.05,'horizonte':.08,'cabeza':.10,'colinas':.12,'faro':.14,'laderas':.20,'puentes':.25,'costa':.30},'nota':'Propuesta visual; probar desplazamiento y oclusiones en Godot. No es fondo aplanado para integrar.'},ensure_ascii=False,indent=2))
# Replace the three entries if this script is run again.
names={r['archivo'] for r in newrecords}
manifest['pares']=[r for r in manifest['pares'] if r['archivo'] not in names]+newrecords
manifest['validacion']=[r for r in manifest['validacion'] if r['archivo'] not in names]+[{'archivo':r['archivo'],'misma_silueta_y_posicion':True,'boceto_grises':True,'definido_sepia':True,'bordes_repetibles_exactos':'x'} for r in newrecords]
(root/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
(root/'lista_de_entrega.txt').write_text('\n'.join('Game_Assets/Nivel_01_Camino/fondos_unificados_v001/'+state+'/'+r['archivo'] for r in manifest['pares'] for state in ['boceto','definido'])+'\n')
(root/'enlaces_fuentes.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2))
notes='''ENLACES DEL PANORAMA — 17 A 19
17_colinas_enlace: colinas bajas para unir cabeza y puentes; colocar detras de hitos.
18_laderas_rocosas: terreno intermedio bajo los puentes, delante de las formas mas lejanas.
19_costa_enlace: franja baja para disimular uniones de cabeza, puente, casa/cascada y ola/faro.
Las tres son RGBA3548x600, repetibles en X, con papel blanco opaco en boceto y sepia unificado en definido. Misma mascara y tamaño por par.
El borde inferior llega al lienzo: ocultarlo tras terreno o fuera de camara. Superponer las franjas; no alinearlas como piezas de un rompecabezas sin solape.
Ver comparativas/montaje_parallax_* y montaje_parallax.json. Son referencias de composicion, no fondos horneados para el juego.
Al variar el parallax los hitos se desplazan respecto a las laderas; probar el rango completo de la camara en Godot para evitar huecos.
No se modificaron escenas, scripts ni colisiones. Generacion integrada image_gen, acabado tecnico Python autorizado.
'''
(root/'notas_enlaces_para_claude.txt').write_text(notes)
shutil.copy2(Path(__file__),root/'procesar_enlaces.py')
html=root/'comparar.html'
text=html.read_text().replace('40 parejas','43 parejas')
import re
for s in sources:
 text=re.sub(r'<section><h2>camino/'+re.escape(s['name'])+r'</h2>.*?</section>','',text,flags=re.S)
text=re.sub(r'<section><h2>Montaje del panorama</h2>.*?</section>','',text,flags=re.S)
for r in newrecords:
 rel=r['archivo'];img='comparativas/'+rel.replace('/','__')
 text+=f'<section><h2>{rel}</h2><img src="{img}"><p><a href="boceto/{rel}">Boceto</a> · <a href="definido/{rel}">Definido</a></p></section>'
text+='<section><h2>Montaje del panorama</h2><img src="comparativas/montaje_parallax_comparado.jpg"></section>'
html.write_text(text)
mainnotes=root/'notas_para_claude.txt'
mainnotes.write_text(mainnotes.read_text().replace('40 parejas, 80 PNG','43 parejas, 86 PNG').replace('para los 40 pares','para los 43 pares')+'\nVer notas_enlaces_para_claude.txt para las nuevas piezas17–19 y el montaje completo.\n')
archive=p.BASE/'outputs/camino_enlaces_parallax_v001.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for f in root.rglob('*'):
  if f.is_file() and (f.name in {s['name'] for s in sources} or f.name.startswith(('montaje_parallax','notas_enlaces','enlaces_fuentes','procesar_enlaces')) or f.name in {'manifest.json','lista_de_entrega.txt','comparar.html','notas_para_claude.txt'} or f.name in {'camino__'+s['name'] for s in sources} or f.name in {'mosaico_'+s['name'] for s in sources}):z.write(f,f.relative_to(p.BASE/'outputs'))
with zipfile.ZipFile(p.BASE/'outputs/camino_fondos_unificados_v001.zip','w',zipfile.ZIP_DEFLATED) as z:
 for f in sorted(root.rglob('*')):
  if f.is_file():z.write(f,f.relative_to(p.BASE/'outputs'))
print('3 PARES Y MONTAJE CREADOS. TOTAL:',len(manifest['pares']),flush=True)
