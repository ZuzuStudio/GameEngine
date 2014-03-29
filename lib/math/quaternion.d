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
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    /**
     *  Constructor that uses vector & angle
     */
    this (Vector!(T, 3) v, T w)
    {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
        this.w = w;
    }

    /**
     *  Constructor that uses quaternion
     */
    this (Quaternion!(T) q)
    {
        x = q.x;
        y = q.y;
        z = q.z;
        w = q.w;
    }

    /**
     *  Default postblit сonstructor
     */

    /**
     *  Default assign operator
     */

    /**
     *  Operators *= and /= for quaternion and scalar
     */
     Quaternion!(T) opOpAssign(string op)(ref const T)
        if(op == "*" || op == "/")
     {

     }

     /**
     *  Unary operations + and -
     */
    Quaternion!(T) opUnary(string op)() const
    if(op == "+" || op == "-")
    {
        // Fell the power of Dlang!
        mixin("return Quaternion!(T)(" ~ op ~ "x, " ~ op ~ "y, " ~ op ~ "z, " ~ op ~ "w);");
    }

    @property string toString()
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", components);
        return writer.data;
    }

private:
    union
    {
        struct
        {
            T x, y, z, w;
        }
        T[4] components;
    }
}

/**
 * Predefined quaternion types
 */
alias Quaternion!(float) Quaternionf;
alias Quaternion!(double) Quaterniond;

unittest
{
    // Constructors testing
    Quaternionf q = Quaternionf(1.0, 2.0, 3.0, 3.14);
    assert((q.x - 1.0 < float.epsilon) && (q.y - 2.0 < float.epsilon) && (q.z - 3.0 < float.epsilon) && (q.w - 3.14 < float.epsilon));
    Vector3f v = Vector3f(1.9, 2.7, 3.1);
    Quaternionf q1 = Quaternionf(v, 6.2);
    assert((q1.x - v.x < float.epsilon) && (q1.y - v.y < float.epsilon) && (q1.z - v.z < float.epsilon) && (q1.w - 6.2 < float.epsilon));
}

unittest
{
    Quaternionf q = Quaternionf(1.0, 2.0, 3.0, 3.14);
    Quaternionf q1 = -q;
    assert(q == -q1);
}
