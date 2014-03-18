module lib.math.quaternion;

private
{
    import std.stdio;
    import std.conv;
    import std.range;
    import std.format;
    import std.math;
    import std.traits;

    import lib.math.vector;
}

public:

struct Quaternion(T)
{
    public:

    /**
     *  Constructor
     */
    this (T x, T y, T z, T w)
    {
        x = x;
        y = y;
        z = z;
        w = w;
    }

    /**
     *  Constructor that uses vector & angle
     */
    this (Vector!(T, 3) v, T w)
    {
        vector = v;
        angle = w;
    }

    /**
     *  Postblit сonstructor
     */
    this(this)
    {
        vector = vector;
        angle = angle;
    }

    private:
        Vector!(T, 3) vector;
        T angle;
}

/**
 * Predefined quaternion types
 */
alias Quaternion!(float) Quaternionf;

unittest {
    // Constructors testing
    Vector3f v = Vector3f(1.0, 2.0, 3.0);
    Quaternionf q = Quaternionf(v, 4.5);
    assert(q.vector == v && (q.angle - 4.5) < float.epsilon);
}
