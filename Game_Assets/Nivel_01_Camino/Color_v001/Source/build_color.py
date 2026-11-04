from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageChops
import numpy as np
from common import box,cells,fit,save_atlas,preview,write_json,spriteframes

R=Path(__file__).resolve().parents[1]
B=R.parent/'Bocetos_v001'
keys=['ground_a','ground_b','ground_c','reeds','stones','tree_left','tree_right','03_bosque_orilla']
alignment=[]
plates=[]
for key in keys:
    ref=Image.open(B/('Fondos' if key.startswith('03_') else 'Modulos')/(key+'.png')).convert('RGBA')
    src=Image.open(R/'Source'/f'{key}_original.png').convert('RGBA')
    sb,rb=box(src),box(ref)
    paint=src.crop(sb).resize((rb[2]-rb[0],rb[3]-rb[1]),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',ref.size)
    out.paste(paint,rb[:2])
    # Lock the original silhouette; fill only enclosed interior cavities.
    line=ref.getchannel('A')
    binary=line.point(lambda x:255 if x>8 else 0)
    padded=Image.new('L',(ref.width+2,ref.height+2));padded.paste(binary,(1,1))
    flood=padded.copy();ImageDraw.floodfill(flood,(0,0),128)
    holes=flood.point(lambda x:255 if x==0 else 0).crop((1,1,ref.width+1,ref.height+1))
    silhouette=ImageChops.lighter(line,holes)
    # Generated paint supplies impasto texture/color, original supplies geometry.
    # Opaque warm/cool underpaint prevents transparent gaps in generated texture.
    under=Image.new('RGBA',ref.size,(92,111,105,255));under.alpha_composite(out)
    out=under;out.putalpha(silhouette)
    out.save(R/'Oleo'/f'{key}_oleo.png')
    # Keep the original graphite available for an exact line-overlay reference.
    ref.save(R/'References'/f'{key}_graphite.png')
    p=out.copy();p.alpha_composite(ref)
    plates.append(fit(p,(512,256) if key.startswith('03_') else (256,256),.03))
    alignment.append({'name':key+'_oleo','size':list(out.size),'original_bbox':list(rb),'source_bbox':list(sb),'canvas_match':True,'bounding_box_registration':True,'filled_interiors':True,'pixel_contour_match_certified':True,'filled_interior_pixels':int(np.count_nonzero(np.array(holes))),'review':'Original alpha silhouette retained pixel-for-pixel; enclosed cavities filled. Open contours remain open. Generated impasto RGB registered by bounds, internal paint details may differ.'})
    assert out.size==ref.size
write_json(R/'alignment_report.json',alignment)
preview([p.resize((512,256)) if p.size!=(512,256) else p for p in plates],R/'Previews/oleo_gallery.gif',700,R/'Previews/oleo_contact.png',keys)

strokes=cells(R/'Source/stroke_masks_original.png',4,3)
for i,im in enumerate(strokes):
    mask=im.convert('L').resize((512,256),Image.Resampling.LANCZOS)
    a=np.array(mask); a[a<10]=0; a[a>245]=255
    Image.fromarray(a).save(R/'Masks/Strokes'/f'stroke_{i+1:02}.png')
dabs=cells(R/'Source/dab_masks_original.png',2,2)
for i,im in enumerate(dabs):
    a=np.array(im.convert('L').resize((256,256),Image.Resampling.LANCZOS));a[a<10]=0;a[a>245]=255
    Image.fromarray(a).save(R/'Masks/Dabs'/f'dab_{i+1:02}.png')

props=cells(R/'Source/props_original.png',3,2)
for i in range(4):
    a=np.array(props[i]);a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);props[i]=Image.fromarray(a)
fit(props[0],(256,256),.22,'bottom').save(R/'Altar/altar_small.png')
for idx,name in [(1,'inkwell_full'),(2,'inkwell_empty')]:
    # Shared fixed container rectangle; exact fill-level difference is generated art.
    im=props[idx].crop(box(props[idx])).resize((112,112),Image.Resampling.LANCZOS)
    out=Image.new('RGBA',(256,256));out.paste(im,(72,126));out.save(R/'Altar'/f'{name}.png')
fit(props[3],(64,64),.14).save(R/'Altar/inkwell_cap.png')
fit(props[4],(256,256),.08).save(R/'Objects/brush_pickup.png')
fit(props[5],(256,256),.10).save(R/'Gate/gate_active_glow.png')

ref=Image.open(B/'Modulos/gate.png').convert('RGBA')
src=Image.open(R/'Source/gate_tinta_original.png').convert('RGBA')
rb=box(ref); crop=src.crop(box(src)).resize((rb[2]-rb[0],rb[3]-rb[1]),Image.Resampling.LANCZOS)
out=Image.new('RGBA',ref.size);out.paste(crop,rb[:2]);out.save(R/'Gate/gate_tinta.png')
alignment.append({'name':'gate_tinta','size':list(out.size),'canvas_match':True,'bounding_box_registration':True,'pixel_contour_match_certified':False,'review':'Arch opening and stone contours need overlay review; no claim of pixel-perfect tracing.'})
write_json(R/'alignment_report.json',alignment)

splash=[]
for i,im in enumerate(cells(R/'Source/dip_splash_original.png',3,2)):
    frame=im.resize((128,128),Image.Resampling.LANCZOS)
    frame.save(R/'Dip_Splash'/f'dip_splash_{i+1:02}.png');splash.append(frame)
save_atlas(splash,R/'Dip_Splash/dip_splash_atlas.png')
preview(splash,R/'Previews/dip_splash.gif',75,R/'Previews/dip_splash_contact.png')

# Raster master textures for the periodic Godot effect renderer.
fit(Image.open(R/'Source/inkfall_stream_original.png').convert('RGBA'),(160,720),.02).save(R/'Inkfall/stream_master.png')
fit(Image.open(R/'Source/inkfall_base_original.png').convert('RGBA'),(384,128),.04).save(R/'Inkfall/base_master.png')
fit(Image.open(R/'Source/barrier_master_original.png').convert('RGBA'),(256,512),.04,'bottom').save(R/'Barrier/barrier_master.png')
print('COLOR static pack:8oil,12stroke masks,4dabs,altar/inkwells/pickup/gate,6splash,3effectmasters')
