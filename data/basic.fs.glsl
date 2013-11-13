#version 330

uniform sampler2D in_textureSampler;

in vec2 pass_uv;

out vec3 out_color;

void main()
{
	out_color = texture2D(in_textureSampler, pass_uv).rgb;
}
