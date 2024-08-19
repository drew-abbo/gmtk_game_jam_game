shader_type canvas_item;

uniform float black_amount : hint_range(0.0, 1.0) = 0.0;

// make the screen face in from black (2 sec)
void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	COLOR = vec4(pixel_color.r, pixel_color.g, pixel_color.b, black_amount);
}
