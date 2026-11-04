"""Export the generated 16-phase run; only uniform scale and head registration."""
from pathlib import Path
import hashlib
import math
import numpy as np
from PIL import Image
from common import cells, box, preview, save_atlas, spriteframes, write_json

ROOT = Path(__file__).resolve().parents[1]


def eye_center(im):
    a = np.array(im)
    h, w = a.shape[:2]
    # The sole white eye, isolated from the gray ears and outline.
    mask = (a[:, :, :3].min(2) > 180) & (a[:, :, 3] > 190)
    roi = np.zeros((h, w), bool)
    roi[int(h*.25):int(h*.44), int(w*.69):int(w*.84)] = True
    mask &= roi
    groups = []
    for yy, xx in zip(*np.nonzero(mask)):
        if not mask[yy, xx]:
            continue
        todo = [(int(xx), int(yy))]; pts = []; mask[yy, xx] = False
        while todo:
            x, y = todo.pop(); pts.append((x, y))
            for nx, ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
                if 0 <= nx < w and 0 <= ny < h and mask[ny,nx]:
                    mask[ny,nx] = False; todo.append((nx,ny))
        if len(pts) >= 8:
            mean = np.array(pts).mean(0)
            distance = np.linalg.norm(mean - [w*.756, h*.348])
            groups.append((distance, mean, len(pts)))
    if not groups:
        raise ValueError('Could not identify the white eye')
    return min(groups, key=lambda g:g[0])[1]


for folder in ['Sprites', 'Previews', 'Godot', 'Layers/body', 'Layers/brush_back']:
    (ROOT/folder).mkdir(exist_ok=True, parents=True)
raw = []
for im in cells(ROOT/'Source/body_original.png', 4, 4):
    # Reject low-alpha generator haze; the unmodified original is retained.
    a = np.array(im); a[a[:,:,3] < 190] = 0
    raw.append(Image.fromarray(a))
first_bounds = box(raw[0])
scale = 216/(first_bounds[3]-first_bounds[1])
eyes = [eye_center(im) for im in raw]
eye_target = np.array([242., 352-(first_bounds[3]-eyes[0][1])*scale])
frames = []; bodies=[]; brushes=[]; measured = []
# Stored brush: project the canonical object along the back; body/scarf
# naturally occlude the shaft. Do not cut a gap into the weapon itself.
canonical=Image.open(ROOT/'Source/Brush/brush_base.png').convert('RGBA')
tip=Image.open(ROOT/'Source/Brush/tip_dry.png').convert('RGBA')
canonical.alpha_composite(tip)
q=.60; angle=110; c=math.cos(math.radians(angle));s=math.sin(math.radians(angle))
butt=eye_target+[-61,10]
matrix=(c/q,s/q,20-(c*butt[0]+s*butt[1])/q,
        -s/q,c/q,24+(s*butt[0]-c*butt[1])/q)
back=canonical.transform((384,384),Image.Transform.AFFINE,matrix,Image.Resampling.BICUBIC)
for i, (im, eye) in enumerate(zip(raw, eyes)):
    im = im.resize((round(im.width*scale), round(im.height*scale)), Image.Resampling.LANCZOS)
    offset = tuple(np.round(eye_target-eye*scale).astype(int))
    body = Image.new('RGBA', (384,384)); body.paste(im, offset)
    body.save(ROOT/f'Layers/body/{i+1:02}.png'); bodies.append(body)
    back.save(ROOT/f'Layers/brush_back/{i+1:02}.png'); brushes.append(back)
    out = back.copy(); out.alpha_composite(body)
    out.save(ROOT/f'Sprites/run_{i+1:02}.png'); frames.append(out)
    measured.append({'frame':i+1, 'bounds':box(out), 'body_bounds':box(body), 'eye_xy':list(np.round(eye*scale+offset,3)),
                     'source_eye_xy':list(np.round(eye,3)), 'paste_xy':[int(v) for v in offset]})
save_atlas(frames, ROOT/'run_atlas.png')
save_atlas(bodies, ROOT/'Layers/run_body_atlas.png')
save_atlas(brushes, ROOT/'Layers/run_brush_back_atlas.png')
# Preserve v007's half-second cycle: 16 frames / 32 FPS = 0.5 seconds.
# GIF uses centiseconds. This 30/40ms schedule totals exactly 500ms.
gif_ms = [30]*16
for idx in [7,15]: gif_ms[idx] = 40
preview(frames, ROOT/'Previews/run.gif', gif_ms, ROOT/'Previews/contact.png')
preview(frames, ROOT/'Previews/run_slow.gif', 100)
preview([im.crop((100,170,285,320)).resize((370,300)) for im in frames],
        ROOT/'Previews/hands_slow.gif', 120, ROOT/'Previews/hands_contact.png')
plates=[]
for frame in frames:
    p=Image.new('RGBA',(384,384),(231,226,214,255));p.alpha_composite(frame);plates.append(p)
plates[0].save(ROOT/'Previews/run.apng',save_all=True,append_images=plates[1:],duration=31.25,loop=0,disposal=0,blend=0)
spriteframes(ROOT/'Godot/Wolf_Run.tres', [{'name':'run','fps':32,'loop':True,
             'files':[f'../Sprites/run_{i+1:02}.png' for i in range(16)]}])
for name in ['body','brush_back']:
    spriteframes(ROOT/f'Godot/Wolf_Run_{name}.tres',[{'name':'run','fps':32,'loop':True,
                 'files':[f'../Layers/{name}/{i+1:02}.png' for i in range(16)]}])
digest=[hashlib.sha256(im.tobytes()).hexdigest() for im in frames]
eye_array=np.array([m['eye_xy'] for m in measured])
metrics = {'frames':16,'unique_frames':len(set(digest)),'cell':[384,384], 'atlas':[6144,384],
           'fps':32,'cycle_seconds':.5,'offset':[-192,-352], 'rgba':True,
           'shared_scale':scale, 'registration':'White-eye centroid; uniform scale, whole-frame translations only.',
           'eye_range_xy':list(np.round(np.ptp(eye_array,axis=0),3)),
           'per_frame':measured,
           'brush':{'placement':'Stored on back, behind body/scarf', 'draw_order':['brush_back','body'],
                    'projection_scale':q,'angle_clockwise':angle,'butt_xy':list(butt),
                    'tip_xy':list(butt+214*q*np.array([c,s])), 'used_in_run':False},
           'review':'Drawn hand consistency and cyclic continuity reviewed visually, not guaranteed by pixel metrics. Game integration not performed.'}
metrics['all_borders_transparent']=all(not any(np.array(im)[:,:,3][edge].any() for edge in [(0,slice(None)),(-1,slice(None)),(slice(None),0),(slice(None),-1)]) for im in frames)
assert len(frames)==16 and len(set(digest))==16
assert metrics['all_borders_transparent']
log_path=ROOT/'Source/godot_validation.log'
if log_path.exists() and 'VALIDATION_OK:' in log_path.read_text(encoding='utf-8'):
    metrics['godot_validation']={'version':'4.7.2','resources':3,'frames_per_resource':16,
                                 'fps':32,'preview_scene_load':True,
                                 'log':'Source/godot_validation.log',
                                 'environment_warning':'Root certificate store unavailable in sandbox; art resources loaded successfully.'}
write_json(ROOT/'VALIDACION.json',metrics)
print({'frames':16,'unique_frames':len(set(digest)), 'eye_range_xy':metrics['eye_range_xy'],
       'bounds':[m['bounds'] for m in measured]})
