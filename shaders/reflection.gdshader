// Reflection + rim shader
shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_tex;
uniform float noise_pow = 2.0;
uniform float noise_scl = 0.1;
uniform float rim_pow = 4.0;
uniform float rim_str = 1.0; 

void fragment() {
    vec3 n = normalize(NORMAL);
    vec3 v = normalize(VIEW);
	
	// reflection between view and normal
	vec3 r = reflect(v, n);
	
	// sample noise (using reflection .xy)
	float noise = pow( texture(noise_tex, vec2(r.x, r.y) * noise_scl).r, noise_pow);
	
	// compute rim (using reflection .z)
	float rim = pow( clamp((r.z + 1.0) * 0.5, 0.0, 1.0), rim_pow);
	
	// output result
	ALBEDO = vec3(clamp(noise + rim * rim_str, 0.0, 1.0));
}
