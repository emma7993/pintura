shader_type canvas_item;
// Óleo debajo del grafito: se ve solo donde el pincel ya pintó.
// paint_mask es una imagen en coordenadas de mundo (zones/nivel_01_camino.gd la va estampando con max()).

uniform sampler2D paint_mask : filter_linear, repeat_disable;
uniform vec4 mask_rect;   // x, y, ancho, alto de la máscara en px de mundo

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float m = texture(paint_mask, (world_pos - mask_rect.xy) / mask_rect.zw).r;
	vec4 c = texture(TEXTURE, UV);
	COLOR = vec4(c.rgb, c.a * smoothstep(0.08, 0.55, m)) * COLOR;
}
