module lib.math.squarematrix;

private
{
    import std.conv;
    import std.format;
    import std.range;
    import std.traits;
    import std.algorithm;
    import std.math;
}
import lib.math.vector;
import lib.math.permutation;


alias Matrix2x2f = SquareMatrix!(float, 2);
alias Matrix3x3f = SquareMatrix!(float, 3);
alias Matrix4x4f = SquareMatrix!(float, 4);
alias Matrix2x2d = SquareMatrix!(double, 2);
alias Matrix3x3d = SquareMatrix!(double, 3);
alias Matrix4x4d = SquareMatrix!(double, 4);

/**
 *   Square matrix with row-column order of storing
 *   with size varying from 1 to 4
 */
struct SquareMatrix(T, size_t sizeCTA)// CTA is 'compile time argument'
if(isNumeric!T && sizeCTA > 1 && sizeCTA <= 4)
{
public:
    /**
     *   Compile time calculation linear size of matrix
     */
    private enum linearSize = size * size;
    alias size = sizeCTA;
    alias Type = T;

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
    ref SquareMatrix!(T, size) opOpAssign(string op)(T scalar) pure nothrow @safe
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
    ref SquareMatrix!(T, size) opOpAssign(string op)(SquareMatrix!(T, size) right) pure nothrow @safe
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
    ref SquareMatrix!(T, size) opOpAssign(string op)(SquareMatrix!(T, size) right) pure nothrow @safe
    if(op == "*")
    {
        return this = this * right;
    }

    /**
     *  Operator * for square matrix and vector
     */
    Vector!(T, size) opBinary(string op)(Vector!(T, size) right) const pure nothrow @safe
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
     *  Right sided operator * for square matrix and vector
     */
    Vector!(T, size) opBinaryRight(string op)(Vector!(T, size) left) const pure nothrow @safe
    if(op == "*")
    {
        Vector!(T, size) result;

        foreach(i; 0..size)
        foreach(j; 0..size)
        {
            result[i] =  result[i] + left[i] * matrix[j * size + i];
        }

        return result;
    }

    /**
     *  Index operator T = SquareMatrix!(T, size)[i,j]
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
     *  Index operator T = SquareMatrix!(T, size)[index]
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
     *   Assign index operator SquareMatrix!(T, size)[i, j] = T
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
     *  Assign index operator SquareMatrix!(T, size)[index] = T
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
    
    /**
     *  Horrible piece of crap, but it works.
     *  Will be remade in better way in the nearest future 
     */
    static if (size == 3)
    {  
        /**
         *  Returns inverse SquareMatrix 3x3
         */
        @property SquareMatrix!(T, size) inverse() pure nothrow @safe
        {
                T invDet = 1 / this.determinant;
        
                SquareMatrix!(T, size) result;
        
                result.a11 =  (a33 * a22 - a32 * a23) * invDet;
                result.a12 = -(a33 * a12 - a32 * a13) * invDet;
                result.a13 =  (a23 * a12 - a22 * a13) * invDet;
            
                result.a21 = -(a33 * a21 - a31 * a23) * invDet;
                result.a22 =  (a33 * a11 - a31 * a13) * invDet;
                result.a23 = -(a23 * a11 - a21 * a13) * invDet;
        
                result.a31 =  (a32 * a21 - a31 * a22) * invDet;
                result.a32 = -(a32 * a11 - a31 * a12) * invDet;
                result.a33 =  (a22 * a11 - a21 * a12) * invDet;
        
                return result;    
         }
        
         /**
          *  Returns determinant of SquareMatrix 3x3
          */
         @property T determinant() pure nothrow @safe
         {  
            return a11 * (a22 * a33 - a23 * a32)
                 - a12 * (a21 * a33 - a23 * a31)
                 + a13 * (a21 * a32 - a22 * a31);
         }
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
     *  Necessary fot GL functions
     */
    @property T* ptr()
    {
        return matrix.ptr;
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
}

/**
 *  Predicate for SquareMatrix
 */
template isLibMathSquareMatrix(T)
{
	import std.traits;
	static if(__traits(compiles, {T.Type a;}) && __traits(compiles, {auto a = T.size;}))
		enum bool isLibMathSquareMatrix = is(T == SquareMatrix!(T.Type, T.size));
	else
		enum bool isLibMathSquareMatrix = false;
}

/**
 *  Scale transformations generator
 */
SquareMatrix!(T, 4) initScaleTransformation (T)(T x, T y, T z) pure nothrow
{
    return SquareMatrix!(T,4).diagonal(x, y, z, 1.0f);
}

SquareMatrix!(T,4)  initScaleTransformation (T)(Vector!(T, 3) data) pure nothrow
{
    return SquareMatrix!(T,4).diagonal(data.x, data.y, data.z, 1.0f);
}

/**
 *  Rotation transformations generator.
 *  Arguments are angles measured in RADIANS
 */
SquareMatrix!(T, 4) initRotationTransformation (T) (T x, T y, T z) pure nothrow
{
    auto overX = SquareMatrix!(T, 4).identity;
    auto overY = SquareMatrix!(T, 4).identity;
    auto overZ = SquareMatrix!(T, 4).identity;

    overX.a22 = cos(x);
    overX.a23 = -sin(x);
    overX.a32 = sin(x);
    overX.a33 = cos(x);

    overY.a11 = cos(y);
    overY.a13 = -sin(y);
    overY.a31 = sin(y);
    overY.a33 = cos(y);

    overZ.a11 = cos(z);
    overZ.a12 = -sin(z);
    overZ.a21 = sin(z);
    overZ.a22 = cos(z);

    return overZ * overY * overX;
}

SquareMatrix!(T, 4) initRotationTransformation (T) (Vector!(T, 3) data) pure nothrow
{
    return initRotationTransformation(data.x, data.y, data.z);
}

/**
 *  Position transformations generator
 */
SquareMatrix!(T, 4) initPositionTransformation (T) (T x, T y, T z) pure nothrow
{
    auto result = SquareMatrix!(T, 4).identity;
    result.a14 = x;
    result.a24 = y;
    result.a34 = z;

    return result;
}

SquareMatrix!(T, 4) initPositionTransformation (T) (Vector!(T, 3) data) pure nothrow
{
    return initPositionTransformation(data.x, data.y, data.z);
}

/**
 *  Camera transformations generator
 */
SquareMatrix!(T, 4) initCameraTransformation (T) (Vector!(T, 3) target, Vector!(T, 3) up) pure nothrow
{
    auto N = target.normalized;
    auto U = up.normalized;

    U = cross(U, N);
    auto V = cross(N, U);

    auto result = SquareMatrix!(T, 4).identity;
    result.a11 = U.x;
    result.a12 = U.y;
    result.a13 = U.z;

    result.a21 = V.x;
    result.a22 = V.y;
    result.a23 = V.z;

    result.a31 = N.x;
    result.a32 = N.y;
    result.a33 = N.z;

    return result;
}

/**
 *  Perspective transformation generator
 *  Angle is measured in DEGREES
 */
SquareMatrix!(T, 4) initPerspectiveTransformation (T) (T angle, T width, T height, T nearestPlane, T farPlane)
{
    T ratio = width / height;
    T near = nearestPlane;
    T far = farPlane;
    T range = near - far;
    T tangentHalf = tan (angle / 360.0f * PI);

    auto result = SquareMatrix!(T, 4)().diagonal(1.0f / (ratio * tangentHalf), 1.0f / tangentHalf,
                  (-near - far) / range, 0.0f );
    result.a34 = 2.0f * far * near / range;
    result.a43 = 1.0f;

    return result;
}

SquareMatrix!(T, 4) initPerspectiveTransformation (T) (T[] data)
in
{
    assert (data.length == 5, "initPerspectiveTransformation: wrong array length");
}
body
{
    return initPerspectiveTransformation(data[0], data[1], data[2], data[3], data[4]);
}

enum MatrixLines{rows, collumns};
alias rows = MatrixLines.rows;
alias collumns = MatrixLines.collumns;

T permutation(MatrixLines kind, T)(T matrix, Permutation permutation)@safe
if(isLibMathSquareMatrix!T)
in
{
	assert(T.size == permutation.size, "permutation size mismatch");
}
body
{
	typeof(return) result = matrix;

	void set(ref T object, size_t position, T.Type[T.size] value)
	in
	{
		assert(position < T.size);
	}
	body
	{
		foreach(i, e; value)
		static if(rows == kind)
			object.matrix[position * T.size + i] = value[i];
		else static if(collumns == kind)
			object.matrix[i * T.size + position] = value[i];
	}

	T.Type[T.size] get(const ref T object, size_t position)
	in
	{
		assert(position < T.size);
	}
	body
	{
		typeof(return) value = new T.Type[T.size];
		foreach(i, e; value)
		static if(rows == kind)
			value[i] = object.matrix[position * T.size + i];
		else static if(collumns == kind)
			value[i] = object.matrix[i * T.size + position];
		return value;
	}

	mixin CorePermute!(result, set, get, permutation);
	permute();
	return result;
}

unittest
{
	// Testing predicate
	assert(isLibMathSquareMatrix!Matrix2x2f);
	assert(isLibMathSquareMatrix!Matrix3x3f);
	assert(isLibMathSquareMatrix!Matrix4x4f);
	assert(isLibMathSquareMatrix!(SquareMatrix!(int, 3)));
	assert(!isLibMathSquareMatrix!int);
	assert(!isLibMathSquareMatrix!float);
	assert(!isLibMathSquareMatrix!Vector3f);
}

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
// Testing special functions
    auto matrix = initScaleTransformation(1.4f, 3.0f, 2.0f);
    assert(matrix == Matrix4x4f(
        1.4f, 0.0f, 0.0f, 0.0f,
        0.0f, 3.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 2.0f, 0.0f,
        0.0f, 0.0f, 0.0f, 1.0f
    ));

    matrix = initPositionTransformation(2.0f, 3.0f, 2.5f);
    assert(matrix == Matrix4x4f(
        1.0f, 0.0f, 0.0f, 2.0f,
        0.0f, 1.0f, 0.0f, 3.0f,
        0.0f, 0.0f, 1.0f, 2.5f,
        0.0f, 0.0f, 0.0f, 1.0f
    ));

    matrix = initRotationTransformation(cast (float)( 45.0f / 180.0f * PI), 0.0f, cast (float) (30.0f / 180.0f * PI));
    assert(matrix[0, 0] < 0.866f + 0.001f && matrix[0, 0] > 0.866f - 0.001f);
    assert(matrix[1, 2] < -0.612f + 0.001f && matrix[1, 2] > -0.612f - 0.001f);

    matrix = initPerspectiveTransformation(45.0f, 20.0f, 30.0f, 1.0f, 100.0f);
    assert(matrix[0, 0] < 3.621f + 0.001f && matrix[0, 0] > 3.621f - 0.001f);
    assert(matrix[2, 3] < -2.02f + 0.01f && matrix[1, 2] > -2.02f - 0.01f);

    matrix = initCameraTransformation (Vector3f(1.0f, 2.0f, 1.4f), Vector3f(3.0f, 2.5f, 1.2f));
    assert(matrix[0, 1] < -0.278f + 0.001f && matrix[0, 0] > -0.278f - 0.001f);
    assert(matrix[1, 1] < -0.068f + 0.001f && matrix[1, 1] > -0.068f - 0.001f);
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
    //assert("lib.math.squarematrix.SquareMatrix!(float, 4).SquareMatrix" == typeid(Matrix4x4f.diagonal(1, 2, 3, 4)).toString());
    //assert("lib.math.squarematrix.SquareMatrix!(float, 4).SquareMatrix" == typeid(Matrix4x4f.diagonal(1, 2.0, 3, 4)).toString());
    //assert("lib.math.squarematrix.SquareMatrix!(float, 4).SquareMatrix" == typeid(Matrix4x4f.diagonal(1, 2, 3.0L, 4L)).toString());
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

unittest
{
	// Testing permutation
	auto m = Matrix4x4f( 1.0f,  2.0f,  3.0f,  4.0f,
	                     5.0f,  6.0f,  7.0f,  8.0f,
	                     9.0f, 10.0f, 11.0f, 12.0f,
	                    13.0f, 14.0f, 15.0f, 16.0f);
	auto p = Permutation(4);
	p.transpose(1,2);
	p.transpose(2,3);
	assert(Matrix4x4f(   1.0f,  2.0f,  3.0f,  4.0f,
	                     9.0f, 10.0f, 11.0f, 12.0f,
	                    13.0f, 14.0f, 15.0f, 16.0f,
	                     5.0f,  6.0f,  7.0f,  8.0f) == m.permutation!rows(p));

	assert(Matrix4x4f(   1.0f,  3.0f,  4.0f,  2.0f,
	                     5.0f,  7.0f,  8.0f,  6.0f,
	                     9.0f, 11.0f, 12.0f, 10.0f,
	                    13.0f, 15.0f, 16.0f, 14.0f) == m.permutation!collumns(p));
}
