// A band of light that sweeps diagonally over a picture, lighting only its visible pixels (the glint of the logo).
shader_type canvas_item;

uniform float progress : hint_range(-0.5, 1.5) = -0.5;
uniform float width : hint_range(0.01, 0.5) = 0.16;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float along = (UV.x * 0.6 + (1.0 - UV.y) * 1.0) / 1.6;
	float band = smoothstep(width, 0.0, abs(along - progress));
	COLOR = vec4(base.rgb + vec3(band * 0.95), base.a);
}
