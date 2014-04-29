import std.stdio:
writefln;
import std.string:
toStringz;

import derelict.util.exception:
DerelictException;
import derelict.assimp3.assimp;
import derelict.opengl3.gl3;

import WackyExceptions;

import lib.math.squarematrix;
import lib.math.vector;

/**
 *  The class represents a simple mesh
 */
class WackyMesh
{
public:

    /**
     *  Explicit creation of a mesh
     */
    this(float[] vertices, uint[] indices, float[] textureCoordinates = null)
    {
        if (!vertices || !indices)
            throw new WackyException("WackyMesh: empty vertex or index array");

        this.vertices = vertices.dup;
        this.indices = indices.dup;
        this.UVs = UVs.dup;

        generateBuffers();
    }

    this(Vector3f[] vertices, uint[] indices, Vector2f[] UVs = null)
    {
        if (!vertices || !indices)
            throw new WackyException("WackyMesh: empty vertex or index array");
        foreach(e; vertices)
        {
            this.vertices ~= e.x;
            this.vertices ~= e.y;
            this.vertices ~= e.z;
        }

        this.indices = indices.dup;

        if (UVs)
        {
            foreach(e; UVs)
            {
                this.UVs ~= e.x;
                this.UVs ~= e.y;
            }
        }

        generateBuffers();
    }

    /**
     *  Reading a mesh from a file
     */
    this(string fileName)
    {
        if (!DerelictASSIMP3.isLoaded)
        {
            try
            {
                DerelictASSIMP3.load;
            }
            catch (DerelictException)
            {
                throw new WackyException("ASSIMP3 or one of its dependencies "
                                         "cannot be found on the file system");
            }
        }

        auto scene = aiImportFile (toStringz(fileName),
                                   aiProcess_Triangulate
                                   | aiProcess_FlipUVs);
        if (cast (bool) scene)
        {
            std.stdio.writeln("cool");
        }
    }

    ~this()
    {
        glDeleteBuffers(buffers.length, buffers.ptr);
        glDeleteVertexArrays(1, &VAO);
        DerelictASSIMP3.unload;
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
     *  float[] normals
     */
    float[] vertices;
    float[] UVs;
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
        glBufferData(GL_ARRAY_BUFFER, float.sizeof * UVs.length, UVs.ptr, GL_STATIC_DRAW);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * float.sizeof, cast (const void*) 0);

        glBindBuffer(GL_ARRAY_BUFFER, buffers[INDICES]);
        glBufferData(GL_ARRAY_BUFFER, uint.sizeof * indices.length, indices.ptr, GL_STATIC_DRAW);

        glBindVertexArray(0);
    }
}
