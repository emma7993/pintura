from pathlib import Path
import numpy as np
from PIL import Image
from common import box,cells,fit,write_json
R=Path(__file__).resolve().parents[1]

def grounded(im,f,anchor_x=128):
    a=np.array(im.convert('RGBA'));a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);im=Image.fromarray(a)
    b=box(im,16);cut=im.crop(b);cut=cut.resize((max(1,round(cut.width*f)),max(1,round(cut.height*f))),Image.Resampling.LANCZOS)
    aa=np.array(cut)[:,:,3];ys,xs=np.nonzero(aa>16)
    low=ys.max();foot=np.nonzero(aa[max(0,low-8):low+1,:]>64)[1];base=float(np.median(foot))
    out=Image.new('RGBA',(256,512));out.paste(cut,(round(anchor_x-base),480-int(low)))
    return out

def main():
    Image.open(R/'Source/front_master_original.png').convert('RGBA').resize((512,1024),Image.Resampling.LANCZOS).save(R/'Bruma/front_master.png')
    fit(Image.open(R/'Source/puddle_master_original.png').convert('RGBA'),(384,96),.025).save(R/'Manos/puddle_master.png')
    for i,im in enumerate(cells(R/'Source/wisps_master_original.png',3,2)):
        folder=R/'Bruma/Wisps'/f'{i+1:02}';folder.mkdir(parents=True,exist_ok=True);fit(im,(128,128),.12).save(folder/'master.png')
    eyes=cells(R/'Source/eyes_master_original.png',3,4)
    for k in range(3):
        folder=R/'Bruma/Eyes'/f'{k+1:02}';folder.mkdir(parents=True,exist_ok=True)
        for frame,row in enumerate([0,1,2,1]):eyes[row*3+k].resize((128,64),Image.Resampling.LANCZOS).save(folder/f'{frame+1:02}.png')
    # Generated fill texture registered into a periodic reflection tile.
    tex=Image.open(R/'Source/body_master_original.png').convert('RGB').resize((256,512),Image.Resampling.LANCZOS)
    half=Image.new('RGB',(512,512));half.paste(tex,(0,0));half.paste(tex.transpose(Image.Transpose.FLIP_LEFT_RIGHT),(256,0))
    tile=Image.new('RGB',(512,1024));tile.paste(half,(0,0));tile.paste(half.transpose(Image.Transpose.FLIP_TOP_BOTTOM),(0,512))
    a=np.array(tile,dtype=float);yy,xx=np.mgrid[:1024,:512]
    distance=np.minimum.reduce([xx,511-xx,yy,1023-yy]);w=np.clip(distance/32,0,1);w=w*w*(3-2*w)
    a=a*w[:,:,None]+np.array([5,7,10])*(1-w[:,:,None]);a=np.uint8(np.round(a))
    Image.fromarray(a).convert('RGBA').save(R/'Bruma/body.png')
    report={}
    for kind in 'ABC':
        anchor_x=64 if kind=='B' else 128
        seq={name:[im.resize((256,512),Image.Resampling.LANCZOS) for im in cells(R/'Source'/f'{kind}_{name}_original.png',3 if name=='grab' else 4,2)] for name in ['emerge','reach','grab']}
        for name,images in seq.items():
            for i,im in enumerate(images):
                a=np.array(im);a[:,:,3]=np.where(a[:,:,3]<190,0,a[:,:,3]);images[i]=Image.fromarray(a)
        b=box(seq['emerge'][-1],64);f=(310 if kind=='C' else 380)/(b[3]-b[1])
        # Shared whole-object scale across ALL animations of each design.
        # Find a common fit that preserves the base anchor and avoids clipping fingers.
        for images in seq.values():
            for im in images:
                bb=box(im,64);a=np.array(im)[:,:,3];ys,xs=np.nonzero(a>=64);low=ys.max();foot=np.nonzero(a[max(0,low-4):low+1,:]>=64)[1];base=float(np.median(foot))
                f=min(f,(252-anchor_x)/max(1,bb[2]-base),(anchor_x-5)/max(1,base-bb[0]))
        packed={name:[grounded(im,f,anchor_x) for im in images] for name,images in seq.items()}
        # Ping-pong authored key poses makes a closed probing gesture without a reset.
        packed['reach']=[packed['reach'][i] for i in [0,1,2,3,4,3,2,1]]
        packed['sink']=[packed['emerge'][i] for i in [7,6,4,3,1,0]]
        for name,images in packed.items():
            folder=R/'Manos'/kind/name;folder.mkdir(parents=True,exist_ok=True)
            for i,im in enumerate(images):im.save(folder/f'{i+1:02}.png')
        # Full mature hand is the source for color-triggered erasure VFX.
        packed['emerge'][-1].save(R/'Manos'/kind/'dissolve_master.png')
        report[kind]={'anchor_xy':[anchor_x,480],'common_object_scale':f,'emerge_height_last':box(packed['emerge'][-1],64)[3]-box(packed['emerge'][-1],64)[1],'reach_key_order_0_based':[0,1,2,3,4,3,2,1],'sink_emerge_order_0_based':[7,6,4,3,1,0]}
    write_json(R/'Source/registration.json',report)
    print('SHADOW_STATIC_READY',report)
if __name__=='__main__':main()
