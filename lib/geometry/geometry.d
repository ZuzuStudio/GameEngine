module lib.geometry.geometry;

private
{
    import lib.math.squarematrix;
}

abstract class Geometry
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
