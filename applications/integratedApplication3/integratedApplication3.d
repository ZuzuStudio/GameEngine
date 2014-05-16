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

    /**
     * Graphics settings
     */
    WackyRender engine = new WackyRender("Collision", WackyWindowMode.WINDOW_MODE, 400, 400);
    WackyRenderInitializer.initialize(engine);
    engine.observer.setStep(50.0f);
    engine.observer.setPosition(0.0f, 0.0f, -300.0f);

    WackyShaderProgram shader = new WackyShaderProgram;
    shader.attachShader("shaders/vertexShader.glsl", WackyShaderTypes.VERTEX_SHADER);
    shader.attachShader("shaders/fragmentShader.glsl", WackyShaderTypes.FRAGMENT_SHADER);
    shader.linkShaderProgram();
    shader.useShaderProgram();

    engine.observer.setPosition(-200, 100, -2000);

    /* container of spheres meshses */
    WackySimpleMesh []spheres;

    /* lenght of edge of cube concist of spheres */
/*-----------------------------------------------*/
    int size = 8;
/*-----------------------------------------------*/

    foreach(i; 0..size * size * size ){
        WackySimpleMesh sphere = new WackySimpleMesh("models/sphere.md2");
        spheres ~= sphere;
    }

    /* The Destroyers*/
    WackySimpleMesh destroyers[];

/*-----------------------------------------------*/
    int destrNumber = 8; // number of destroyers
/*-----------------------------------------------*/
    foreach(i; 0..destrNumber){
        WackySimpleMesh destroyer = new WackySimpleMesh("models/sphere.md2");
        destroyers ~= destroyer;
    }

    spheres ~= destroyers;

    engine.enableVSync();

    /**
     *   Physics settings
     */

    PhysicsWorld world = new PhysicsWorld(0.0f);  // gravitation

    foreach(x; 0..size)
    foreach(y; 0..size)
    foreach(z; 0..size)
    {
            RigidBody rb = new RigidBody(1.0f,                            // mass
                                           Vector3f(x*50, y*50, z*50),        // position
                                           Quaternionf(0,0,0,1),            // orientation
                                           new Sphere(Vector3f(), 19),    // sphere with radius 19
                                           0.8);                              // bounce

            rb.applyTorque(Vector3f(x*10_000, y*10_000, z*10_000));
            world.addDynamicBody(rb);
    }

    /* The destroyers */
    float k = 3;        // size koeff of big sphere (of Destroyers)
    foreach(i; 0..destrNumber){
        RigidBody rb = new RigidBody(10.0f, // mass
                                       Vector3f(size* i * 5, size * i * 5, -10_000 - i * 5_00),        // position
                                       Quaternionf(0,0,0,1),            // orientation
                                       new Sphere(Vector3f(), 19 * k),    // sphere with radius 19.0
                                       1.0);                              // bounce

        rb.applyForce(Vector3f(0,0,2_000_000));
        rb.applyTorque(Vector3f(i*10_000, i*10_000, i*10_000));
        world.addDynamicBody(rb);
    }

    auto scene = delegate()
    {
        foreach(i; 0..size * size * size)
        {
            spheres[i].render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(i).transformation
                           );
        }

         foreach(i; size * size * size..size * size *size + destrNumber)
        {
            spheres[i].render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(i).transformation * initScaleTransformation(k, k, k)
                           );
        }


        world.update(engine.SPF);
    };

    engine.execute(false, scene, shader.getUniformLocation("WVPTransformation"));

}
