"""Pack complete raster drawings. No limb extraction, deformation, skeleton or rig."""
from pathlib import Path
import json, hashlib
from PIL import Image, ImageDraw
import numpy as np

ROOT=Path(__file__).resolve().parents[1]

def runs(mask):
    diff=np.diff(np.r_[False,mask,False].astype(int))
    return [(int(a),int(b-1)) for a,b in zip(np.flatnonzero(diff==1),np.flatnonzero(diff==-1)) if b-a>=5]

def bounds(im):
    ys,xs=np.nonzero(np.array(im)[:,:,3]>=32)
    return (int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1))

def torso_x(im):
    a=np.array(im)
    box=bounds(im)
    h=box[3]-box[1]
    centers=[]
    for y in range(round(box[1]+h*.59),round(box[1]+h*.67)):
        solid=(a[y,:,3]>=128)&(a[y,:,:3].max(axis=1)<90)
        segments=runs(solid)
        if segments:
            centers.append((segments[-1][0]+segments[-1][1])/2)
    return float(np.median(centers)) if centers else (box[0]+box[2])/2

refs=[Image.open(ROOT/f'References/walk_{i:02}.png').convert('RGBA') for i in range(1,9)]
frames=[]
packing=[]
for g in range(4):
    key=refs[g*2]
    frames.append(key.copy())
    packing.append({'output_frame':len(frames),'v004_original_frame':g*2+1,'whole_frame_unchanged':True})
    source=Image.open(ROOT/f'Source/inbetweens_{g+1:02}_original.png').convert('RGBA')
    cells=[source.crop((round(i*source.width/2),0,round((i+1)*source.width/2),source.height)) for i in range(2)]
    boxes=[bounds(im) for im in cells]
    height=max(b[3]-b[1] for b in boxes)
    scale=219/height
    for j,(im,b) in enumerate(zip(cells,boxes)):
        crop=im.crop(b)
        crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.LANCZOS)
        # Match registration of the neighboring original drawings, without altering anatomy.
        t=(2/3 if j==0 else 1/3)
        a=refs[(g*2+j)%8]
        c=refs[(g*2+j+1)%8]
        target=torso_x(a)*(1-t)+torso_x(c)*t
        shift_x=round(target-torso_x(crop))
        floor=int(np.nonzero(np.array(crop)[:,:,3]>=128)[0].max())
        shift_y=238-floor
        out=Image.new('RGBA',(256,256))
        out.paste(crop,(shift_x,shift_y))
        frames.append(out)
        packing.append({'output_frame':len(frames),'source_group':g+1,'source_cell':j+1,'common_pair_scale':scale,'whole_drawing_translation':[shift_x,shift_y],'target_torso_x':target,'source_bounds':list(b),'original_phase':(g*2+(j+1)*2/3)%8})

atlas=Image.new('RGBA',(3072,256))
contact=Image.new('RGB',(1024,846),(242,240,232))
gif_frames=[]
metrics=[]
for i,im in enumerate(frames):
    im.save(ROOT/f'Individual_Frames/walk/walk_{i+1:02}.png')
    atlas.paste(im,(256*i,0))
    solid=np.array(im)[:,:,3]>=128
    ys,xs=np.nonzero(solid)
    border=solid[0].any() or solid[-1].any() or solid[:,0].any() or solid[:,-1].any()
    assert ys.max()==238,(i+1,ys.max())
    assert not border,('clipped',i+1)
    metrics.append({'frame':i+1,'floor_y_alpha128':int(ys.max()),'bounds':[int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)],'torso_x':round(torso_x(im),2),'transparent_border':not bool(border),'png_sha256':hashlib.sha256((ROOT/f'Individual_Frames/walk/walk_{i+1:02}.png').read_bytes()).hexdigest()})
    plate=Image.new('RGBA',(256,256),(242,240,232,255))
    ImageDraw.Draw(plate).line((5,239,250,239),fill=(180,174,162,255))
    plate.alpha_composite(im)
    plate=plate.convert('RGB')
    contact.paste(plate,(i%4*256,i//4*282))
    ImageDraw.Draw(contact).text((i%4*256+8,i//4*282+258),f'{i+1:02}'+('  v004 original' if i%3==0 else '  intermedio'),fill=(45,45,45))
    gif_frames.append(plate)
atlas.save(ROOT/'SpriteSheets/walk_v005_r03.png')
contact.save(ROOT/'Previews/walk_contact.png')
palette=contact.quantize(colors=256)
gif_frames=[im.quantize(palette=palette,dither=Image.Dither.NONE) for im in gif_frames]
durations=[int(round((i+1)*125/12)-round(i*125/12))*10 for i in range(12)]
gif_frames[0].save(ROOT/'Previews/walk.gif',save_all=True,append_images=gif_frames[1:],duration=durations,loop=0,disposal=2,optimize=False)
assert len({im.tobytes() for im in frames})==12,'duplicated frame'
for n in range(4):
    assert frames[n*3].tobytes()==refs[n*2].tobytes()
(ROOT/'Source/packing_metrics.json').write_text(json.dumps(packing,indent=2))
(ROOT/'Source/qa_metrics.json').write_text(json.dumps({'frames':metrics,'count':12,'atlas':[3072,256],'fps_base':12,'preview_cycles_per_second':.8,'gif_cycle_ms':sum(durations),'original_v004_keys':[1,3,5,7],'new_inbetweens':8,'all_unique':True,'kinematics':'V004 step length retained as artistic reference; constant foot speed and cycle stride not certified','status':'technical_pack_pass_pending_visual_review'},indent=2))
lines=['[gd_resource type="SpriteFrames" load_steps=14 format=3]','', '[ext_resource type="Texture2D" path="../SpriteSheets/walk_v005_r03.png" id="walk"]','']
for i in range(12):
    lines += [f'[sub_resource type="AtlasTexture" id="frame_{i}"]','atlas = ExtResource("walk")',f'region = Rect2({i*256}, 0, 256, 256)','']
entries=', '.join(f'{{"duration": 1.0, "texture": SubResource("frame_{i}")}}' for i in range(12))
lines += ['[resource]', 'animations = [{"frames": ['+entries+'], "loop": true, "name": &"walk", "speed": 12.0}]','']
(ROOT/'Godot/Wolf.tres').write_text('\n'.join(lines),encoding='utf-8')
print('PASS: 12 unique frames,4 unchanged v004 keys,3072x256 RGBA,y238,GIF1250ms')
