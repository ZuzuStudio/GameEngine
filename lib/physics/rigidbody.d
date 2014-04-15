module physics.rigidbody;

import lib.math.vector;
import lib.math.quaternion;
import lib.math.squarematrix;
import lib.geometry.geometry;

/**
 *  Absolute rigid body
 */
class RigidBody
{
public:
    this()
    {

        mass = 1.0f;
        invMass = 1.0f;
        position = Vector3f();
        linearVelocity = Vector3f();
        inertia = Matrix3x3f.identity;
        invInertia = Matrix3x3f.identity;
        orientation = Quaternionf();
        angularAcceleration = Vector3f();
        torqueAccumulator = Vector3f();

        geometry = null;
    }

    void integrateForces(float dt)
    {
        linearAcceleration = forceAccumulator * invMass;
        linearVelocity += linearAcceleration * dt;


        angularAcceleration = inertia * torqueAccumulator;
        angularVelocity += angularAcceleration * dt;
    }

    void integrateVelocities(float dt)
    {
        if (linearVelocity.length < float.epsilon)
            linearVelocity = Vector3f(0.0f, 0.0f, 0.0f);
        if (angularVelocity.length < float.epsilon)
            angularVelocity = Vector3f(0.0f, 0.0f, 0.0f);

        position += linearVelocity * dt;
        orientation += 0.5f * Quaternionf(angularVelocity, 0.0f) * orientation * dt;
        // orientation.normalize();
    }

    void setGeometry(Geometry geometry)
    {
        this.geometry = geometry;

        inertia = geometry.inertiaTensor(mass);
        //  invInertia = inertia.inverse;
     }

    void applyForce(Vector3f force)
    {
        forceAccumulator += force;
    }

    void applyTorque(Vector3f torque)
    {
        torqueAccumulator += torque;
    }

private:

    float mass;
    float invMass;
    Vector3f position;
    Vector3f linearVelocity;
    Vector3f linearAcceleration;
    Vector3f forceAccumulator;


    Matrix3x3f inertia;
    Matrix3x3f invInertia;
    Quaternionf orientation;
    Vector3f angularVelocity;
    Vector3f angularAcceleration;
    Vector3f torqueAccumulator;

    Geometry geometry;
}
