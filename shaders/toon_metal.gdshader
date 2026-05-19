// Shader Toon with Specular
shader_type spatial;

uniform vec4 base_color : source_color = vec4(1.0);
uniform sampler2D color_ramp : source_color, repeat_disable, filter_nearest;

uniform vec3 specular_color : source_color = vec3(1.0);
uniform float specular_size : hint_range(1.0, 256.0) = 8.0;
uniform float specular_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float specular_strength : hint_range(0.0, 4.0) = 1.0;

uniform sampler2D noise_tex;
uniform float noise_pow = 2.0;
uniform float noise_scl = 0.1;
uniform float rim_pow = 4.0;
uniform float rim_str = 1.0; 

void fragment() {
    ALBEDO = base_color.rgb;
    METALLIC = 0.0;
	ROUGHNESS = 1.0;	
    AO = 0.0;
}

void light() {
    vec3 n = normalize(NORMAL);
    vec3 l = normalize(LIGHT);
    vec3 v = normalize(VIEW);

    // toon diffuse (half lambert)
    float ndotl = (dot(n, l) + 1.0) * 0.5;
	
	// diffuse + attenuation
	float difsdw = ndotl * ATTENUATION;
	
	// reflection between view and normal
	vec3 r = reflect(v, n);
	
	// sample noise (using reflection .xy)
	float noise = pow( texture(noise_tex, vec2(r.x, r.y) * noise_scl).r, noise_pow);
	
	// compute rim (using reflection .z)
	float rim = pow( clamp((r.z + 1.0) * 0.5, 0.0, 1.0), rim_pow);	
	
	// rim + reflection
	float rim_and_reflection = clamp(noise + rim * rim_str, 0.0, 1.0);
	
	// diffuse + shadow + rim + reflection
	float final_diffuse = difsdw * rim_and_reflection;

	// get color form color ramp
    vec3 toon = texture(
        color_ramp,
        vec2(final_diffuse, 0.5)
    ).rgb;

    // half vector 
    vec3 h = normalize(v + l);

	// specular
    float spec = pow(
        max(dot(n, h), 0.0),
        specular_size
    );

	// sharp specular
    spec = step(specular_threshold, spec);

	// output diffuse and specular
    DIFFUSE_LIGHT =  toon;
    SPECULAR_LIGHT = (
        specular_color *
        spec *
        specular_strength *
        ATTENUATION
    );
	
}
