class_name Inventario
extends RefCounted
## Lo que el lobo lleva consigo y lo que ya resolvió. Se guarda en user://partida.cfg al cambiar y se
## carga una vez al empezar (cargar()). En Windows queda en %APPDATA%/Godot/app_userdata/<proyecto>/,
## en Mac en ~/Library/Application Support/Godot/app_userdata/<proyecto>/.
## Tintero: se recoge vacío en el altar del Nivel 1 y se llena en el lago de tinta. Pintar con el pincel
## gasta tinta (la puerta y, más adelante, las peleas contra los monstruos) y hay que volver a llenarlo.

const ARCHIVO := "user://partida.cfg"
const TINTA_MAX := 100.0
const COSTO_PUERTA := 20.0
## Pensado para las peleas: con el tintero lleno alcanzan unos 8 trazos de ataque después de la puerta.
const COSTO_TRAZO := 10.0
## Cada mano de sombra que el pincel deshace con un tajo.
const COSTO_GOLPE := 5.0

static var pincel := false
static var tintero := false
static var tinta := 0.0
## Marcas de lo ya resuelto, p. ej. "n1_sombras", "n1_puerta"; también valores como "n1_trazo_x".
static var progreso := {}
## Atajo de prueba pendiente (teclas 1–5 en el Nivel 1); -1 = ninguno. No se guarda.
static var atajo := -1
static var _cargado := false


static func cargar() -> void:
	if _cargado:
		return
	_cargado = true
	var c := ConfigFile.new()
	if c.load(ARCHIVO) != OK:
		return
	pincel = c.get_value("inventario", "pincel", false)
	tintero = c.get_value("inventario", "tintero", false)
	tinta = c.get_value("inventario", "tinta", 0.0)
	progreso = c.get_value("progreso", "marcas", {})


static func guardar() -> void:
	var c := ConfigFile.new()
	c.set_value("inventario", "pincel", pincel)
	c.set_value("inventario", "tintero", tintero)
	c.set_value("inventario", "tinta", tinta)
	c.set_value("progreso", "marcas", progreso)
	c.save(ARCHIVO)


## Borra la partida: vuelve a empezar desde cero.
static func reiniciar() -> void:
	_cargado = true
	pincel = false
	tintero = false
	tinta = 0.0
	progreso = {}
	guardar()


static func marcar(clave: String, valor: Variant = true) -> void:
	progreso[clave] = valor
	guardar()


static func hecho(clave: String) -> bool:
	return progreso.get(clave, false) != false


static func llenar() -> void:
	tinta = TINTA_MAX
	guardar()


## Descuenta la tinta si alcanza; devuelve false (sin gastar nada) si no alcanza.
static func gastar(cantidad: float) -> bool:
	if tinta < cantidad:
		return false
	tinta -= cantidad
	guardar()
	return true
