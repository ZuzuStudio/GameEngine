module lib.graphics.wackyRender;

private
{
    import std.stdio;
    import std.string;

    import derelict.glfw3.glfw3;
    import derelict.opengl3.gl3;
    import derelict.util.exception: DerelictException;

    import lib.graphics.wackyPipeline;
    import lib.graphics.wackyCamera;

    import lib.math.vector;
}

public
{
    import lib.graphics.wackyEnums;
    import lib.graphics.wackyExceptions;
}

class WackyRender
{
public:

    static WackyPipeline pipeline;
    static WackyCamera observer;

    this(string name, WackyWindowMode mode,
         int width = WackyValues.DEFAULT_VALUE, int height = WackyValues.DEFAULT_VALUE)
    {
        if (!DerelictGLFW3.isLoaded)
        {
            try
            {
                DerelictGLFW3.load;
            }
            catch (DerelictException)
            {
                throw new WackyException("GLFW3 or one of its dependencies "
                                         "cannot be found on the file system");
            }
        }

        if (!DerelictGL3.isLoaded)
        {
            try
            {
                DerelictGL3.load;
            }
            catch (DerelictException)
            {
                throw new WackyException("OpenGL3 or one of its dependencies "
                                         "cannot be found on the file system");
            }
        }

        this.width = width;
        this.height = height;
        this.name = name;
        this.mode = mode;

        initialize(this.width, this.height, this.name, this.mode);

        pipeline = new WackyPipeline;
        observer = new WackyCamera;

        glEnable(GL_DEPTH_TEST);
    }

    ~this()
    {
        glfwDestroyWindow(window);
        glfwTerminate();
        DerelictGL3.unload();
        DerelictGLFW3.unload();
    }


    /**
    *   Main loop.
    *   The parameter action() should contain all the objects to be rendered
    */

    auto execute(bool WAS_THE_TEXTURE_SET, void delegate() action, uint WVPTransformationLocation)
    {
        ///// temporary texture
        if (!WAS_THE_TEXTURE_SET)
        {
            import lib.graphics.wackyTexture;
            WackyTexture texture = new WackyTexture("textures/wood.jpg", GL_TEXTURE_2D);
            texture.load();
            texture.bind(GL_TEXTURE0);
        }
        /////
        float mainTime = glfwGetTime();

        if (isVSyncEnabled)
            glfwSwapInterval(1);

        while(!glfwWindowShouldClose(window))
        {
            if (isNextFrame(mainTime))
            {
                glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
                glfwPollEvents();

                observer.keyProcessing();
                pipeline.setCameraData(Vector3f(observer.getPosition),
                                        Vector3f(observer.getTarget),
                                        Vector3f(observer.getUp));

                glUniformMatrix4fv(WVPTransformationLocation, 1, GL_TRUE, pipeline.getWVPTransformation.ptr);

                action();

                glfwSwapBuffers(window);
            }
        }
    }

    /**
     *  Returns the number of seconds since the constructor
     *  for WackyRender was called
     */
    auto getTime() nothrow
    {
        return glfwGetTime();
    }

    /**
     * Sets a key and an action for making the window close
     */
    auto setExitKeyAndAction(WackyKeys key, WackyActions action) nothrow
    {
        exitKey = key;
        exitAction = action;
    }

    /**
     *  Setting MINIMAL time per frame.
     *  It may happen that the time segment is
     *  too short for a frame to be rendered,
     *  so the desired value is only a lower limit
     *  for a frame rendering time.
     *  If VSync is enabled, setting the value less than
     *  (1 / monitor refresh frequency) will be senseless
     */
    auto setMinimalTimePerFrame(float seconds) pure nothrow
    {
        timePerFrame = seconds;
    }

    /**
     *  Enables vertical synchronization.
     *  If VSync is enabled, FPS is likely to
     *  be the same as the user's monitor
     *  refresh frequency or greater
     */
    auto enableVSync() pure nothrow
    {
        isVSyncEnabled = true;
    }

    /**
     *  Disables vertical synchronization
     */
    auto disableVSync() pure nothrow
    {
        isVSyncEnabled = false;
    }

    /**
     * Getters
     */
    @property
    {
        auto SPF() pure nothrow
        {
            return timePerFrame;
        }

        auto FPS() pure nothrow
        {
            return 1.0f / timePerFrame;
        }

        auto windowPointer() pure nothrow
        {
            return window;
        }

        auto windowWidth() pure nothrow
        {
            return width;
        }

        auto windowHeight() pure nothrow
        {
            return height;
        }

        auto windowName() pure nothrow
        {
            return name;
        }

        auto windowMode() pure nothrow
        {
            return mode;
        }

        auto currentExitKey() nothrow
        {
            return exitKey;
        }

        auto currentExitAction() nothrow
        {
            return exitAction;
        }

        auto VSyncEnabled() nothrow
        {
            return isVSyncEnabled;
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

    float timePerFrame = 0.001f; // 0.001 second

    bool isVSyncEnabled = false;

    /**
     *  The function does all necessary work for the render functioning
     */
    auto initialize (int width, int height, string name, WackyWindowMode mode)
    {
        if (glfwInit() == GL_FALSE)
            throw new WackyRenderException("Error while initializing GLFW3");

        if (width == WackyValues.DEFAULT_VALUE && height == WackyValues.DEFAULT_VALUE)
        {
            this.width = width = glfwGetVideoMode(glfwGetPrimaryMonitor()).width;
            this.height = height = glfwGetVideoMode(glfwGetPrimaryMonitor()).height;
        }

        if (isBadResolution(width, height))
            throw new WackyRenderException("Invalid resolution");

        GLFWmonitor* monitor = null;
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

    /**
     *  FPS handler
     */
    auto isNextFrame(ref float previous)
    {
        auto current = glfwGetTime();
        if (current - previous > timePerFrame)
        {
            previous = current;
            return true;
        }
        return false;
    }

    // There will be some changes
    extern(C) static auto mouseButtonCallback (GLFWwindow* window, int key, int action, int mods) nothrow
    {
    }

    extern(C) static auto mouseMoveCallback (GLFWwindow* window, double x, double y)
    {
        observer.mouseMoveEventHandler(cast (float) x, cast (float) y);
    }

    extern(C) static auto keyboardCallback (GLFWwindow* window, int key, int scancode, int action, int mods) nothrow
    {
        if (key == exitKey && action == exitAction)
            glfwSetWindowShouldClose (window, true);

        observer.keyEventHandler (cast (WackyKeys) key, cast (WackyActions) action);
    }
}
