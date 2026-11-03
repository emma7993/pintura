extends SceneTree
## Arma un GIF animado con las capturas de una prueba (las PNG que deja --write-movie), sin programas extra:
##   Godot --headless --path . -s res://herramientas/hacer_gif.gd -- <patrón> <desde> <hasta> <salida.gif> [ancho] [paso] [x,y,w,h]
## Ejemplo: ... -- pruebas/nivel1_%08d.png 0 440 pruebas/nivel1.gif 480 1
## [x,y,w,h] recorta antes de escalar (para acercarse al lobo). Paleta fija de 252 colores con tramado
## ordenado; las capturas van a 10 FPS, así que el GIF usa 10 cuadros por segundo dividido entre el paso.

const BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

var _out := PackedByteArray()


func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	if a.size() < 4:
		print("Uso: -- <patrón> <desde> <hasta> <salida.gif> [ancho] [paso] [x,y,w,h]")
		quit(1)
		return
	var pattern: String = a[0]
	var first := int(a[1])
	var last := int(a[2])
	var out_path: String = a[3]
	var width := int(a[4]) if a.size() > 4 else 480
	var step := int(a[5]) if a.size() > 5 else 1
	var crop := Rect2i()
	if a.size() > 6:
		var p: PackedStringArray = a[6].split(",")
		crop = Rect2i(int(p[0]), int(p[1]), int(p[2]), int(p[3]))
	var frames: Array[Image] = []
	for i in range(first, last + 1, step):
		var path := ProjectSettings.globalize_path("res://" + pattern % i)
		if not FileAccess.file_exists(path):
			continue
		var img := Image.load_from_file(path)
		if crop.size != Vector2i.ZERO:
			img = img.get_region(crop)
		img.convert(Image.FORMAT_RGB8)
		img.resize(width, int(round(float(img.get_height()) * width / img.get_width())), Image.INTERPOLATE_LANCZOS)
		frames.append(img)
	if frames.is_empty():
		print("No hay capturas con ese patrón")
		quit(1)
		return
	var w := frames[0].get_width()
	var h := frames[0].get_height()
	_header(w, h)
	var delay := int(round(10.0 * step))           # centésimas de segundo por cuadro
	for img in frames:
		_frame(_indices(img), w, h, delay)
	_out.append(0x3B)
	var f := FileAccess.open("res://" + out_path, FileAccess.WRITE)
	f.store_buffer(_out)
	print("GIF listo: %s (%d cuadros, %dx%d, %d KB)" % [out_path, frames.size(), w, h, _out.size() / 1024])
	quit(0)


## Paleta 6 x 7 x 6 (rojo, verde, azul) + 4 grises.
func _header(w: int, h: int) -> void:
	_out.append_array("GIF89a".to_ascii_buffer())
	_u16(w)
	_u16(h)
	_out.append_array([0xF7, 0, 0])                 # paleta global de 256 colores
	for r in 6:
		for g in 7:
			for b in 6:
				_out.append_array([r * 51, int(g * 42.5), b * 51])
	for k in 4:
		var v := 40 + k * 60
		_out.append_array([v, v, v])
	_out.append_array([0x21, 0xFF, 0x0B])           # bucle infinito (NETSCAPE2.0)
	_out.append_array("NETSCAPE2.0".to_ascii_buffer())
	_out.append_array([3, 1, 0, 0, 0])


func _indices(img: Image) -> PackedByteArray:
	var data := img.get_data()
	var w := img.get_width()
	var n := data.size() / 3
	var idx := PackedByteArray()
	idx.resize(n)
	for i in n:
		var x := i % w
		var y := i / w
		var d: float = (BAYER[(y & 3) * 4 + (x & 3)] + 0.5) / 16.0 - 0.5
		var r := clampi(int(data[i * 3] / 51.0 + d + 0.5), 0, 5)
		var g := clampi(int(data[i * 3 + 1] / 42.5 + d + 0.5), 0, 6)
		var b := clampi(int(data[i * 3 + 2] / 51.0 + d + 0.5), 0, 5)
		idx[i] = r * 42 + g * 6 + b
	return idx


func _frame(idx: PackedByteArray, w: int, h: int, delay: int) -> void:
	_out.append_array([0x21, 0xF9, 4, 0x04])        # control gráfico: no desechar, demora
	_u16(delay)
	_out.append_array([0, 0])
	_out.append(0x2C)
	_u16(0)
	_u16(0)
	_u16(w)
	_u16(h)
	_out.append(0)
	_out.append(8)                                  # tamaño mínimo de código LZW
	var lzw := _lzw(idx)
	var i := 0
	while i < lzw.size():
		var n := mini(255, lzw.size() - i)
		_out.append(n)
		_out.append_array(lzw.slice(i, i + n))
		i += n
	_out.append(0)


## Compresión LZW de GIF (códigos de 9 a 12 bits, se reinicia al llenar el diccionario).
func _lzw(idx: PackedByteArray) -> PackedByteArray:
	var res := PackedByteArray()
	var clear := 256
	var stop := 257
	var size := 9
	var next := 258
	var dict := {}
	var bits := 0
	var nbits := 0
	# código de limpieza al empezar
	bits |= clear << nbits
	nbits += size
	var prefix := int(idx[0])
	for i in range(1, idx.size()):
		var c := int(idx[i])
		var key := (prefix << 8) | c
		if dict.has(key):
			prefix = dict[key]
			continue
		bits |= prefix << nbits
		nbits += size
		while nbits >= 8:
			res.append(bits & 0xFF)
			bits >>= 8
			nbits -= 8
		if next < 4096:
			dict[key] = next
			next += 1
			if next > (1 << size) and size < 12:
				size += 1
		else:
			bits |= clear << nbits
			nbits += size
			while nbits >= 8:
				res.append(bits & 0xFF)
				bits >>= 8
				nbits -= 8
			dict.clear()
			size = 9
			next = 258
		prefix = c
	bits |= prefix << nbits
	nbits += size
	bits |= stop << nbits
	nbits += size
	while nbits > 0:
		res.append(bits & 0xFF)
		bits >>= 8
		nbits -= 8
	return res


func _u16(v: int) -> void:
	_out.append(v & 0xFF)
	_out.append((v >> 8) & 0xFF)
