shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 tint : source_color;
uniform float blur = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float blur_strength = blur / 100.0;
	vec3 blurred_color = vec3(0.0);
	int sample_count = 0;
	for(float x = -blur_strength; x <= blur_strength; x += blur_strength / 10.0){
		for(float y = -blur_strength; y <= blur_strength; y+= blur_strength / 10.0) {
			blurred_color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(x,y)).rgb;
			sample_count++;
		}	
	}
	
	blurred_color /= float(sample_count);
	ALBEDO = blurred_color * tint.rgb;
	ALPHA = tint.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
