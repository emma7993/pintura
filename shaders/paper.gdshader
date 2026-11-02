shader_type canvas_item;
// Grano de papel + viñeta + ligero tinte: une la pintura con el lobo recortado.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear, repeat_disable;
uniform float grain : hint_range(0.0, 0.2) = 0.045;
uniform float vignette : hint_range(0.0, 1.0) = 0.55;
uniform vec3 tint = vec3(1.0, 0.97, 0.92);

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	vec3 col = texture(screen_tex, SCREEN_UV).rgb;
	float g = hash(floor(FRAGCOORD.xy * 0.5) + floor(TIME * 12.0)) - 0.5;
	col += g * grain;
	vec2 uv = SCREEN_UV - 0.5;
	float v = smoothstep(0.85, 0.2, length(uv * vec2(1.1, 1.0)));
	col *= mix(1.0 - vignette, 1.0, v);
	col *= tint;
	COLOR = vec4(col, 1.0);
}
