module lib.math.vector;

private
{
    import std.math;
    import std.format;
    import std.range;
    import std.traits, std.stdio;
}

struct Vector(T, int size)
{
public:

    /*
     *  Constructor
     */
    this(T[] values...)
    {
        if(values.length == size){

            foreach(i; 0..size)
                coordinates[i] = values[i];
        }
    }

    /*
     *  Copy сonstructor
     */
    //this(this){
    //    coordinates = coordinates.dup;
    //}

    /*
     *  Operation assign
     */
    ref Vector!(T, size) opAssign(ref const Vector!(T, size) v)
    {
        if(v.coordinates.length == size)
            foreach(i; 0..size)
                coordinates[i] = v.coordinates[i];
        // TO DO
        // behavior in case of different lengths of vectors

        return this;
    }

    /*
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

    /*
     *  Binary operations +, -, +=, -= for two vectors
     */
    Vector!(T, size) opBinary(string op)(Vector!(T, size) right) const
    if(op == "+" || op == "-" || op == "+=" || op == "-=" )
    {
        Vector!(T, size) result;

        foreach(i; 0..size)
        mixin("result.coordinates[i] = coordinates[i] " ~ op ~ " right.coordinates[i];");
        return result;
    }

    /*
     *  Binary operations *, /, *=, /= for vector and scalar
     */
    Vector!(T, size) opBinary(string op)(T scalar) const
    if(op == "*" || op == "/" || op == "*=" || op == "/=")
    {
        Vector!(T, size) result;

        foreach(i; 0..size)
        mixin("result.coordinates[i] = cast(T)(coordinates[i] " ~ op ~ " scalar);");
        return result;
    }

    /*
     *  Idex operation
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

    /*
     *  Get Vector length squared
     */
    @property T lengthsqr()
    {
        T lensqr = 0;
        foreach (component; coordinates)
        lensqr += component * component;
        return lensqr;
    }

    /*
     *  Get vector length
     */
    @property T length()
    {
        static if (isFloatingPoint!T)
        {
            T lensqr = lengthsqr();
            return sqrt(lensqr);
        }
        // TO DO
        // behavior in case of integer vectors
    }

    /*
     *  Set vector length to 1
     */
    void normalize()
    {
        static if (isFloatingPoint!T)
        {
            T lensqr = lengthsqr();
            if (lensqr > 0)
            {
                T coef = 1.0 / sqrt(lensqr);
                foreach (ref component; coordinates)
                component *= coef;
            }
        }
        // TO DO
        // behavior in case of integer vectors
    }

    /*
     *  Return normalized copy
     */
    @property Vector!(T, size) normalized()
    {
        Vector!(T, size) result = this;
        result.normalize();
        return result;
    }

    /*
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

    /*
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
    T[size] coordinates; // = new T [size];
}

/*
 * Dot product
 */
T dot(T, int size) (Vector!(T, size) a, Vector!(T, size) b)
 {
    T result = 0;
    foreach(i; 0..size)
        result += a.coordinates[i] * b.coordinates[i];
    return result;
 }

/*
 * Cross product for 3D vectors
 */
Vector!(T, size) cross(T, int size) (Vector!(T, size) a, Vector!(T, size) b)
    if(size == 3)
{
    /*
     *     | i   j   k   |
     * det | a.x a.y a.z | = i((a.y * b.z) - (a.z * b.y)) + j((a.z * b.x) - (a.x * b.z)) +k((a.x * b.y) - (a.y * b.x));
     *     | b.x b.y b.z |
     */
    return Vector!(T, size)
    (
        (a.y * b.z) - (a.z * b.y),
        (a.z * b.x) - (a.x * b.z),
        (a.x * b.y) - (a.y * b.x)
    );
}

/*
 *  Compute distance between two points
 */
T distance(T) (Vector!(T, size) a, Vector!(T, size) b)
{
    Vector!(T, size) difference =  a - b;
    return difference.length;
}

/*
 *  Compute distance squared between two points
 */
T distancesqr(T) (Vector!(T,3) a, Vector!(T,3) b)
{
    Vector!(T, size) difference =  a - b;
    return difference.lengthsqr;
}

/*
 * Predefined vector types
 */
alias Vector!(float, 3) Vector3f;

unittest
{
    Vector3f a = Vector3f(1.0f, 2.0f, 3.0f);
    Vector3f b = -a;
    Vector3f c = a + b;
    float d =  dot(a, b);
    Vector3f f = cross(a, b);

    assert(c.isZero);
    assert(d == -14.0);
    assert(f.isZero);
    assert(a.lengthsqr == 14.0f);
}
