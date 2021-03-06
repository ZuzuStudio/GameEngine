module lib.graphics.wackyShaderProgram;

private
{
    import std.stdio;
    import std.string;
    import std.file;

    import derelict.opengl3.gl3;
}

public
{
    import lib.graphics.wackyEnums;
    import lib.graphics.wackyExceptions;
}

/**
 *  Class that reads the source code of a shader, compiles it
 *  and links the obtained shader program.
 *  Sending data to a shader hasn't been implemented yet
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
            return;

        GLuint shader = glCreateShader(type);

        GLchar*[1] pointer;
        pointer[0]=cast(char*)code.ptr;

        GLint[1] length;
        length[0]=cast (int) code.length;

        glShaderSource (shader, 1, cast(const (char*)*)pointer.ptr, cast(const int*)length);
        glCompileShader(shader);

        auto shaderStatus = shaderStatus(shader);
        if (shaderStatus != null)
        {
            writefln("WackyShaderProgram: (\"%s\"):", fileName);
            writeln(shaderStatus);
            return;
        }

        glAttachShader(id, shader);

        shaderAttached = true;
    }

    /**
     *  Links the program object specified by shaderProgram
     */
    auto linkShaderProgram()
    {
        if (!shaderAttached)
            throw new WackyShaderProgramException("WackyShaderProgram: no files"
                                                  " were attached");
        glLinkProgram (id);

        auto programStatus = programStatus(id);
        if (!programStatus)
        {
            writefln("WackyShaderProgram: error while linking shader program");
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

    /**
     *  Returns true if at least one shader
     *  has been attached successfully
     */
    @property auto isShaderAttached() pure nothrow
    {
        return shaderAttached;
    }

    /**
     *  Returns a number that represents
     *  a reference to the variable is the program
     */
    auto getUniformLocation(string variableName)
    {
        return glGetUniformLocation(id, cast (const (char)*) variableName);
    }

private:

    GLuint id;
    bool shaderAttached;

    /**
     *  Reads the code from the file with the given filename
     */
    string readSourceCode(string fileName)
    {
        string code;
        try
        {

            code = fileName.readText();

        }
        catch(FileException)
        {
            writefln("WackyShaderProgram: cannot read file \"%s\"", fileName);
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
        char[2048] log;
        if (!ok)
        {
            glGetShaderInfoLog(shader, log.sizeof, null, cast(char*) log);
            return log.dup;
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
