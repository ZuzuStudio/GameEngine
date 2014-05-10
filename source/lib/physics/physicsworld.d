module lib.physics.physicsworld;
public
{
    import lib.physics.rigidbody; 
}

/**
 *  Physics world
 */
class PhysicsWorld{
public:
    this(float gravitation = 9.81f) pure nothrow @safe
    {
        this.gravitation = gravitation;
    }

    void addDynamicBody(RigidBody dynamicBody) pure nothrow @safe
    {
        dynamicBodies ~= dynamicBody;
    }

    void update(double dt) pure nothrow @safe
    {
        if (dynamicBodies.length == 0)
            return;
    }

private:
    RigidBody []dynamicBodies;
    Vector3f gravitation;
}
