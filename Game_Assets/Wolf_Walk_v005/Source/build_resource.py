"""Write the portable Godot SpriteFrames resource; no game integration."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
lines=['[gd_resource type="SpriteFrames" load_steps=22 format=3]','',
       '[ext_resource type="Texture2D" path="../SpriteSheets/walk_v005.png" id="walk"]',
       '[ext_resource type="Texture2D" path="../SpriteSheets/look_around_v005.png" id="look"]',
       '[ext_resource type="Texture2D" path="../SpriteSheets/idle_v005.png" id="idle"]','']
for anim,count in [('walk',12),('look',6)]:
    for i in range(count):
        lines += [f'[sub_resource type="AtlasTexture" id="{anim}_{i}"]',f'atlas = ExtResource("{anim}")',f'region = Rect2({i*256}, 0, 256, 256)','']

def frames(anim,durations):
    return ', '.join(f'{{"duration": {d}, "texture": SubResource("{anim}_{i}")}}' for i,d in enumerate(durations))

lines += ['[resource]', 'animations = [',
    '{"frames": ['+frames('walk',[1.0]*12)+'], "loop": true, "name": &"walk", "speed": 12.0},',
    '{"frames": [{"duration": 1.0, "texture": ExtResource("idle")}], "loop": true, "name": &"idle", "speed": 1.0},',
    '{"frames": ['+frames('look',[0.72,0.72,0.96,2.28,0.72,0.60])+'], "loop": false, "name": &"look_around", "speed": 6.0}',
    ']','']
(ROOT/'Godot/Wolf.tres').write_text('\n'.join(lines),encoding='utf-8')
print('Wolf.tres: walk12@12FPS, idle1, look6/no-loop/1second')
