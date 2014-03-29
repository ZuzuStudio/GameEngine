module main;

import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import std.stdio, std.file, std.math;
import pipeline, math3d, camera, texture, additional, mesh;
import core.thread;

Camera observer;

void main()
{
    DerelictGLFW3.load();
    DerelictGL3.load();

    glfwInit();
    scope (exit) glfwTerminate();

    auto window = glfwCreateWindow (1366, 768, "Training", glfwGetPrimaryMonitor(), null);
    scope (exit) glfwDestroyWindow (window);

    glfwSetMouseButtonCallback (window, cast(GLFWmousebuttonfun ) mouseCallback);
    glfwSetKeyCallback (window, cast(GLFWkeyfun) keyCallback);
    glfwSetCursorPosCallback (window, cast(GLFWcursorposfun) mouseMovCallback);
    glfwMakeContextCurrent (window);

    DerelictGL3.reload();

    observer = new Camera (window);

    auto  mesh = new Mesh();
    mesh.LoadMesh ("saa");

    auto pipeline = new Pipeline;

    GLuint shaderProgram = glCreateProgram();

    string filename="vertexShader.glsl";
    string vertexShaderCode = filename.readText();

    filename="fragmentShader.glsl";
    string fragmentShaderCode = filename.readText();

    newShader (shaderProgram, vertexShaderCode,  GL_VERTEX_SHADER);
    newShader (shaderProgram, fragmentShaderCode ,  GL_FRAGMENT_SHADER);

    glLinkProgram (shaderProgram);

    GLint ok;
    glGetProgramiv (shaderProgram, GL_LINK_STATUS, &ok);
    if (!ok)
    {
        GLchar log[1024];
        glGetProgramInfoLog(shaderProgram, log.sizeof, null, cast(char*) log);
        writeln(log);
    }

    glValidateProgram (shaderProgram);
    glUseProgram (shaderProgram);

    GLuint worldLocation = glGetUniformLocation (shaderProgram, "gWorld");

    glfwSetInputMode (window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    int width, height;
    glfwGetWindowSize (window, &width, &height);

    pipeline.SetScale(0.01f, 0.01f, 0.01f);
    pipeline.SetPerspective(30.0f, width, height, 0.5f, 100.0f);
    pipeline.SetPosition(0.0f, 0.0f, 3.0f);
    pipeline.SetRotation(0.0f, 0.0f, 0.0f);

    Matrix4f world;

    auto gSampler = glGetUniformLocation(shaderProgram, "gSampler");
    glUniform1i (gSampler, 0);

    glEnable (GL_DEPTH_TEST);

    while (!glfwWindowShouldClose(window))
    {
        glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glfwPollEvents();

        pipeline.SetCamera (observer.GetPosition(), observer.GetTarget(), observer.GetUp());
        world = pipeline.GetTransformation;

        glUniformMatrix4fv(worldLocation, 1, GL_TRUE, &world[0][0]);

        mesh.Render();

        Thread.sleep( dur!("msecs")( 16 ) );
        glfwSwapBuffers(window);
    }

}


////////////////////

auto mouseCallback = (GLFWwindow* window, int key, int action, int mods)
{
    if (key == GLFW_MOUSE_BUTTON_RIGHT && action == GLFW_PRESS)
        glfwSetWindowShouldClose (window, true);
};

auto keyCallback = (GLFWwindow* window, int key, int scancode, int action, int mods)
{
    observer.KeyboardProcessing (key, action);
};

auto mouseMovCallback = (GLFWwindow * window, double x, double y)
{
    observer.MouseProcessing(cast (float) x, cast (float) y);
};
