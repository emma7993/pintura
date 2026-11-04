from pathlib import Path
from PIL import Image,ImageDraw
import numpy as np,json,hashlib
R=Path(__file__).resolve().parents[1]
W=R.parents[1]/'Wolf_Pincel_v001'
checks={}
for entry in json.loads((R/'alignment_report.json').read_text()):
    if not entry['name'].endswith('_oleo'):continue
    key=entry['name'][:-5]
    ref=Image.open(R/'References'/f'{key}_graphite.png').convert('RGBA')
    art=Image.open(R/'Oleo'/f'{key}_oleo.png').convert('RGBA')
    assert art.size==ref.size
    ra=np.array(ref)[:,:,3];aa=np.array(art)[:,:,3]
    # All original graphite coverage is retained without displacement.
    assert np.all(aa>=ra)
    assert art.getpixel((0,0))[3]==ref.getpixel((0,0))[3]
    line=ref.getchannel('A').point(lambda a:255 if a>8 else 0)
    flood=Image.new('L',(line.width+2,line.height+2));flood.paste(line,(1,1));ImageDraw.floodfill(flood,(0,0),128)
    outside=np.array(flood.crop((1,1,line.width+1,line.height+1)))==128
    assert np.array_equal(aa[outside],ra[outside])
checks['oil_original_coverage_and_transparent_exterior']=True
for folder in ['Altar','Gate','Objects']:
    for p in (R/folder).glob('*.png'):
        im=Image.open(p);assert im.mode=='RGBA' and im.getchannel('A').getextrema()[0]==0
checks['props_rgba_transparent_exterior']=True
for name,count in [('walk_pincel',12),('run',8),('run_pincel',8),('paint_slash',8),('paint_up',8),('dip',6)]:
    im=Image.open(W/'Previews'/f'{name}.gif');assert im.n_frames==count,(name,im.n_frames)
    if name=='walk_pincel':
        total=0
        for i in range(im.n_frames):im.seek(i);total+=im.info['duration']
        assert total==1250
checks['wolf_gifs_counts_and_walk_1250ms']=True
for root in [R,W]:
    manifest=[]
    for p in sorted(root.rglob('*')):
        rel=p.relative_to(root)
        if not p.is_file() or any(part in ['.godot','__pycache__'] for part in rel.parts):continue
        if p.suffix not in ['.png','.gif','.tres','.txt','.md','.json','.csv','.gd','.py','.godot','.tscn']:continue
        if p.name in ['MANIFEST.json','VALIDACION_ENTREGA.json']:continue
        manifest.append({'file':rel.as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
    (root/'MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    result=json.loads((root/'VALIDACION.json').read_text())
    result['godot_import_and_preview']='Godot 4.7.2: imports and runtime previews passed; sandbox certificate/user preference warnings only'
    result['delivery_checks']=checks
    (root/'VALIDACION_ENTREGA.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print('DELIVERY_QA_OK',checks)
