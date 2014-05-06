module lib.math.quaternion;

private
{
    import std.format;
    import std.math;
    import std.range;
    import std.traits;
}
import lib.math.vector;
import lib.math.squarematrix;


/**
 * Predefined quaternion types
 */
alias Quaternionf = Quaternion!(float);
alias Quaterniond = Quaternion!(double);

public:

struct Quaternion(T)
{
public:

    /**
     *  Constructor
     */
    this (T x, T y, T z, T w) pure nothrow @safe
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    /**
     *  Constructor that uses vector & angle
     */
    this (Vector!(T, 3) v, T w) pure nothrow @safe
    {
        this.x = v.x;
        this.y = v.y;
        this.z = v.z;
        this.w = w;
    }

    /**
     *  Constructor that uses quaternion
     */
    this (Quaternion!(T) q) pure nothrow @safe
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
     *  Right sided operators * and / for quaternion and scalar
     */
    Quaternion!(T) opBinaryRight(string op)(T scalar) const pure nothrow @safe
    if(op == "*" || op == "/")
    {
        mixin("return this " ~op ~ " scalar;");
    }

    /**
     *  Operators * and / for quaternion and scalar
     */
    Quaternion!(T) opBinary(string op)( T scalar) const pure nothrow @safe
    if(op == "*" || op == "/")
    {
        Quaternion!(T) result = this;
        mixin("return result " ~op~ "= scalar;");
    }

    /**
     *  Operators *= and /= for quaternion and scalar
     */
    ref Quaternion!(T) opOpAssign(string op)(T scalar) pure nothrow @safe
    if(op == "*" || op == "/")
    {
        mixin("x " ~op~ "= scalar;"
              "y " ~op~ "= scalar;"
              "z " ~op~ "= scalar;"
              "w " ~op~ "= scalar;");
        return this;
    }


    /**
     *  Binary operator +, -, * for two quaternions
     */
    Quaternion!(T) opBinary(string op)(Quaternion!(T) right) const pure nothrow @safe
    if(op == "+" || op == "-" || op == "*")
    {
        Quaternion!(T) result = this;
        mixin("return result" ~ op ~ "= right;");
    }

    /**
     *  Binary operator += , -= for two quaternions
     */
    ref Quaternion!(T) opOpAssign(string op)(Quaternion!(T) right) pure nothrow @safe
    if(op == "+" || op == "-" )
    {
        mixin("x " ~op ~ "= right.x;"
              "y " ~op ~ "= right.y;"
              "z " ~op ~ "= right.z;"
              "w " ~op ~ "= right.w;"
             );
        return this;
    }

    /**
     *  Binary operator *= for two quaternions
     */
    ref Quaternion!(T) opOpAssign(string op)(Quaternion!(T) right) pure nothrow @safe
    if(op == "*")
    {
        this = Quaternion!(T)
               (
                   (x * right.w) + (w * right.x) + (y * right.z) - (z * right.y),
                   (y * right.w) + (w * right.y) + (z * right.x) - (x * right.z),
                   (z * right.w) + (w * right.z) + (x * right.y) - (y * right.x),
                   (w * right.w) - (x * right.x) - (y * right.y) - (z * right.z)
               );
        return this;
    }

    /**
     *  Binary operator * for a quaternion and a 3-dimensional vector
     */
    Quaternion!(T) opBinary (string op) (Vector!(T, 3) v) const pure nothrow @safe
    if (op == "*")
    {
        return Quaternion!(T)(this) *= v;
    }

    /**
     *  Binary operator *= for a quaternion and a 3-dimensional vector
     */
    ref Quaternion!(T) opOpAssign (string op) (Vector!(T, 3) v) pure nothrow @safe
    if (op == "*")
    {
        this = Quaternion!(T)(
                   (w * v.x) + (y * v.z) - (z * v.y),
                   (w * v.y) + (z * v.x) - (x * v.z),
                   (w * v.z) + (x * v.y) - (y * v.x),
                   - (x * v.x) - (y * v.y) - (z * v.z)
               );
        return this;
    }

    /**
     *  Unary operators + and -
     */
    Quaternion!(T) opUnary(string op)() const pure nothrow @safe
    if(op == "+" || op == "-")
    {
        // Fell the power of Dlang!
        mixin("return Quaternion!(T)(" ~ op ~ "x, " ~ op ~ "y, " ~ op ~ "z, " ~ op ~ "w);");
    }

    /**
     *  Zero property, for more sweet usability
     */
    @property static Quaternion!(T) zero() pure nothrow @safe
    {
        return Quaternion!(T).init;
    }

    @property string toString() const
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", components);
        return writer.data;
    }

    /**
     *  Get normalized copy
     */
    @property Quaternion!(T) normalized() const pure nothrow @safe
    {
        auto result = Quaternion!(T)(this);
        result.normalize();
        return result;
    }

    /**
     *  Set quaternion length to 1
     */
    void normalize() pure nothrow @safe
    {
        T length = this.length;
        x /= length;
        y /= length;
        z /= length;
        w /= length;
    }

    /**
     *  Get quaternion length
     */
    @property T length() const pure nothrow @safe
    {
        return sqrt(this.lengthsqr);
    }

    /**
     *  Get quaternion length squared
     */
    @property T lengthsqr() const pure nothrow @safe
    {
        return x * x + y * y + z * z + w * w;
    }

    /**
     *  Returns conjugate quaternion
     */
    @property Quaternion!(T) conjugate() const pure nothrow @safe
    {
        return Quaternion!(T)(-x, -y, -z, w);
    }

    union
    {
        T[4] components = [cast(T)0, cast(T)0, cast(T)0, cast(T)0];

        struct
        {
            T x, y, z, w;
        }
    }
}

/**
 *  Fast rotation using quaternions.
 *  The angle is measured in RADIANS
 *
 */
Vector!(T, 3) rotate(T, U) (Vector!(T, 3) processed, Vector!(T, 3) axis, U angle)
if( is (U:T) )
{
    const T sinHalfAngle = sin (cast(T)angle/2);
    const T cosHalfAngle = cos (cast(T)angle/2);

    Quaternion!(T) rotationQuaternion = Quaternion!(T)(
                                            axis.x * sinHalfAngle,
                                            axis.y * sinHalfAngle,
                                            axis.z * sinHalfAngle,
                                            cosHalfAngle
                                        );

    Quaternion!(T) conjugateQuaternion = rotationQuaternion.conjugate;

    Quaternion!(T) result = rotationQuaternion * processed * conjugateQuaternion;
    return Vector!(T, 3)(result.x, result.y, result.z);
}

unittest
{
    // Testing default zero initialization
    Quaternionf a = Quaternionf();
    assert([0.0f, 0.0f, 0.0f, 0.0f] == a.components);
    Quaternionf b;
    assert([0.0f, 0.0f, 0.0f, 0.0f] == b.components);
    assert([0.0f, 0.0f, 0.0f, 0.0f] == (Quaternionf.init).components);
    assert(Quaternionf.zero == Quaternionf.init);


    assert([0.0f, 0.0f, 0.0f, 0.0f] == (Quaternionf.init).components);
    assert([0.0, 0.0, 0.0, 0.0] == (Quaterniond.init).components);
}

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
    // Operators testing
    Quaternionf q = Quaternionf(1.0, 2.0, 3.0, 0.5);
    Quaternionf q1 = -q;
    assert(q == -q1);
    q1 = 3f * q;

    assert(3f * q  == Quaternionf(3.0, 6.0, 9.0, 1.5));

    Quaternionf q3 = Quaternionf(1.0f, 2.0f, 3.0f, 5.0f) *= Vector3f(2.0f, 3.0f, 5.0f);
    assert(q3 == Quaternionf(11.0f, 16.0f, 24.0f, -23.0f));
}

unittest
{
    // normalize() and conjugate() tests
    Quaternionf q = Quaternionf(1.0f, 2.0f, 3.0f, 4.0f);
    q.normalize();
    assert(q.length < 1.0f + float.epsilon && q.length > 1.0f - float.epsilon);
    Quaternionf q1 = Quaternionf(1.0f, 2.0f, 3.0f, 4.0f);
    auto q2 = q1.normalized;
    assert(q1.x == 1.0f && q1.y == 2.0f && q1.z == 3.0f && q1.w == 4.0f);
    assert(q2.length < 1.0f + float.epsilon && q2.length > 1.0f - float.epsilon);
    assert(q.conjugate == Quaternionf(-q.x, -q.y, -q.z, q.w));
}

unittest
{
    // Rotation test
    auto vector = rotate(Vector3f(1.0f, 2.0f, 4.0f), Vector3f(1.0f, 0.0f, 0.0f), 45.0f / 180.0f * PI);
    assert(vector.x < 1.0f + float.epsilon && vector.x > 1.0f - float.epsilon);
    assert(vector.y < -1.41f + 0.01f && vector.y > -1.41f - 0.01f);
    assert(vector.z < 4.24f + 0.01f && vector.z > 4.24f - 0.01f);
}
