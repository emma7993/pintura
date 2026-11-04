from pathlib import Path
from PIL import Image, ImageDraw
import numpy as np
from common import cells, box, preview, save_atlas, spriteframes, write_json

root = Path(__file__).resolve().parents[1]
palette = {
    'negro': (40, 38, 42), 'blanco': (242, 238, 226),
    'amarillo': (231, 184, 47), 'azul': (54, 117, 196),
    'verde': (72, 151, 92), 'rojo': (186, 43, 52),
}
tiles = cells(root/'Source/original.png', 5, 3)
animations = []
manifest = {}

def pack(index, tint=None):
    im = tiles[index]
    a = np.array(im)
    a[a[:,:,3]<150] = 0
    if tint:
        shade = .64 + .54*a[:,:,:3].mean(axis=2)/255
        a[:,:,:3] = np.clip(shade[:,:,None]*np.array(tint),0,255).astype('uint8')
        a[a[:,:,3]==0,:3] = 0
    im = Image.fromarray(a)
    out = Image.new('RGBA',(384,384))
    x = (384-im.width)//2
    if index<10:
        x = 352-box(im)[2]
    out.paste(im,(x,(384-im.height)//2))
    return out

def deliver(name, frames, fps, loop=False):
    dest = root/'Sprites'/name
    dest.mkdir(parents=True,exist_ok=True)
    files = []
    for i,frame in enumerate(frames,1):
        assert frame.mode=='RGBA' and frame.size==(384,384)
        assert frame.getchannel('A').getbbox()
        file = dest/f'{i:02}.png'
        frame.save(file)
        files.append(file.relative_to(root).as_posix())
    save_atlas(frames,root/'Atlases'/f'{name}.png')
    animations.append(dict(name=name,files=['../'+file for file in files],fps=fps,loop=loop))
    manifest[name] = dict(files=files,fps=fps,loop=loop,anchor=[192,192] if name=='impacto_critico' else [352,192])

for folder in ['Atlases','Previews','Godot']:
    (root/folder).mkdir(exist_ok=True)
for name,color in palette.items():
    deliver('normal_'+name,[pack(0,color)],1)
    deliver('estela_'+name,[pack(i,color) for i in range(1,5)],20)
deliver('critica_roja',[pack(5)],1)
critical_trail = [pack(i) for i in range(6,10)]
impact = [pack(i) for i in range(10,15)]
deliver('estela_critica',critical_trail,20)
deliver('impacto_critico',impact,20)
spriteframes(root/'Godot/Pincel_Flechas.tres',animations)
preview(critical_trail+impact,root/'Previews/critico.gif',[80]*4+[100]*4+[220])
preview([pack(i,palette['azul']) for i in range(1,5)],root/'Previews/estela_normal.gif',100)
board = Image.new('RGBA',(1152,812),(132,128,123,255))
draw = ImageDraw.Draw(board)
for i,(name,color) in enumerate(palette.items()):
    x,y = i%3*384,i//3*406
    board.alpha_composite(pack(0,color),(x,y))
    draw.text((x+12,y+380),name,fill='white')
board.convert('RGB').save(root/'Previews/paleta.png')
preview([pack(i) for i in range(15)],root/'Previews/poses.gif',120,root/'Previews/hoja_efectos.png')
write_json(root/'ASSETS.json',dict(cell=[384,384],facing='right',palette_rgb=palette,animations=manifest))

