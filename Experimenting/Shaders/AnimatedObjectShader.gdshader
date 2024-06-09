shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,specular_schlick_ggx, diffuse_toon;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_linear_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_linear_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

group_uniforms MangaEffect;
uniform float frame_time = 0.17;
uniform float intensity: hint_range(0.0, 2.0, 0.1) = 1.2 ;
uniform float size: hint_range(0.0, 2.0, 0.1) = 0.4 ;
uniform sampler2D hatch1: repeat_enable;
uniform float texture_size = 1.0;
group_uniforms;


void vertex() {
	float rounded_time = round(TIME/frame_time) * frame_time;
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
float heightX = pow(abs(cos(VERTEX.y * size + rounded_time * 20.0)), 0.5) * intensity -
                pow(abs(sin(VERTEX.x * size * 0.4 + rounded_time * 10.0)), 0.5) * intensity * 0.4;
float heightY = pow(abs(cos(VERTEX.z * size * 0.8 + rounded_time * 20.0)), 0.5) * intensity * 0.8 -
                pow(abs(sin(VERTEX.y * size * 0.6 + rounded_time * 15.0)), 0.5) * intensity * 0.6;
float heightZ = pow(abs(cos(VERTEX.x * size * 1.1 + rounded_time * 25.0)), 0.5) * intensity * 1.1 -
                pow(abs(sin(VERTEX.z * size * 0.5 + rounded_time * 5.0)), 0.5) * intensity * 0.5;
VERTEX += vec3(heightX, heightY, heightZ);

}






void fragment() {
	float rounded_time = round(TIME/frame_time) * frame_time;
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = 0.0;
	SPECULAR = specular;
	
	ALBEDO = vec3(0.5, texture(hatch1,UV * texture_size + rounded_time * 5.0).x * 2.0 - 1.0,
				 texture(hatch1,vec2(UV.x, -UV.y) * texture_size + rounded_time).x * 2.0 - 1.0);
}

void light()
{
	DIFFUSE_LIGHT += vec3((clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR).x, 0.0, 0.0);
	//DIFFUSE_LIGHT += vec3(3.0, 0.0, 0.0);
}




