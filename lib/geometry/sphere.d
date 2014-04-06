module lib.geometry.sphere;

private
{
    import lib.geometry.shape;
    import lib.math.matrix;
}

class Sphere : Shape
{
    this(float r)
    {
        radius = r;
    }

    override Matrix3x3f inertiaTensor(float mass)
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
