module lib.physics.collision;

import lib.physics.contact;
import lib.geometry.sphere;

/**
 *  I absolutly agree with your opinion:
 *  it's horrible piece of crap.
 *  But I need this wrapper 
 */
bool collided(Geometry geometry1, Geometry geometry2, ref Contact contact) pure nothrow @safe
in
{
    assert(is (geometry1 : Sphere) && is (geometry2 : Sphere), "Unfortunatly function collided supports only spheres now");
}
body
{
    return CollisionSphereVsSphere(cast(Sphere)geometry1,cast(Sphere) geometry2, contact);
}

/**
 *  It's detects collisions beytween sphere vs sphere
 */
bool CollisionSphereVsSphere(Sphere sphere1, Sphere sphere2, ref Contact contact) pure nothrow @safe
{
    /**  If distance betwen centres of spheres is less ther R1 + R2 => it's collision   */

    float distance = distance(sphere1.center, sphere2.center);
    float radiusSum = sphere1.radius + sphere2.radius;

    if(distance < radiusSum)
    {
        contact.penetration = radiusSum - distance;
        contact.normal = (sphere1.center - sphere2.center).normalized;
        contact.point = sphere2.center + contact.normal * sphere2.radius;
        return true;
    }

    return false;
};
