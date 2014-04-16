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
    Quaternion!(T) opBinary(string op)( T scalar) const pure nothrow @safe
    if(op == "*" || op == "/")
    {
        Quaternion!(T) result = this;
        mixin("return result "~op~"= scalar;");
    }

    /**
     *  Operators *= and /= for quaternion and scalar
     */
    Quaternion!(T) opOpAssign(string op)(T scalar) pure nothrow @safe
    if(op == "*" || op == "/")
    {
        mixin("x " ~op~ "= scalar;"
              "y " ~op~ "= scalar;"
              "z " ~op~ "= scalar;"
              "w " ~op~ "= scalar;");
        return this;
    }

    /**
     *  Binary operetor +, -, * for two quaternions
     */
    Quaternion!(T) opBinary(string op)(Quaternion!(T) right) pure nothrow @safe
    if(op == "+" || op == "-" || op == "*")
    {
        Quaternion!(T) result = this;
        mixin("return result" ~ op ~ "= right;");
    }

    /**
     *  Binary operetor += , -= for two quaternions
     */
    Quaternion!(T) opOpAssign(string op)(Quaternion!(T) right) pure nothrow @safe
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
     *  Binary operetor *= for two quaternions
     */
    Quaternion!(T) opOpAssign(string op)(Quaternion!(T) right) pure nothrow @safe
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
    // Operetors testing
    Quaternionf q = Quaternionf(1.0, 2.0, 3.0, 0.5);
    Quaternionf q1 = -q;
    assert(q == -q1);
    q1 = 3f * q;

    assert(3f * q  == Quaternionf(3.0, 6.0, 9.0, 1.5));
}
