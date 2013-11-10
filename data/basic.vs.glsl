#version 330

layout (location = 0) in vec4 position;
layout (location = 1) in vec4 color;

uniform float time;

smooth out vec4 myColor;

void main()
{
	vec4 offset = vec4(cos(time) * 0.5f, sin(time) * 0.5f, 0.0f, 0.0f);
    gl_Position = position + offset;
    myColor = color;
}
