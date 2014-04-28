module lib.physics.contact.d;

public import lib.physics.rigidbody;

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
