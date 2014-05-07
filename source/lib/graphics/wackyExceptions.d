module lib.graphics.wackyExceptions;

/**
 *  A common exception for the library
 */
class WackyException: Exception
{
    public this(string message)
    {
        super(message);
    }
}

/**
 *  The render exception
 */
class WackyRenderException: Exception
{
    public this(string message)
    {
        super(message);
    }
}

/**
 *  The mesh exception
 */
class WackySimpleMeshException: Exception
{
    public this(string message)
    {
        super(message);
    }
}

/**
 *  Shader exception
 */
class WackyShaderProgramException: Exception
{
    public this(string message)
    {
        super(message);
    }
}
