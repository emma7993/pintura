from pathlib import Path
import json,math
import numpy as np
from PIL import Image,ImageDraw
from common import preview,write_json
from prepare_bodies import head_measure
R=Path(__file__).resolve().parents[1]
EXPECTED={'idle':6,'walk':12,'run':8,'jump_start':2,'jump_up':2,'fall':2,'land':2,'dash':6,'wall_slide':4,'wall_jump':4,'slash_side':7,'slash_up':7,'slash_down':6,'paint_rise':8,'paint_up':8,'dip':6,'hurt':3,'death':8}
LAYERS=['body','brush_back','brush_base','tip_color','tip_dry','tip_ink','smear']
spec=json.loads((R/'Source/animation_spec.json').read_text());rows=json.loads((R/'brush_contacts.json').read_text())
report={'size':[384,384],'origin_offset':[-192,-352],'ground_reference_y':352,'frame_count':101,'layers':LAYERS,'animations':{},'head_measurement':'Centroid of largest connected dark neutral head region, alpha>128, RGBmax<125, channel spread<35; ROI x110..324,y105..249. Grey outline, scarf and tail are excluded. QA overlays show the measured mask.','stored_brush_projection':'Foreshortened to 0.53 of the drawn in-hand length while hidden behind the back; only ring and distal bristles are exported. This avoids detached exposed middle sections. In-hand raster extent is215px.'}
GROUNDED={'idle','walk','run','jump_start','land','slash_side','slash_up','paint_rise','paint_up','dip','hurt'}
def feet(im):
    a=np.array(im)[:,:,3];present=(a[325:353,:]>64).any(axis=0);groups=[];start=None
    for i,on in enumerate([*present,False]):
        if on and start is None:start=i
        elif not on and start is not None:
            if i-start>=4:groups.append((start+i-1)/2)
            start=None
    return groups
for name,count in EXPECTED.items():
    data=[];frames=[]
    for layer in LAYERS:
        paths=sorted((R/'Animations'/name/layer).glob('*.png'));assert len(paths)==count,(name,layer,len(paths))
        for p in paths:
            im=Image.open(p);assert im.size==(384,384) and im.mode=='RGBA'
            if layer=='smear':
                a=np.array(im);v=a[:,:,3]>0;assert np.array_equal(a[:,:,0][v],a[:,:,1][v]) and np.array_equal(a[:,:,1][v],a[:,:,2][v])
        atlas=Image.open(R/'Animations'/name/f'{layer}_atlas.png');assert atlas.size==(384*count,384)
    for i in range(count):
        im=Image.open(R/'Animations'/name/'body'/f'{i+1:02}.png').convert('RGBA');frames.append(im)
        a=np.array(im)[:,:,3];yy,xx=np.nonzero(a>16);h=head_measure(im)
        m={'frame':i+1,'lowest_visible_y':int(yy.max()) if len(yy) else None,'height_px':int(yy.max()-yy.min()+1) if len(yy) else 0,'head_center_xy':list(h) if h else None,'foot_centers_lower_band_x':feet(im)}
        data.append(m)
        if name in GROUNDED:assert m['lowest_visible_y']==352,(name,i+1,m['lowest_visible_y'])
    result={**spec[name],'measurements':data,'height_range':[min(v['height_px'] for v in data),max(v['height_px'] for v in data)]}
    if name in ['idle','walk','run']:
        assert all(213<=v['height_px']<=219 for v in data)
        centers=np.array([v['head_center_xy'] for v in data]);mean=centers.mean(axis=0);delta=np.roll(centers,-1,axis=0)-centers
        maxdev=np.max(abs(centers-mean),axis=0);maxstep=np.max(abs(delta),axis=0);maxnorm=float(np.max(np.linalg.norm(delta,axis=1)))
        result.update({'head_mean_xy':mean.tolist(),'head_max_deviation_from_mean_xy':maxdev.tolist(),'head_max_adjacent_delta_xy_including_loop':maxstep.tolist(),'head_max_adjacent_distance_px_including_loop':maxnorm,'height_216_plusminus3_pass':True})
        limit=3 if name=='run' else 2
        assert np.all(maxdev<=limit) and np.all(maxstep<=limit) and maxnorm<=limit,(name,maxdev,maxstep,maxnorm)
        debug=[]
        for im in frames:
            center,mask=head_measure(im,True);a=np.zeros((384,384,4),dtype=np.uint8);a[mask]=[0,170,210,150];out=im.copy();out.alpha_composite(Image.fromarray(a));d=ImageDraw.Draw(out);x,y=center;d.line((x-8,y,x+8,y),fill=(210,0,0,255));d.line((x,y-8,x,y+8),fill=(210,0,0,255));debug.append(out)
        preview(debug,R/'Previews'/f'{name}_head_QA.gif',100,R/'Previews'/f'{name}_head_QA.png')
    if name in ['walk','run']:
        gaps=[max(v['foot_centers_lower_band_x'])-min(v['foot_centers_lower_band_x']) if len(v['foot_centers_lower_band_x'])>=2 else 0 for v in data]
        half=len(gaps)//2;openings=[max(gaps[:half]),max(gaps[half:])]
        result['halfcycle_max_foot_openings_px']=openings
        result['stride_opening_estimate_px_per_cycle']=sum(openings)
        result['conservative_twice_max_opening_estimate_px']=2*max(gaps)
        result['stride_measurement_note']='Sum of the maximum foot-group separation in each halfcycle, y325..352. Also records twice the larger opening as a conservative symmetric-step estimate. Neither certifies constant planted-foot velocity.'
    report['animations'][name]=result
assert len(rows)==101
for r in rows:
    name=r['animation'];n=r['frame'];back=Image.open(R/'Animations'/name/'brush_back'/f'{n:02}.png').getchannel('A').getextrema()[1];hand=Image.open(R/'Animations'/name/'brush_base'/f'{n:02}.png').getchannel('A').getextrema()[1]
    assert (back==0 if r['weapon_location']=='hand' else hand==0)
    for point in r['contact_by_state_xy'].values():
        if point is not None:assert all(0<=v<=383 for v in point)
    if r['hitbox']:
        x,y,w,h=r['hitbox'];assert x>=0 and y>=0 and w>0 and h>0 and x+w<=384 and y+h<=384
    assert r['hits']==(r['hitbox'] is not None)
    if r['hits'] or r['receives_ink']:assert all(p is not None for p in r['contact_by_state_xy'].values())
assert not json.loads((R/'Source/clipping.json').read_text())
for layer in LAYERS:assert Image.open(R/'Animations/death'/layer/'08.png').getchannel('A').getextrema()[1]==0
idle=np.array(report['animations']['idle']['head_mean_xy']);stops={}
for n in [4,10]:
    p=np.array(report['animations']['walk']['measurements'][n-1]['head_center_xy']);dif=p-idle;assert np.max(abs(dif))<=2;stops[str(n)]={'head_xy':p.tolist(),'delta_from_idle_xy':dif.tolist(),'pass':True}
report['idle_to_walk_passing_head_registration']=stops
paths={}
for name,expected in [('paint_rise',-120),('paint_up',-90)]:
    a=[r for r in rows if r['animation']==name and r['paints']];pts=np.array([r['tip_xy'] for r in a]);vec=pts[-1]-pts[0];ang=math.degrees(math.atan2(vec[1],vec[0]));middle=pts[1]-pts[0];error=abs(vec[0]*middle[1]-vec[1]*middle[0])/np.linalg.norm(vec);assert abs(ang-expected)<.01 and error<.01
    paths[name]={'contact_frames':[r['frame'] for r in a],'tip_xy':pts.tolist(),'angle_screen_degrees':ang,'straightness_error_px':float(error)}
report['paint_paths']=paths
a=np.array(Image.open(R/'Brush/brush_base.png'))[:,:,3];thickness=float(np.median((a[:,80:170]>64).sum(axis=0)));assert 6<=thickness<=8
report['brush_measurements']={'in_hand_raster_extent_px':215,'shaft_median_thickness_px_alpha64':thickness,'storage_projection_scale':.53,'storage_projection_extent_px':215*.53}
report['checks']={'all_png_rgba_dimensions_and_counts':True,'all_atlases_horizontal':True,'ground_y352_supported_frames':True,'idle_walk_run_height_216_plusminus3':True,'head_jitter_limits':True,'idle_to_passing_walk_head_alignment':True,'weapon_layers_mutually_exclusive':True,'three_tip_states_aligned_inside_cell':True,'no_clipped_weapon_layers':True,'smears_greyscale':True,'death_last_frame_fully_transparent_all_layers':True,'impact_hitboxes_inside_cell':True,'paint_paths_straight':True}
write_json(R/'VALIDACION.json',report)
print('WOLF_PINCEL_V003_QA_OK',report['checks'])
print('STRIDES',report['animations']['walk']['stride_opening_estimate_px_per_cycle'],report['animations']['run']['stride_opening_estimate_px_per_cycle'])
