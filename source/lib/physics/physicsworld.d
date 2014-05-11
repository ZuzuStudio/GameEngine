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
        
        findDynamicCollisions();
        
        solveContacts(dt);

        foreach(dynamicBody; dynamicBodies)
            dynamicBody.applyForce(gravitation * dynamicBody.mass);

    
    }

private:

    void findDynamicCollisions() pure nothrow @safe
    {
        foreach(body1; dynamicBodies)
            foreach(body2; dynamicBodies)
            {
                Contact c;
                if(collided(body1.geometry, body2.geometry, c))
                contacts ~= c;
            }
    }

    void solveContacts(float dt) pure nothrow @safe
    {
        foreach(contact; contacts)
            solveContact(contact, dt);
    }
    
    Contact []contacts;
    RigidBody []dynamicBodies;
    Vector3f gravitation;
}
