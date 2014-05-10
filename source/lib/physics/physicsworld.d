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
    this(float gravitation = 9.81f)
    {
        this.gravitation = gravitation;
    }

    void addDynamicBody(RigidBody dynamicBody)
    {
        dynamicBodies ~= dynamicBody;
    }

    void update(double dt)
    {
        if (dynamicBodies.length == 0)
            return;
    }

private:
    RigidBody []dynamicBodies;
    Vector3f gravitation;
}
