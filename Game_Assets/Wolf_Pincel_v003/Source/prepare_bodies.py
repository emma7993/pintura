from pathlib import Path
from collections import deque
import numpy as np
from PIL import Image,ImageDraw
from common import cells,box,preview,write_json
R=Path(__file__).resolve().parents[1]

def head_measure(im,mask_out=False):
    a=np.array(im.convert('RGBA'))
    m=(a[:,:,3]>128)&(a[:,:,:3].max(axis=2)<125)&((a[:,:,:3].max(axis=2)-a[:,:,:3].min(axis=2))<35)
    roi=np.zeros_like(m);roi[105:250,110:325]=True;m&=roi
    seen=np.zeros_like(m);groups=[]
    for y,x in zip(*np.nonzero(m)):
        if seen[y,x]:continue
        q=[(int(x),int(y))];seen[y,x]=True;group=[]
        while q:
            xx,yy=q.pop();group.append((xx,yy))
            for nx,ny in [(xx-1,yy),(xx+1,yy),(xx,yy-1),(xx,yy+1)]:
                if 0<=nx<384 and 0<=ny<384 and m[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;q.append((nx,ny))
        if len(group)>150:groups.append(group)
    if not groups:return None
    g=max(groups,key=len);xs,ys=zip(*g)
    center=(float(np.mean(xs)),float(np.mean(ys)))
    if mask_out:
        out=np.zeros_like(m)
        for x,y in g:out[y,x]=True
        return center,out
    return center

def clean(im,fragments=False):
    a=np.array(im.convert('RGBA'));a[:,:,3]=np.where(a[:,:,3]<(32 if fragments else 190),0,a[:,:,3]);return Image.fromarray(a)

def place(im,scale,xcenter=192,foot=352):
    b=box(im,16)
    if np.array(im)[:,:,3].max()==0:return Image.new('RGBA',(384,384))
    cut=im.crop(b).resize((max(1,round((b[2]-b[0])*scale)),max(1,round((b[3]-b[1])*scale))),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(384,384));out.paste(cut,(round(xcenter-cut.width/2),foot+1-cut.height));return out

def translate(im,dx,dy=0):
    out=Image.new('RGBA',im.size);out.paste(im,(round(dx),round(dy)));return out

def main():
    groups={name:cells(R/'Source'/f'{name}_original.png',cols,rows) for name,cols,rows in [('idle',3,2),('walk',4,3),('run',4,2),('air',4,2),('dash',3,2),('wall',4,2),('slash_side',4,2),('slash_up',4,2),('slash_down',3,2),('paint_rise',4,2),('paint_up',4,2),('dip',3,2),('hurt_death',4,3)]}
    for n in [1,5]:
        path=R/'Source'/f'run_contact_{n:02}_original.png'
        if path.exists():groups['run'][n-1]=Image.open(path).convert('RGBA')
    for n in [1,7]:
        path=R/'Source'/f'walk_contact_{n:02}_original.png'
        if path.exists():groups['walk'][n-1]=Image.open(path).convert('RGBA')
    raw={k:[clean(im, k=='hurt_death' and i>=8) for i,im in enumerate(images)] for k,images in groups.items()}
    first=raw['idle'][0];b=box(first,16);s=216/(b[3]-b[1]);ref=place(first,s);reference=head_measure(ref)
    target=(226,reference[1]);packed={};metrics={}
    for name,images in raw.items():
        if name=='hurt_death':
            # The source sheet contains hurt1..3, death1..8, filler12.
            common=216/(box(images[3],16)[3]-box(images[3],16)[1])
        else:
            reference_index=7 if name=='air' else 0
            bb=box(images[reference_index],16);common=216/(bb[3]-bb[1])
        output=[];items=[]
        for i,im in enumerate(images):
            b=box(im,16)
            scale=216/(b[3]-b[1]) if name in ['idle','walk','run'] else common
            out=place(im,scale)
            head=head_measure(out)
            if name in ['idle','walk','run'] and head:
                # Uniform full-figure correction joins exact ground and a stable head.
                # Limit to ±1.3% so standing silhouette remains216±3.
                correction=np.clip((352-target[1])/(352-head[1]),.987,1.013)
                scale*=float(correction);out=place(im,scale);head=head_measure(out)
                if name=='run' and i==0:
                    scale*=.997;out=place(im,scale);head=head_measure(out)
            if head and not (name=='hurt_death' and i>=6):out=translate(out,target[0]-head[0])
            if name=='slash_down':out=translate(out,0,-24)
            if name=='hurt_death' and i==10:out=Image.new('RGBA',(384,384))
            output.append(out)
            a=np.array(out)[:,:,3];ys,xs=np.nonzero(a>16);hc=head_measure(out)
            items.append({'frame':i+1,'scale':scale,'height':int(ys.max()-ys.min()+1) if len(ys) else 0,'bottom_y':int(ys.max()) if len(ys) else None,'head_center_xy':[round(v,4) for v in hc] if hc else None})
        packed[name]=output;metrics[name]=items
    # Return to precisely the same drawing/position, avoiding a stop/sheathe pop.
    neutral=packed['idle'][0]
    for name in ['slash_side','slash_up','paint_rise','paint_up']:
        count=7 if name.startswith('slash') else 8
        packed[name][count-1]=neutral.copy()
    packed['dip'][-1]=neutral.copy()
    definitions={
        'idle':packed['idle'],'walk':packed['walk'],'run':packed['run'],
        'jump_start':packed['air'][:2],'jump_up':packed['air'][2:4],'fall':packed['air'][4:6],'land':packed['air'][6:8],
        'dash':packed['dash'],'wall_slide':packed['wall'][:4],'wall_jump':packed['wall'][4:8],
        'slash_side':packed['slash_side'][:7],'slash_up':packed['slash_up'][:7],'slash_down':packed['slash_down'],
        'paint_rise':packed['paint_rise'],'paint_up':packed['paint_up'],'dip':packed['dip'],
        'hurt':packed['hurt_death'][:3],'death':packed['hurt_death'][3:11]}
    for name,frames in definitions.items():
        # Final shared cell root: upright torso nearx192; running lean keeps pelvis nearx192.
        # Idle/walk receive the same translation so their head registration is preserved.
        dx=-4 if name=='run' else -20
        frames=[translate(im,dx) for im in frames]
        definitions[name]=frames
        folder=R/'Animations'/name/'body';folder.mkdir(parents=True,exist_ok=True)
        for i,im in enumerate(frames):im.save(folder/f'{i+1:02}.png')
        preview(frames,R/'Previews'/f'{name}_body.gif',100,R/'Previews'/f'{name}_body_contact.png')
    write_json(R/'Source/body_registration.json',{'head_target_before_export_translation_xy':target,'final_translation_x_by_animation':{n:(-4 if n=='run' else -20) for n in definitions},'groups_before_export_translation':metrics})
    for name in ['idle','walk','run']:
        print(name,'height',[i['height'] for i in metrics[name]],'heads',[i['head_center_xy'] for i in metrics[name]])
    print('BODY_READY',len(definitions),sum(len(a) for a in definitions.values()))
if __name__=='__main__':main()
