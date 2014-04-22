import std.stdio:
writefln;
import std.string:
toStringz;

import derelict.util.exception:
DerelictException;

import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;

import wackyExceptions;

/**
 * The class represents a texture
 */
class WackyTexture
{
public:
    this(string name, GLenum type)
    {
        if (!DerelictFI.isLoaded)
        {
            try
            {
                DerelictFI.load;
            }
            catch (DerelictException)
            {
                throw new WackyException("FI or one of its dependencies "
                                         "cannot be found on the file system");
            }
        }

        this.type = type;
        this.name = name;
    }

    ~this ()
    {
        FreeImage_Unload (bitmap);
        DerelictFI.unload();
    }

    /**
     *  Loading a texture
     */
    auto load()
    {
        auto imageType = FreeImage_GetFileType (toStringz(name), 0);
        bitmap = FreeImage_ConvertTo32Bits (FreeImage_Load (imageType, toStringz(name)));

        if (!bitmap)
        {
            writefln("WackyTexture: \"%s\" cannot be loaded", name);
            return false;
        }

        glGenTextures(1, &pointer);
        glBindTexture(pointer, type);

        int width = FreeImage_GetWidth (bitmap);
        int height = FreeImage_GetHeight (bitmap);

        glTexImage2D(type, 0, GL_RGBA, width, height,
                     0, GL_BGRA, GL_UNSIGNED_BYTE, cast(void*)FreeImage_GetBits(bitmap));

        glTexParameterf(type, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(type, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        return true;
    }

    /**
     *  Binding texture
     */
    auto bind(GLenum textureUnit)
    {
        glActiveTexture(textureUnit);
        glBindTexture(pointer, type);
    }

    /**
     *  Setters
     */
    @property
    {
        auto getFileName()
        {
            return name;
        }

        auto getPointer()
        {
            return pointer;
        }
    }

private:

    string name;
    GLenum type;
    GLuint pointer;

    int width, height;

    FIBITMAP* bitmap;
}
