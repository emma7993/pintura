from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import json
import numpy as np

root = Path(__file__).resolve().parents[1]
library = root.parent
refs = library/'Wolf_Pincel_v003/Animations'
source = root/'Source/Originales_Estudio_v003'
idle = Image.open(refs/'idle/body/01.png').convert('RGBA')
walk = Image.open(refs/'walk/body/01.png').convert('RGBA')
size = (384,384)
Y,X = np.indices(size)
tail_anchor = (181,293)
idle_seam = [(266,181),(274,180),(283,182),(292,185),(300,188),
             (304,184),(308,181),(316,174),(325,160),(328,156)]
# Boundary of the visible foreground torso and leg, in sprite pixels.
poses = [
    ((168,317),-8, [(303,166),(309,165),(314,166),(320,169),(325,174),(329,180),(335,179),(341,178),(345,166)]),
    ((179,281),9, [(267,173),(273,174),(278,176),(284,177),(292,176),(299,173),(306,171)]),
    ((174,280),-6, [(265,170),(271,171),(277,173),(284,174),(291,175),(296,175),(302,173)]),
    ((178,286),-12, [(272,172),(278,173),(283,175),(290,177),(296,180),(302,181),(308,180)]),
    ((169,311),-9, [(295,165),(301,165),(307,165),(313,167),(319,174),(325,177),(332,175)]),
]

def array(image):
    return np.asarray(image).astype(np.float32)

def pixels(mask, radius=5):
    return np.asarray(Image.fromarray(mask.astype('uint8')*255).filter(ImageFilter.MinFilter(radius)))>0

def charcoal(data):
    rgb = data[:,:,:3]
    neutral = rgb.max(axis=2)-rgb.min(axis=2)
    return (data[:,:,3]>225) & (neutral<14) & (rgb.mean(axis=2)<63)

def luma_detail(data):
    luma = data[:,:,:3].mean(axis=2)
    smooth = np.asarray(Image.fromarray(np.round(luma).astype('uint8')).filter(ImageFilter.GaussianBlur(1.15)))
    return luma-smooth

samples = [array(im) for im in (idle,walk)]
core_samples = [pixels(charcoal(a)) for a in samples]
palette = np.median(np.concatenate([a[core,:3] for a,core in zip(samples,core_samples)]),axis=0)
grain_ref = float(np.std(np.concatenate([luma_detail(a)[core] for a,core in zip(samples,core_samples)])))

def match_charcoal(im):
    a = array(im)
    mask = charcoal(a)
    core = pixels(mask)
    median = np.median(a[core,:3],axis=0)
    before = float(np.std(luma_detail(a)[core]))
    ratio = np.clip(grain_ref*1.08/before,.3,1)
    luma = a[:,:,:3].mean(axis=2)
    strength = np.clip((71-luma)/24,0,1) * mask
    new_rgb = palette + (a[:,:,:3]-median)*ratio
    final = a.copy()
    final[:,:,:3] = np.round(np.clip(a[:,:,:3] + (new_rgb-a[:,:,:3])*strength[:,:,None],0,255))
    assert np.array_equal(final[~mask],a[~mask])
    info = {'body_median_before_rgb': median.tolist(),
            'body_median_after_rgb': np.median(final[core,:3],axis=0).tolist(),
            'body_grain_before_sigma': round(before,3),
            'body_grain_after_sigma': round(float(np.std(luma_detail(final)[core])),3)}
    return Image.fromarray(final.astype('uint8')),info

def cut_zone(seam):
    ys,xs = zip(*seam)
    return (X < np.interp(Y,ys,xs)) & (Y>=ys[0]) & (Y<=ys[-1])

donor = idle.copy()
donor_alpha = np.asarray(idle.getchannel('A')).copy()
donor_alpha[~cut_zone(idle_seam)] = 0
component = np.zeros(size,dtype='uint8')
queue = [(138,300)]
while queue:
    x,y = queue.pop()
    if 0<=x<size[0] and 0<=y<size[1] and donor_alpha[y,x]>=16 and not component[y,x]:
        component[y,x] = 255
        queue.extend(((x-1,y),(x+1,y),(x,y-1),(x,y+1)))
support = np.asarray(Image.fromarray(component).filter(ImageFilter.MaxFilter(3)))>0
donor_alpha[~support] = 0
donor.putalpha(Image.fromarray(donor_alpha))
donor.save(root/'Source/cola_original.png')

entries = sorted(source.glob('*.png'))
assert len(entries)==5
result = []
report = []
for path,(anchor,angle,seam) in zip(entries,poses):
    old = Image.open(path).convert('RGBA')
    tuned, info = match_charcoal(old)
    front = np.asarray(tuned).copy()
    removal = cut_zone(seam)
    front[removal] = 0
    # Rotate the original tail at 1:1, then place it behind the pose.
    rotated = donor.rotate(angle,resample=Image.Resampling.BICUBIC,center=tail_anchor)
    back = Image.new('RGBA',size)
    back.paste(rotated, (anchor[0]-tail_anchor[0],anchor[1]-tail_anchor[1]))
    out = Image.alpha_composite(back,Image.fromarray(front))
    output = np.asarray(out).copy()
    original = np.asarray(old)
    tail_behind = np.asarray(back.getchannel('A'))>0
    protected = (~removal) & (front[:,:,3]>0) & ((front[:,:,3]>=245) | ~tail_behind)
    output[protected] = front[protected]
    # Scarf, eyes, and other protected chromatic pixels come straight from v003.
    assert np.array_equal(output[protected,3],original[protected,3])
    pinned = protected & ~charcoal(array(old))
    assert np.array_equal(output[pinned],original[pinned])
    outside_tail = ~removal & ~tail_behind
    assert np.array_equal(output[outside_tail,3],original[outside_tail,3])
    eye = (Y<260) & (original[:,:,:3].min(axis=2)>200) & (original[:,:,3]>220)
    assert np.array_equal(output[eye],original[eye])
    frame = Image.fromarray(output)
    assert frame.size == size and frame.mode == 'RGBA'
    assert np.array_equal(output[347:,175:,3],original[347:,175:,3])
    frame.save(root/'Sprites'/path.name)
    info.update({'frame':path.stem,'tail_angle_ccw':angle,'tail_scale':1.0})
    report.append(info)
    result.append(frame)

font_path = 'C:/Windows/Fonts/segoeui.ttf'
paper = (239,233,222,255)
sheet = Image.new('RGBA',(1418,352),paper)
draw = ImageDraw.Draw(sheet)
font = ImageFont.truetype(font_path,18)
draw.text((18,9),'Lobito / Original y salto v004',font=ImageFont.truetype(font_path,27),fill='#322e2a')
labels = ['Reposo original','Caminado 01','01 Impulso','02 Ascenso','03 Cima','04 Caída','05 Aterrizaje']
for i,(frame,label) in enumerate(zip([idle,walk,*result],labels)):
    x=13+199*i
    draw.rounded_rectangle((x,52,x+189,316),radius=8,fill='#e6decf')
    draw.line((x+9,298,x+180,298),fill='#bfb5a3',width=1)
    sheet.alpha_composite(frame.crop((84,105,273,365)),(x,51))
    draw.text((x+4,322),label,font=font,fill='#322e2a')
sheet.convert('RGB').save(root/'Previews/comparacion.png')

keys=[(0,0,120),(1,0,50),(1,33,50),(1,62,50),(1,82,50),(2,94,60),
      (2,100,70),(2,97,70),(3,86,60),(3,66,60),(3,40,50),(3,15,40),(4,0,110)]
play = []
for i,up,ms in keys:
    page = Image.new('RGBA',size,paper)
    ImageDraw.Draw(page).line((22,353,362,353),fill='#bfb5a3',width=1)
    page.alpha_composite(result[i],(0,-up))
    play.append(page.convert('RGB'))
play[0].save(root/'Previews/salto.gif',save_all=True,append_images=play[1:],
             duration=[k[2] for k in keys],loop=0,disposal=2)
(root/'VALIDACION.json').write_text(json.dumps({'reference_body_rgb': palette.tolist(),
    'reference_grain_sigma':round(grain_ref,3),'cell':[384,384],'anchor_xy':[192,352],
    'frames':report},ensure_ascii=False,indent=2),encoding='utf-8')
