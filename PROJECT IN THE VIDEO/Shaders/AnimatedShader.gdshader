shader_type spatial;

uniform float size = 0.4;
uniform float intensity = 0.7;
uniform float frame_time = 0.17;

uniform vec3 light_direction = vec3(-0.483, 0.866, -0.129);

uniform sampler2D hatch;
uniform vec3 color: source_color;
uniform float hatch_size = 1.0;

void vertex() {
	float rounded_time = round(TIME / frame_time) * frame_time;
	
	float heightX = pow(abs(cos(VERTEX.y * size + rounded_time * 10.0)), 0.5) * intensity 
	 - pow(abs(cos(VERTEX.z * size * 0.7 + rounded_time * 5.0)), 0.5) * intensity * 1.3;          
	float heightY = pow(abs(cos(VERTEX.x * size + rounded_time * 15.0)), 0.5) * intensity 
	 - pow(abs(cos(VERTEX.z * size * 0.7 + rounded_time * 10.0)), 0.5) * intensity * 1.3;
	float heightZ = pow(abs(cos(VERTEX.y * size + rounded_time * 20.0)), 0.5) * intensity 
	 - pow(abs(cos(VERTEX.x * size * 0.7 + rounded_time * 15.0)), 0.5) * intensity * 1.3;
	VERTEX += vec3(heightX, heightY, heightZ);
}



void fragment() {
	
	float rounded_time = round(TIME / frame_time) * frame_time;
	
	mat3 view_to_world_normal_mat = mat3(
		INV_VIEW_MATRIX[0].xyz,
		INV_VIEW_MATRIX[1].xyz,
		INV_VIEW_MATRIX[2].xyz
	);
	
	float NdotL = dot(view_to_world_normal_mat * NORMAL , light_direction);
	float mask = 1.0;
	if (NdotL < 0.5) {
		mask *= texture(hatch, UV * hatch_size + rounded_time).r * 2.0 - 1.0; 
		mask = clamp(mask, 0.0, 1.0);
	} 
	if (NdotL < 0.1) {
		mask *= texture(hatch, vec2(UV.x, -UV.y) * hatch_size + rounded_time).r * 2.0 - 1.0;
		mask = clamp(mask, 0.0, 1.0); 
	} 
	ALBEDO = mix(vec3(0.0), color, mask);
}


