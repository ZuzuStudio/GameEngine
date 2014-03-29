module lib.math.vector;

private
{
    import std.math;
    import std.format;
    import std.range;
    import std.traits;
}

struct Vector(T, size_t size)
if(isNumeric!T && size > 0 && size <= 4)
{
public:

    /**
     *  Constructor with variable number of arguments
     */
    this(T[] values...)
    {
        if(values.length == size)
        {

            foreach(i; 0..size)
            coordinates[i] = values[i];
        }
        else
        {
            assert(false, "The number of constructor parameters does not match vector dimension.");
        }
    }

    /**
     *  Constructor that uses array of values
     *  It is not used at any situations at the moment
     */
    this(T[] values)
    {
        if(values.length == size)
        {

            foreach(i; 0..size)
            coordinates[i] = values[i];
        }
        else
        {
            assert(false, "The length of array that transmitted to constructor does not match vector dimension.");
        }
    }

    /**
     *  Constructor that uses vector
     */
    this(Vector!(T, size) v)
    {
        coordinates[] = v.coordinates[];
    }

    /**
    *  Default postblit constructor
    */

    /**
     *  Default assign operator
    */

    /**
     *  Operators *= and /= for vector and scalar
     */
    ref Vector!(T, size) opOpAssign(string op)(ref const T scalar)
    if(op == "*" || op == "/")
    {
        foreach(i; 0..size)
        mixin("coordinates[i] " ~ op ~ "= scalar;");
        return this;
    }

    /**
     *  Operators += and -= for two vectors
     */
    ref Vector!(T, size) opOpAssign(string op)(ref const Vector!(T, size) right)
    if(op == "+" || op == "-")
    {
        foreach(i; 0..size)
        mixin("coordinates[i] " ~ op ~ "= right.coordinates[i];");
        return this;
    }

    /**
     *  Binary operator +, -, * and / for possible combination of vector and scalar
     */
    Vector!(T, size) opBinary(string op, U)(ref const U right) const
    if((is(U == Vector!(T,size)) && (op == "+" || op == "-")) || (is(U == T) && (op == "*" || op == "/")))
    {
        Vector!(T, size) result = this;
        mixin("result " ~ op ~ "= right;");
        return result;
    }

    /**
     *  Unary operations + and -
     */
    Vector!(T, size) opUnary(string op)() const
    if(op == "+" || op == "-")
    {
        Vector!(T, size) result;
        foreach(i; 0..size)
        mixin("result.coordinates[i] = " ~ op ~ "coordinates[i];");
        return result;
    }

    /**
     *  Index operation
     */
    ref T opIndex (this vector)(size_t index)
    in
    {
        assert ((0 <= index) && (index < size),
        "Vector!(T,size).opIndex(size_t index): array index out of bounds");
    }
    body
    {
        return coordinates[index];
    }

    /**
     *  Get Vector length squared
     */
    @property T lengthsqr()
    {
        T lensqr = 0;
        foreach (component; coordinates)
        lensqr += component * component;
        return lensqr;
    }

    /**
     *  Get vector length
     */
    @property T length()
    {
        static if (isFloatingPoint!T)
        {
            T lensqr = lengthsqr();
            return sqrt(lensqr);
        }
        else
        {
            // TODO
            // behavior in case of integer vectors
            return cast(T)0;
        }
    }

    /**
     *  Set vector length to 1
     */
    void normalize()
    {
        static if (isFloatingPoint!T)
        {
            T lensqr = lengthsqr();
            if (lensqr > T.epsilon)
            {
                T coef = 1.0 / sqrt(lensqr);
                foreach (ref component; coordinates)
                component *= coef;
            }
        }
        else
        {
            // TODO
            // behavior in case of integer vectors
        }
    }

    /**
     *  Return normalized copy
     */
    @property Vector!(T, size) normalized()
    {
        Vector!(T, size) result = this;
        result.normalize();
        return result;
    }

    /**
     *  Return true if all components are zero
     */
    @property bool isZero()
    {
        foreach(i; 0..size)
        if(coordinates[i] != 0)
            return false;

        return true;
    }

    @property string toString()
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", coordinates);
        return writer.data;
    }

    /**
     *  Swizzling
     */
    template opDispatch(string s)
    if (s == "x" || s == "y" || s == "z")
    {
        enum i = ["x":0, "y":1, "z":2][s];

        @property auto ref opDispatch(this X)()
        {
            return coordinates[i];
        }
    }

private:
    T[size] coordinates;
}

/**
 * Dot product
 */
T dot(T, int size) (Vector!(T, size) a, Vector!(T, size) b)
{
    T result = 0;
    foreach(i; 0..size)
    result += a.coordinates[i] * b.coordinates[i];
    return result;
}

/**
 * Cross product for 3D vectors
 *
 *     | i   j   k   |
 * det | a.x a.y a.z | = i((a.y * b.z) - (a.z * b.y)) + j((a.z * b.x) - (a.x * b.z)) +k((a.x * b.y) - (a.y * b.x));
 *     | b.x b.y b.z |
 */
Vector!(T, size) cross(T, int size) (Vector!(T, size) a, Vector!(T, size) b)
if(size == 3)
{

    return Vector!(T, size)
    (
        (a.y * b.z) - (a.z * b.y),
        (a.z * b.x) - (a.x * b.z),
        (a.x * b.y) - (a.y * b.x)
    );
}

/**
 *  Compute distance between two points
 */
T distance(T) (Vector!(T, size) a, Vector!(T, size) b)
{
    Vector!(T, size) difference =  a - b;
    return difference.length;
}

/**
 *  Compute distance squared between two points
 */
T distancesqr(T) (Vector!(T,3) a, Vector!(T,3) b)
{
    Vector!(T, size) difference =  a - b;
    return difference.lengthsqr;
}

/**
 * Predefined vector types
 */
alias Vector!(float, 2) Vector2f;
alias Vector!(float, 3) Vector3f;
alias Vector!(float, 4) Vector4f;
alias Vector!(double, 2) Vector2d;
alias Vector!(double, 3) Vector3d;
alias Vector!(double, 4) Vector4d;


unittest
{
    // Testing of template instantinating and choise between static and dynamic array
    Vector!(float, 1) a;
    assert(a.coordinates.sizeof == (float[1]).sizeof);
    Vector!(float, 2) b;
    assert(b.coordinates.sizeof == (float[2]).sizeof);
    Vector3f c = Vector3f(1.0f, 2.0f, 3.0f);
    assert(c.coordinates.sizeof == (float[3]).sizeof);
    Vector!(float, 4) d;
    assert(d.coordinates.sizeof == (float[4]).sizeof);
    Vector!(double, 1) g;
    assert(g.coordinates.sizeof == (double[1]).sizeof);
    Vector!(byte, 2) h;
    assert(h.coordinates.sizeof == (byte[2]).sizeof);
}

unittest
{
    // Testing of assign operator and postbli constructor
    Vector3f a=Vector3f(1.0f, 2.0f, 3.0f);
    auto b = a;
    assert(a.coordinates !is b.coordinates);
    assert(a.coordinates == b.coordinates);
    Vector!(float, 4) c = Vector!(float, 4)(1.0f, 2.0f, 3.0f, 4.0f);
    auto d = c;
    assert(c.coordinates !is d.coordinates);
    assert(c.coordinates == d.coordinates);
    // TODO
    // test postblit
}

unittest
{
    // Testing of maath operations
    bool floatingEqual(Vector3f a, Vector3f b)
    {
        float sum = 0.0;
        foreach(i; 0..3)
        sum += (a.coordinates[i] - b.coordinates[i]) ^^ 2;
        return sqrt(sum) < sqrt(float.epsilon);
    }
    Vector3f a = Vector3f(1.0f, 2.0f, 3.0f);
    Vector3f b = Vector3f(1.0f, -2.5f, 2.0f);
    Vector3f result = Vector3f(2.0f, -0.5f, 5.0f);
    assert(floatingEqual(a+b,result));
    // TODO
    // more tests
}

unittest
{
    // Testing of functions length,isZero, dot & cross product
    Vector3f a = Vector3f(1.0f, 2.0f, 3.0f);
    assert(a.lengthsqr == 14.0f);
    Vector3f b = -a;
    assert(b == -a);
    Vector3f c = a + b;
    assert(c.isZero);
    float d =  dot(a, b);
    assert(d == -14.0);
    Vector3f f = cross(a, b);
    assert(f.isZero);
}
