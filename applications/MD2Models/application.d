/*
 *  Some md2 models from the Internet.
 *  The application is based on Wacky Graphic Engine :)
 *
 *  Alexander Kochurko, 2014
 */

import std.stdio;
import std.math;

import lib.graphics.wackyRender;
import lib.graphics.wackyRenderInitializer;
import lib.graphics.wackyShaderProgram;
import lib.graphics.wackySimpleMesh;

import lib.math.squarematrix;

void main()
{
    // The resolution will be set by default
    WackyRender engine = new WackyRender("Models", WackyWindowMode.FULLSCREEN_MODE);
    WackyRenderInitializer.initialize(engine);
    engine.observer.setStep(20.0f);
    engine.observer.setPosition(0.0f, 0.0f, -300.0f);

    WackyShaderProgram shader = new WackyShaderProgram;
    shader.attachShader("shaders/vertexShader.glsl", WackyShaderTypes.VERTEX_SHADER);
    shader.attachShader("shaders/fragmentShader.glsl", WackyShaderTypes.FRAGMENT_SHADER);
    shader.linkShaderProgram();
    shader.useShaderProgram();

    // Loading models
    WackySimpleMesh car = new WackySimpleMesh("models/car.md2");
    car.setTexture("textures/car.jpeg");

    WackySimpleMesh vehicle = new WackySimpleMesh("models/phoenix.md2");
    vehicle.setTexture("textures/phoenix.pcx");

    WackySimpleMesh helicopter = new WackySimpleMesh("models/helicopter.md2");
    helicopter.setTexture("textures/helicopter.png");

    // Background
    WackySimpleMesh welcome = new WackySimpleMesh ([-75.0f, -30.0f, 150.0f,
                                  75.0f, 70.0f, 150.0f,
                                  -75.0f, 70.0f, 150.0f,
                                  75.0f, -30.0f, 150.0f],

                                 [0, 1, 2, 0, 1, 3],

                                 [0.0f, 0.0f,
                                 1.0f, 1.0f,
                                  0.0f, 1.0f,
                                  1.0f, 0.0f],
                                 );

    welcome.setTexture("textures/welcome.png");

    engine.enableVSync();

    auto step = 0.0f;


    auto scene = delegate()
    {

        welcome.render(shader.getUniformLocation ("meshTransformation"),
                       shader.getUniformLocation ("sampler"));


        vehicle.render (shader.getUniformLocation ("meshTransformation"),
                       shader.getUniformLocation ("sampler"),
                       initPositionTransformation (20.0f, 0.0f, 0.0f)
                       * initScaleTransformation (cast (float) abs(sin(step)) * 0.5f,
                                                  cast (float) abs(sin(step)) * 0.5f,
                                                  cast (float) abs(sin(step)) * 0.5f));

        car.render (shader.getUniformLocation("meshTransformation"),
                       shader.getUniformLocation("sampler"),
                       initRotationTransformation(0.0f, -step, 0.0f)
                       * initPositionTransformation(100.0f, 0.0f, 0.0f)
                       * initScaleTransformation(0.1f, 0.1f, 0.1f));

        helicopter.render (shader.getUniformLocation("meshTransformation"),
                          shader.getUniformLocation("sampler"),
                          initPositionTransformation(-30.0f, 0.0f, 0.0f)
                          * initRotationTransformation(0.0f, step, 0.0f)
                          * initScaleTransformation(0.07f, 0.07f, 0.07f));

        step += 0.02f;
    };

    // Rendering
    engine.execute(scene, shader.getUniformLocation("WVPTransformation"));

}
