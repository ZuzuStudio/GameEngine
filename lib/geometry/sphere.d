module lib.geometry.sphere;

private
{
    import lib.geometry.geometry;
    import lib.math.squarematrix;
}

class Sphere : Geometry
{
    this(float r) pure nothrow @safe
    {
        radius = r;
    }

    /**
     *  Inertia tensor of sphere equals to 2/5 * mass* r^2
     */
    override Matrix3x3f inertiaTensor(float mass) pure nothrow @safe
    {
        float v = 0.4f * mass * radius * radius;

        return Matrix3x3f(
                   v, 0f, 0f,
                   0f, v, 0f,
                   0f, 0f, v
               );
    }

private:
    float radius;
};
