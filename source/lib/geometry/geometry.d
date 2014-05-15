module lib.geometry.geometry;

public import lib.math.squarematrix;

/**
 *  Abstract geometry
 */
abstract class Geometry
{
    this(Geometry original) pure nothrow @safe
    {
            transformation = original.transformation;
    }

    Matrix4x4f transformation;

    this() pure nothrow @safe
    {
        transformation = Matrix4x4f.identity;
    }

    Matrix3x3f inertiaTensor(float mass) pure nothrow @safe
    {
        return Matrix3x3f.identity * mass;
    }
};
