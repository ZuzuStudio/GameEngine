import std.stdio;
import std.string;
import std.file;

import derelict.opengl3.gl3;

public import wackyEnums;
import wackyExceptions;

/**
 *  Class that reads the source code of a shader, compiles it
 *  and links the obtained shader program
 */

class WackyShaderProgram
{
public:
    this()
    {
        id = glCreateProgram();
    }

    ~this()
    {
        glDeleteProgram(id);
    }

    /**
     *  Compiles the code and attaches the result
     *  to the the program object specified by shaderProgram
     */
    auto attachShader(string fileName, WackyShaderTypes type)
    {
        string code = readSourceCode(fileName);
        if (!code)
            return false;

        GLuint shader = glCreateShader(type);

        GLchar* pointer[1];
        pointer[0]=cast(char*)code.ptr;

        GLint length[1];
        length[0]=cast (int) code.length;

        glShaderSource (shader, 1, cast(const (char*)*)pointer.ptr, cast(const int*)length);
        glCompileShader(shader);

        auto shaderStatus = shaderStatus(shader);
        if (shaderStatus != null)
        {
            writefln("WackyShaderLoader (\"%s\"):", fileName);
            writeln(shaderStatus);
            return false;
        }

        glAttachShader(id, shader);
        return true;
    }

    /**
     *  Links the program object specified by shaderProgram
     */
    auto linkShaderProgram()
    {
        glLinkProgram (id);

        auto programStatus = programStatus(id);
        if (!programStatus)
        {
            writefln("WackyShaderLoader: error while linking shader program");
            return false;
        }

        glValidateProgram (id);
        return true;
    }

    /**
     *  Installs the program object specified by shaderProgram
     *  as part of current rendering state
     */
    auto useShaderProgram()
    {
        glUseProgram (id);
    }

    /**
     *  Returns a non-zero value by which the program
     *  object can be referenced
     */
    @property auto getId() pure nothrow
    {
        return id;
    }

private:

    GLuint id;

    /**
     *  Reads the code from the file with the given filename
     */
    string readSourceCode(string fileName)
    {
        string code;
        try{

            code = fileName.readText();

        }catch(FileException){
            writefln("WackyShaderLoader: cannot read file \"%s\"", fileName);
            return null;
        }
        return code;
    }

    /**
     *  Checks whether the code was compiled successfully
     *  and return a message from GLSL compiler if not
     */
    char[] shaderStatus(GLuint shader) nothrow
    {
        GLint ok;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &ok);
        char log[2048];
        if (!ok)
        {
            glGetShaderInfoLog(shader, log.sizeof, null, cast(char*) log);
            return log[];
        }
        return null;
    }

    /**
     *  Checks whether the program linked successfully
     */
    auto programStatus(GLuint shader) nothrow
    {
        GLint ok;
        glGetProgramiv(shader, GL_LINK_STATUS, &ok);
        return cast (bool) ok;
    }
}
