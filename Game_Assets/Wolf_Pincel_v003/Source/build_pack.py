from pathlib import Path
import json,math,csv
import numpy as np
from PIL import Image
from common import box,cells,fit,preview,save_atlas,spriteframes,write_json
from prepare_bodies import head_measure
R=Path(__file__).resolve().parents[1]
LAYERS=['body','brush_back','brush_base','tip_color','tip_dry','tip_ink','smear']
NAMES=['idle','walk','run','jump_start','jump_up','fall','land','dash','wall_slide','wall_jump','slash_side','slash_up','slash_down','paint_rise','paint_up','dip','hurt','death']
FPS=dict(zip(NAMES,[6,12,16,12,10,10,12,24,8,16,20,20,20,12,12,10,14,10]))
LOOPS=['idle','walk','run','jump_up','fall','wall_slide']
grips=json.loads((R/'Source/grips.json').read_text())
grips={name:[[x-20,y] for x,y in frames] for name,frames in grips.items()}
targets={
 'slash_side':[[330,120],[340,180],[370,238],[372,233],[365,200]],
 'slash_up':[[300,100],[310,120],[276,50],[279,30],[275,80]],
 'slash_down':[[300,160],[245,375],[244,375],[245,375]],
 'paint_rise':[[330,352],[350,345],[355,352],[360,352],[330,352-30*math.sqrt(3)],[210,352-150*math.sqrt(3)]],
 'paint_up':[[320,130],[330,310],[345,340],[350,352],[350,230],[350,80]],
 'dip':[[310,170],[325,330],[330,350],[330,352],[330,352]]}
targets={name:[[x-20,y] for x,y in frames] for name,frames in targets.items()}
paintframes={'slash_side':[3,4],'slash_up':[3,4],'paint_rise':[4,5,6],'paint_up':[4,5,6]}
hitframes={**paintframes,'slash_down':[2,3,4]}

# Original thin brush: one common canonical coordinate system, 215px raster extent.
raw=cells(R/'Source/brush_master_original.png',1,3);canonical=[]
for im in raw:
    a=np.array(im);a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);im=Image.fromarray(a)
    crop=im.crop(box(im,16)).resize((215,8),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(256,48));out.paste(crop,(20,20));canonical.append(out)
base=canonical[1].copy();base.paste((0,0,0,0),(202,0,256,48));base.save(R/'Brush/brush_base.png')
tips={}
for state,im in zip(['color','dry','ink'],canonical):
    tip=im.copy();tip.paste((0,0,0,0),(0,0,202,48));tips[state]=tip;tip.save(R/'Brush/Tips'/f'{state}.png')
back=base.copy();back.paste((0,0,0,0),(80,0,256,48));back.save(R/'Brush/brush_back_ring.png')
smears=[]
for i,im in enumerate(cells(R/'Source/smears_clean_original.png',3,2)):
    a=np.array(im);a[:,:,3]=np.where(a[:,:,3]<205,0,a[:,:,3]);l=np.uint8(np.round(a[:,:,:3].mean(axis=2)));a[:,:,:3]=l[:,:,None];im=Image.fromarray(a);smears.append(im);im.save(R/'Source'/f'smear_{i+1:02}_registered.png')

resources={key:[] for key in LAYERS};records=[];info={};clipped=[]
for name in NAMES:
    bodies=[Image.open(p).convert('RGBA') for p in sorted((R/'Animations'/name/'body').glob('*.png'))]
    sheets={key:[] for key in LAYERS};plates=[];debug=[]
    for i,body in enumerate(bodies):
        n=i+1;layers={key:Image.new('RGBA',(384,384)) for key in LAYERS};layers['body']=body
        out_of_back=name in targets and i<len(targets[name])
        damage=n in hitframes.get(name,[]);paints=n in paintframes.get(name,[]);receives=name=='dip' and n in [4,5]
        opacity=1.0
        if name=='death':opacity=[1,1,1,.9,.75,.45,.15,0][i]
        if out_of_back:
            gx,gy=grips[name][i];tx,ty=targets[name][i]
            vx,vy=tx-gx,ty-gy;distance=math.hypot(vx,vy);angle=math.degrees(math.atan2(vy,vx));q=1.0;pivot=234-distance
            sourcebase=base;role='hand'
        else:
            hc=head_measure(body) or (206,200)
            gx=hc[0]-39;gy=min(245,hc[1]+29);angle=112;q=.53;pivot=20
            if name=='death' and i>=3:gx,gy,angle=100,340,0
            sourcebase=back;role='back'
        rad=math.radians(angle);c,s=math.cos(rad),math.sin(rad)
        matrix=(c/q,s/q,pivot-(c*gx+s*gy)/q,-s/q,c/q,24+(s*gx-c*gy)/q)
        def transform(im):
            out=im.transform((384,384),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
            if opacity<1:
                a=np.array(out);a[:,:,3]=np.uint8(a[:,:,3]*opacity);out=Image.fromarray(a)
            return out
        layers['brush_base' if out_of_back else 'brush_back']=transform(sourcebase)
        contacts={}
        for state,im in tips.items():
            out=transform(im);layers['tip_'+state]=out;a=np.array(out)[:,:,3];ys,xs=np.nonzero(a>64)
            if len(xs):
                projection=xs*c+ys*s;choose=projection>=projection.max()-1;contacts[state]=[round(float(xs[choose].mean()),3),round(float(ys[choose].mean()),3)]
            else:contacts[state]=None
        tip=[round(gx+(234-pivot)*q*c,4),round(gy+(234-pivot)*q*s,4)]
        hitbox=None
        if damage:
            x0=max(2,math.floor(min(gx,tip[0])-12));y0=max(2,math.floor(min(gy,tip[1])-12));x1=min(382,math.ceil(max(gx,tip[0])+12));y1=min(382,math.ceil(max(gy,tip[1])+12));hitbox=[x0,y0,x1-x0,y1-y0]
            sm_index={'slash_side':0,'slash_up':1,'slash_down':2,'paint_rise':3,'paint_up':4}[name]
            mark=fit(smears[sm_index],(max(1,x1-x0),max(1,y1-y0)),.06)
            layers['smear'].paste(mark,(x0,y0))
        records.append({'animation':name,'frame':n,'weapon_location':role,'grip_role':'hand' if out_of_back else 'storage_anchor','grip_xy':[round(gx,4),round(gy,4)],'angle_degrees_clockwise':round(angle,4),'tip_xy':tip,'contact_by_state_xy':contacts,'paints':paints,'receives_ink':receives,'hits':damage,'hitbox':hitbox,'brush_raster_length_px':215,'canonical_grip_x':round(pivot,4),'projection_scale':q,'opacity':opacity})
        plate=Image.new('RGBA',(384,384))
        for layer in ['brush_back','brush_base','tip_color','smear','body']:plate.alpha_composite(layers[layer])
        plates.append(plate)
        for key,im in layers.items():
            folder=R/'Animations'/name/key;folder.mkdir(parents=True,exist_ok=True);im.save(folder/f'{n:02}.png');sheets[key].append(im)
            if key not in ['body','smear']:
                a=np.array(im)[:,:,3]
                if max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())>64:clipped.append([name,n,key])
    for key,images in sheets.items():
        save_atlas(images,R/'Animations'/name/f'{key}_atlas.png')
        resources[key].append({'name':name,'files':[f'../Animations/{name}/{key}/{j+1:02}.png' for j in range(len(images))],'fps':FPS[name],'loop':name in LOOPS})
    duration=[100,100,110,100,100,110,100,100,110,100,100,120] if name=='walk' else round(1000/FPS[name])
    preview(plates,R/'Previews'/f'{name}.gif',duration,R/'Previews'/f'{name}_contact.png')
    info[name]={'frames':len(bodies),'fps':FPS[name],'loop':name in LOOPS,'hand_frames':[j+1 for j in range(len(targets.get(name,[])))],'paint_frames':paintframes.get(name,[]),'hit_frames':hitframes.get(name,[]),'ink_frames':[4,5] if name=='dip' else []}
for key,animations in resources.items():spriteframes(R/'Godot'/f'Wolf_{key}.tres',animations)
write_json(R/'brush_contacts.json',records);write_json(R/'Source/animation_spec.json',info);write_json(R/'Source/clipping.json',clipped)
with (R/'brush_contacts.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['animation','frame','weapon_location','grip_x','grip_y','angle_degrees_clockwise','tip_x','tip_y','contact_color_x','contact_color_y','contact_dry_x','contact_dry_y','contact_ink_x','contact_ink_y','paints','receives_ink','hits','hitbox_json'])
    for r in records:w.writerow([r['animation'],r['frame'],r['weapon_location'],*r['grip_xy'],r['angle_degrees_clockwise'],*r['tip_xy'],*(r['contact_by_state_xy']['color'] or ['','']),*(r['contact_by_state_xy']['dry'] or ['','']),*(r['contact_by_state_xy']['ink'] or ['','']),r['paints'],r['receives_ink'],r['hits'],json.dumps(r['hitbox'])])
print('PACK_READY',len(info),'animations',len(records),'body frames',len(LAYERS),'layers; clipping:',clipped)
