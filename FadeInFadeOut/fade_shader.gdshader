shader_type canvas_item;

uniform float black_amount : hint_range(0.0, 1.0) = 0.0;

// make the screen face in from black (2 sec)
void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	COLOR = vec4(pixelColor.r, pixelColor.g, pixelColor.b, black_amount);
}
