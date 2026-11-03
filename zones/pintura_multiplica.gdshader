shader_type canvas_item;
render_mode blend_mul;
// Capa de color "encima del lienzo": multiplica los fondos y el grafito por óleo donde el pincel pintó,
// así las líneas del boceto siguen viéndose a través del color (como pintar sobre el dibujo).
// paint_mask es la misma máscara de mundo que usa oleo_revelado.gdshader.

uniform sampler2D paint_mask : filter_linear, repeat_disable;
uniform sampler2D oil : filter_linear, repeat_enable;
uniform vec4 mask_rect;            // x, y, ancho, alto de la máscara en px de mundo
uniform float strength = 0.9;
uniform float oil_scale = 420.0;   // px de mundo por repetición de la textura de óleo
uniform float angle = 0.5236;      // giro de las vetas del óleo para que sigan el trazo

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float m = smoothstep(0.08, 0.6, texture(paint_mask, (world_pos - mask_rect.xy) / mask_rect.zw).r);
	vec2 p = world_pos / oil_scale;
	float c = cos(angle);
	float s = sin(angle);
	p = vec2(c * p.x + s * p.y, -s * p.x + c * p.y);
	vec2 q = abs(fract(p * 0.5) * 2.0 - 1.0);        // repetición en espejo: sin costuras duras
	vec4 o = texture(oil, vec2(0.12, 0.10) + q * vec2(0.76, 0.80));
	COLOR = vec4(mix(vec3(1.0), o.rgb, m * strength * o.a), 1.0);
}
