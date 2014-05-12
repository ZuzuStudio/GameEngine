import std.stdio;
import lib.math.vector;

import lib.physics.physicsworld;


/**
 *  Two spheres collision example
 */
void main()
{
    PhysicsWorld world = new PhysicsWorld(0.0f);
    world.add(new RigidBody(    // id = 0
                             1.0f,  // mass
                             Vector3f(0,0,0),   // position
                             Quaternion3f(0,0,0,0), // orientation
                             new Sphere(Vector3f(0,0,0), 4.0f)  // geometry
                            )
              );

    world.add(new RigidBody(    // id = 1
                             1.0f,  // mass
                             Vector3f(16,0,0),   // position
                             Quaternion3f(0,0,0,0), // orientation
                             new Sphere(Vector3f(0,0,0), 4.0f)  // geometry
                            )
              );

    world.getDynamicBody[0].applyForce(2,0,0);
    world.getDynamicBody[0].applyTorque(2,0,0);

    world.getDynamicBody[1].applyForce(-2,0,0);
    world.getDynamicBody[1].applyTorque(-2,0,0);

    forech(i; 0..1_000_000)
        world.update(1 / 60.0f);
    
    return 0;
}
