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

    WackySimpleMesh Sphere1 = new WackySimpleMesh("models/sphere.md2");
    Sphere1.setTexture("textures/wood.jpg");

    WackySimpleMesh Sphere2 = new WackySimpleMesh("models/sphere.md2");
    Sphere2.setTexture("textures/wood.jpg");

    WackySimpleMesh Sphere3 = new WackySimpleMesh("models/sphere.md2");
    Sphere3.setTexture("textures/wood.jpg");

    WackySimpleMesh Sphere4 = new WackySimpleMesh("models/sphere.md2");
    Sphere4.setTexture("textures/wood.jpg");

    WackySimpleMesh Sphere5 = new WackySimpleMesh("models/sphere.md2");
    Sphere5.setTexture("textures/wood.jpg");

    WackySimpleMesh Sphere6 = new WackySimpleMesh("models/sphere.md2");
    Sphere6.setTexture("textures/metal.jpg");
    
    WackySimpleMesh Sphere7 = new WackySimpleMesh("models/sphere.md2");
    Sphere7.setTexture("textures/metal.jpg");

    WackySimpleMesh Sphere8 = new WackySimpleMesh("models/sphere.md2");
    Sphere8.setTexture("textures/metal.jpg");

    WackySimpleMesh Sphere9 = new WackySimpleMesh("models/sphere.md2");
    Sphere9.setTexture("textures/metal.jpg");

    WackySimpleMesh Sphere10 = new WackySimpleMesh("models/sphere.md2");
    Sphere10.setTexture("textures/wood.jpg");


    //engine.observer.setPosition(-450,0,-450);
    //engine.observer.setTarget(3,0,4);
    

    //engine.enableVSync();
    auto step = 0.0f;
    //engine.SPF;

    /**
    *   Physics
    */

    PhysicsWorld world = new PhysicsWorld(-20.0f);

    world.addDynamicBody(new RigidBody(    // id = 0
                             4.0f,  // mass
                             Vector3f(0f, 0f, 200f),   // position
                             Quaternionf(0f, 0f, 0f, 1f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f/2f), 0.9f  // geometry
                         )
                        );

    world.addDynamicBody(new RigidBody(    // id = 1
                             6.0f,  // mass
                             Vector3f(20f, 20f, 200f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f/2f), 0.2f  // geometry
                         )
                        );

    world.addDynamicBody(new RigidBody(    // id = 2
                             3.0f,  // mass
                             Vector3f(-20f, -20f, 200f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f/2f), 0.8f  // geometry
                         )
                        );


    world.addDynamicBody(new RigidBody(    // id = 3
                             10.0f,  // mass
                             Vector3f(20f, -20f, 200f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f/2f), 0.2f  // geometry
                         )
                        );


    world.addDynamicBody(new RigidBody(    // id = 4
                             7.0f,  // mass
                             Vector3f(-20f, 20f, 200f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f/2f), 0.7f  // geometry
                         )
                        );

    
    world.addDynamicBody(new RigidBody(    // id = 5
                             9.0f,  // mass
                             Vector3f(20, 20f, 250f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f), 0.4f  // geometry
                         )
                        );

      world.addDynamicBody(new RigidBody(    // id = 6
                             9.0f,  // mass
                             Vector3f(-20, -20f, 250f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f), 0.85f  // geometry
                         )
                        );

  world.addDynamicBody(new RigidBody(    // id = 7
                             9.0f,  // mass
                             Vector3f(-20, 20f, 250f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f), 0.15f  // geometry
                         )
                        );

  world.addDynamicBody(new RigidBody(    // id = 8
                             9.0f,  // mass
                             Vector3f(20, -20f, 250f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f), 0.76f  // geometry
                         )
                        );


  world.addDynamicBody(new RigidBody(    // id = 9
                             9.0f,  // mass
                             Vector3f(0, 0f, -8000f),   // position
                             Quaternionf(0f, 0f, 0f, 1.0f), // orientation
                             new Sphere(Vector3f(0,0,0), 19.0f*1.1f), 0.4f  // geometry
                         )
                        );

 
    for(int i = 0; i < 9; ++ i)
        world.getDynamicBody(i).applyTorque(Vector3f(-i*20000+100000,i*40000,-i*15500));

    world.getDynamicBody(9).applyForce(Vector3f(0,0,960000));
    world.getDynamicBody(9).applyTorque(Vector3f(-10000,-90000,0));


    auto scene = delegate()
    {
        Sphere1.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(0).transformation * initScaleTransformation(0.5f, 0.5f, 0.5f)//First sphere
                           );

        Sphere2.render (shader.getUniformLocation("meshTransformation"),
                             shader.getUniformLocation("sampler"),
                             world.getDynamicBody(1).transformation * initScaleTransformation(0.5f, 0.5f, 0.5f) //Second sphere
                            );

        Sphere3.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(2).transformation * initScaleTransformation(0.5f, 0.5f, 0.5f)
                            //* initScaleTransformation(0.5f, 0.5f, 0.5f)  //3 sphere
                           );

        Sphere4.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(3).transformation * initScaleTransformation(0.5f, 0.5f, 0.5f) //4 sphere
                           );

        Sphere5.render (shader.getUniformLocation("meshTransformation"),
                             shader.getUniformLocation("sampler"),
                             world.getDynamicBody(4).transformation * initScaleTransformation(0.5f, 0.5f, 0.5f) //5 sphere
                            );

        Sphere6.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(5).transformation //6 sphere
                           );

        Sphere7.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(6).transformation
                            //* initScaleTransformation(0.5f, 0.5f, 0.5f)  //3 sphere
                           );

        Sphere8.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(7).transformation //4 sphere
                           );

        Sphere9.render (shader.getUniformLocation("meshTransformation"),
                             shader.getUniformLocation("sampler"),
                             world.getDynamicBody(8).transformation //5 sphere
                            );

        Sphere10.render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(9).transformation * initScaleTransformation(1.1f, 1.1f, 1.1f) //6 sphere
                           );

        //step += 0.02f;
        world.update(engine.SPF);
    };

    engine.execute(scene, shader.getUniformLocation("WVPTransformation"));

}
