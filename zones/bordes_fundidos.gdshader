shader_type canvas_item;
// Funde los bordes izquierdo y derecho de una capa de fondo para que no se vea un corte donde se repite
// (las capas de nivel_01_fondos_v002 no son continuas). borde = fracción del ancho que se funde en cada lado.
uniform float borde = 0.12;

void fragment() {
	float k = min(UV.x, 1.0 - UV.x) / borde;
	COLOR.a *= pow(clamp(k, 0.0, 1.0), 1.5);
}
