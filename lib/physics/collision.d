module lib.physics.collision.d;

import lib.physics.contact;
import lib.geometry.sphere;

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
