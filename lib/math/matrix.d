module lib.math.squarematrix;

private
{
    import std.conv;
    import std.format;
    import std.math;
    import std.range;
    import std.traits;
    import std.algorithm;

    import lib.math.vector;
}

/**
 *   Square matrix with row-column order of storing
 *
 */
struct SquareMatrix(T, size_t size)
if(isNumeric!T && size > 0 && size <= 4)
{
public:
    /**
     *  Constructor with variable number of arguments
     */
    this(T)(T[] values...) pure nothrow @safe
    in
    {
        assert (values.length == linearSize, "SquareMatrix!(T, size): wrong array length in constructor!");
    }
    body
    {
        foreach(i; 0.. size * size)
        matrix[i] = values[i];
    }

    /**
     *  Constructor that uses array of values
     *  It is not used at any situations at the moment
     */
    this(T)(T[] values) pure nothrow @safe
    in
    {
        assert (values.length == linearSize, "SquareMatrix!(T, N): wrong array length in constructor!");
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
     *  Operators *= and /= for square matrix and scalar
     */
    ref SquareMatrix!(T, size) opOpAssign(string op)(T scalar) pure nothrow @safe
    if(op == "*" || op == "/")
    {
        foreach(i; 0..linearSize)
        mixin("matrix[i] " ~ op ~ "= scalar;");
        return this;
    }

    /**
     *  Binary operator * and / for square matrix and scalar
     */
    SquareMatrix!(T, size) opBinary(string op, U)(U right) const pure nothrow @safe
    if(is(U : T) && (op == "*" || op == "/"))
    {
        SquareMatrix!(T, size) result = this;
        mixin("result " ~ op ~ "= right;");
        return result;
    }

    /**
     *  Operators += and -= for two square matrix
     */
    ref SquareMatrix!(T, size) opOpAssign(string op)(ref const SquareMatrix!(T, size) right) pure nothrow @safe
    if(op == "+" || op == "-")
    {
        foreach(i; 0..linearSize)
        mixin("matrix[i] " ~ op ~ "= right.matrix[i];");
        return this;
    }

    /**
     *  Binary operator + and - for square matrices
     */
    SquareMatrix!(T, size) opBinary(string op)(ref const SquareMatrix!(T, size) right) const pure nothrow @safe
    if(op == "+" || op == "-")
    {
        SquareMatrix!(T, size) result = this;
        mixin("result " ~ op ~ "= right;");
        return result;
    }

    /**
     *  Index operator T = Matrix[i,j]
     *  Indices start with 0
     */
    T opIndex(size_t i, size_t j)  const pure nothrow @safe
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
                "Matrix.opIndex(size_t index): array index out of bounds");
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
        assert (0 <= i && 0<= j && i < size && j < size, "Matrix.opIndexAssign(T t, size_t i, size_t j): array index out of bounds");
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
        assert ((0 <= index) && (index < linearSize), "Matrix.opIndexAssign(T t, size_t index): array index out of bounds");
    }
    body
    {
        return (matrix[index] = t);
    }

    /**
     *   Returns identity square matrix
     */
    @property static SquareMatrix!(T, size) identity() pure nothrow @safe
    {
        return SquareMatrix!(T, size)(representationIdentity);
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

    /**
     *   Symbolic element access
     */
    private static string elements(string letter)
    {
        string result;
        foreach (i; 0..size)
        foreach (j; 0..size)
        {
            result ~= "T " ~ letter ~ to!string(i+1) ~ to!string(j+1) ~ ";";
        }
        return result;
    }
private:
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

        T matrix[linearSize];
    }

    /**
     *   Compile time calculation linear size of matrix
     */
	enum linearSize = size * size;
    
    /**
     *   Compile time identity matrix representation
     */
	mixin(makeIdentityEnum());

	/**
     *   Build compile time identity matrix representation
     */
	private static string makeIdentityEnum() pure nothrow @safe
	{
		string result = "enum T[linearSize] representationIdentity = [cast(T)";
		foreach(i; 0..size-1)
		{
			result ~= "1, ";
			foreach(j; 0..size)
				result ~= "0, ";
		}
		return result ~ "1];";
	}
	
	/**
     *  Constructor by representation
     */
    this(T)(T[linearSize] values) pure nothrow @safe
    in
    {
        assert (values.length == linearSize, "SquareMatrix!(T, N): wrong array length in constructor!");
    }
    body
    {
        swap(matrix, values);
    }
};

alias SquareMatrix!(float,3) Matrix3x3f;
alias SquareMatrix!(float,4) Matrix4x4f;
alias SquareMatrix!(double,3) Matrix3x3d;
alias SquareMatrix!(double,4) Matrix4x4d;

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
//  Testing perators
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
}
