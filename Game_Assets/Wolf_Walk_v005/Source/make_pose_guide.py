"""Technical pose chart, not a replacement for the wolf artwork.
Creates numerical contact targets used as an image_gen supporting reference.
"""
from pathlib import Path
import json, math
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
im = Image.new('RGB', (1024, 768), 'white')
d = ImageDraw.Draw(im)
poses = []
for i in range(12):
    ox, oy = i % 4 * 256, i // 4 * 256
    phase = i % 6 / 6
    stance_x = 172 - 87.5 * phase
    swing_x = 84.5 + 87.5 * phase
    swing_y = 238 - 16 * math.sin(math.pi * phase)
    right = (stance_x, 238) if i < 6 else (swing_x, swing_y)
    left = (swing_x, swing_y) if i < 6 else (stance_x, 238)
    d.rectangle((ox, oy, ox + 255, oy + 255), outline='#cccccc')
    d.text((ox + 5, oy + 5), f'{i+1:02}  support={"R" if i < 6 else "L"}', fill='black')
    d.line((ox + 15, oy + 238, ox + 240, oy + 238), fill='#bbbbbb')
    d.line((ox + 128, oy + 88, ox + 128, oy + 160), fill='#bbbbbb', width=2)
    for foot, color in [(left, '#a06528'), (right, '#2260a0')]:
        x, y = foot
        hx, hy, ax, ay = 128.0, 160.0, x - 5, y - 5
        dx, dy = ax - hx, ay - hy
        length = math.hypot(dx, dy)
        bend = math.sqrt(46**2 - (length / 2)**2)
        kx = (hx + ax) / 2 + dy / length * bend
        ky = (hy + ay) / 2 - dx / length * bend
        d.line([(ox + hx, oy + hy), (ox + kx, oy + ky), (ox + ax, oy + ay)], fill=color, width=3)
        d.line((ox + x - 12, oy + y, ox + x + 12, oy + y), fill=color, width=4)
        d.ellipse((ox + x - 2, oy + y - 2, ox + x + 2, oy + y + 2), fill=color)
    poses.append({'frame': i+1, 'right_sole_center': list(right), 'left_sole_center': list(left), 'stance': 'right' if i < 6 else 'left'})
im.save(ROOT / 'POSE_GUIDE.png')
(ROOT / 'POSE_TARGETS.json').write_text(json.dumps({'cell': [256,256], 'step_distance_px':87.5,'cycle_distance_px':175.0,'stance_delta_px_per_frame':87.5/6,'poses':poses},indent=2))
