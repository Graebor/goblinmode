shader_type canvas_item;
//Based on: https://godotshaders.com/shader/zoom-blur-transition/

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float blur_strength : hint_range(0.0, 1.0) = 0.5;
uniform int samples : hint_range(4, 32) = 20;
uniform vec2 blur_center = vec2(0.5, 0.5);
varying vec4 modulate;
void vertex() { modulate = COLOR; }

void fragment() {
	vec2 uv = UV;
	float blur_mix = progress;
	float strength = sin(progress * PI / 2.0) * blur_strength * blur_mix;
	vec2 to_center = blur_center - uv;
	vec4 blurred = vec4(0.0);
	float total = 0.0;
	for (int i = 0; i < samples; i++) {
		float percent = float(i) / float(samples - 1);
		float weight = percent * (1.0 - percent);
		vec2 sample_uv = uv + to_center * percent * strength;
		vec4 tex = texture(TEXTURE, sample_uv) * modulate;
		tex.a = (1.0 - progress * progress * progress) * tex.a;
		blurred += tex * weight;
		total += weight;
	}
	blurred /= max(total, 0.0001);
	COLOR = blurred;
}