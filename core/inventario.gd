class_name Inventario
extends RefCounted
## Lo que el lobo lleva consigo entre zonas (dura mientras corre el juego; todavía no se guarda en disco).
## Tintero: se recoge vacío en el altar del Nivel 1 y se llena en el lago de tinta. Pintar con el pincel
## gasta tinta (la puerta y, más adelante, las peleas contra los monstruos) y hay que volver a llenarlo.

const TINTA_MAX := 100.0
const COSTO_PUERTA := 20.0
## Pensado para las peleas: con el tintero lleno alcanzan unos 8 trazos de ataque después de la puerta.
const COSTO_TRAZO := 10.0

static var pincel := false
static var tintero := false
static var tinta := 0.0


static func llenar() -> void:
	tinta = TINTA_MAX


## Descuenta la tinta si alcanza; devuelve false (sin gastar nada) si no alcanza.
static func gastar(cantidad: float) -> bool:
	if tinta < cantidad:
		return false
	tinta -= cantidad
	return true
