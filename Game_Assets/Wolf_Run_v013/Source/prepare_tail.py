from pathlib import Path
from PIL import Image
import json
from common import cells
r=Path(__file__).resolve().parents[1]
boxes=[(100,279,192,335),(100,280,192,335),(100,274,192,328),(100,266,192,318),
       (100,280,192,335),(100,281,192,337),(100,273,192,328),(100,266,192,318)]
out=Image.new('RGBA',(512,256))
for i,(im,b) in enumerate(zip(cells(r/'Source/referencia_usuario.png',4,2),boxes)):
    out.paste(im.crop(b),(i%4*128+18,i//4*128+36))
out.save(r/'Source/tail_edit_target.png')
(r/'Source/tail_boxes.json').write_text(json.dumps(boxes),encoding='utf-8')
