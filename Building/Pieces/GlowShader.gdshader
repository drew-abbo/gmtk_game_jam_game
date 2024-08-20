shader_type canvas_item;

uniform bool do_glow = true;

void fragment() {
	if (do_glow) {
		vec4 pixel_color = texture(TEXTURE, UV);
		float glow_intensity = 0.1 * (sin(1.0 * TIME * PI) + 1.0) + 0.05;
		pixel_color += vec4(glow_intensity, glow_intensity, glow_intensity, 0);
		COLOR = vec4(pixel_color.r, pixel_color.g, pixel_color.b, pixel_color.a);
	}
}
