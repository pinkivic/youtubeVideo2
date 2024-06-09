shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;
uniform sampler2D normal_texture : source_color, hint_normal_roughness_texture, filter_nearest;

uniform sampler2D hatching_texture : repeat_enable;
uniform float hatching_size = 1.0;

uniform float depth_treshold : hint_range(0.0, 1.0) = 0.05;
uniform float lineThickness = 1.3;

varying mat4 CAMERA;


float get_depth(vec2 screen_uv, mat4 inv_projection_matrix)
{
	float depth = texture(depth_texture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= -view.w;
	return view.z;
}

vec3 get_normal(vec2 screen_uv)
{
	return texture(normal_texture, screen_uv).rgb * 2.0 - 1.0;
}

float get_roughness(vec2 screen_uv)
{
	return texture(normal_texture, screen_uv).a * 2.0 - 1.0;
}

vec3 get_worldPosition(vec2 screen_uv, mat4 inv_projection_matrix, mat4 camera){
	float depth = texture(depth_texture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 world = camera * inv_projection_matrix * vec4(ndc, 1.0);
	return world.xyz / world.w;
}

float transform_value(float value) {
    if (value >= 0.1) {
        return 1.0;
    } else {
        return value;
    }
}

void vertex()
{
	POSITION = vec4(VERTEX, 1.0);
	CAMERA = INV_VIEW_MATRIX;
}

void fragment() {
	// SCREEN TEXTURE
	vec3 original = texture(screen_texture, SCREEN_UV).rgb;
	
	// NORMALS
	vec3 normal = get_normal(SCREEN_UV);
	
	// ROUGHNESS
	float roughness = get_roughness(SCREEN_UV);
	
	// DEPTH
	float depth = get_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
	
	// WORLD POSITION
	vec3 world_position = get_worldPosition(SCREEN_UV, INV_PROJECTION_MATRIX, CAMERA);
	
	// GET SURROUNDING TEXEL
	vec2 texel_size = 1.0 / VIEWPORT_SIZE.xy;
	vec2 uvs[4];
	uvs[0] = vec2(SCREEN_UV.x, SCREEN_UV.y + texel_size.y );// + lineThickness / VIEWPORT_SIZE.y
	uvs[1] = vec2(SCREEN_UV.x, SCREEN_UV.y - texel_size.y );// + lineThickness / VIEWPORT_SIZE.y
	uvs[2] = vec2(SCREEN_UV.x + texel_size.x, SCREEN_UV.y);
	uvs[3] = vec2(SCREEN_UV.x - texel_size.x, SCREEN_UV.y);
	
	// EDGE DETECTION
	float depth_diff = 0.0;
	float normal_sum = 0.0;
	for (int i = 0; i < 4; i++)
	{
		float d = get_depth(uvs[i], INV_PROJECTION_MATRIX);
		depth_diff += depth - d;
		
		vec3 n = get_normal(uvs[i]);
		vec3 normal_diff = normal - n;
		
		vec3 normal_edge_bias = vec3(1.0, 1.0, 1.0);
		float normal_bias_diff = dot(normal_diff, normal_edge_bias);
		float normal_indicator = smoothstep(-0.01, 0.01, normal_bias_diff);
		
		normal_sum += dot(normal_diff, normal_diff) * normal_indicator;
	}
	float depth_edge = step(depth_treshold, depth_diff);
	
	
	
	// HATCHING
	//vec2 warpedUV = vec2( world_position.y * 0.5 + world_position.x * 0.5, world_position.y * 0.5 + world_position.z * 0.5) * hatching_size + normal.xy * 0.05;
	//vec3 hetch_screen = texture(hatching_texture, warpedUV).xyz;
	vec3 hetch_effect = vec3(1.0);
	if(original.r > 0.05 && original.r < 0.65)
	{
		hetch_effect = vec3(transform_value(original.b));
	}
	else if(original.r < 0.1)
	{
		hetch_effect = vec3(transform_value(original.b) * transform_value(original.g));
	}
	if(roughness > 0.05)
	{
		hetch_effect = vec3((original.x + original.y + original.z) / 3.0);
	}
	
	// ADDING THE EDGE TO THE HETCH
	vec3 edge_mix = mix(hetch_effect, vec3(0), depth_edge + normal_sum);
	
	ALBEDO = edge_mix;
}	
	

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
