module lib.math.vector;

private
{
    import std.conv;
    import std.math;
    import std.format;
    import std.range;
    import std.traits;
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
    this(this){
        coordinates = coordinates.dup;
    }
    /*
     *  Operation assign
     */
    void opAssign(Vector!(T, size) v)
    {
        if (v.coordinates.length == size)
            foreach(i; 0..size)
                coordinates[i] = v.coordinates[i];
        // TO DO
        // behavior in case of different lengths of vectors
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
        return res;
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
        return res;
    }

    /*
     *  Binary operations *, /, *=, /= for vector and scalar
     */
    Vector!(T, size) opBinary(string op)(S scalar) const
    if( (op == "*" || op == "/" || op == "*=" || op == "/=") && isNumeric!S )
    {
        Vector!(T, size) result;

        foreach(i; 0..size)
        mixin("result.coordinates[i] = cast(T)(coordinates[i] " ~ op ~ " scalar);");
        return res;
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
        return (coordinates[] == [0]);
    }

    @property string toString()
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", coordinates);
        return writer.data;
    }

private:
    T[] coordinates = new T [size];
}

/*
 * Dot product
 */
T dot(T, int size) (Vector!(T, size) a, Vector!(T, size) b)
{
    T result = 0;
    foreach (i; 0..size)
        result += a[i] * b[i];
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
    const Vector3f a = Vector3f(1.0f, 2.0f, 3.0f);
    const Vector3f b = -a;
    const Vector3f c = +a - b;
    const Vector3f d = dot(a, b);
    const Vector3f f = cross(a, b);

    assert(c.isZero);
    assert(d == Vectro3f(1.0, 4.0, 9.0));
    assert(f.isZero);
    assert(a.lengthsqr == 14.0f);
}
