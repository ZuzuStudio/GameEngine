module lib.physics.contact;

public
{
    import lib.physics.rigidbody;
    import lib.math.vector;
}

/**
 *  Contact of two rigid bodyes
 */
struct Contact
{
    RigidBody body1;
    RigidBody body2;
  
    Vector3f point;
    Vector3f normal;
  
    float penetration;
};
