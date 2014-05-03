module wackyExceptions;

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
 *  The shader handler exception
 */
class WackyShaderHandlerException: Exception
{
    public this(string message)
    {
        super(message);
    }
}
