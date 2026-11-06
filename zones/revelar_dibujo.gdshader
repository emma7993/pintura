shader_type canvas_item;
// Revela una capa como si se dibujara: un frente irregular que sale de «centro» (px de pantalla) y crece con
// «radio». Junto al frente el trazo aparece más oscuro (grafito recién puesto) y se asienta detrás.
// invertir = true hace lo contrario (la capa se borra al pasar el frente): para el boceto que se va.
// También funde los bordes izquierdo y derecho (capas que se repiten).
uniform vec2 centro = vec2(640.0, 360.0);
uniform float radio = 0.0;
uniform float suave = 140.0;
uniform bool invertir = false;
uniform float borde = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 px = SCREEN_UV / SCREEN_PIXEL_SIZE;
	float n = ruido(px / 70.0) * 0.65 + ruido(px / 13.0) * 0.35;
	float d = distance(px, centro) + (n - 0.5) * suave * 1.6;
	float k = 1.0 - smoothstep(radio - suave, radio, d);   // 1 = ya dibujado
	if (invertir) {
		COLOR.a *= 1.0 - k;
	} else {
		float frente = smoothstep(radio - suave, radio - suave * 0.35, d) * k;
		COLOR.rgb *= 1.0 - frente * 0.35;
		COLOR.a *= k;
	}
	if (borde > 0.0) {
		float b = min(UV.x, 1.0 - UV.x) / borde;
		COLOR.a *= pow(clamp(b, 0.0, 1.0), 1.5);
	}
}
