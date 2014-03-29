module additional;

import derelict.opengl3.gl3;
import pipeline, math3d;
import std.stdio;

struct Vertex
{
    Vector3f a;
    Vector2f b;
}

void newShader(GLuint program, string code, GLenum type)
{
    GLuint shader = glCreateShader(type);

    GLchar* pointer[1];
    pointer[0]=cast(char*)code.ptr;

    GLint length[1];
    length[0]=cast (int) code.length;

    glShaderSource (shader, 1, cast(const (char*)*)pointer.ptr, cast(const int*)length);
    glCompileShader(shader);

    GLint ok;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &ok);

    if (!ok)
    {
        char log[1024];
        glGetShaderInfoLog(shader, log.sizeof, null, cast(char*) log);
        writeln(log);
    }
    glAttachShader(program, shader);
}
