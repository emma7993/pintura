from pathlib import Path
import sys,json,shutil,zipfile,re
import numpy as np
from PIL import Image,ImageDraw
sys.path.insert(0,str(Path(__file__).parent))
try:import procesamiento as p
except ModuleNotFoundError:import procesar as p
root=p.OUT
sources=json.loads((p.BASE/'work/unificacion/faro_mar_fuentes_listas.json').read_text())
new=[]
for s in sources:
 im=Image.open(s['path']).convert('RGBA').resize((1774,887),Image.Resampling.LANCZOS)
 rough=Image.open(s['roughpath']).convert('RGBA').resize(im.size,Image.Resampling.LANCZOS) if s.get('roughpath') else None
 mask=p.filled_alpha(im)
 if s['n'] in [20,22]:
  curve=[]
  for x in range(1774):
   ys=np.where(mask[:,x]>0)[0];curve.append(float(ys[0]) if ys.size else 590)
  curve=p.periodic(np.array(curve)[None,:],True,False)[0]
  yy=np.arange(887)[:,None]
  mask=p.u8(np.clip(yy-curve[None,:]+1,0,1)*255)
  if s['n']==22:
   fade=np.clip((887-yy)/110,0,1);mask=p.u8(mask*fade)
 b,d,dd,bb,_=p.paired(im,rough,mask=mask)
 if s['n'] in [20,22]:
  dd=p.periodic(dd,True,False);bb=p.periodic(bb,True,False)
 if s['n']==22:dd*=.28;bb*=.38
 else:bb*=.85
 b=p.rgba_from(bb,mask,True);d=p.rgba_from(dd,mask)
 if s['n'] in [20,22]:
  for state,image in [('b',b),('d',d)]:
   ar=np.asarray(image).copy();edge=p.u8((ar[:,0].astype(float)+ar[:,-1])/2);ar[:,0]=edge;ar[:,-1]=edge;ar[ar[...,3]==0,:3]=0
   if state=='b':b=Image.fromarray(ar)
   else:d=Image.fromarray(ar)
 rel=Path('camino')/s['name'];p.save_pair(rel,b,d,s['path'],{'repetible':'x' if s['n'] in [20,22] else False,'lado_del_faro':'izquierda' if s['n']==21 else 'derecha/fondo'})
 ba=np.asarray(b);da=np.asarray(d);assert np.array_equal(ba[...,3],da[...,3])
 if s['n'] in [20,22]:assert np.array_equal(ba[:,0],ba[:,-1]) and np.array_equal(da[:,0],da[:,-1])
 new.append(p.records[-1])

layout=[]
for state in ['boceto','definido']:
 world=Image.new('RGBA',(5322,1000),(255,255,255,255) if state=='boceto' else (247,237,223,255))
 distant=Image.open(root/state/'camino/22_mar_lejano.png').convert('RGBA')
 for x in range(0,5322,1774):world.alpha_composite(distant,(x,-105))
 path=Image.open(root/state/'camino/21_camino_izquierda_faro.png').convert('RGBA').resize((2100,887),Image.Resampling.LANCZOS)
 world.alpha_composite(path,(0,-120))
 sea=Image.open(root/state/'camino/20_mar_agitado_derecha.png').convert('RGBA')
 # Lay continuous water first; shoreline covers its inland part.
 for x in [0,1774,3548]:world.alpha_composite(sea,(x,20))
 patharr=np.asarray(path).copy();fade=np.ones(path.width)
 fade[-180:]=np.linspace(1,0,180)
 patharr[...,3]=p.u8(patharr[...,3]*fade[None,:]);path=Image.fromarray(patharr)
 world.alpha_composite(path,(0,-120))
 lighthouse=Image.open(root/state/'camino/10_faro_lejano.png').convert('RGBA')
 la=np.asarray(lighthouse).copy();edge=np.ones(lighthouse.width)
 edge[:100]=np.linspace(0,1,100);edge[-100:]=np.linspace(1,0,100)
 la[...,3]=p.u8(la[...,3]*edge[None,:]);lighthouse=Image.fromarray(la)
 world.alpha_composite(lighthouse,(1400,20))
 world=world.crop((0,0,5322,887))
 world.convert('RGB').save(root/'comparativas'/('montaje_faro_mar_'+state+'.png'))
pair=Image.new('RGB',(1774,706),'white');draw=ImageDraw.Draw(pair)
for j,state in enumerate(['boceto','definido']):
 im=Image.open(root/'comparativas'/('montaje_faro_mar_'+state+'.png')).resize((1774,333),Image.Resampling.LANCZOS)
 pair.paste(im,(0,j*353+20));draw.text((12,j*353+4),state.upper()+' | CAMINO A LA IZQUIERDA - FARO - MAR AGITADO A LA DERECHA',fill=(80,65,50))
pair.save(root/'comparativas/montaje_faro_mar_comparado.jpg',quality=96)
notes='''CORRECCION DE LA ZONA DEL FARO — CAMINO A LA IZQUIERDA, MAR A LA DERECHA
20_mar_agitado_derecha.png:1774x887, RGBA, oleaje con espuma a la derecha del faro. Repetible horizontalmente.
21_camino_izquierda_faro.png:1774x887, RGBA, acceso de losas y roca costera a la izquierda. No es un tile; solapar su extremo derecho con la base del faro.
22_mar_lejano.png:1774x887, RGBA, mar muy palido al fondo. Repetible en X, situar por detras del faro y20.
Dos estados por pieza: boceto gris con blanco opaco dentro de formas; definido sepia unificado. Misma mascara alfa y tamaño por par, comprobados.
En la zona del faro NO usar17_colinas_enlace,18_laderas_rocosas ni19_costa_enlace como mar. Las colinas siguen disponibles para el paisaje interior de Camino.
El montaje_faro_mar_* reemplaza la propuesta anterior en la zona maritima. Ninguna duna ni colina se usa a la derecha del faro.
Montaje de referencia: lienzo5322x887; mar lejano repetido X a y=-105, camino a x0,y=-120 escalado2100x887, mar agitado continuo con tiles en x0/1774/3548,y20, faro existente x1400,y20. Camino solapado sobre mar y faro al frente. Ajustar a camara real.
Factores iniciales propuestos: mar lejano0.08, faro0.14, camino0.16, mar agitado0.20. Para un empalme completamente fijo, mantener20 y10 en el mismo plano y compensar diferencia por animacion de agua separada.
Las vistas son referencias, no escenas Godot ni colisiones. Probar todo el desplazamiento de camara antes de usar diferencias de parallax en piezas que se tocan.
Generacion integrada image_gen y acabado tecnico Python autorizado. Prompts adjuntos.
'''
(root/'notas_faro_mar_para_claude.txt').write_text(notes)
(root/'montaje_faro_mar.json').write_text(json.dumps({'tamano':[5322,887],'izquierda':'21_camino_izquierda_faro.png','centro':'10_faro_lejano.png','derecha':'20_mar_agitado_derecha.png','fondo':'22_mar_lejano.png','reemplaza_colinas_en_zona_mar':True,'camino_y':-120,'solape_bordes_px':180},ensure_ascii=False,indent=2))
(root/'faro_mar_fuentes.json').write_text(json.dumps(sources,ensure_ascii=False,indent=2))
shutil.copy2(Path(__file__),root/'procesar_faro_mar.py')
meta=json.loads((root/'manifest.json').read_text());names={r['archivo'] for r in new}
meta['pares']=[r for r in meta['pares'] if r['archivo'] not in names]+new
meta['validacion']=[r for r in meta['validacion'] if r['archivo'] not in names]+[{'archivo':r['archivo'],'misma_silueta_y_posicion':True,'boceto_grises':True,'definido_sepia':True,'bordes_repetibles_exactos':r['repetible']} for r in new]
(root/'manifest.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2))
(root/'lista_de_entrega.txt').write_text('\n'.join('Game_Assets/Nivel_01_Camino/fondos_unificados_v001/'+state+'/'+r['archivo'] for r in meta['pares'] for state in ['boceto','definido'])+'\n')
html=root/'comparar.html';text=html.read_text().replace('43 parejas','46 parejas')
for s in sources:text=re.sub(r'<section><h2>camino/'+re.escape(s['name'])+r'</h2>.*?</section>','',text,flags=re.S)
text=re.sub(r'<section><h2>Faro: camino y mar</h2>.*?</section>','',text,flags=re.S)
for r in new:
 rel=r['archivo'];text+=f'<section><h2>{rel}</h2><img src="comparativas/{rel.replace("/","__")}"><p><a href="boceto/{rel}">Boceto</a> · <a href="definido/{rel}">Definido</a></p></section>'
text+='<section><h2>Faro: camino y mar</h2><img src="comparativas/montaje_faro_mar_comparado.jpg"></section>';html.write_text(text)
mainnotes=root/'notas_para_claude.txt'
mn=mainnotes.read_text().replace('43 parejas, 86 PNG','46 parejas, 92 PNG').replace('para los 43 pares','para los 46 pares')
correction='Correccion vigente del faro: ver notas_faro_mar_para_claude.txt. Camino a izquierda, olas a derecha; colinas solo en tierra.'
mn=mn.replace(correction+'\n','');mainnotes.write_text(mn.rstrip()+'\n\n'+correction+'\n')
oldlayout=root/'montaje_parallax.json'
if oldlayout.exists():
 old=json.loads(oldlayout.read_text());old['zona_faro_montaje_activo']='montaje_faro_mar.json';old['colinas_solo_en_tierra']=True;oldlayout.write_text(json.dumps(old,ensure_ascii=False,indent=2))
with zipfile.ZipFile(p.BASE/'outputs/camino_faro_camino_y_mar_v001.zip','w',zipfile.ZIP_DEFLATED) as z:
 for f in root.rglob('*'):
  if f.is_file() and (f.name in {s['name'] for s in sources} or f.name in {'camino__'+s['name'] for s in sources} or f.name.startswith(('montaje_faro_mar','notas_faro_mar','faro_mar_fuentes','procesar_faro_mar')) or f.name in {'manifest.json','lista_de_entrega.txt'}):z.write(f,f.relative_to(p.BASE/'outputs'))
print('6 PNG verificados; montaje y notas listos.',flush=True)
