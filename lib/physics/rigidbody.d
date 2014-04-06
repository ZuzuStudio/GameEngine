module physics.rigidbody;

import lib.math.vector;
import lib.math.quaternion;
import lib.math.matrix;
import lib.geometry.shape;

/**
 *  Absolute rigid body
 */
class RigidBody
{
public:
    this()
    {
        position = Vector3f(0.0f, 0.0f, 0.0f);
        orientation = Quaternionf(0.0f, 0.0f, 0.0f, 1.0f);

        mass = 1.0f;
        invMass = 1.0f;

        linearVelocity = Vector3f(0.0f, 0.0f, 0.0f);
        linearAcceleration = Vector3f(0.0f, 0.0f, 0.0f);

        angularVelocity = Vector3f(0.0f, 0.0f, 0.0f);
        angularAcceleration = Vector3f(0.0f, 0.0f, 0.0f);

        forceAccumulator = Vector3f(0.0f, 0.0f, 0.0f);
        torqueAccumulator = Vector3f(0.0f, 0.0f, 0.0f);

        shape = null;
    }

private:
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

    Shape shape;
}
