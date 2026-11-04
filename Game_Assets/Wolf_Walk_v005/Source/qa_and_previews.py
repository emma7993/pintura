"""Measurement and preview encoding of exported sprites; does not redraw artwork."""
from pathlib import Path
import json, hashlib
from PIL import Image, ImageDraw
import numpy as np

ROOT=Path(__file__).resolve().parents[1]

def runs(mask):
    starts=np.flatnonzero(np.diff(np.r_[False,mask,False].astype(int))==1)
    ends=np.flatnonzero(np.diff(np.r_[False,mask,False].astype(int))==-1)-1
    return [(int(a),int(b)) for a,b in zip(starts,ends) if b-a>=3]

def load_frames(anim,count):
    return [Image.open(ROOT/f'Individual_Frames/{anim}/{anim}_{i:02}.png').convert('RGBA') for i in range(1,count+1)]

def preview(anim,frames,durations):
    plates=[]
    contact=Image.new('RGB',(256*4,282*((len(frames)+3)//4)),(240,238,230))
    for i,im in enumerate(frames):
        plate=Image.new('RGBA',(256,256),(240,238,230,255))
        ImageDraw.Draw(plate).line((5,239,250,239),fill=(170,165,150,255),width=1)
        plate.alpha_composite(im)
        plate=plate.convert('RGB')
        contact.paste(plate,(i%4*256,i//4*282))
        ImageDraw.Draw(contact).text((i%4*256+8,i//4*282+259),f'{anim} {i+1:02}',fill=(50,50,50))
        plates.append(plate)
    contact.save(ROOT/f'Previews/{anim}_contact.png')
    palette=contact.quantize(colors=256)
    encoded=[p.quantize(palette=palette,dither=Image.Dither.NONE) for p in plates]
    encoded[0].save(ROOT/f'Previews/{anim}.gif',save_all=True,append_images=encoded[1:],duration=durations,loop=0,disposal=2,optimize=False)

walk=load_frames('walk',12)
look=load_frames('look_around',6)
idle=load_frames('idle',1)
preview('walk',walk,[int(round((i+1)*125/12)-round(i*125/12))*10 for i in range(12)])
preview('look_around',look,[120,120,160,380,120,100])
preview('idle',idle,[1000])
ground_frames=[]
for i,im in enumerate(walk):
    plate=Image.new('RGBA',(256,256),(240,238,230,255))
    draw=ImageDraw.Draw(plate)
    draw.line((0,239,255,239),fill=(160,156,146,255))
    for n in range(-2,20):
        x=round(n*17.5-(i*175/12)%17.5)
        draw.line((x,240,x,247),fill=(160,156,146,255))
    plate.alpha_composite(im)
    ground_frames.append(plate.convert('RGB').quantize(colors=256))
ground_frames[0].save(ROOT/'Previews/walk_contact_test.gif',save_all=True,append_images=ground_frames[1:],duration=[int(round((i+1)*125/12)-round(i*125/12))*10 for i in range(12)],loop=0,disposal=2,optimize=False)
landmarks=json.loads((ROOT/'Source/rig_landmarks.json').read_text())['frames']
records=[]
for i,im in enumerate(walk):
    a=np.array(im)
    solid=a[:,:,3]>=128
    ys,xs=np.nonzero(solid)
    floor=int(ys.max())
    contacts=runs(solid[max(0,floor-1):floor+1].any(axis=0))
    ideal=landmarks[i]['right_sole_center' if i<6 else 'left_sole_center'][0]
    contact=min(contacts,key=lambda r:abs((r[0]+r[1])/2-ideal))
    center=(contact[0]+contact[1])/2
    records.append({'frame':i+1,'ground_y_alpha_128':floor,'sole_runs':contacts,'stance_sole_center_measured':center,'stance_sole_center_rig':ideal,'bounds':[int(xs.min()),int(ys.min()),int(xs.max())+1,int(ys.max())+1],'transparent_border':not(bool(solid[0].any()) or bool(solid[-1].any()) or bool(solid[:,0].any()) or bool(solid[:,-1].any()))})

# Each half-step includes the rear foot at the next contact, i.e. 7 samples / 6 intervals.
first=list(r['stance_sole_center_measured'] for r in records[:6])
first.append((min(records[6]['sole_runs'])[0]+min(records[6]['sole_runs'])[1])/2)
second=list(r['stance_sole_center_measured'] for r in records[6:])
second.append((min(records[0]['sole_runs'])[0]+min(records[0]['sole_runs'])[1])/2)
delta_a=[round(first[i]-first[i+1],4) for i in range(6)]
delta_b=[round(second[i]-second[i+1],4) for i in range(6)]
steps=[round(first[0]-first[-1],4),round(second[0]-second[-1],4)]
virtual=Image.open(ROOT/'Source/loop_virtual_13.png').convert('RGBA')
closure=np.array_equal(np.array(walk[0]),np.array(virtual))
assert Image.open(ROOT/'SpriteSheets/walk_v005.png').size==(3072,256)
assert closure,'Virtual frame13 must exactly equal1'
assert all(r['ground_y_alpha_128']==238 for r in records)
assert all(r['transparent_border'] for r in records)
assert all(14<=d<=15 for d in delta_a+delta_b),(delta_a,delta_b)
assert 170<=sum(steps)<=180,steps
assert np.array_equal(np.array(idle[0]),np.array(look[0]))
assert np.array_equal(np.array(idle[0]),np.array(look[-1]))
all_floors={}
for anim,frames in [('walk',walk),('idle',idle),('look_around',look)]:
    all_floors[anim]=[int(np.nonzero(np.array(im)[:,:,3]>=128)[0].max()) for im in frames]
    assert all(y==238 for y in all_floors[anim])
results={'method':'Visible sole center from alpha>=128 in bottom two rows; measured from final raster PNG, not target guide','walk_frames':records,'right_stance_centers':first,'left_stance_centers':second,'right_frame_deltas':delta_a,'left_frame_deltas':delta_b,'measured_step_distances_px':steps,'measured_cycle_distance_px':sum(steps),'rig_step_distance_px':87.5,'rig_cycle_distance_px':175.0,'virtual_frame13_equals_frame1':closure,'idle_equals_look_endpoints':True,'gif_walk_cycle_ms':1250,'gif_walk_cycles_per_second':0.8,'result':'PASS'}
results['all_animation_floor_rows']=all_floors
results['all_walk_frames_unique']=len({im.tobytes() for im in walk})==12
gif=Image.open(ROOT/'Previews/walk.gif')
times=[]
for i in range(gif.n_frames):
    gif.seek(i)
    times.append(gif.info['duration'])
assert gif.n_frames==12 and sum(times)==1250
results['gif_encoded_frames']=gif.n_frames
results['gif_frame_durations_ms']=times
(ROOT/'Source/qa_metrics.json').write_text(json.dumps(results,indent=2))
print(json.dumps({'steps':steps,'cycle':sum(steps),'deltas_right':delta_a,'deltas_left':delta_b,'floor':[r['ground_y_alpha_128'] for r in records],'closure':closure},indent=2))
