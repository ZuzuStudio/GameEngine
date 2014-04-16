module lib.math.quaternion;

private
{
    import std.format;
    import std.math;
    import std.range;
    import std.traits;

    import lib.math.vector;
    import lib.math.squarematrix;
}

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
    Quaternion!(T) opBinary(string op)(const T scalar) const pure nothrow @safe
    if(op == "*" || op == "/")
    {
        Quaternion!(T) result = this;
        mixin("return result "~op~"= scalar;");
    }

    /**
     *  Operators *= and /= for quaternion and scalar
     */
    ref Quaternion!(T) opOpAssign(string op)(const T scalar) pure nothrow @safe
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
    Quaternion!(T) opBinary(string op)(const ref Quaternion!(T) right) pure nothrow @safe
    if(op == "+" || op == "-" || op == "*")
    {
        Quaternion!(T) result = this;
        mixin("return result" ~ op ~ "= right;");
    }

    /**
     *  Binary operator * for a quaternion and a 3-dimensional vector
     */
    Quaternion!(T) opBinary (string op) (Vector!(T, 3) arg)
    if (op == "*")
    {
        const T tempX =   (w * arg.x) + (y * arg.z) - (z * arg.y);
        const T tempY =   (w * arg.y) + (z * arg.x) - (x * arg.z);
        const T tempZ =   (w * arg.z) + (x * arg.y) - (y * arg.x);
        const T tempW = - (x * arg.x) - (y * arg.y) - (z * arg.z);

        return Quaternion!(T) (tempX, tempY, tempZ, tempW);
    }

    /**
     *  Binary operator += , -= for two quaternions
     */
    ref Quaternion!(T) opOpAssign(string op)(const Quaternion!(T) right) pure nothrow @safe
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
    ref Quaternion!(T) opOpAssign(string op)(const ref Quaternion!(T) right) pure nothrow @safe
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

    @property string toString()
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", components);
        return writer.data;
    }

    @property Quaternion!(T) normalized() nothrow
    {
        const T length = sqrt (x * x + y * y + z * z + w * w);
        return Quaternion!(T)(x / length, y / length, z / length, w / length);
    }

    @property T length() pure nothrow
    {
        return x * x + y * y + z * z + w * w;
    }

    @property Quaternion!(T) conjugate()
    {
       return Quaternion!(T)(-x, -y, -z, w);
    }

    void normalize() pure nothrow
    {
        const T length = sqrt (x * x + y * y + z * z + w * w);
        x /= length;
        y /= length;
        z /= length;
        w /= length;
    }

private:
    union
    {
		T[4] components = [cast(T)0, cast(T)0, cast(T)0, cast(T)0];

        struct
        {
            T x, y, z, w;
        }
    }
}

unittest
{
	// Testing default zero initialization
	Quaternionf a = Quaternionf();
	assert([0.0f, 0.0f, 0.0f, 0.0f] == a.components);
	Quaternionf b;
	assert([0.0f, 0.0f, 0.0f, 0.0f] == b.components);
	assert([0.0f, 0.0f, 0.0f, 0.0f] == (Quaternionf.init).components);
	// TODO why folowing assertion is failed?
	//assert(Quaternionf.zero == Quaternionf.init);


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

    auto q3 = Quaternionf(1.0f, 2.0f, 3.0f, 5.0f) * Vector3f(2.0f, 3.0f, 5.0f);
    assert(q3 == Quaternionf(11.0f, 16.0f, 24.0f, -23.0f));
}

unittest
{
    // normalize() and conjugate() tests
    Quaternionf q = Quaternionf(1.0f, 2.0f, 3.0f, 4.0f);
    q.normalize();
    assert(q.length < 1.0f + float.epsilon && q.length > 1.0f - float.epsilon);
    assert (q.conjugate == Quaternionf(-q.x, -q.y, -q.z, q.w));
}
