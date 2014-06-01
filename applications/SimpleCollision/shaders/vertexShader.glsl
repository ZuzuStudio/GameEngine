#version 330

// Attributes
layout (location = 0) in vec3 position;
layout (location = 1) in vec2 UVs;

// Matrix which is controlled by the pipeline
uniform mat4 WVPTransformation;

// Matrix which is controlled by a mesh
uniform mat4 meshTransformation;

// Output
out vec2 UVsToFragmentShader;

void main()
{
	// Resulting position
    gl_Position = WVPTransformation * meshTransformation * vec4 (position, 1.0);

    // Passing texture coordinates to the fragment shader
    UVsToFragmentShader = UVs;

}
