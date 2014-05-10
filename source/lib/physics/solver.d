module lib.physics.solver;

public {
    import lib.physics.contact;
    import lib.physics.rigidbody;
}

void solveContact(Contact c, float dt) pure nothrow @safe
{
    RigidBody body1 = c.body1;
    RigidBody body2 = c.body2;
    
    Vector3f r1 = c.point - body1.position;
    Vector3f r2 = c.point - body2.position;
    
    Vector3f relativeVelocity;  //  by default initialization it is the Vector3f(0, 0, 0);

    relativeVelocity += body1.linearVelocity + cross(body1.angularVelocity, r1);
    relativeVelocity -= body2.linearVelocity + cross(body2.angularVelocity, r2);
    
    float velocityProjection = dot(relativeVelocity, c.normal);
    
    /* Check if the bodies are already moving apart */
    if (velocityProjection > 0.0f)
        return;
    
    /* Jacobian */
    Vector3f n1 = c.normal;
    Vector3f w1 = c.normal.cross(r1);
    Vector3f n2 = -c.normal;
    Vector3f w2 = -c.normal.cross(r2);

    float a = dot (n1, body1.linearVelocity)
            + dot(n2, body2.linearVelocity)
            + dot(w1, body1.angularVelocity)
            + dot(w2, body2.angularVelocity);

   float b = dot(n1, n1 * body1.invMass)
           + dot(w1, w1 * body1.invInertia) 
           + dot(n2, n2 * body2.invMass)  
           + dot(w2, w2 * body2.invInertia);

    float lambda = -a / b;

    if(lambda < 0)
        lambda = 0;
    
    /* Speed correction */
    body1.linearVelocity += n1 * lambda * body1.invMass;
    body1.angularVelocity += w1 * lambda * body1.invInertia;
    body2.linearVelocity += n2 * lambda * body2.invMass;
    body2.angularVelocity += w2 * lambda * body2.invInertia;
}
