module texture;

import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;

class Texture
{
    public:

        this (GLenum _type, string _fileName)
        {
            DerelictFI.load();

            type =  _type;
            fileName = _fileName.dup;
        }

        ~this ()
        {
           FreeImage_Unload (bitmap);
        }

        auto Load (GLfloat _parameter)
        {
            // Загрузка через fileName почему-то не работает
           string temp = "car.jpeg";

             auto imageType = FreeImage_GetFileType (temp.ptr, 0);
             bitmap = FreeImage_ConvertTo32Bits (FreeImage_Load (imageType, temp.ptr));

             if (!bitmap)
                return false;

            glGenTextures(1, &texturePointer);
            glBindTexture(texturePointer, type);

            int width = FreeImage_GetWidth (bitmap);
            int height = FreeImage_GetHeight (bitmap);

            glTexImage2D(type, 0, GL_RGBA, width, height,
                 0, GL_BGRA, GL_UNSIGNED_BYTE, cast(void*)FreeImage_GetBits(bitmap));

            glTexParameterf(type, GL_TEXTURE_MIN_FILTER, _parameter);
            glTexParameterf(type, GL_TEXTURE_MAG_FILTER, _parameter);

            return true;
        }

        auto Bind(GLenum unit)
        {
            glActiveTexture(unit);
            glBindTexture(texturePointer, type);
        }

        private:
            GLuint texturePointer;
            GLenum type;

            string fileName;
            FIBITMAP* bitmap;
};
