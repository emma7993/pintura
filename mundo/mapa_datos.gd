class_name MapaDatos
extends RefCounted
## El mapa completo del juego como datos (según docs/diseno/Diseno_Metroidvania_Immix.md, sección 6, y sus
## esquemas por zona). Cada sala ocupa una celda de la cuadrícula de su zona; las salas vecinas que el
## esquema une se conectan por dentro (puerta lateral o hueco en el piso/techo). Las puertas del hub y los
## atajos entre zonas son portales (como las transiciones entre áreas).
## Cambiar aquí el mapa cambia el mundo explorable (mundo/mundo.gd) y el mapa en pantalla (M).

## Zonas: nombre, color en el mapa, celda de su esquina superior izquierda en el mundo.
const ZONAS := {
	"pintura": {"nombre": "La Pintura", "color": Color(0.85, 0.80, 0.66), "origen": Vector2i(0, 0)},
	"camino": {"nombre": "Camino", "color": Color(0.55, 0.62, 0.48), "origen": Vector2i(-2, -4)},
	"sueno": {"nombre": "Un sueño y muchos momentos", "color": Color(0.86, 0.78, 0.40), "origen": Vector2i(-8, -1)},
	"cambio": {"nombre": "Cambio", "color": Color(0.30, 0.58, 0.62), "origen": Vector2i(3, 3)},
	"miedo": {"nombre": "Miedo", "color": Color(0.72, 0.30, 0.36), "origen": Vector2i(4, -1)},
	"final": {"nombre": "Al final", "color": Color(0.88, 0.58, 0.42), "origen": Vector2i(-8, 3)},
}

## Salas: id único, zona, columna y fila dentro de la zona, nombre, nota y tipo.
## tipo: "normal", "clave" (hub u objeto clave), "jefe", "cerrada" (empieza cerrada; "req" dice con qué
## se abre). banca = punto de control. enemigos = letras del esquema (M, U, S, B).
const SALAS := [
	# --- La Pintura (hub) ---
	{"id": "pintura", "zona": "pintura", "c": 0, "f": 0, "nombre": "La Pintura", "nota": "Centro del mapa: cada puerta se pinta aquí", "tipo": "clave", "banca": true, "ancho": 2},
	# --- Camino ---
	{"id": "ca_despertar", "zona": "camino", "c": 0, "f": 0, "nombre": "Despertar", "nota": "Miedo y sombras", "tipo": "normal"},
	{"id": "ca_barranco", "zona": "camino", "c": 1, "f": 0, "nombre": "Barranco", "nota": "Correr y saltar", "tipo": "normal"},
	{"id": "ca_altar", "zona": "camino", "c": 2, "f": 0, "nombre": "Altar del pincel", "nota": "Pincel y escudo", "tipo": "clave"},
	{"id": "ca_arco", "zona": "camino", "c": 3, "f": 0, "nombre": "Arco dañado", "nota": "Puerta al cuadro", "tipo": "clave", "enemigos": "U"},
	{"id": "ca_sello", "zona": "camino", "c": 4, "f": 0, "nombre": "Sello musical", "nota": "Melodía 1", "tipo": "cerrada", "req": "Melodía 1 (Un sueño)", "enemigos": "S · B"},
	{"id": "ca_a_sueno", "zona": "camino", "c": 0, "f": 1, "nombre": "A Un sueño", "nota": "Atajo", "tipo": "cerrada", "req": "Atajo: melodía del sello"},
	{"id": "ca_paleta", "zona": "camino", "c": 1, "f": 1, "nombre": "Cueva de la paleta", "nota": "Paleta de colores", "tipo": "clave", "enemigos": "M"},
	{"id": "ca_cueva", "zona": "camino", "c": 2, "f": 1, "nombre": "Entrada a la cueva", "nota": "Junto al altar", "tipo": "normal", "enemigos": "M"},
	{"id": "ca_copista", "zona": "camino", "c": 3, "f": 1, "nombre": "Taller del copista", "nota": "Vendedor", "tipo": "normal"},
	{"id": "ca_descanso", "zona": "camino", "c": 4, "f": 1, "nombre": "Zona de descanso", "nota": "Cascada de pintura", "tipo": "normal", "banca": true},
	{"id": "ca_a_miedo", "zona": "camino", "c": 0, "f": 2, "nombre": "A Miedo", "nota": "Atajo", "tipo": "cerrada", "req": "Atajo: pintar rojo en el acantilado"},
	{"id": "ca_enemigos", "zona": "camino", "c": 1, "f": 2, "nombre": "Zona de enemigos", "nota": "Aprende a atacar", "tipo": "normal", "enemigos": "M"},
	{"id": "ca_cascada", "zona": "camino", "c": 2, "f": 2, "nombre": "Cascada", "nota": "Primer descanso", "tipo": "normal", "banca": true},
	{"id": "ca_pozo", "zona": "camino", "c": 3, "f": 2, "nombre": "Pozo bloqueado", "nota": "Se abre atacando", "tipo": "cerrada", "req": "Golpear con el pincel"},
	{"id": "ca_jefe", "zona": "camino", "c": 4, "f": 2, "nombre": "Sala del jefe", "nota": "Jefe de Camino · da el blanco y el dash", "tipo": "jefe"},
	# --- Un sueño y muchos momentos ---
	{"id": "su_a_camino", "zona": "sueno", "c": 0, "f": 0, "nombre": "A Camino", "nota": "Atajo", "tipo": "cerrada", "req": "Atajo: melodía del sello"},
	{"id": "su_raices", "zona": "sueno", "c": 1, "f": 0, "nombre": "Raíces flotantes", "nota": "Enemigos Raíz", "tipo": "normal"},
	{"id": "su_arbol", "zona": "sueno", "c": 2, "f": 0, "nombre": "Árbol del sueño", "nota": "Puzzle de notas", "tipo": "normal"},
	{"id": "su_boveda", "zona": "sueno", "c": 3, "f": 0, "nombre": "Bóveda lejana", "nota": "Requiere el arco", "tipo": "cerrada", "req": "El arco"},
	{"id": "su_umbral", "zona": "sueno", "c": 0, "f": 1, "nombre": "Umbral", "nota": "Desde La Pintura", "tipo": "normal", "banca": true},
	{"id": "su_claro", "zona": "sueno", "c": 1, "f": 1, "nombre": "Claro de luz", "nota": "Primeras notas", "tipo": "normal"},
	{"id": "su_burbujas", "zona": "sueno", "c": 2, "f": 1, "nombre": "Burbujas", "nota": "Plataformas móviles", "tipo": "normal"},
	{"id": "su_cascada", "zona": "sueno", "c": 3, "f": 1, "nombre": "Cascada amarilla", "nota": "Color amarillo", "tipo": "clave", "banca": true},
	{"id": "su_jefe", "zona": "sueno", "c": 4, "f": 1, "nombre": "Sala del jefe", "nota": "Jefe de Un sueño", "tipo": "jefe"},
	{"id": "su_a_final", "zona": "sueno", "c": 0, "f": 2, "nombre": "A Al final", "nota": "Atajo · pared", "tipo": "cerrada", "req": "Atajo: agarre de pared"},
	{"id": "su_orilla", "zona": "sueno", "c": 1, "f": 2, "nombre": "Orilla onírica", "nota": "Recuerdos flotantes", "tipo": "normal"},
	{"id": "su_arpa", "zona": "sueno", "c": 2, "f": 2, "nombre": "Arpa rota", "nota": "Cuerdas y arco", "tipo": "clave"},
	{"id": "su_ecos", "zona": "sueno", "c": 3, "f": 2, "nombre": "Cueva de ecos", "nota": "Nota extra", "tipo": "normal"},
	# --- Cambio ---
	{"id": "cb_pozo", "zona": "cambio", "c": 1, "f": 0, "nombre": "Pozo de entrada", "nota": "Desde La Pintura", "tipo": "normal"},
	{"id": "cb_a_final", "zona": "cambio", "c": 0, "f": 1, "nombre": "A Al final", "nota": "Atajo · corrientes", "tipo": "cerrada", "req": "Atajo: planeo con bufanda"},
	{"id": "cb_borde", "zona": "cambio", "c": 1, "f": 1, "nombre": "Borde del bosque", "nota": "Corrientes", "tipo": "normal"},
	{"id": "cb_a_miedo", "zona": "cambio", "c": 3, "f": 1, "nombre": "A Miedo", "nota": "Atajo · bote", "tipo": "cerrada", "req": "Atajo: bote y melodía"},
	{"id": "cb_coral", "zona": "cambio", "c": 0, "f": 2, "nombre": "Claro de coral", "nota": "Herrero", "tipo": "normal"},
	{"id": "cb_raices", "zona": "cambio", "c": 1, "f": 2, "nombre": "Raíces hundidas", "nota": "Algas cortantes", "tipo": "normal"},
	{"id": "cb_cardumen", "zona": "cambio", "c": 2, "f": 2, "nombre": "Cardumen", "nota": "Peces de corriente", "tipo": "normal"},
	{"id": "cb_jefe", "zona": "cambio", "c": 3, "f": 2, "nombre": "Sala del jefe", "nota": "Jefe de Cambio", "tipo": "jefe"},
	{"id": "cb_fondo", "zona": "cambio", "c": 1, "f": 3, "nombre": "Fondo oscuro", "nota": "Corrientes fuertes", "tipo": "normal", "banca": true},
	{"id": "cb_violin", "zona": "cambio", "c": 2, "f": 3, "nombre": "Violín roto", "nota": "Cuerdas y notas", "tipo": "clave"},
	{"id": "cb_cascada", "zona": "cambio", "c": 3, "f": 3, "nombre": "Cascada azul", "nota": "Color azul", "tipo": "clave", "banca": true},
	# --- Miedo ---
	{"id": "mi_faro", "zona": "miedo", "c": 1, "f": 0, "nombre": "Faro", "nota": "Puzzle de luz", "tipo": "normal"},
	{"id": "mi_acantilado", "zona": "miedo", "c": 3, "f": 0, "nombre": "Acantilado", "nota": "Viento y arco", "tipo": "normal"},
	{"id": "mi_a_camino", "zona": "miedo", "c": 4, "f": 0, "nombre": "A Camino", "nota": "Atajo · pintar rojo", "tipo": "cerrada", "req": "Atajo: pintar rojo"},
	{"id": "mi_muelle", "zona": "miedo", "c": 0, "f": 1, "nombre": "Muelle", "nota": "Desde La Pintura", "tipo": "normal", "banca": true},
	{"id": "mi_mar", "zona": "miedo", "c": 1, "f": 1, "nombre": "Mar embravecido", "nota": "Calmar con melodía", "tipo": "normal"},
	{"id": "mi_medusa", "zona": "miedo", "c": 2, "f": 1, "nombre": "Isla Medusa", "nota": "Medusas de sombra", "tipo": "normal"},
	{"id": "mi_roja", "zona": "miedo", "c": 3, "f": 1, "nombre": "Pintura roja", "nota": "Color rojo", "tipo": "clave"},
	{"id": "mi_a_cambio", "zona": "miedo", "c": 0, "f": 2, "nombre": "A Cambio", "nota": "Atajo · bote", "tipo": "cerrada", "req": "Atajo: bote"},
	{"id": "mi_arrecife", "zona": "miedo", "c": 1, "f": 2, "nombre": "Arrecife", "nota": "Marejadas y escudo", "tipo": "normal"},
	{"id": "mi_cueva", "zona": "miedo", "c": 2, "f": 2, "nombre": "Cueva marina", "nota": "Fuente de pigmento", "tipo": "normal"},
	{"id": "mi_descanso", "zona": "miedo", "c": 3, "f": 2, "nombre": "Zona de descanso", "nota": "Cascada de pintura", "tipo": "normal", "banca": true},
	{"id": "mi_jefe", "zona": "miedo", "c": 4, "f": 2, "nombre": "Sala del jefe", "nota": "Exige escudo máximo", "tipo": "jefe"},
	# --- Al final ---
	{"id": "fi_a_sueno", "zona": "final", "c": 0, "f": 0, "nombre": "A Un sueño", "nota": "Atajo · pared", "tipo": "cerrada", "req": "Atajo: agarre de pared"},
	{"id": "fi_goma", "zona": "final", "c": 1, "f": 0, "nombre": "Goma arábiga", "nota": "Agarre de pared", "tipo": "clave"},
	{"id": "fi_muros", "zona": "final", "c": 2, "f": 0, "nombre": "Muros altos", "nota": "Requiere agarre", "tipo": "cerrada", "req": "Agarre de pared"},
	{"id": "fi_arpas", "zona": "final", "c": 3, "f": 0, "nombre": "Cima de arpas", "nota": "Notas y arco", "tipo": "normal"},
	{"id": "fi_entrada", "zona": "final", "c": 0, "f": 1, "nombre": "Entrada", "nota": "Desde La Pintura", "tipo": "normal", "banca": true},
	{"id": "fi_bocetos", "zona": "final", "c": 1, "f": 1, "nombre": "Sala de bocetos", "nota": "Tinta negra", "tipo": "normal"},
	{"id": "fi_canon", "zona": "final", "c": 2, "f": 1, "nombre": "Cañón de viento", "nota": "Viento y dash", "tipo": "normal"},
	{"id": "fi_olas", "zona": "final", "c": 3, "f": 1, "nombre": "Sala de olas", "nota": "Música y escudo", "tipo": "normal"},
	{"id": "fi_a_cambio", "zona": "final", "c": 0, "f": 2, "nombre": "A Cambio", "nota": "Atajo", "tipo": "cerrada", "req": "Atajo: planeo"},
	{"id": "fi_paleta", "zona": "final", "c": 2, "f": 2, "nombre": "Sala de paleta", "nota": "Probar colores", "tipo": "normal", "banca": true},
	{"id": "fi_descanso", "zona": "final", "c": 3, "f": 2, "nombre": "Zona de descanso", "nota": "Cascada de pintura", "tipo": "normal", "banca": true},
	{"id": "fi_arena", "zona": "final", "c": 4, "f": 2, "nombre": "Arena final", "nota": "Jefe final", "tipo": "jefe"},
]

## Conexiones por dentro de cada zona (salas vecinas en la cuadrícula), tal como las unen los esquemas.
const CONEXIONES := [
	# Camino
	["ca_despertar", "ca_barranco"], ["ca_barranco", "ca_altar"], ["ca_altar", "ca_arco"], ["ca_arco", "ca_sello"],
	["ca_altar", "ca_cueva"], ["ca_arco", "ca_copista"], ["ca_sello", "ca_descanso"],
	["ca_a_sueno", "ca_paleta"], ["ca_paleta", "ca_cueva"], ["ca_paleta", "ca_enemigos"],
	["ca_a_miedo", "ca_enemigos"], ["ca_enemigos", "ca_cascada"], ["ca_cascada", "ca_pozo"],
	["ca_copista", "ca_pozo"], ["ca_descanso", "ca_jefe"],
	# Un sueño
	["su_a_camino", "su_umbral"], ["su_umbral", "su_a_final"], ["su_umbral", "su_claro"], ["su_claro", "su_burbujas"],
	["su_burbujas", "su_cascada"], ["su_cascada", "su_jefe"], ["su_raices", "su_claro"], ["su_raices", "su_arbol"],
	["su_arbol", "su_boveda"], ["su_boveda", "su_cascada"], ["su_claro", "su_orilla"], ["su_orilla", "su_arpa"],
	["su_arpa", "su_burbujas"], ["su_arpa", "su_ecos"], ["su_ecos", "su_cascada"],
	# Cambio
	["cb_pozo", "cb_borde"], ["cb_a_final", "cb_borde"], ["cb_a_final", "cb_coral"], ["cb_borde", "cb_raices"],
	["cb_coral", "cb_raices"], ["cb_raices", "cb_cardumen"], ["cb_raices", "cb_fondo"], ["cb_cardumen", "cb_violin"],
	["cb_fondo", "cb_violin"], ["cb_violin", "cb_cascada"], ["cb_cascada", "cb_jefe"], ["cb_jefe", "cb_a_miedo"],
	# Miedo
	["mi_faro", "mi_mar"], ["mi_acantilado", "mi_a_camino"], ["mi_acantilado", "mi_roja"], ["mi_muelle", "mi_mar"],
	["mi_mar", "mi_medusa"], ["mi_medusa", "mi_roja"], ["mi_muelle", "mi_a_cambio"], ["mi_mar", "mi_arrecife"],
	["mi_medusa", "mi_cueva"], ["mi_arrecife", "mi_cueva"], ["mi_cueva", "mi_descanso"], ["mi_descanso", "mi_jefe"],
	["mi_roja", "mi_descanso"],
	# Al final
	["fi_a_sueno", "fi_entrada"], ["fi_goma", "fi_muros"], ["fi_muros", "fi_arpas"], ["fi_goma", "fi_bocetos"],
	["fi_arpas", "fi_olas"], ["fi_entrada", "fi_bocetos"], ["fi_bocetos", "fi_canon"], ["fi_canon", "fi_olas"],
	["fi_entrada", "fi_a_cambio"], ["fi_canon", "fi_paleta"], ["fi_olas", "fi_descanso"], ["fi_paleta", "fi_descanso"],
	["fi_descanso", "fi_arena"],
]

## Portales: puertas del hub y atajos entre zonas. [sala A, sala B, rótulo, con qué se abre]
const PORTALES := [
	["pintura", "ca_arco", "Camino", "Primera puerta, siempre abierta"],
	["pintura", "su_umbral", "Un sueño y muchos momentos", "Pintar la puerta con el negro"],
	["pintura", "cb_pozo", "Cambio", "Blanco: dash, viento y descenso"],
	["pintura", "mi_muelle", "Miedo", "Melodía de las olas y bote"],
	["pintura", "fi_entrada", "Al final", "La Pintura completa y la melodía final"],
	["ca_a_sueno", "su_a_camino", "Atajo Camino · Un sueño", "Melodía del sello"],
	["ca_a_miedo", "mi_a_camino", "Atajo Camino · Miedo", "Pintura roja en el acantilado"],
	["su_a_final", "fi_a_sueno", "Atajo Un sueño · Al final", "Agarre de pared"],
	["cb_a_final", "fi_a_cambio", "Atajo Cambio · Al final", "Planeo con bufanda"],
	["cb_a_miedo", "mi_a_cambio", "Atajo Cambio · Miedo", "Bote y melodía de las olas"],
]

const INICIO := "ca_despertar"

## Tamaño de una celda de la cuadrícula (una sala) en px de mundo.
const CW := 1920.0
const CH := 1080.0

## Salas de Camino que ya son el Nivel 1 jugable (zones/nivel_01_camino.gd): el mundo en bloques no las
## arma; al entrar en ellas se pasa al Nivel 1.
const NIVEL1 := ["ca_despertar", "ca_barranco", "ca_altar", "ca_arco", "ca_cueva", "ca_cascada", "ca_pozo"]


static func sala(id: String) -> Dictionary:
	for d in SALAS:
		if d.id == id:
			return d
	return {}


## Rectángulo de la sala en la cuadrícula del mundo.
static func rect(id: String) -> Rect2:
	var d := sala(id)
	var cell: Vector2i = ZONAS[d.zona].origen + Vector2i(d.c, d.f)
	return Rect2(cell.x * CW, cell.y * CH, CW * float(d.get("ancho", 1)), CH)


## Tramos del Nivel 1 (x en px del nivel) que corresponden a cada sala, arriba y en la cueva.
const NIVEL1_TRAMOS := [
	# [sala, x desde, x hasta, en la cueva]
	["ca_despertar", -200.0, 2600.0, false], ["ca_barranco", 2600.0, 4300.0, false],
	["ca_altar", 4300.0, 5300.0, false], ["ca_arco", 5300.0, 10200.0, false],
	["ca_cascada", 4600.0, 5800.0, true], ["ca_pozo", 5800.0, 6200.0, true], ["ca_cueva", 6200.0, 9200.0, true],
]


## Sala del mapa en la que está el lobo dentro del Nivel 1 (la cueva empieza bajo y = 800).
static func nivel1_sala(p: Vector2) -> String:
	return String(_nivel1_tramo(p)[0])


## Punto del mapa que corresponde a una posición del Nivel 1.
static func nivel1_mapa(p: Vector2) -> Vector2:
	var t := _nivel1_tramo(p)
	var r := rect(t[0])
	var k := clampf((p.x - float(t[1])) / (float(t[2]) - float(t[1])), 0.05, 0.95)
	return Vector2(r.position.x + r.size.x * k, r.position.y + r.size.y * 0.8)


static func _nivel1_tramo(p: Vector2) -> Array:
	var cave := p.y > 800.0
	for t in NIVEL1_TRAMOS:
		if t[3] == cave and p.x >= t[1] and p.x < t[2]:
			return t
	return NIVEL1_TRAMOS[6] if cave else NIVEL1_TRAMOS[3]
