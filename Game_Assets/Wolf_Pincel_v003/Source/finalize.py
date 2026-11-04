from pathlib import Path
import json,hashlib,re
R=Path(__file__).resolve().parents[1]
resource=(R/'Source/validate_godot.log').read_text(encoding='utf-8',errors='replace')
capture=(R/'Source/capture.log').read_text(encoding='utf-8',errors='replace')
assert 'WOLF_PINCEL_V003_RESOURCES_OK 707' in resource
assert 'WOLF_V003_CAPTURE 0' in capture
assert not re.search(r'SCRIPT ERROR|Parse Error|Failed loading|Error importing',resource+capture)
p=R/'VALIDACION.json';data=json.loads(p.read_text(encoding='utf-8'))
data['godot']={'version':'4.7.2','layers_loaded':7,'animations_per_layer':18,'frames_loaded':707,'preview_capture':'Previews/godot_preview.png','resource_or_script_errors':False,'environment_notes':'Sandbox headless warned about Windows certificate store and saving user/editor preferences; completed imports, resource validation and GPU preview successfully.'}
p.write_text(json.dumps(data,indent=2,ensure_ascii=False),encoding='utf-8')
walk=data['animations']['walk'];run=data['animations']['run']
note=f"\n\n## Resultado final de revisión\n\nZancada estimada por suma de aperturas: walk **{walk['stride_opening_estimate_px_per_cycle']:g} px/ciclo**, run **{run['stride_opening_estimate_px_per_cycle']:g} px/ciclo**, frente a objetivos aproximados de 145/300. Desplazamiento máximo entre centros de cabeza consecutivos, incluido el cierre: walk **{walk['head_max_adjacent_distance_px_including_loop']:.3f} px**, run **{run['head_max_adjacent_distance_px_including_loop']:.3f} px**.\n\nGodot 4.7.2 importó y cargó los 707 cuadros de las siete capas; el preview gráfico se renderizó correctamente. Los avisos de certificados y preferencias del usuario provienen del entorno headless restringido; no hubo errores de recursos o scripts en la comprobación final.\n"
doc=R/'INTEGRACION_CLAUDE.md';doc.write_text(doc.read_text(encoding='utf-8')+note,encoding='utf-8')
manifest=[]
for file in sorted(R.rglob('*')):
    rel=file.relative_to(R)
    if not file.is_file() or any(s in ['.godot','__pycache__'] for s in rel.parts):continue
    if file.suffix in ['.log','.pyc'] or file.name=='MANIFEST.json':continue
    manifest.append({'file':rel.as_posix(),'bytes':file.stat().st_size,'sha256':hashlib.sha256(file.read_bytes()).hexdigest()})
(R/'MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print('FINAL_DELIVERY_READY',len(manifest),'files indexed; walk',walk['stride_opening_estimate_px_per_cycle'],'run',run['stride_opening_estimate_px_per_cycle'])
