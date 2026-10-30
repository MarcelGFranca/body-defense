// A band of light that sweeps diagonally over the round part of a picture only (the globe of the logo).
shader_type canvas_item;

uniform float progress : hint_range(-0.5, 1.5) = -0.5;
uniform float width : hint_range(0.01, 0.5) = 0.14;
uniform float globe_radius = 0.26;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float along = (UV.x * 0.6 + (1.0 - UV.y) * 1.0) / 1.6;
	float band = smoothstep(width, 0.0, abs(along - progress));
	float inside = 1.0 - smoothstep(globe_radius - 0.02, globe_radius, length(UV - vec2(0.5)));
	COLOR = vec4(base.rgb + vec3(band * inside * 0.9), base.a);
}
