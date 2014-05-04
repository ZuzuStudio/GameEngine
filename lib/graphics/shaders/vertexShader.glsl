#version 330

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 vertexTextureCoordinates;

uniform mat4 WVPTransformation;
uniform mat4 meshTransformation;

out vec2 fragmentTextureCoordinates;

void main()
{
    gl_Position = WVPTransformation * meshTransformation * vec4 (position, 1.0);

	fragmentTextureCoordinates = vertexTextureCoordinates;
};
