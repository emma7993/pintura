from pathlib import Path
from common import cells
r=Path(__file__).resolve().parents[1]
cells(r/'Source/original.png',3,2)[3].save(r/'Source/fall_edit_target.png')
