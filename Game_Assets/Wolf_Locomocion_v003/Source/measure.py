from pathlib import Path
from collections import deque
import json
import numpy as np
from PIL import Image,ImageDraw
from common import box,cells,preview,write_json
R=Path(__file__).resolve().parents[1]

def torso_measure(im,mask_out=False):
    a=np.array(im.convert('RGBA'))
    # Torso core, isolated from grey outline, red scarf, grey tail and forearms.
    mask=(a[:,:,3]>=128)&(a[:,:,:3].max(axis=2)<115)
    roi=np.zeros_like(mask);roi[143:180,90:190]=True;mask &= roi
    ys,xs=np.nonzero(mask)
    if not len(xs):raise ValueError('No torso core')
    i=np.argmin((xs-138)**2+(ys-160)**2);seed=(int(xs[i]),int(ys[i]))
    seen=np.zeros_like(mask);q=deque([seed]);seen[seed[1],seed[0]]=True
    while q:
        x,y=q.popleft()
        for nx,ny in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
            if 0<=nx<256 and 0<=ny<256 and mask[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;q.append((nx,ny))
    ys,xs=np.nonzero(seen)
    if len(xs)<120:raise ValueError(('Torso segmentation too small',len(xs)))
    return (round(float(xs.mean()),3),round(float(ys.mean()),3),seen) if mask_out else (round(float(xs.mean()),3),round(float(ys.mean()),3))

def foot_centers(im):
    a=np.array(im)[:,:,3]
    present=(a[224:239,:]>64).any(axis=0)
    runs=[];start=None
    for i,on in enumerate([*present,False]):
        if on and start is None:start=i
        elif not on and start is not None:
            if i-start>=4:runs.append((start+i-1)/2)
            start=None
    return runs

