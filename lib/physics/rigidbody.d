module physics.rigidbody;

import lib.math.vector;
import lib.math.quaternion;
import lib.math.matrix;

/**
 *  Absolute rigid body
 */

class RigidBody
{
    Vector3f position;
    Quaternionf orientation;

    float mass;
    float invMass;
    Vector3f linearVelocity;
    Vector3f linearAcceleration;

    Matrix3x3f inertia;
    Matrix3x3f invInertia;
    Vector3f angularVelocity;
    Vector3f angularAcceleration;

    Vector3f forceAccumulator;
    Vector3f torqueAccumulator;

//    Geometry geometry;
}
