/*
 *  A cute green square.
 *  The application is based on Wacky Graphic Engine :)
 *
 *  Alexander Kochurko, 2014
 */

import std.stdio;

import lib.graphics.wackyRender;
import lib.graphics.wackyRenderInitializer;
import lib.graphics.wackyShaderProgram;
import lib.graphics.wackySimpleMesh;

void main()
{
    // Creates the context for OpenGL
    WackyRender engine = new WackyRender("Triangle", WackyWindowMode.WINDOW_MODE, 640, 480);

    // Initializes the engine's variables with optimal values
    // [not necessary]
    WackyRenderInitializer.initialize(engine);

    // Creates shader program
    WackyShaderProgram shader = new WackyShaderProgram;

    // Attaches our source code files
    shader.attachShader("../../../resources/shaders/greenSquareVS.glsl", WackyShaderTypes.VERTEX_SHADER);
    shader.attachShader("../../../resources/shaders/greenSquareFS.glsl", WackyShaderTypes.FRAGMENT_SHADER);

    // Links the program
    shader.linkShaderProgram();

    // Uses the obtained program
    shader.useShaderProgram();

    // Creates a simple mesh without any textures. The color
    // should be defined in the fragment shader
    WackySimpleMesh square = new WackySimpleMesh ([-0.5f, -0.5f, 0.0f,
                                  0.5f, 0.5f, 0.0f,
                                  -0.5f, 0.5f, 0.0f,
                                  0.5f, -0.5f, 0.0f],

                                 [0, 1, 2, 0, 1, 3]);

    // Enables vertical synchronization
    // [not necessary]
    engine.enableVSync();

    // Rendering function
    engine.execute(()

    // The delegate with the data to be rendered
    {
        square.render(shader.getUniformLocation("meshTransformation"));

    }, shader.getUniformLocation("WVPTransformation"));

}
