"""Storyboarding only: keep generated poses intact, pack and annotate previews."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import numpy as np
from common import cells,preview,save_atlas,write_json,box
r=Path(__file__).resolve().parents[1]
titles=['01 · Corte ascendente','02 · Barrido horizontal','03 · Remate descendente']
captions=[['Desenvaine','Alarga y corta','Salida del trazo','Enlace alto'],
          ['Preparación','Barrido','Salida del trazo','Enlace al remate'],
          ['Carga arriba','Golpe descendente','Contacto y salpicadura','Recoge el pincel']]
fontpath='C:/Windows/Fonts/segoeui.ttf'
try:font=ImageFont.truetype(fontpath,23);small=ImageFont.truetype(fontpath,17)
except OSError:font=small=ImageFont.load_default()
raw=cells(r/'Source/original.png',4,3);frames=[]
sheet=Image.new('RGB',(1536,1390),(231,226,214));draw=ImageDraw.Draw(sheet)
for row in range(3):
    folder=r/f'Poses/attack_{row+1:02}';folder.mkdir(exist_ok=True,parents=True)
    draw.text((16,row*450+12),titles[row],font=font,fill=(30,30,30))
    attack=[]
    for col in range(4):
        src=raw[row*4+col]
        a=np.array(src);a[a[:,:,3]<64]=0;src=Image.fromarray(a)
        # Shared scale, no individual body/bounds normalization.
        baseline=[340,325,325][row]
        out=Image.new('RGBA',(512,512));out.paste(src,(66,448-baseline))
        out.save(folder/f'{col+1:02}.png');frames.append(out);attack.append(out)
        plate=Image.new('RGBA',(512,512),(231,226,214,255));plate.alpha_composite(out)
        sheet.paste(plate.convert('RGB').resize((384,384),Image.Resampling.LANCZOS),(col*384,row*450+45))
        draw.text((col*384+16,row*450+430),captions[row][col],font=small,fill=(40,40,40))
    save_atlas(attack,r/f'Poses/attack_{row+1:02}_keyposes_atlas.png')
    preview(attack,r/f'Previews/attack_{row+1:02}_animatic.gif',[180,90,130,220])
sheet.save(r/'Previews/diseno_combo.png')
times=[90,60,80,90,80,60,80,90,110,60,120,300]
preview(frames,r/'Previews/combo_animatic.gif',times)
preview(frames,r/'Previews/combo_lento.gif',240)
write_json(r/'DISENO.json',{'status':'Concepto y poses clave, no animación final para integrar',
 'attacks':3,'keyposes_per_attack':4,'cell':[512,512],'origin_suggested':[-256,-448],
 'weapon_design':{'carried_nominal_px':215,'extended_target_px':310,'shaft_width_target_px':[5,7],
                  'note':'Objetivos de diseño, no mediciones certificadas de la lámina generada'},
 'ink_color':'Negro profundo; cerdas visibles y pequeñas gotas',
 'per_pose_bounds':[box(im) for im in frames],
 'not_included':['Capas cuerpo/pincel/tinta separadas','Cuadros intermedios finales','SpriteFrames','Hitboxes y contactos medidos'],
 'times_ms_are_storyboard_only':times})
