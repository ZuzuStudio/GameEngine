module lib.physics.physicsworld;
public
{
    import lib.physics.rigidbody;
    import lib.physics.collision;
    import lib.physics.solver;
}

/**
 *  Physics world
 */
class PhysicsWorld{
public:
    this(float gravitation = 9.81f) pure nothrow @safe
    {
        this.gravitation = Vector3f(0, -gravitation, 0);
    }

    void addDynamicBody(RigidBody dynamicBody) pure nothrow @safe
    {
        dynamicBodies ~= dynamicBody;
    }

    void update(double dt) pure nothrow @safe
    {
        if (dynamicBodies.length == 0)
            return;

        foreach(dynamicBody; dynamicBodies){

            dynamicBody.applyForce(gravitation * dynamicBody.mass);
            dynamicBody.integrateForces(dt);
            dynamicBody.resetForces();
        }

        findDynamicCollisions();
        solveContacts(dt);

        foreach(dynamicBodiy; dynamicBodies)
        {
            dynamicBodiy.integrateVelocities(dt);
        }
    }

    RigidBody getDynamicBody(size_t i) pure nothrow @safe
    in
    {
        assert(i >= 0 && i < dynamicBodies.length, "RigidBody getBody(size_t i): out of bounds.");
    }
    body
    {
        return dynamicBodies[i];
    }

private:
    void findDynamicCollisions() pure nothrow @safe
    {
        for(int i = 0; i < dynamicBodies.length; ++i)
            for(int j = i+1; j < dynamicBodies.length; ++j)
            {
                Contact c;
                if(CollisionSphereVsSphere(dynamicBodies[i].geometry, dynamicBodies[j].geometry, c))
                {
                    c.body1 = dynamicBodies[i];
                    c.body2 = dynamicBodies[j];
                    contacts ~= c;
                }
            }
    }

    void solveContacts(float dt) pure nothrow @safe
    {
        foreach(contact; contacts)
            solveContact(contact, dt);
        contacts.length = 0;
    }

    Contact []contacts;
    RigidBody []dynamicBodies;
    Vector3f gravitation;
}
