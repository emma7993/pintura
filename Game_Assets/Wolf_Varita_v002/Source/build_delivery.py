from pathlib import Path
import json,math,csv
import numpy as np
from PIL import Image
from common import preview,save_atlas,write_json,spriteframes
from prepare_bodies import torso_measure,foot_centers
R=Path(__file__).resolve().parents[1]
S=R/'Source/Packed_Bodies'
grips=json.loads((R/'Source/grips_actions.json').read_text())
def read(name):return [Image.open(p).convert('RGBA') for p in sorted((S/name).glob('*.png'))]
def hand(im):
    a=np.array(im);mask=a[:,:,3]>128;roi=np.zeros_like(mask);roi[119:156,175:235]=True;mask &=roi
    ys,xs=np.nonzero(mask);end=int(xs.max()); ys,xs=np.nonzero(mask&(np.indices(mask.shape)[1]>=end-7))
    return [end-6,round(float(np.median(ys)),1)]
spec={}
for base in ['idle','walk','run']:
    frames=read(base)
    for wand in [False,True]:spec[base+('_varita' if wand else '')]={'frames':frames,'wand':wand,'grips':[hand(im) for im in frames],'loop':True,'fps':6 if base=='idle' else (12 if base=='walk' else 16)}
air=read('air_clean')
for name,indices,loop in [('jump_start',[0,1],False),('jump_up',[2,3],True),('fall',[4,5],True),('land',[6,7],False)]:
    for wand in [False,True]:spec[name+('_varita' if wand else '')]={'frames':[air[i] for i in indices],'wand':wand,'grips':[grips['air_clean'][i] for i in indices],'loop':loop,'fps':10}
for name in ['paint_rise','paint_up','dip']:
    spec[name]={'frames':read(name),'wand':True,'grips':grips[name],'loop':False,'fps':10,'paint':[4,5,6] if name!='dip' else [],'ink':[4,5] if name=='dip' else []}
# A descending stroke is the exact time reverse of the ascending straight contact.
order=[7,6,5,5,4,3,2,0]
spec['paint_slash']={'frames':[read('paint_rise')[i] for i in order],'wand':True,'grips':[grips['paint_rise'][i] for i in order],'loop':False,'fps':10,'paint':[4,5,6],'ink':[]}

base=Image.open(R/'References/brush_base_original.png').convert('RGBA')
tips={state:Image.open(R/'References'/f'tip_{state}_original.png').convert('RGBA') for state in ['color','dry','ink']}
base.save(R/'Brush/brush_base.png')
for state,im in tips.items():im.save(R/'Brush/Tips'/f'tip_{state}.png')
resources={layer:[] for layer in ['body','brush_base','tip_color','tip_dry','tip_ink']}
metadata=[];summary={};all_clipped=[]
Q=.79
START=16;END=239
rise=[[239,236],[215,236-24*math.sqrt(3)],[119,236-120*math.sqrt(3)]]
slash=list(reversed(rise))
for name,cfg in spec.items():
    frames=cfg['frames'];sheet={layer:[] for layer in resources};plates=[]
    for index,body in enumerate(frames):
        n=index+1;layers={'body':body}
        if cfg['wand']:
            gx,gy=cfg['grips'][index]
            angle=-68.0+math.sin(index*math.tau/len(frames))*.5
            pivot=16+224*.27
            target=None
            if name in ['paint_rise','paint_slash'] and n in [4,5,6]:target=(rise if name=='paint_rise' else slash)[n-4]
            elif name=='paint_rise' and n==1:target=[252,238]
            elif name=='paint_up' and n in [4,5,6]:target=[233,[236,125,24][n-4]]
            elif name=='dip' and n in [2,3,4,5]:target=[235,[238,238,238,238][n-2]]
            elif name=='paint_rise' and n in [2,3]:target=[[239,230],[239,236]][n-2]
            elif name=='paint_slash' and n in [2,3]:angle=[-95,-125][n-2]
            elif name=='paint_up' and n in [2,3]:target=[[247,238],[233,230]][n-2]
            if target is not None:
                vx,vy=target[0]-gx,target[1]-gy
                distance=math.hypot(vx,vy);angle=math.degrees(math.atan2(vy,vx));pivot=END-distance/Q
            else:
                # Keep the entire upright tool inside the fixed 256 cell.
                # Never shift the body or shorten the brush to fit it.
                distance=(END-pivot)*Q
                for _ in range(4):
                    rad=math.radians(angle);tx=gx+distance*math.cos(rad);ty=gy+distance*math.sin(rad)
                    if tx>252:angle-=1
                    elif ty<3: pivot+=1.5;distance=(END-pivot)*Q
                    else:break
            rad=math.radians(angle);c,s=math.cos(rad),math.sin(rad)
            transform=(c/Q,s/Q,pivot-(c*gx+s*gy)/Q,-s/Q,c/Q,32+(s*gx-c*gy)/Q)
            raster=lambda im:im.transform((256,256),Image.Transform.AFFINE,transform,Image.Resampling.BICUBIC)
            layers['brush_base']=raster(base)
            contacts={}
            for state,im in tips.items():
                out=raster(im);layers['tip_'+state]=out
                a=np.array(out)[:,:,3];ys,xs=np.nonzero(a>64)
                if not len(xs):raise ValueError(('Empty tip',name,n,state,gx,gy,angle,pivot))
                projection=xs*c+ys*s;chosen=projection>=projection.max()-1
                contacts[state]=[round(float(xs[chosen].mean()),3),round(float(ys[chosen].mean()),3)]
            row={'animation':name,'frame':n,'grip_xy':[gx,gy],'angle_degrees_clockwise':round(angle,4),'tip_xy':[round(gx+(END-pivot)*Q*c,4),round(gy+(END-pivot)*Q*s,4)],'contact_by_state_xy':contacts,'paints':n in cfg.get('paint',[]),'receives_ink':n in cfg.get('ink',[]),'brush_length_px':round((END-START)*Q,3),'grip_fraction_from_butt':round((pivot-START)/(END-START),4),'target_tip_xy':target}
            metadata.append(row)
        plate=Image.new('RGBA',(256,256))
        if cfg['wand']:
            plate.alpha_composite(layers['brush_base']);plate.alpha_composite(layers['tip_color' if name.startswith('paint') else 'tip_dry'])
        plate.alpha_composite(body);plates.append(plate)
        for layer,im in layers.items():
            folder=R/'Animations'/name/layer;folder.mkdir(parents=True,exist_ok=True);im.save(folder/f'{n:02}.png');sheet[layer].append(im)
            a=np.array(im)[:,:,3]
            if max(a[0,:].max(),a[-1,:].max(),a[:,0].max(),a[:,-1].max())>64:all_clipped.append([name,n,layer])
    for layer,images in sheet.items():
        if not images:continue
        save_atlas(images,R/'Animations'/name/f'{layer}_atlas.png')
        resources[layer].append({'name':name,'files':[f'../Animations/{name}/{layer}/{i+1:02}.png' for i in range(len(images))],'fps':cfg['fps'],'loop':cfg['loop']})
    duration=[100,100,110,100,100,110,100,100,110,100,100,120] if name.startswith('walk') else round(1000/cfg['fps'])
    preview(plates,R/'Previews'/f'{name}.gif',duration,R/'Previews'/f'{name}_contact.png')
    centers=[torso_measure(im) for im in frames]
    heights=[]
    for im in frames:
        a=np.array(im)[:,:,3];ys,xs=np.nonzero(a>16);heights.append(int(ys.max()-ys.min()+1))
    xs=[a[0] for a in centers];ys=[a[1] for a in centers];mean=float(np.mean(xs))
    feet=[foot_centers(im) for im in frames];spans=[max(a)-min(a) if len(a)>=2 else 0 for a in feet]
    summary[name]={'frames':len(frames),'has_wand':cfg['wand'],'height_px_by_frame':heights,'height_min':min(heights),'height_max':max(heights),'height_216_plusminus3_pass':all(213<=h<=219 for h in heights),'torso_center_xy_by_frame':centers,'torso_x_max_deviation_from_mean':round(max(abs(x-mean) for x in xs),3),'torso_x_max_adjacent_delta_including_loop':round(max(abs(xs[i]-xs[(i+1)%len(xs)]) for i in range(len(xs))),3),'torso_y_range':round(max(ys)-min(ys),3),'foot_centers_bottom_band_by_frame':feet,'max_foot_center_separation_px':round(max(spans),3),'stride_estimate_two_steps_px':round(2*max(spans),3)}
for layer,anims in resources.items():spriteframes(R/'Godot'/f'Wolf_{layer}.tres',anims)
write_json(R/'brush_contacts.json',metadata)
with (R/'brush_contacts.csv').open('w',newline='',encoding='utf-8') as f:
    writer=csv.writer(f);writer.writerow(['animation','frame','grip_x','grip_y','angle_degrees_clockwise','tip_x','tip_y','color_x','color_y','dry_x','dry_y','ink_x','ink_y','paints','receives_ink','grip_fraction_from_butt'])
    for row in metadata:writer.writerow([row['animation'],row['frame'],*row['grip_xy'],row['angle_degrees_clockwise'],*row['tip_xy'],*row['contact_by_state_xy']['color'],*row['contact_by_state_xy']['dry'],*row['contact_by_state_xy']['ink'],row['paints'],row['receives_ink'],row['grip_fraction_from_butt']])
write_json(R/'Source/animation_metrics.json',summary)
write_json(R/'Source/clipping_report.json',all_clipped)
print('ANIMATIONS',len(spec),'BODY_FRAMES',sum(len(a['frames']) for a in spec.values()),'WAND_RECORDS',len(metadata),'CLIPPED',all_clipped)
print('STRIDES',summary['walk']['stride_estimate_two_steps_px'],summary['run']['stride_estimate_two_steps_px'])
print('GRIP_FRACTION',min(a['grip_fraction_from_butt'] for a in metadata),max(a['grip_fraction_from_butt'] for a in metadata))
