// Dyes a marked enemy with the color of the lymphocyte that marked it, keeping the shading of the sprite.
shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.78, 0.5, 0.9, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// COLOR already holds the sprite pixel times its modulate.
	float light = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
	vec3 dyed = tint.rgb * (0.55 + 0.75 * light);
	COLOR.rgb = mix(COLOR.rgb, dyed, amount * 0.8);
}
