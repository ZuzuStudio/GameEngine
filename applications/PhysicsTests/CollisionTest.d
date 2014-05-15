import std.stdio;
import lib.math.vector;

import lib.physics.physicsworld;
import lib.geometry.sphere;

/**
 *  Two spheres collision test
 */
void main()
{
    PhysicsWorld world = new PhysicsWorld(0.0f);
    world.addDynamicBody(new RigidBody(    // id = 0
                             1.0f,  // mass
                             Vector3f(0,0,0),   // position
                             Quaternionf(0,0,0,0), // orientation
                             new Sphere(Vector3f(0,0,0), 4.0f)  // geometry
                            )
              );

    world.addDynamicBody(new RigidBody(    // id = 1
                             1.0f,  // mass
                             Vector3f(16,0,0),   // position
                             Quaternionf(0,0,0,0), // orientation
                             new Sphere(Vector3f(0,0,0), 4.0f)  // geometry
                            )
              );

    world.getDynamicBody(0).applyForce(Vector3f(2,0,0));
    world.getDynamicBody(0).applyTorque(Vector3f(2,0,0));

    world.getDynamicBody(1).applyForce(Vector3f(-2,0,0));
    world.getDynamicBody(1).applyTorque(Vector3f(-2,0,0));

    foreach(i; 0..1_000){
        world.update(1 / 60.0f);

        writeln(world.getDynamicBody(0).position);
        writeln(world.getDynamicBody(1).position);
    }
}
