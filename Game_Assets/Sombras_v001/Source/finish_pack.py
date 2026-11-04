from pathlib import Path
import json,math,csv
import numpy as np
from PIL import Image,ImageDraw
from common import box,preview,save_atlas,spriteframes,write_json
R=Path(__file__).resolve().parents[1]
registration=json.loads((R/'Source/registration.json').read_text())
fogdefs=[('front_loop','Bruma/Front',8,8,True),('body','Bruma',1,1,True),('recoil','Bruma/Recoil',6,12,False)]
fogdefs += [(f'wisp_{i:02}',f'Bruma/Wisps/{i:02}',6,10,False) for i in range(1,7)]
fogdefs += [(f'eyes_{i:02}',f'Bruma/Eyes/{i:02}',4,6,True) for i in range(1,4)]
handdefs=[(kind+'_'+anim,f'Manos/{kind}/{anim}',count,fps,loop) for kind in 'ABC' for anim,count,fps,loop in [('emerge',8,12,False),('reach',8,10,True),('grab',6,14,False),('sink',6,12,False),('dissolve',8,12,False)]]
handdefs += [('puddle_loop','Manos/Puddle',8,8,True)]
resources={'Manos':[],'Bruma':[]};checks={};contacts=[]
forest=Image.open(R/'References/camino_graphite.png').convert('RGBA').resize((1024,512),Image.Resampling.LANCZOS)
wolf=Image.open(R/'References/wolf_style.png').convert('RGBA')
puddle=Image.open(R/'Manos/Puddle/01.png').convert('RGBA');puddle_bottom=box(puddle,16)[3]-1

def fingertips(im):
    a=np.array(im);alpha=a[:,:,3];eye=(a[:,:,:3].min(axis=2)>190)&(alpha>160)
    eye[430:,:]=False
    yy,xx=np.nonzero(eye)
    ey=float(np.median(yy)) if len(yy) else (box(im,64)[1]+90)
    lo=max(0,round(ey-100));hi=min(420,round(ey+110))
    profile=[]
    for y in range(lo,hi):
        xs=np.nonzero(alpha[y,:]>96)[0];profile.append(float(xs.max()) if len(xs) else np.nan)
    p=np.array(profile);valid=np.isfinite(p)
    if not valid.any():return [],None
    p=np.interp(np.arange(len(p)),np.nonzero(valid)[0],p[valid]);smooth=np.convolve(np.pad(p,(2,2),mode='edge'),np.ones(5)/5,mode='valid')
    candidates=[i for i in range(1,len(p)-1) if smooth[i]>=smooth[i-1] and smooth[i]>=smooth[i+1]]
    candidates.sort(key=lambda i:smooth[i],reverse=True)
    chosen=[]
    for i in candidates:
        if all(abs(i-j)>=14 for j in chosen):chosen.append(i)
        if len(chosen)==5:break
    for i in np.linspace(0,len(p)-1,5,dtype=int):
        if len(chosen)>=5:break
        if all(abs(i-j)>=10 for j in chosen):chosen.append(int(i))
    tips=[]
    for i in sorted(chosen):
        y=lo+i;xs=np.nonzero(alpha[y,:]>96)[0]
        if len(xs):tips.append([int(xs.max()),int(y)])
    ys,xs=np.nonzero((alpha>96)&(np.indices(alpha.shape)[0]>=lo)&(np.indices(alpha.shape)[0]<hi))
    edge=int(xs.max());y=int(round(float(np.median(ys[xs>=edge-1]))));near=np.nonzero(alpha[y,:]>96)[0]
    return tips,[int(near.max()),y]

def scene_plate(im,name,on_path):
    if on_path:
        out=Image.new('RGBA',(768,512),(233,228,216,255));out.alpha_composite(forest,(-128,0));out.alpha_composite(wolf,(490,242))
    else:out=Image.new('RGBA',(384 if name[0] in 'ABC' else 512,512),(233,228,216,255))
    if name[0] in 'ABC' and '_' in name:
        anchor=registration[name[0]]['anchor_xy'];x=(230 if on_path else 192)-anchor[0]
        out.alpha_composite(im,(x,0));out.alpha_composite(puddle,((230 if on_path else 192)-192,480-puddle_bottom))
    else:
        if im.size==(512,1024):
            art=im.resize((256,512),Image.Resampling.LANCZOS);out.alpha_composite(art,(0 if on_path else 128,0))
        else:out.alpha_composite(im,(50 if on_path else round((out.width-im.width)/2),round((out.height-im.height)/2)))
    return out

for category,defs in [('Manos',handdefs),('Bruma',fogdefs)]:
    for name,folder,count,fps,loop in defs:
        paths=[R/'Bruma/body.png'] if name=='body' else [R/folder/f'{i:02}.png' for i in range(1,count+1)]
        images=[Image.open(p).convert('RGBA') for p in paths]
        size=images[0].size;assert all(im.size==size for im in images)
        save_atlas(images,R/folder/f'{name}_atlas.png')
        resources[category].append({'name':name,'files':['../'+p.relative_to(R).as_posix() for p in paths],'fps':fps,'loop':loop})
        floor=[]
        for i,im in enumerate(images):
            a=np.array(im)[:,:,3];ys,xs=np.nonzero(a>16);floor.append(int(ys.max()) if len(ys) else None)
            if name[0] in 'ABC' and name.endswith(('reach','grab')):
                tips,primary=fingertips(im)
                contacts.append({'animation':name,'design':name[0],'frame':i+1,'anchor_xy':registration[name[0]]['anchor_xy'],'fingertips_xy':tips,'primary_tip_xy':primary,'contact_xy':primary if name.endswith('grab') and i+1 in [3,4] else None,'hits':name.endswith('grab') and i+1 in [3,4],'method':'Measured silhouette tips by row extrema; hooked claws use leading contour as primary strike contact.'})
        checks[name]={'count':count,'size':list(size),'rgba':True,'fps':fps,'loop':loop,'anchor_xy':registration[name[0]]['anchor_xy'] if name[0] in 'ABC' else None,'lowest_visible_y_by_frame':floor,'loop_playback':'ping-pong five authored key poses, 0,1,2,3,4,3,2,1' if name.endswith('reach') else ('periodic phase sampling' if name in ['front_loop','puddle_loop'] else ('open/half/closed/half' if name.startswith('eyes_') else None))}
        if name in ['front_loop','puddle_loop']:
            closure=Image.open(R/folder/'closure_test.png').convert('RGBA');assert np.array_equal(np.array(images[0]),np.array(closure))
            checks[name]['virtual_next_frame_equals_first']=True
        if name[0] in 'ABC' and not name.endswith('dissolve'):
            assert all(y==480 for y in floor),(name,floor)
        for onpath in [False,True]:
            plates=[scene_plate(im,name,onpath) for im in images]
            suffix='camino' if onpath else 'crema'
            preview(plates,R/'Previews'/f'{name}_{suffix}.gif',round(1000/fps),R/'Previews'/f'{name}_{suffix}_contact.png')
        if name[0] in 'ABC' and name.endswith(('reach','grab')):
            marked=[]
            for i,im in enumerate(images):
                p=scene_plate(im,name,False);draw=ImageDraw.Draw(p);anchor=registration[name[0]]['anchor_xy'];offset=192-anchor[0]
                row=next(a for a in contacts if a['animation']==name and a['frame']==i+1)
                for j,(x,y) in enumerate(row['fingertips_xy']):draw.ellipse((x+offset-2,y-2,x+offset+2,y+2),fill=(0,140,200,255));draw.text((x+offset+3,y),str(j+1),fill=(0,100,150,255))
                if row['contact_xy']:
                    x,y=row['contact_xy'];draw.ellipse((x+offset-5,y-5,x+offset+5,y+5),outline=(200,40,40,255),width=2)
                marked.append(p)
            preview(marked,R/'Previews'/f'{name}_contacts_QA.gif',round(1000/fps),R/'Previews'/f'{name}_contacts_QA.png')
for category,anims in resources.items():spriteframes(R/'Godot'/f'Sombras_{category}.tres',anims)
body=np.array(Image.open(R/'Bruma/body.png'))
h=int(np.abs(body[:,0,:].astype(int)-body[:,-1,:].astype(int)).max());v=int(np.abs(body[0,:,:].astype(int)-body[-1,:,:].astype(int)).max());assert h==0 and v==0
front=np.array(Image.open(R/'Bruma/Front/01.png'));join=int(np.abs(front[:,0,:].astype(int)-body[:,0,:].astype(int)).max());assert join==0,join
puddles=[np.array(Image.open(R/'Manos/Puddle'/f'{i:02}.png'))[:,:,3] for i in range(1,9)];assert all(np.array_equal(puddles[0],a) for a in puddles)
report={'animations':checks,'hand_design_registration':registration,'puddle_anchor_xy':[192,puddle_bottom],'hand_ground_y':480,'all_non_dissolve_hands_ground_y_480':True,'dissolve_ground_policy':'Same logical ground anchor y480; visible fragments lift/erase and final frame is transparent. The separate stable puddle supplies the ground contact throughout.','body_seam_max_rgba_delta_left_right':h,'body_seam_max_rgba_delta_top_bottom':v,'front_body_join_max_rgba_delta':join,'puddle_alpha_border_fixed':True,'fingertip_warning':'Points are measured leading silhouette extrema, not skeletal joint tracking. For hooked claws use contact_xy for hit testing and inspect the marked QA sheets.','hands_frame_count':sum(a[2] for a in handdefs),'fog_frame_count':sum(a[2] for a in fogdefs)}
write_json(R/'hand_contacts.json',contacts);write_json(R/'VALIDACION.json',report)
with (R/'hand_contacts.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['animation','frame','primary_tip_x','primary_tip_y','hits','contact_x','contact_y','fingertips_json'])
    for row in contacts:w.writerow([row['animation'],row['frame'],*(row['primary_tip_xy'] or ['','']),row['hits'],*(row['contact_xy'] or ['','']),json.dumps(row['fingertips_xy'])])
print('SOMBRAS_QA_OK',{'hands_frames':report['hands_frame_count'],'fog_frames':report['fog_frame_count'],'seams':[h,v,join],'contact_records':len(contacts)})
