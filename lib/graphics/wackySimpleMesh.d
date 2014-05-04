module wackySimpleMesh;

private
{
    import std.stdio: writefln;
    import std.string: toStringz;
    import std.conv: to;

    import derelict.util.exception: DerelictException;
    import derelict.assimp3.assimp;
    import derelict.opengl3.gl3;

    import wackyExceptions;
    import wackyTexture;

    import lib.math.squarematrix;
    import lib.math.vector;
}

/**
 *  A simplest mesh that supports single texture layer
 */
class WackySimpleMesh
{
public:

    /**
     *  Explicit creation of a mesh
     */
    this(float[] vertices, uint[] indices, float[] UVs = null)
    {
        if (!vertices || !indices)
            throw new WackySimpleMeshException("WackyMesh: empty vertex or index array");

        this.vertices = vertices.dup;
        this.indices = indices.dup;
        this.UVs = UVs.dup;

        generateBuffers();
    }

    this(Vector3f[] vertices, uint[] indices, Vector2f[] UVs = null)
    {

        if (!vertices || !indices)
            throw new WackySimpleMeshException("WackyMesh: empty vertex or index array");

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
            bool UVExists;
            initializeMesh(scene.mMeshes[0], UVExists);

            if (!UVExists)
                writefln("WackyMesh: the mesh \"%s\" doesn't containt texture coordinates", fileName);

            generateBuffers();
        }
        else
            writefln("WackyMesh: the mesh \"%s\" cannot be loaded", fileName);
    }

    ~this()
    {
        if (textureUnit != -1)
            texturesAccounting--;

        glDeleteBuffers(buffers.length, buffers.ptr);
        glDeleteVertexArrays(1, &VAO);
        DerelictASSIMP3.unload;
    }

    /**
     *  Sets the necessary texture
     */
    auto setTexture(string fileName)
    {
        if (!texture || fileName != texture.getFileName)
        {
            texture = new WackyTexture (fileName, GL_TEXTURE_2D);
            if(texture.load())
            {
                texturesAccounting++;
                textureUnit = texturesAccounting;
            }
        }

        bindTexture();
    }

    /**
     *  Draws the mesh
     */
    auto render(uint meshTransformationLocation, uint samplerLocation = -1, Matrix4x4f transformation = Matrix4x4f.identity)
    {
        glUniformMatrix4fv(meshTransformationLocation, 1, GL_TRUE, transformation.ptr);

        if (samplerLocation != -1)
            glUniform1i(samplerLocation, textureUnit);

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

    static int texturesAccounting = -1;
    int textureUnit = -1;
    WackyTexture texture;

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

        if (UVs)
        {
            glBindBuffer(GL_ARRAY_BUFFER, buffers[TEXTURE_COORDINATES]);
            glBufferData(GL_ARRAY_BUFFER, float.sizeof * UVs.length, UVs.ptr, GL_STATIC_DRAW);
            glEnableVertexAttribArray(1);
            glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 2 * float.sizeof, cast (const void*) 0);
        }

        glBindBuffer(GL_ARRAY_BUFFER, buffers[INDICES]);
        glBufferData(GL_ARRAY_BUFFER, uint.sizeof * indices.length, indices.ptr, GL_STATIC_DRAW);

        glBindVertexArray(0);
    }

    /**
     *  Extracts values for the object from the aiMesh* mesh
     */
    auto initializeMesh(const aiMesh* mesh, ref bool UVExists)
    {
        auto positionsFromFile = mesh.mVertices;
        auto textureCoordinatesFromFile = mesh.mTextureCoords[0];
        auto indicesFromFile = mesh.mFaces;

        if (textureCoordinatesFromFile)
        {
            UVExists = true;
            foreach(i; 0 .. mesh.mNumVertices)
            {
                vertices ~= positionsFromFile[i].x;
                vertices ~= positionsFromFile[i].y;
                vertices ~= positionsFromFile[i].z;

                UVs ~= textureCoordinatesFromFile[i].x;
                UVs ~= textureCoordinatesFromFile[i].y;
            }
        }

        else
        {
            UVExists = false;
            foreach(i; 0 .. mesh.mNumVertices)
            {
                vertices ~= positionsFromFile[i].x;
                vertices ~= positionsFromFile[i].y;
                vertices ~= positionsFromFile[i].z;
            }

        }

        foreach(i; 0 .. mesh.mNumFaces)
        {
            auto tripleIndices = indicesFromFile[i];
            assert (tripleIndices.mNumIndices == 3);

            indices ~= tripleIndices.mIndices[0];
            indices ~= tripleIndices.mIndices[1];
            indices ~= tripleIndices.mIndices[2];
        }
    }

    /**
     *  Connects the specified texture with
     *  a free texture module
     */
    auto bindTexture()
    {
        if (textureUnit != -1)
            texture.bind(GL_TEXTURE0 + textureUnit);
    }
}
