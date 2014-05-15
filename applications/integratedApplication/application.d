/*
 *  The application is based on Wacky Graphic Engine :)
 *
 *  Alexander Kochurko, Artiom Stepanishev,  2014
 */

import std.stdio;
import std.math;

import lib.graphics.wackyRender;
import lib.graphics.wackyRenderInitializer;
import lib.graphics.wackyShaderProgram;
import lib.graphics.wackySimpleMesh;

import lib.math.squarematrix;

import lib.physics.physicsworld;


void main()
{
    WackyRender engine = new WackyRender("Collision", WackyWindowMode.FULLSCREEN_MODE);
    WackyRenderInitializer.initialize(engine);
    engine.observer.setStep(50.0f);
    engine.observer.setPosition(0.0f, 0.0f, -300.0f);

    WackyShaderProgram shader = new WackyShaderProgram;
    shader.attachShader("shaders/vertexShader.glsl", WackyShaderTypes.VERTEX_SHADER);
    shader.attachShader("shaders/fragmentShader.glsl", WackyShaderTypes.FRAGMENT_SHADER);
    shader.linkShaderProgram();
    shader.useShaderProgram();

    WackySimpleMesh firstSphere = new WackySimpleMesh("models/sphere.md2");
    firstSphere.setTexture("textures/metal.jpg");

    WackySimpleMesh secondSphere = new WackySimpleMesh("models/sphere.md2");
    secondSphere.setTexture("textures/wood.jpg");

    WackySimpleMesh thirdSphere = new WackySimpleMesh("models/sphere.md2");
    thirdSphere.setTexture("textures/wood.jpg");

    engine.enableVSync();
    auto step = 0.0f;
    //engine.SPF;

    /**
    *   Physics
    */

    PhysicsWorld world = new PhysicsWorld(0.0f);

    world.addDynamicBody(new RigidBody(    // id = 0
                             1.0f,  // mass
                             Vector3f(0f, 0f, 0f),   // position
                             Quaternionf(0f, 0f, 0f, 0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f), 0.5f  // geometry
                            )
              );

    world.addDynamicBody(new RigidBody(    // id = 1
                             1.0f,  // mass
                             Vector3f(500,50,0),   // position
                             Quaternionf(0,0,0,0), // orientation
                             new Sphere(Vector3f(0,0,0),19.0f), 0.3f  // geometry
                            )
                         );

     world.addDynamicBody(new RigidBody(    // id = 2
                             1.0f,  // mass
                             Vector3f(-1000,-80,0),   // position
                             Quaternionf(0,0,0,0), // orientation
                             new Sphere(Vector3f(0,0,0),19f/2f), 0.3f  // geometry
                            )
                        );

    world.getDynamicBody(0).applyForce(Vector3f(0,0,0));
    world.getDynamicBody(0).applyTorque(Vector3f(0,0,0));

    world.getDynamicBody(1).applyForce(Vector3f(-11000,-1200,0));
    world.getDynamicBody(1).applyTorque(Vector3f(0,0,0));

    world.getDynamicBody(2).applyForce(Vector3f(16500,1000,0));
    world.getDynamicBody(2).applyTorque(Vector3f(0,0,0));


    auto scene = delegate()
    {
        firstSphere.render (shader.getUniformLocation("meshTransformation"),
                       shader.getUniformLocation("sampler"),
                       world.getDynamicBody(0).transformation //First sphere
                            );

        secondSphere.render (shader.getUniformLocation("meshTransformation"),
                          shader.getUniformLocation("sampler"),
                          world.getDynamicBody(1).transformation //Second sphere
                             );

                thirdSphere.render (shader.getUniformLocation("meshTransformation"),
                          shader.getUniformLocation("sampler"),
                          world.getDynamicBody(2).transformation
                                    * initScaleTransformation(0.5f, 0.5f, 0.5f)  //Second sphere
                             );

        //step += 0.02f;
        world.update(engine.SPF);
    };

    engine.execute(scene, shader.getUniformLocation("WVPTransformation"));

}
