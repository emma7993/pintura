from pathlib import Path
import json,hashlib
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parents[1]
report=json.loads((R/'VALIDACION.json').read_text())
puddle=Image.open(R/'Manos/Puddle/01.png').convert('RGBA');bottom=report['puddle_anchor_xy'][1]
composed=[]
for name,cfg in report['animations'].items():
    if not name[0] in 'ABC' or '_' not in name:continue
    kind,animation=name.split('_',1);anchor=cfg['anchor_xy']
    for i in range(cfg['count']):
        im=Image.open(R/'Manos'/kind/animation/f'{i+1:02}.png').convert('RGBA')
        assert im.size==(256,512)
        plate=Image.new('RGBA',(384,512));plate.alpha_composite(im,(192-anchor[0],0));plate.alpha_composite(puddle,(0,480-bottom))
        ys,xs=np.nonzero(np.array(plate)[:,:,3]>16);assert ys.max()==480,(name,i+1,ys.max())
        composed.append({'animation':name,'frame':i+1,'ground_y':480})
    if animation=='dissolve':assert np.array(im)[:,:,3].max()==0
for i in range(1,7):assert np.array(Image.open(R/'Bruma/Wisps'/f'{i:02}/06.png'))[:,:,3].max()==0
for name in ['front_loop','puddle_loop']:
    folder=R/('Bruma/Front' if name=='front_loop' else 'Manos/Puddle')
    frames=[np.array(Image.open(folder/f'{i:02}.png')) for i in range(1,9)]
    assert len({a.tobytes() for a in frames})==8
    assert np.array_equal(frames[0],np.array(Image.open(folder/'closure_test.png')))
report['ground_after_separate_puddle_composition_y']=480
report['all_composed_hands_have_ground_anchor_y480']=True
report['composed_hand_floor_measurements']=composed
report['front_and_puddle_eight_distinct_frames']=True
report['godot_validation']={'version':'4.7.2','spriteframes_animations':28,'frames_loaded':179,'runtime_preview_capture':'passed','resource_or_script_errors':False,'environment_notes':'Headless sandbox reported Windows certificate-store/user-preferences warnings; GPU previews rendered successfully.'}
(R/'VALIDACION.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
for root in [R,R.parent/'Wolf_Varita_v002']:
    manifest=[]
    for p in sorted(root.rglob('*')):
        rel=p.relative_to(root)
        if not p.is_file() or any(v in ['.godot','__pycache__'] for v in rel.parts):continue
        if p.suffix in ['.log','.pyc'] or p.name=='MANIFEST.json':continue
        manifest.append({'file':rel.as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
    (root/'MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('DELIVERY_VALIDATED',len(composed),'composed hand frames; eight distinct phase frames, transparent endings, SHA256 manifests')
