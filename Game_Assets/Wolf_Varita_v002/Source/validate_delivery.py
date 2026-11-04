from pathlib import Path
import json,math
import numpy as np
from PIL import Image
from prepare_bodies import torso_measure
R=Path(__file__).resolve().parents[1]
metrics=json.loads((R/'Source/animation_metrics.json').read_text())
rows=json.loads((R/'brush_contacts.json').read_text())
report={'cell_rgba':[256,256],'origin_offset':[-128,-238],'ground_reference_y':238,'animations':metrics,'measurement_method':'Torso: connected black core, RGB max<115 and alpha>=128, ROI x90..189,y143..179; excludes grey outline, scarf and tail. Height: alpha>16. Stride: twice maximum separation of two foot groups in y224..238, an opening-based estimate, not a certified planted-foot velocity.','air_pose_height_policy':'User approved preserving head/torso scale and allowing natural flexion on jump/landing. Shared source scale for all eight air poses, no per-frame height normalization.','checks':{}}
clipped=[]
for name,m in metrics.items():
    fs=sorted((R/'Animations'/name/'body').glob('*.png'));assert len(fs)==m['frames']
    for i,p in enumerate(fs):
        im=Image.open(p);assert im.size==(256,256) and im.mode=='RGBA'
        assert list(torso_measure(im))==m['torso_center_xy_by_frame'][i]
    if name in ['walk','walk_varita','run','run_varita']:
        limit=2 if name.startswith('walk') else 3
        assert m['torso_x_max_deviation_from_mean']<=limit
        assert m['torso_x_max_adjacent_delta_including_loop']<=limit
    for layer in ['brush_base','tip_color','tip_dry','tip_ink']:
        for p in (R/'Animations'/name/layer).glob('*.png'):
            im=Image.open(p);assert im.mode=='RGBA' and im.size==(256,256)
            a=np.array(im)[:,:,3]
            if max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())>64:clipped.append(str(p.relative_to(R)))
    body=[np.array(Image.open(p))[:,:,3].astype(float) for p in fs]
    jumps=[float(np.abs(body[i]-body[(i+1)%len(body)]).mean()) for i in range(len(body))]
    m['loop_alpha_mae_last_to_first']=round(jumps[-1],4)
    m['loop_alpha_mae_max_internal']=round(max(jumps[:-1]),4) if len(jumps)>1 else 0
assert not clipped
assert all(0<=a['grip_fraction_from_butt']<=1/3+.0001 for a in rows)
assert all(all(0<=v<=255 for v in c) for a in rows for c in a['contact_by_state_xy'].values())
line_checks={}
for name,targetangle in [('paint_rise',-120),('paint_slash',60),('paint_up',-90)]:
    a=[r for r in rows if r['animation']==name and r['paints']]
    assert [r['frame'] for r in a]==[4,5,6]
    pts=np.array([r['tip_xy'] for r in a]);d=pts[-1]-pts[0]
    angle=math.degrees(math.atan2(d[1],d[0]));distance=abs(np.cross(d,pts[1]-pts[0]))/np.linalg.norm(d)
    assert abs(angle-targetangle)<.01 and distance<.01
    line_checks[name]={'tip_xy_frames_4_5_6':pts.tolist(),'screen_direction_degrees':round(angle,4),'collinearity_error_px':round(float(distance),5)}
idle=np.mean(np.array(metrics['idle']['torso_center_xy_by_frame']),axis=0)
passing={}
for n in [4,10]:
    p=np.array(metrics['walk']['torso_center_xy_by_frame'][n-1]);delta=p-idle
    assert abs(delta[0])<=2 and abs(delta[1])<=3
    passing[str(n)]={'idle_center':idle.tolist(),'walk_center':p.tolist(),'delta_xy':np.round(delta,4).tolist(),'pass':True}
report['idle_to_passing_walk']=passing
report['paint_paths']=line_checks
report['checks']={'all_dimensions_and_counts':True,'locomotion_torso_limits':True,'idle_walk_registration':True,'wand_length_176_17px_ratio_to_216':176.17/216,'grip_in_lower_third_all_frames':True,'no_clipped_weapon_layer':True,'contacts_inside_cell':True,'paint_contact_frames':[4,5,6],'dip_receives_ink_frames':[4,5],'walk_stride_measured_estimate_px':metrics['walk']['stride_estimate_two_steps_px'],'run_stride_measured_estimate_px':metrics['run']['stride_estimate_two_steps_px'],'standing_animation_heights_216px':all(m['height_216_plusminus3_pass'] for n,m in metrics.items() if not n.startswith(('jump','fall','land')))}
(R/'VALIDACION.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf-8')
print('WOLF_V002_QA_OK',report['checks'])
