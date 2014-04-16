module lib.math.squarematrix;

private
{
    import std.conv;
    import std.format;
    import std.range;
    import std.traits;
    import std.algorithm;
}
import lib.math.vector;


alias Matrix2x2f = SquareMatrix!(float,2);
alias Matrix3x3f = SquareMatrix!(float,3);
alias Matrix4x4f = SquareMatrix!(float,4);
alias Matrix2x2d = SquareMatrix!(double,2);
alias Matrix3x3d = SquareMatrix!(double,3);
alias Matrix4x4d = SquareMatrix!(double,4);

/**
 *   Square matrix with row-column order of storing
 *   with size varying from 1 to 4
 */
struct SquareMatrix(T, size_t size)
if(isNumeric!T && size > 1 && size <= 4)
{
public:
    /**
     *   Compile time calculation linear size of matrix
     */
    private enum linearSize = size * size;

    /**
     *  Constructor with variable number of arguments
     */
    this(T[] values...) pure nothrow @safe
    in
    {
        assert (values.length == linearSize, "SquareMatrix!(T, size): wrong array length in constructor!");
    }
    body
    {
        foreach(i; 0..linearSize)
        matrix[i] = values[i];
    }

    /**
     *  Constructor that uses array of values
     */
    this(T[] values) pure nothrow @safe
    in
    {
        assert (values.length == linearSize, "SquareMatrix!(T, size): wrong array length in constructor!");
    }
    body
    {
        matrix[] = values[];
    }

    /**
     *   Default postblit constructor
     */

    /**
     *  Default assign operator
     */

    /**
     *  Binary operator * and / for square matrix and scalar
     */
    SquareMatrix!(T, size) opBinary(string op)(T right) const pure nothrow @safe
    if(op == "*" || op == "/")
    {
        SquareMatrix!(T, size) result = this;
        mixin("result " ~ op ~ "= right;");
        return result;
    }

    /**
     *  Operators *= and /= for square matrix and scalar
     */
    SquareMatrix!(T, size) opOpAssign(string op)(T scalar) pure nothrow @safe
    if(op == "*" || op == "/")
    {
        foreach(i; 0..linearSize)
        mixin("matrix[i] " ~ op ~ "= scalar;");
        return this;
    }

    /**
     *  Binary operator + and - for square matrices
     */
    SquareMatrix!(T, size) opBinary(string op)(SquareMatrix!(T, size) right) const pure nothrow @safe
    if(op == "+" || op == "-")
    {
        SquareMatrix!(T, size) result = this;
        mixin("result " ~ op ~ "= right;");
        return result;
    }

    /**
     *  Operators += and -= for two square matrix
     */
    SquareMatrix!(T, size) opOpAssign(string op)(SquareMatrix!(T, size) right) pure nothrow @safe
    if(op == "+" || op == "-")
    {
        foreach(i; 0..linearSize)
        mixin("matrix[i] " ~ op ~ "= right.matrix[i];");
        return this;
    }

    /**
     *  Binary operator * for two square matrices
     */
    // TODO more pretty code
    SquareMatrix!(T, size) opBinary(string op)(SquareMatrix!(T, size) right) const pure nothrow @safe
    if(op == "*")
    {
        SquareMatrix!(T, size) result;
        alias left = this;
        foreach (i; 0..size)
        foreach (j; 0..size)
        foreach (k; 0..size)
        result[i, j] = result[i, j] + left[i, k] * right[k, j];
        return result;
    }

    /**
     *  Operators *= for two square matrix
     */
    SquareMatrix!(T, size) opOpAssign(string op)(SquareMatrix!(T, size) right) pure nothrow @safe
    if(op == "*")
    {
        return this = this * right;
    }

    /**
    *  Operator * for square matrix and vector
    */
    Vector!(T, size) opBinary(string op)(Vector!(T, size) right) pure nothrow @safe
    if(op == "*")
    {
        Vector!(T, size) result;

        foreach(i; 0..size)
        foreach(j; 0..size)
        {
            result[i] =  result[i] + matrix[i * size + j] * right[j];
        }

        return result;
    }

    /**
     *  Index operator T = Matrix[i,j]
     *  Indices start with 0
     */
    T opIndex(size_t i, size_t j) const pure nothrow @safe
    in
    {
        assert ((0 <= i) && (j < size),
                "SquareMatrix!(T, size).opIndex(size_t i, size_t j): array index out of bounds");
    }
    body
    {
        return matrix[i * size + j];
    }

    /**
     *  Index operator T = Matrix[index]
     *  Index starts with 0
     */
    T opIndex(in size_t index) const pure nothrow @safe
    in
    {
        assert ((0 <= index) && (index < linearSize),
                "SquareMatrix!(T, size).opIndex(size_t index): array index out of bounds");
    }
    body
    {
        return matrix[index];
    }

    /**
     *   Assign index operator Matrix[i, j] = T
     *   Indices start with 0
     */
    T opIndexAssign(T t, size_t i, size_t j) pure nothrow @safe
    in
    {
        assert (0 <= i && 0<= j && i < size && j < size, "SquareMatrix!(T, size).opIndexAssign(T t, size_t i, size_t j): array index out of bounds");
    }
    body
    {
        return (matrix[i * size + j] = t);
    }

    /**
     *  Assign index operator Matrix[index] = T
     *  Indices start with 0
     */
    T opIndexAssign(T t, size_t index) pure nothrow @safe
    in
    {
        assert ((0 <= index) && (index < linearSize), "SquareMatrix!(T, size).opIndexAssign(T t, size_t index): array index out of bounds");
    }
    body
    {
        return (matrix[index] = t);
    }

    /**
     *   Returns zero square matrix
     */
    @property static SquareMatrix!(T, size) zero() pure nothrow @safe
    {
        return SquareMatrix!(T, size).init;
    }

    /**
     *   Returns identity square matrix
     */
    @property static SquareMatrix!(T, size) identity() pure nothrow @safe
    {
        return SquareMatrix!(T, size)(identityRepresentation);
    }

    /**
     *   Returns diagonal square matrix
     */
    static SquareMatrix!(T, size) diagonal(T[] values...) pure nothrow @safe
        in
    {
        assert (values.length == size, "SquareMatrix!(T, size): wrong arguments number for diagonal matrix!");
    }
    body
    {
        SquareMatrix!(T,size) result;
        foreach(i; 0..size)
        result.matrix[i * size + i] = values[i];
        return result;
    }

    @property string toString() const
    {
        auto writer = appender!string();
        foreach (i; 0..size)
        {
            formattedWrite(writer, "[");
            foreach (j; 0..size)
            {
                formattedWrite(writer, "%s", matrix[i * size + j]);
                if (j < size-1)
                    formattedWrite(writer, ", ");
            }
            formattedWrite(writer, "]\n");
        }
        return writer.data;
    }

private:

    /**
     *   Compile time identity matrix representation
     */
    mixin(makeIdentityEnum());

    /**
     *   Build compile time identity matrix representation
     */
    static string makeIdentityEnum() pure nothrow @safe
    {
        string result = "enum T[linearSize] identityRepresentation = [cast(T)";
        foreach(i; 0..size-1)
        {
            result ~= "1, ";
            foreach(j; 0..size)
            result ~= "0, ";
        }
        return result ~ "1];";
    }

    /**
     *  Constructor that uses array of values for compiling time creating identity matrix
     */
    this(T)(T[linearSize] values) pure nothrow @safe
    in
    {
        assert (values.length == linearSize, "SquareMatrix!(T, size): wrong array length in constructor!");
    }
    body
    {
        swap(matrix, values);
    }

    /**
     *   Symbolic element access
     */
    static string elements(string letter)
    {
        string result;
        foreach (i; 0..size)
        foreach (j; 0..size)
        {
            result ~= "T " ~ letter ~ to!string(i+1) ~ to!string(j+1) ~ " = cast(T)0;";
        }
        return result;
    }

    /**
     *   Matrix elements
     */
    union
    {
        /**
         * This auto-generated structure provides symbolic access
         * to matrix elements, like in standard mathematic
         * notation:
         *
         *  a11 a12 a13 a14 .. a1N
         *  a21 a22 a23 a24 .. a2N
         *  a31 a32 a33 a34 .. a3N
         *  a41 a42 a43 a44 .. a4N
         *   :   :   :   :      :
         *  aN1 aN2 aN3 aN4 .. aNN
         */
        struct
        {
            mixin(elements("a"));
        }

        /**
         *   Declaration zero initialized matrix;
         */
        T[linearSize] matrix;
    }
};

unittest
{
// Testing constructors
    float ar[9] = [1,2,3,4,5,6,7,8,9];
    Matrix3x3f m1 = Matrix3x3f(ar);
    Matrix3x3f m2 = Matrix3x3f(1,2,3,4,5,6,7,8,9);
    assert(m1 == m2);
    assert(m1.a12 == 2 && m1.a21 == 4);
    assert(m1[0,0] == 1 );

}


unittest
{
//  Testing operators
    Matrix3x3f m1 = Matrix3x3f(
        9,8,7,
        6,5,4,
        3,2,1
    );
    Matrix3x3f m2 = Matrix3x3f(
        1,2,3,
        4,5,6,
        7,8,9
    );

    assert(m1 + m2 == Matrix3x3f(
        10,10,10,
        10,10,10,
        10,10,10
    ));

    assert(m1 * 3.0f == Matrix3x3f(
        27, 24, 21,
        18, 15, 12,
        9, 6, 3

    ));
    assert(Matrix3x3f().identity == Matrix3x3f(
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ));

    Vector3f v = Vector3f(1.0f, 2.0f, 3.0f);
    Matrix3x3f m = Matrix3x3f(1.0f, 2.0f, 3.0f,
    4.0f, 5.0f, 6.0f,
    7.0f, 8.0f, 9.0f);

    assert( m * v  == Vector3f(14.0f, 32.0f, 50.0f));

}

unittest
{
    assert(Matrix2x2f(0.6, 0.8, -0.8, 0.6) * Matrix2x2f(0.6, -0.8, 0.8, 0.6) == Matrix2x2f.identity);
}

unittest
{
    //Testing diagonal initializator
    assert(Matrix2x2f.diagonal(3.0f, -4.0f) == Matrix2x2f(
        3, 0,
        0, -4
    ));
    assert(Matrix3x3f.diagonal(1.0f, 2.0f, 3.0f) == Matrix3x3f(
        1, 0, 0,
        0, 2, 0,
        0, 0, 3
    ));
    assert(Matrix4x4f.diagonal(1.5, 2, 3, 4.0f) == Matrix4x4f(
    	                                             1.5, 0, 0, 0,
    	                                             0, 2f, 0, 0,
    	                                             0, 0, 3f, 0,
    	                                             0, 0, 0, 4
    	));
	assert("lib.math.squarematrix.SquareMatrix!(float, 4).SquareMatrix" == typeid(Matrix4x4f.diagonal(1, 2, 3, 4)).toString());
	assert("lib.math.squarematrix.SquareMatrix!(float, 4).SquareMatrix" == typeid(Matrix4x4f.diagonal(1, 2.0, 3, 4)).toString());
	assert("lib.math.squarematrix.SquareMatrix!(float, 4).SquareMatrix" == typeid(Matrix4x4f.diagonal(1, 2, 3.0L, 4L)).toString());
    assert( Matrix3x3f(
        1.5, 0f, 0f,
        0f, 0f, 0f,
        0f, 0f, 0f
    ) == Matrix3x3f(
        1.5f, 0f, 0f,
        0f, 0f, 0f,
        0f, 0f, 0f
    )
          );
}
