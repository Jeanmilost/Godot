/**
* Heightmap based mountains shader
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
uniform float     height            = 1.0;

/**
* Vertex shader main function
*/
void vertex()
{
	VERTEX.y = texture(height_map, UV).r * height;
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
}
