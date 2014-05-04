#version 330

// The attribute is a position of current vertex
layout (location = 0) in vec3 position;

// Matrix which is controlled by the pipeline
uniform mat4 WVPTransformation;

// Matrix which is controlled by a mesh
uniform mat4 meshTransformation;

void main()
{
	// Resulting position
    gl_Position = WVPTransformation * meshTransformation * vec4 (position, 1.0);
};
