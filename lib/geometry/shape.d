module lib.geometry.shape;

private
{
    import lib.math.matrix;
}

abstract class Shape
{
    Matrix4x4f transformation;

    this() pure nothrow @safe
    {
        transformation = Matrix4x4f.identity;
    }

    Matrix3x3f inertiaTensor(float mass)
    {
        return Matrix3x3f.identity * mass;
    }
};
