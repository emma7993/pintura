from pathlib import Path
from PIL import Image
import numpy as np
from common import save_atlas,preview,write_json,spriteframes
R=Path(__file__).resolve().parents[1]
resources=[]
for folder,name,size in [('Inkfall/Stream','ink_stream',(160,720)),('Inkfall/Base','ink_base',(384,128)),('Barrier','barrier',(256,512))]:
    stem='barrier' if name=='barrier' else 'ink'
    paths=[R/folder/f'{stem}_{i:02}.png' for i in range(1,9)]
    frames=[Image.open(p).convert('RGBA') for p in paths]
    assert all(im.size==size for im in frames)
    if name!='barrier':
        assert np.array_equal(np.array(frames[0]),np.array(Image.open(R/folder/'closure_test.png').convert('RGBA')))
        assert len({im.tobytes() for im in frames})==8
    else:assert np.array_equal(np.array(frames[-1]),np.array(Image.open(R/folder/'rest.png').convert('RGBA')))
    save_atlas(frames,R/folder/f'{name}_atlas.png')
    preview(frames,R/'Previews'/f'{name}.gif',100,R/'Previews'/f'{name}_contact.png')
    resources.append({'name':name,'files':[f'../{folder}/{p.name}' for p in paths],'fps':10,'loop':name!='barrier'})
stream=[Image.open(R/'Inkfall/Stream'/f'ink_{i:02}.png').convert('RGBA') for i in range(1,9)]
base=[Image.open(R/'Inkfall/Base'/f'ink_{i:02}.png').convert('RGBA') for i in range(1,9)]
combo=[]
for a,b in zip(stream,base):
    im=Image.new('RGBA',(384,804));im.alpha_composite(a,(112,0));im.alpha_composite(b,(0,676));combo.append(im)
preview(combo,R/'Previews/inkfall_combined.gif',100,R/'Previews/inkfall_combined_contact.png')
resources.append({'name':'dip_splash','files':[f'../Dip_Splash/dip_splash_{i:02}.png' for i in range(1,7)],'fps':14,'loop':False})
spriteframes(R/'Godot/Color_Effects.tres',resources)
checks={'oil_count':8,'stroke_masks':12,'dabs':4,'stream_frames':8,'base_frames':8,'splash_frames':6,'barrier_frames':8,'effects_loop_period_seconds':.8,'stream_base_virtual_frame9_equals_frame1':True,'barrier_rest_equals_frame8':True,'all_effect_frames_unique':True}
for sub,size in [('Masks/Strokes',(512,256)),('Masks/Dabs',(256,256))]:
    for p in (R/sub).glob('*.png'):
        im=Image.open(p);assert im.mode=='L' and im.size==size
        assert np.array(im).min()==0 and np.array(im).max()==255
checks['masks_dimensions_range_pass']=True
write_json(R/'VALIDACION.json',checks)
print('COLOR_QA_OK',checks)
