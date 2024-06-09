shader_type canvas_item;

group_uniforms UsefullStuff;
uniform float intensity: hint_range(0.0, 10) = 1.0;
uniform float speed = 1.0;
group_uniforms;

group_uniforms PointlessStuff;
uniform vec4 EPIC_Color: source_color; 
group_uniforms;

void vertex() 
{
	float wave1 = (sin(TIME*2.3 * speed) * 5.0 + sin(TIME * 3.3 * speed) * 8.0)  * ( 0.8 - UV.y);
	float wave2 = (sin(TIME*1.8 * speed) * 5.0 + sin(TIME * 2.3 * speed) * 8.0)  * ( 0.8 - UV.y) * (1.0 - UV.y * 2.0);
	float wave3 = 0.0;
	VERTEX += vec2(wave1 * intensity, wave2  * intensity) ;
	
	vec4 vertex_color1 = vec4(UV.xyx,1.0);
	vec4 vertex_color2 = vec4(UV.yxx,1.0);
	
	COLOR = mix(vertex_color1, vertex_color2, (sin(TIME * speed)+ 1.0)*0.5);
}

void fragment() {
	
	
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
