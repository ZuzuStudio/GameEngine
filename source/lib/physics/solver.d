module lib.physics.solver;

public {
    import lib.physics.contact;
    import lib.physics.rigidbody;
}

void solveContact(Contact c, float dt)
{
    RigidBody body1 = c.body1;
    RigidBody body2 = c.body2;
    
    Vector3f r1 = c.point - body1.position;
    Vector3f r2 = c.point - body2.position;
    
    Vector3f relativeVelocity;  //  by default initialization it is Vector3f(0, 0, 0);

    relativeVelocity += body1.linearVelocity + cross(body1.angularVelocity, r1);
    relativeVelocity -= body2.linearVelocity + cross(body2.angularVelocity, r2);
    
    float velocityProjection = dot(relativeVelocity, c.normal);
    
    // Check if the bodies are already moving apart
    if (velocityProjection > 0.0f)
        return;
    
    // Jacobian
    Vector3f n1 = c.normal;
    Vector3f w1 = c.normal.cross(r1);
    Vector3f n2 = -c.normal;
    Vector3f w2 = -c.normal.cross(r2);

    // TODO ...
}
