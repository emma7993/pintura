shader_type canvas_item;
uniform float paper_mix : hint_range(0.0, 1.0) = 0.0;
uniform float reveal : hint_range(0.0, 1.0) = 1.0;
void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 graphite = vec3(gray * 0.99, gray * 0.985, gray * 0.96);
	vec3 paper = mix(vec3(0.92, 0.90, 0.85), tex.rgb, 0.26);
	COLOR *= vec4(mix(graphite, paper, paper_mix), tex.a * step(UV.x, reveal));
}
