#version 330

smooth in vec4 myColor;

uniform float time;

out vec4 outputColor;

void main()
{
    outputColor = vec4(myColor.r * sin(-time), myColor.g * cos(time), myColor.b * sin(time), 1.0f);
}
