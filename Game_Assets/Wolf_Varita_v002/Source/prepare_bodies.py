from pathlib import Path
from collections import deque
import json
import numpy as np
from PIL import Image,ImageDraw
from common import box,cells,preview,write_json
R=Path(__file__).resolve().parents[1]

def torso_measure(im,mask_out=False):
    a=np.array(im.convert('RGBA'))
    # Torso core, isolated from grey outline, red scarf, grey tail and forearms.
    mask=(a[:,:,3]>=128)&(a[:,:,:3].max(axis=2)<115)
    roi=np.zeros_like(mask);roi[143:180,90:190]=True;mask &= roi
    ys,xs=np.nonzero(mask)
    if not len(xs):raise ValueError('No torso core')
    i=np.argmin((xs-138)**2+(ys-160)**2);seed=(int(xs[i]),int(ys[i]))
    seen=np.zeros_like(mask);q=deque([seed]);seen[seed[1],seed[0]]=True
    while q:
        x,y=q.popleft()
        for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
            if 0<=nx<256 and 0<=ny<256 and mask[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;q.append((nx,ny))
    ys,xs=np.nonzero(seen)
    if len(xs)<120:raise ValueError(('Torso segmentation too small',len(xs)))
    return (round(float(xs.mean()),3),round(float(ys.mean()),3),seen) if mask_out else (round(float(xs.mean()),3),round(float(ys.mean()),3))

def foot_centers(im):
    a=np.array(im)[:,:,3]
    present=(a[224:239,:]>64).any(axis=0)
    runs=[];start=None
    for i,on in enumerate([*present,False]):
        if on and start is None:start=i
        elif not on and start is not None:
            if i-start>=4:runs.append((start+i-1)/2)
            start=None
    return runs

def main():
    groups={'idle':(3,2),'walk':(4,3),'run':(4,2),'paint_rise':(4,2),'paint_up':(4,2),'dip':(3,2)}
    if (R/'Source/air_clean_original.png').exists():groups['air_clean']=(4,2)
    metrics={};collection={}
    for name,(cols,rows) in groups.items():
        selected=R/'Source'/('run_refined_original.png' if name=='run' and (R/'Source/run_refined_original.png').exists() else f'{name}_original.png')
        source=cells(selected,cols,rows)
        if name=='walk':
            for number in [6,7,12]:
                fix=R/'Source'/f'walk_fix_{number:02}_original.png'
                if fix.exists():source[number-1]=Image.open(fix).convert('RGBA')
        if name=='paint_rise' and (R/'Source/prep_fix_original.png').exists():source[1]=Image.open(R/'Source/prep_fix_original.png').convert('RGBA')
        raw=[];bbs=[]
        for im in source:
            a=np.array(im);a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);im=Image.fromarray(a);bbs.append(box(im,190));raw.append(im)
        # Uniform whole-figure raster registration, never disassemble/deform limbs.
        # Air poses use a common scale, anchored to the last upright pose.
        air_scale=216/(bbs[-1][3]-bbs[-1][1])
        frames=[];items=[]
        for i,(im,b) in enumerate(zip(raw,bbs)):
            f=air_scale if name=='air_clean' else 216/(b[3]-b[1])
            crop=im.crop(b).resize((round((b[2]-b[0])*f),round((b[3]-b[1])*f)),Image.Resampling.LANCZOS)
            out=Image.new('RGBA',(256,256));out.paste(crop,(round(128-crop.width/2),239-crop.height))
            before=torso_measure(out)
            dx=round(138-before[0])
            registered=Image.new('RGBA',(256,256));registered.paste(out,(dx,0));out=registered
            center=torso_measure(out)
            frames.append(out)
            a=np.array(out)[:,:,3];ys,xs=np.nonzero(a>16)
            items.append({'frame':i+1,'source_bbox':list(b),'whole_figure_scale':f,'registration_dx':dx,'torso_before':before,'torso_center_xy':center,'height':int(ys.max()-ys.min()+1),'ground_y':int(ys.max()),'foot_centers_x':foot_centers(out)})
        collection[name]=frames;metrics[name]=items
        folder=R/'Source/Packed_Bodies'/name;folder.mkdir(parents=True,exist_ok=True)
        for i,im in enumerate(frames):im.save(folder/f'{i+1:02}.png')
        preview(frames,R/'Previews'/f'{name}_body.gif',100,R/'Previews'/f'{name}_body_contact.png')
        debug=[]
        for im in frames:
            x,y,mask=torso_measure(im,True);overlay=im.copy();a=np.zeros((256,256,4),dtype=np.uint8);a[mask]=[0,180,220,150];overlay.alpha_composite(Image.fromarray(a));draw=ImageDraw.Draw(overlay);draw.line((x,140,x,183),fill=(255,0,0,255));debug.append(overlay)
        preview(debug,R/'Previews'/f'{name}_torso_QA.gif',100,R/'Previews'/f'{name}_torso_QA.png')
        print(name,'heights',[it['height'] for it in items],'centers',[it['torso_center_xy'] for it in items],'feet',[it['foot_centers_x'] for it in items])
    write_json(R/'Source/body_registration.json',metrics)
if __name__=='__main__':main()
