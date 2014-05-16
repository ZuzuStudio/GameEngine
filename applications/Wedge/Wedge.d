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
  WackyRender engine = new WackyRender("Collision", WackyWindowMode.FULLSCREEN_MODE);
    WackyRenderInitializer.initialize(engine);
    engine.observer.setStep(50.0f);
    engine.observer.setPosition(0.0f, 0.0f, -300.0f);

    WackyShaderProgram shader = new WackyShaderProgram;
    shader.attachShader("shaders/vertexShader.glsl", WackyShaderTypes.VERTEX_SHADER);
    shader.attachShader("shaders/fragmentShader.glsl", WackyShaderTypes.FRAGMENT_SHADER);
    shader.linkShaderProgram();
    shader.useShaderProgram();
    
    engine.observer.setPosition(-200, 100, -2000);

    /* container of speres meshses */
    WackySimpleMesh []spheries;
    
    /* lenght of edge of cube concist of spheres */
/*-----------------------------------------------*/
    int size = 7;
/*-----------------------------------------------*/

    foreach(i; 0..size * size * size ){
        WackySimpleMesh sphere = new WackySimpleMesh("models/sphere.md2");
        sphere.setTexture("textures/wood.jpg");
        spheries ~= sphere;
    }

    /* The Distroyers*/
    WackySimpleMesh distroyers[];
    
/*-----------------------------------------------*/
    int distrNumber = 7; // number of destroyres
/*-----------------------------------------------*/
    foreach(i; 0..distrNumber){
        WackySimpleMesh distroyer = new WackySimpleMesh("models/sphere.md2");
        distroyer.setTexture("textures/metal.jpg");
        distroyers ~= distroyer;
    }

    spheries ~= distroyers;
    
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
     
    /* The distroyers */
    float k = 3;        // size koeff of big sphere (of Distroyers)
    foreach(i; 0..distrNumber/2){
        RigidBody rb = new RigidBody(10.0f, // mass
                                       Vector3f(size* i * 10, size * i * 10, -10_000 + i * 2_00),        // position
                                       Quaternionf(0,0,0,1),            // orientation
                                       new Sphere(Vector3f(), 19 * k),    // sphere with radius 19.0
                                       1.0);                              // bounce 
        
        rb.applyForce(Vector3f(0,0,1_000_000));
        rb.applyTorque(Vector3f(i*10_000, i*10_000, i*10_000));
        world.addDynamicBody(rb);
    }
    
    foreach(i; (distrNumber/2)..distrNumber){
        RigidBody rb = new RigidBody(10.0f, // mass
                                       Vector3f(size* i * 10, size * i * 10, -10_000 + (distrNumber - i) * 2_00),        // position
                                       Quaternionf(0,0,0,1),            // orientation
                                       new Sphere(Vector3f(), 19 * k),    // sphere with radius 19.0
                                       1.0);                              // bounce 
        
        rb.applyForce(Vector3f(0,0,1_000_000));
        rb.applyTorque(Vector3f(i*10_000, i*10_000, i*10_000));
        world.addDynamicBody(rb);
    }
        
    auto scene = delegate()
    {   
        foreach(i; 0..size * size * size)
        {
            spheries[i].render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(i).transformation
                           );
        }   
        
         foreach(i; size * size * size..size * size *size + distrNumber)
        {
            spheries[i].render (shader.getUniformLocation("meshTransformation"),
                            shader.getUniformLocation("sampler"),
                            world.getDynamicBody(i).transformation * initScaleTransformation(k, k, k) 
                           );
        }   

         world.update(engine.SPF);
    };

    engine.execute(scene, shader.getUniformLocation("WVPTransformation"));

}
