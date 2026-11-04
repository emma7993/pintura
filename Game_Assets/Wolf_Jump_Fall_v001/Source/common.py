from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np
import json

def box(im, threshold=16):
    a=np.array(im.convert('RGBA'))[:,:,3]
    ys,xs=np.nonzero(a>=threshold)
    if not len(xs): return (0,0,1,1)
    return tuple(map(int,(xs.min(),ys.min(),xs.max()+1,ys.max()+1)))

def cells(path,cols,rows):
    im=Image.open(path).convert('RGBA')
    return [im.crop((round(i%cols*im.width/cols),round(i//cols*im.height/rows),round((i%cols+1)*im.width/cols),round((i//cols+1)*im.height/rows))) for i in range(cols*rows)]

def fit(im,size,margin=0.08,anchor='center'):
    crop=im.crop(box(im))
    f=min(size[0]*(1-2*margin)/crop.width,size[1]*(1-2*margin)/crop.height)
    crop=crop.resize((max(1,round(crop.width*f)),max(1,round(crop.height*f))),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',size)
    y=round((size[1]-crop.height)/2) if anchor=='center' else round(size[1]*(1-margin)-crop.height)
    out.paste(crop,(round((size[0]-crop.width)/2),y))
    return out

def save_atlas(frames,path,cols=None):
    cols=cols or len(frames)
    w,h=frames[0].size
    atlas=Image.new('RGBA',(w*cols,h*((len(frames)+cols-1)//cols)))
    for i,im in enumerate(frames): atlas.paste(im,(i%cols*w,i//cols*h))
    atlas.save(path)

def preview(frames,path,durations=100,contact=None,labels=None):
    # Preview backgrounds and guides are not included in game PNGs.
    max_w=max(im.width for im in frames); max_h=max(im.height for im in frames)
    f=min(1.0,384/max_w,540/max_h)
    size=(max(1,round(max_w*f)),max(1,round(max_h*f)))
    plates=[]
    for im in frames:
        plate=Image.new('RGBA',(max_w,max_h),(231,226,214,255))
        plate.alpha_composite(im)
        plates.append(plate.convert('RGB').resize(size,Image.Resampling.LANCZOS))
    cols=min(4,len(frames)); rows=(len(frames)+cols-1)//cols
    sheet=Image.new('RGB',(size[0]*cols,(size[1]+22)*rows),(231,226,214))
    draw=ImageDraw.Draw(sheet)
    for i,im in enumerate(plates):
        at=(i%cols*size[0],i//cols*(size[1]+22))
        sheet.paste(im,at)
        draw.text((at[0]+5,at[1]+size[1]+3),labels[i] if labels else f'{i+1:02}',fill=(40,40,40))
    pal=sheet.quantize(colors=256)
    encoded=[im.quantize(palette=pal,dither=Image.Dither.NONE) for im in plates]
    encoded[0].save(path,save_all=True,append_images=encoded[1:],duration=durations,loop=0,disposal=2,optimize=False)
    if contact: sheet.save(contact)

def write_json(path,data):
    Path(path).write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8')

def spriteframes(path,animations):
    # animations: [{name,files,fps,loop,durations?}]. Paths relative to .tres directory.
    count=sum(len(a['files']) for a in animations)
    out=[f'[gd_resource type="SpriteFrames" load_steps={count+1} format=3]','']
    n=0
    for a in animations:
        for file in a['files']:
            n+=1; out.append(f'[ext_resource type="Texture2D" path="{file}" id="t{n}"]')
    out+=['','[resource]','animations = [']
    n=0
    for a in animations:
        fs=[]
        for i in range(len(a['files'])):
            n+=1; d=a.get('durations',[1.0]*len(a['files']))[i]
            fs.append('{"duration": '+str(d)+', "texture": ExtResource("t'+str(n)+'")}')
        out.append('{"name": &"'+a['name']+'", "speed": '+str(a['fps'])+', "loop": '+str(a['loop']).lower()+', "frames": ['+', '.join(fs)+']},')
    out+= [']','']
    Path(path).write_text('\n'.join(out),encoding='utf-8')
