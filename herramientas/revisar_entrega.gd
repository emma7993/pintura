extends SceneTree
## Revisa una entrega de ChatGPT/Codex en Game_Assets antes de integrarla (sin ventana):
##   Godot --headless --path . -s res://herramientas/revisar_entrega.gd -- Wolf_Varita_v002
## (o herramientas/revisar_entrega.bat / .sh <carpeta>). Escribe pruebas/revision_<carpeta>.txt.
##
## Siempre: guía INTEGRACION_CLAUDE.md, recursos de Godot, PNG con tamaño y cantidad por carpeta.
## Personajes (Animations/<anim>/<capa>/NN.png, celdas 256x256, suelo y=238):
##   - mismas cuadros en todas las capas de una animación;
##   - pies en el suelo (y=238 ±3) y altura del lobo (~216 ±3) en reposo, caminata, carrera y gestos;
##   - temblor: cuánto se corre la cabeza entre cuadros seguidos (máx. 3 px);
##   - brush_contacts.json con la punta de cada cuadro de las animaciones con pincel.

const SUELO := 238
const ALTO := 216
const TOL_SUELO := 3
const TOL_ALTO := 4
const TOL_TORSO := 3.0
const AIRE := ["jump_start", "jump_up", "fall", "land"]   # en el aire o flexionado: la altura cambia

var _lineas: PackedStringArray = []
var _problemas := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		print("Uso: ... -s res://herramientas/revisar_entrega.gd -- <carpeta dentro de Game_Assets>")
		quit(1)
		return
	var nombre: String = args[0].trim_suffix("/").trim_suffix("\\").get_file()
	var raiz := ProjectSettings.globalize_path("res://Game_Assets/" + nombre)
	if not DirAccess.dir_exists_absolute(raiz):
		print("No existe: ", raiz)
		quit(1)
		return
	_log("Revisión de Game_Assets/%s  (%s)" % [nombre, Time.get_datetime_string_from_system()])
	_revisar_general(raiz)
	if DirAccess.dir_exists_absolute(raiz + "/Animations"):
		_revisar_personaje(raiz)
	_log("")
	_log("RESULTADO: " + ("TODO BIEN" if _problemas == 0 else "%d punto(s) a revisar" % _problemas))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://pruebas"))
	var f := FileAccess.open("res://pruebas/revision_%s.txt" % nombre, FileAccess.WRITE)
	f.store_string("\n".join(_lineas) + "\n")
	quit(0 if _problemas == 0 else 2)


func _log(t: String) -> void:
	_lineas.append(t)
	print(t)


func _mal(t: String) -> void:
	_problemas += 1
	_log("  REVISAR  " + t)


func _bien(t: String) -> void:
	_log("  ok       " + t)


func _revisar_general(raiz: String) -> void:
	_log("")
	_log("General")
	if FileAccess.file_exists(raiz + "/INTEGRACION_CLAUDE.md"):
		_bien("INTEGRACION_CLAUDE.md")
	else:
		_mal("falta INTEGRACION_CLAUDE.md (¿la entrega sigue en proceso?)")
	var tres := _archivos(raiz + "/Godot", "tres")
	if tres.is_empty():
		_mal("sin recursos .tres en Godot/")
	else:
		_bien("Godot/: " + ", ".join(tres))
	for extra in ["VALIDACION.json", "Previews", "Source"]:
		if FileAccess.file_exists(raiz + "/" + extra) or DirAccess.dir_exists_absolute(raiz + "/" + extra):
			_bien(extra)
		else:
			_mal("falta " + extra)


func _revisar_personaje(raiz: String) -> void:
	var contactos := {}
	var cpath := raiz + "/brush_contacts.json"
	if FileAccess.file_exists(cpath):
		for c in JSON.parse_string(FileAccess.get_file_as_string(cpath)):
			contactos["%s:%d" % [c.animation, int(c.frame)]] = true
	for anim in DirAccess.get_directories_at(raiz + "/Animations"):
		_log("")
		var dir := raiz + "/Animations/" + anim
		var capas := DirAccess.get_directories_at(dir)
		var n := _archivos(dir + "/body", "png").size()
		_log("%s  (%d cuadros; capas: %s)" % [anim, n, ", ".join(capas)])
		for capa in capas:
			var m := _archivos(dir + "/" + capa, "png").size()
			if m != n:
				_mal("%s tiene %d cuadros y body %d" % [capa, m, n])
		var aire := AIRE.has(anim.trim_suffix("_varita"))
		var centros: Array[float] = []
		var suelos: Array[int] = []
		var altos: Array[int] = []
		for i in n:
			var img := Image.load_from_file("%s/body/%02d.png" % [dir, i + 1])
			if img == null:
				_mal("no se pudo leer body/%02d.png" % (i + 1))
				continue
			if img.get_size() != Vector2i(256, 256):
				_mal("body/%02d.png mide %s (se esperaba 256x256)" % [i + 1, img.get_size()])
			var m := _medir(img)
			suelos.append(m.suelo)
			altos.append(m.alto)
			centros.append(m.centro)
		if centros.is_empty():
			continue
		var bad_suelo := suelos.filter(func(s: int) -> bool: return absi(s - SUELO) > TOL_SUELO)
		if bad_suelo.is_empty():
			_bien("pies en el suelo (y=%d..%d)" % [suelos.min(), suelos.max()])
		else:
			_mal("pies fuera del suelo: y=%s" % [suelos])
		if aire:
			_log("  info     altura %d..%d px (en el aire o flexionado: se acepta que cambie)" % [altos.min(), altos.max()])
		elif altos.max() - ALTO > TOL_ALTO or ALTO - altos.min() > TOL_ALTO:
			_mal("altura %d..%d px (se esperaba %d ±%d): el lobo crecería o se encogería" % [altos.min(), altos.max(), ALTO, TOL_ALTO])
		else:
			_bien("altura %d..%d px" % [altos.min(), altos.max()])
		if n > 1 and (anim.begins_with("walk") or anim.begins_with("run") or anim.begins_with("idle")):
			var peor := 0.0
			var donde := 0
			for i in n:
				var d := absf(centros[(i + 1) % n] - centros[i])
				if d > peor:
					peor = d
					donde = i + 1
			if peor > TOL_TORSO:
				_mal("la cabeza salta %.1f px entre los cuadros %d y %d (se verá trabado)" % [peor, donde, donde % n + 1])
			else:
				_bien("cabeza estable (salto máximo %.1f px entre cuadros)" % peor)
		if capas.has("brush_base"):
			var faltan: Array[int] = []
			for i in n:
				if not contactos.has("%s:%d" % [anim, i + 1]):
					faltan.append(i + 1)
			if faltan.is_empty():
				_bien("punta del pincel en brush_contacts.json")
			else:
				_mal("brush_contacts.json sin los cuadros %s" % [faltan])


## Pies (fila opaca más baja), altura de la silueta y centro horizontal de la cabeza (píxeles negros entre
## y=30 y 95: es lo que el ojo sigue; las patas y brazos se mueven mucho y no sirven para medir temblor; sin
## bufanda roja, borde gris claro ni cola gris).
func _medir(img: Image) -> Dictionary:
	var top := 999
	var bottom := -1
	var suma := 0.0
	var cuenta := 0
	for y in range(0, img.get_height(), 2):
		for x in range(0, img.get_width(), 2):
			var c := img.get_pixel(x, y)
			if c.a < 0.07:
				continue
			top = mini(top, y)
			bottom = maxi(bottom, y)
			if c.a > 0.5 and maxf(c.r, maxf(c.g, c.b)) < 0.28 and y > 30 and y < 95:
				suma += x
				cuenta += 1
	return {"suelo": bottom + 1, "alto": bottom - top + 1, "centro": suma / maxf(1.0, cuenta)}


func _archivos(dir: String, ext: String) -> PackedStringArray:
	var out: PackedStringArray = []
	if not DirAccess.dir_exists_absolute(dir):
		return out
	for f in DirAccess.get_files_at(dir):
		if f.get_extension() == ext:
			out.append(f)
	out.sort()
	return out
