/**
* Heightmap based mountains shader
*@note Based on https://docs.godotengine.org/en/2.1/community/tutorials/3d/mesh_generation_with_heightmap_and_shaders.html
*      and https://godotshaders.com/shader/mountain-background-shader/
*@author Jean-Milost Reymond
*/
shader_type spatial;

render_mode unshaded, shadows_disabled;

// NOTE the variable names should be formatted this way because they are exposed on the inspector
uniform sampler2D mountain_texture;
uniform sampler2D sand_texture;
uniform sampler2D height_map;
uniform vec4      aerial_perspective_color;
uniform vec2      mountain_uv_scale = vec2( 25.0, 25.0 );
uniform vec2      sand_uv_scale     = vec2( 100.0, 100.0 );
uniform float     height            = 11.0;
uniform float     mountain_distance = 2000.0;

/**
* Vertex shader main function
*/
void vertex()
{
	float r  = atan(VERTEX.z, VERTEX.x);
	VERTEX.y = texture(height_map, UV).r * height * length(UV - vec2(0.5, 0.5));
	NORMAL   = vec3(0.0, 1.0, 0.0);
}

/**
* Fragment shader main function
*/
void fragment()
{
	float dist = length(UV - vec2(0.5, 0.5));

	ALBEDO = mix
	(
		mix
		(
			texture(mountain_texture, UV * mountain_uv_scale),
			texture(sand_texture, UV * sand_uv_scale),
			clamp(pow(texture(height_map, UV * 1.1 ).r * 1.4, 6.0), 0.0, 1.0)
		).rgb,
		aerial_perspective_color.rgb,
		dist * 0.8
	);
	DEPTH = clamp( 0.99999 + dist * 0.00001, 0.0, 1.0 );
}
