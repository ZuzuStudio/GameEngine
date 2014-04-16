module lib.graphics.wackyRender;

import std.stdio;
import std.string;
import core.memory;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import derelict.util.exception: DerelictException;

public import wackyEnums;
public import wackyExceptions;
import wackyShaderHandler;
import wackyPipeline;

class WackyRender
{
public:

    WackyShaderHandler shaderHandler;

    this(int width, int height, string name, WackyWindowMode mode)
    {
        try
        {
            DerelictGLFW3.load();
        }
        catch (DerelictException)
        {
            throw new WackyException("GLFW3 or one of its dependencies "
                                     "cannot be found on the file system");
        }

        try
        {
            DerelictGL3.load();
        }
        catch (DerelictException)
        {
            throw new WackyException("OpenGL3 or one of its dependencies "
                                     "cannot be found on the file system");
        }

        this.width = width;
        this.height = height;
        this.name = name;
        this.mode = mode;

        initialize(this.width, this.height, this.name, this.mode);

        shaderHandler = new WackyShaderHandler();
    }

    ~this()
    {
        glfwDestroyWindow(window);
        glfwTerminate();
        DerelictGL3.unload();
        DerelictGLFW3.unload();
    }


    /**
    *   Main loop
    *   Garbage collector will have been forbidden to operate
    *   until the function will be executed
    */

    // there's only a sketch of the rendering function
    auto execute()
    {
        GC.collect();
        GC.disable();
        scope (exit) GC.enable();

        while(!glfwWindowShouldClose(window))
        {
            glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glfwPollEvents();


            glfwSwapBuffers(window);
        }
    }

    /**
     *  Returns the number of seconds since the constructor
     *  for WackyRender was called
     */
    auto getTime()
    {
        return glfwGetTime();
    }

    /**
     * Sets a key and an action for making the window close
     */
    auto setExitKeyAndAction(WackyKeys key, WackyActions action)
    {
        exitKey = key;
        exitAction = action;
    }

    /**
     * Getters
     */
    @property
    {
        auto windowPointer()
        {
            return window;
        }

        auto windowWidth()
        {
            return width;
        }

        auto windowHeight()
        {
            return width;
        }

        auto windowName()
        {
            return name;
        }

        auto windowMode()
        {
            return mode;
        }

        auto currentExitKey()
        {
            return exitKey;
        }

        auto currentExitAction()
        {
            return exitAction;
        }
    }

private:

    int width;
    int height;
    string name;
    WackyWindowMode mode;

    GLFWwindow* window;

    static WackyKeys exitKey = WackyKeys.KEY_ESCAPE;
    static WackyActions exitAction = WackyActions.PRESS;

    /**
     *  The function does all necessary work for the render functioning
     */
    auto initialize (int width, int height, string name, WackyWindowMode mode)
    {
        if (glfwInit() == GL_FALSE)
            throw new WackyRenderException("Error while initializing GLFW3");

        if (isBadResolution(width, height))
            throw new WackyRenderException("Invalid resolution");

        GLFWmonitor* monitor;
        if (mode == WackyWindowMode.FULLSCREEN_MODE)
            monitor = glfwGetPrimaryMonitor();

        window = glfwCreateWindow (width, height, name.ptr, monitor, null);
        if (!window)
            throw new WackyRenderException("Error while creating window");

        setCallbacks();
        glfwSetInputMode (window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

        glfwMakeContextCurrent (window);
        glfwSetCursorPos(window, 0.0f, 0.0f);
        DerelictGL3.reload();
    }

    /**
     *  Resolution validation
     */
    auto static isBadResolution(int width, int height)
    {
        const GLFWvidmode* maxResolution = glfwGetVideoMode(glfwGetPrimaryMonitor());

        return width < 100
               || height < 100
               || width > maxResolution.width
               || height > maxResolution.height;
    }

    /**
     *  Sets the callbacks
     */
    auto setCallbacks()
    {
        glfwSetMouseButtonCallback (window, cast(GLFWmousebuttonfun ) &mouseButtonCallback);
        glfwSetKeyCallback (window, cast(GLFWkeyfun) &keyboardCallback);
        glfwSetCursorPosCallback (window, cast(GLFWcursorposfun) &mouseMoveCallback);
    }

    /**
    *   GLFW3 callbacks
    */

    // There will be some changes
    extern(C) static auto mouseButtonCallback (GLFWwindow* window, int key, int action, int mods) nothrow
    {
    }

    extern(C) static auto mouseMoveCallback (GLFWwindow* window, double x, double y) nothrow
    {
    }

    extern(C) static auto keyboardCallback (GLFWwindow* window, int key, int scancode, int action, int mods) nothrow
    {
        if (key == exitKey && action == exitAction)
            glfwSetWindowShouldClose (window, true);
    }
}
