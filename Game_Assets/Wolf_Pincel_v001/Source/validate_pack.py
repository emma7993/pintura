from pathlib import Path
import sys,json,hashlib,csv
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parents[1]
report={'frame_counts':{},'cell':[256,256],'ground_y':238,'walk_unchanged_from_reference':True,'clipped_layers':[],'tip_contacts_in_cell':True}
for folder in sorted((R/'Animations').iterdir()):
    files=sorted((folder/'body').glob('*.png'));report['frame_counts'][folder.name]=len(files)
    for p in files:
        im=Image.open(p);assert im.size==(256,256) and im.mode=='RGBA'
        a=np.array(im)[:,:,3];ys,xs=np.nonzero(a>16);assert ys.max()==238,(str(p),ys.max())
    if folder.name=='walk_pincel':
        for i,p in enumerate(files):assert np.array_equal(np.array(Image.open(p)),np.array(Image.open(R/'References'/f'walk_{i+1:02}.png')))
    for layer in folder.iterdir():
        if not layer.is_dir() or layer.name=='body':continue
        assert len(list(layer.glob('*.png')))==len(files)
        for p in layer.glob('*.png'):
            a=np.array(Image.open(p))[:,:,3]
            if max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())>64:report['clipped_layers'].append(str(p.relative_to(R)))
assert not report['clipped_layers'],report['clipped_layers']
rows=json.loads((R/'brush_contacts.json').read_text())
for row in rows:
    for contact in row.get('contact_by_state_xy',{}).values():assert all(0<=v<=255 for v in contact)
with (R/'brush_contacts.csv').open('w',newline='',encoding='utf-8') as f:
    writer=csv.writer(f);writer.writerow(['animation','frame_1_based','tip_x','tip_y','ink_contact_x','ink_contact_y','paints_if_loaded','receives_ink'])
    for row in rows:
        writer.writerow([row['animation'],row['frame'],*(row['tip_xy'] or ['', '']),*row.get('contact_by_state_xy',{}).get('ink',['','']),row['paints'],row['receives_ink']])
(R/'VALIDACION.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print('WOLF_QA_OK',report)
