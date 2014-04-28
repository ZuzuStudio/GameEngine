import derelict.assimp3.assimp;
import derelict.opengl3.gl3;

import lib.math.squarematrix;

/**
 *  The class represents a simple mesh
 */
class WackyMesh
{
public:

    this(float[] vertices, uint[] indices, float[] textureCoordinates)
    {
        this.vertices = vertices;
        this.indices = indices;
        this.textureCoordinates = textureCoordinates;

        generateBuffers();
    }

    ~this()
    {
        glDeleteBuffers(buffers.length, buffers.ptr);
        glDeleteVertexArrays(1, &VAO);
    }

    /**
     *  Draws the mesh
     */
    auto render(GLuint uniformMat4Location, Matrix4x4f transformation = Matrix4x4f.identity)
    {
        glUniformMatrix4fv(uniformMat4Location, 1, GL_TRUE, transformation.ptr);
        glBindVertexArray(VAO);
        glDrawElementsBaseVertex(GL_TRIANGLES, indices.length, GL_UNSIGNED_INT, cast (void*) indices.ptr, 0);
        glBindVertexArray(0);
    }

private:
    /*
     *  Normals' support is not implemented yet
     *  Vector 2f[] normals
     */
    float[] vertices;
    float[] textureCoordinates;
    uint[] indices;

    enum
    {
        POSITION = 0,
        TEXTURE_COORDINATES = 1,
        INDICES = 2,
    }

    uint buffers[3];

    /**
     *  Vertex array object
     */
    uint VAO;

    /**
     *  Creates VAO
     */
    auto generateBuffers()
    {

        glGenVertexArrays(1, &VAO);
        glBindVertexArray(VAO);
        glGenBuffers(buffers.length, buffers.ptr);

        glBindBuffer(GL_ARRAY_BUFFER, buffers[POSITION]);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * vertices.length, vertices.ptr, GL_STATIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast (const void*) 0);

        glBindBuffer(GL_ARRAY_BUFFER, buffers[TEXTURE_COORDINATES]);
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * textureCoordinates.length, textureCoordinates.ptr, GL_STATIC_DRAW);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * float.sizeof, cast (const void*) 0);

        glBindBuffer(GL_ARRAY_BUFFER, buffers[INDICES]);
        glBufferData(GL_ARRAY_BUFFER, uint.sizeof * indices.length, indices.ptr, GL_STATIC_DRAW);

        glBindVertexArray(0);
    }
}
