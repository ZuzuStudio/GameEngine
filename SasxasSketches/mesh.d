module mesh;

import derelict.assimp3.assimp;
import derelict.opengl3.gl3;
import texture;

class Mesh
{
public:

    this ()
    {
        DerelictASSIMP3.load ();
    }

    auto LoadMesh (string fileName)
    {
        Clear ();
        // Та же проблема, что и в texture.d
        char  temp[7] = "car.md2";

        auto scene = aiImportFile (temp.ptr,  aiProcess_Triangulate | aiProcess_GenSmoothNormals | aiProcess_FlipUVs);

        bool ok = cast (bool) scene;
        if (ok)
        {
            InitFromScene (scene);

            texture = new Texture (GL_TEXTURE_2D, "всё равно это имя не передаётся нормально");
            texture.Load(GL_LINEAR);
            texture.Bind(GL_TEXTURE0);
        }

        return ok;
    }

    auto Render()
    {
        glBindBuffer (GL_ARRAY_BUFFER, VertexAttributesBuffer);
        glBindBuffer (GL_ELEMENT_ARRAY_BUFFER, IndexBuffer);

        glEnableVertexAttribArray (0);
        glEnableVertexAttribArray (1);

        glVertexAttribPointer (0, 3, GL_FLOAT, GL_FALSE, 20, cast (const void*) 0);
        glVertexAttribPointer (1, 2, GL_FLOAT, GL_FALSE, 20, cast (const void*)12);

        glDrawElements (GL_TRIANGLES, cast (uint) Indices.length, GL_UNSIGNED_INT, cast (const void*) 0);

        glDisableVertexAttribArray (1);
        glDisableVertexAttribArray (0);
    }

private:

    auto Clear()
    {
        VertexAttributes.clear ();
        Indices.clear ();
    }


    auto InitFromScene (const aiScene* scene)
    {
        auto mesh = scene.mMeshes[0];
        InitMesh (mesh);
    }

    auto InitMesh(const aiMesh* mesh)
    {

        foreach (i ; 0 .. mesh.mNumVertices)
        {
            auto positionCoords = &(mesh.mVertices[i]);
            auto textureCoords = &(mesh.mTextureCoords[0][i]);

            VertexAttributes ~= positionCoords.x;
            VertexAttributes ~= positionCoords.y;
            VertexAttributes ~= positionCoords.z;

            VertexAttributes ~= textureCoords.x;
            VertexAttributes ~= textureCoords.y;
        }

        for( int i = 0 ; i < mesh.mNumFaces; ++i)
        {
            auto Face = mesh.mFaces[i];
            Indices ~= Face.mIndices[0];
            Indices ~= Face.mIndices[1];
            Indices ~= Face.mIndices[2];
        }

        GenerateBuffers ();
    }

    auto GenerateBuffers()
    {
        glGenBuffers (1, &VertexAttributesBuffer);
        glBindBuffer (GL_ARRAY_BUFFER, VertexAttributesBuffer);

        glGenBuffers (1, &IndexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IndexBuffer);

        glBufferData (GL_ARRAY_BUFFER, GLfloat.sizeof * VertexAttributes.length, VertexAttributes.ptr, GL_STATIC_DRAW);
        glBufferData (GL_ELEMENT_ARRAY_BUFFER, GLuint.sizeof * Indices.length, Indices.ptr, GL_STATIC_DRAW);
    }

    float VertexAttributes [];
    uint Indices [];
    uint IndexBuffer, VertexAttributesBuffer;

    Texture texture;
};
