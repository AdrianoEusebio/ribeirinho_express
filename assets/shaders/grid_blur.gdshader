shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_radius : hint_range(0.5, 10.0) = 3.0;
uniform float darkness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 texel = vec2(1.0) / vec2(textureSize(screen_texture, 0));
	vec4 color = vec4(0.0);

	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			color += texture(screen_texture, SCREEN_UV + vec2(float(x), float(y)) * texel * blur_radius);
		}
	}
	color /= 25.0;
	color.rgb *= (1.0 - darkness);
	COLOR = color;
}
