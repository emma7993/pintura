from pathlib import Path
import json,hashlib
import numpy as np
from PIL import Image,ImageDraw
from common import cells,box,preview,save_atlas,spriteframes,write_json
from measure import torso_measure,foot_centers
R=Path(__file__).resolve().parents[1]

def eye_stats(im):
    a=np.array(im);m=(a[:,:,:3].min(axis=2)>205)&(a[:,:,3]>180)
    roi=np.zeros_like(m);roi[45:130,110:235]=True;m&=roi
    seen=np.zeros_like(m);components=[]
    for y,x in zip(*np.nonzero(m)):
        if seen[y,x]:continue
        stack=[(x,y)];seen[y,x]=True;pts=[]
        while stack:
            xx,yy=stack.pop();pts.append((xx,yy))
            for nx,ny in [(xx-1,yy),(xx+1,yy),(xx,yy-1),(xx,yy+1)]:
                if 0<=nx<256 and 0<=ny<256 and m[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;stack.append((nx,ny))
        components.append(pts)
    if not components:return {'area':0,'width':0,'height':0,'bbox':None}
    pts=max(components,key=len);xs,ys=zip(*pts);b=[min(xs),min(ys),max(xs)+1,max(ys)+1]
    return {'area':len(pts),'width':int(b[2]-b[0]),'height':int(b[3]-b[1]),'bbox':list(map(int,b))}

report={'format':'RGBA 256x256','ground_reference_y':238,'origin_offset':[-128,-238],'scope':'walk and run, no weapon or attacks','art_method':'Complete hand-drawn generated poses, one uniform scale per sequence; whole-sprite registration only, no limb reconstruction. User atlas is motion-language reference, not known frame order.'}
resources=[];eyes_gallery=[];labels=[]
for name,rows,count,fps in [('walk',3,12,12),('run',2,8,16)]:
    raw=cells(R/'Source'/f'{name}_original.png',4,rows)
    cleaned=[]
    for im in raw:
        a=np.array(im);a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);cleaned.append(Image.fromarray(a))
    bbs=[box(im,16) for im in cleaned]
    reference_heights=[b[3]-b[1] for i,b in enumerate(bbs) if name=='walk' or i in [0,4]]
    scale=216/float(np.median(reference_heights))
    frames=[];items=[]
    folder=R/'Animations'/name/'body';folder.mkdir(parents=True,exist_ok=True)
    for i,(im,b) in enumerate(zip(cleaned,bbs)):
        cut=im.crop(b).resize((round((b[2]-b[0])*scale),round((b[3]-b[1])*scale)),Image.Resampling.LANCZOS)
        # Grounded walk/contact/compression; free-flight silhouettes shorten naturally.
        yy=23 if name=='run' and i in [2,3,6,7] else 239-cut.height
        out=Image.new('RGBA',(256,256));out.paste(cut,(round(128-cut.width/2),yy))
        before=torso_measure(out);dx=round(138-before[0]);placed=Image.new('RGBA',(256,256));placed.paste(out,(dx,0));out=placed
        out.save(folder/f'{i+1:02}.png');frames.append(out)
        center=torso_measure(out);a=np.array(out)[:,:,3];ys,xs=np.nonzero(a>16);eye=eye_stats(out)
        items.append({'frame':i+1,'torso_xy':center,'height_px':int(ys.max()-ys.min()+1),'bottom_y':int(ys.max()),'eye':eye,'foot_centers_x':foot_centers(out),'registration_dx':dx})
        if i in [0,2,4,6]:
            crop=out.crop((100,40,235,135)).resize((270,190),Image.Resampling.NEAREST);eyes_gallery.append(crop);labels.append(name+f' {i+1:02}')
    save_atlas(frames,R/'Animations'/name/f'{name}_atlas.png')
    duration=[100,100,110,100,100,110,100,100,110,100,100,120] if name=='walk' else 60
    preview(frames,R/'Previews'/f'{name}.gif',duration,R/'Previews'/f'{name}_contact.png')
    resources.append({'name':name,'files':[f'../Animations/{name}/body/{i+1:02}.png' for i in range(count)],'fps':fps,'loop':True})
    x=[p['torso_xy'][0] for p in items];spans=[max(p['foot_centers_x'])-min(p['foot_centers_x']) for p in items if len(p['foot_centers_x'])>=2]
    report[name]={'count':count,'fps':fps,'loop':True,'whole_sequence_scale':scale,'frames':items,'torso_x_max_deviation_px':round(float(max(abs(np.array(x)-np.mean(x)))),3),'stride_opening_estimate_px_per_cycle':round(2*max(spans),2) if spans else None,'height_range':[min(p['height_px'] for p in items),max(p['height_px'] for p in items)],'eye_height_range':[min(p['eye']['height'] for p in items),max(p['eye']['height'] for p in items)]}
spriteframes(R/'Godot/Wolf.tres',resources)
preview(eyes_gallery,R/'Previews/expressions.gif',350,R/'Previews/expressions_contact.png',labels)
report['checks']={'walk_count_12':len(report['walk']['frames'])==12,'run_count_8':len(report['run']['frames'])==8,'torso_x_walk_within_2':report['walk']['torso_x_max_deviation_px']<=2,'torso_x_run_within_3':report['run']['torso_x_max_deviation_px']<=3,'run_white_eye_present_all_frames':all(i['eye']['area']>10 for i in report['run']['frames']),'run_eye_more_open_than_walk':np.mean([i['eye']['height'] for i in report['run']['frames']])>np.mean([i['eye']['height'] for i in report['walk']['frames']])*1.3}
report=json.loads(json.dumps(report,default=lambda o:o.item()))
write_json(R/'VALIDACION.json',report)
print('LOCOMOTION',report['checks'],'heights',report['walk']['height_range'],report['run']['height_range'],'eyes',report['walk']['eye_height_range'],report['run']['eye_height_range'])
