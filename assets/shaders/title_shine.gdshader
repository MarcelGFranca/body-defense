// A white band of light that sweeps diagonally over the letters of the title only (drawn above a static copy).
shader_type canvas_item;

uniform float progress : hint_range(-0.5, 1.5) = -0.5;
uniform float width : hint_range(0.01, 0.5) = 0.12;
uniform vec2 box_size = vec2(720.0, 144.0);

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	float along = (local.x * 0.6 + (box_size.y - local.y) * 1.0) / (box_size.x * 0.6 + box_size.y);
	float band = smoothstep(width, 0.0, abs(along - progress));
	COLOR = vec4(1.0, 1.0, 0.92, COLOR.a * band);
}
