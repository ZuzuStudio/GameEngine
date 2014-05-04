#version 330

in vec2 fragmentTextureCoordinates;
out vec4 resultColor;

uniform sampler2D sampler;

void main()
{
	resultColor = texture2D(sampler, fragmentTextureCoordinates.st);
};
