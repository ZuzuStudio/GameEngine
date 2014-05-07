#version 330

// Input
in vec2 UVsToFragmentShader;

// The vector defines current fragment color
out vec4 resultColor;

// Sampler
uniform sampler2D sampler;

void main()
{
	resultColor = texture2D(sampler, UVsToFragmentShader.st);
}
