module lib.math.vector;

private
{
    import std.format;
    import std.math;
    import std.range;
    import std.traits;
    import lib.math.permutation;
}

import lib.math.squarematrix;


/**
 * Predefined vector types
 */
alias Vector2i = Vector!(int, 2);
alias Vector2f = Vector!(float, 2);
alias Vector3f = Vector!(float, 3);
alias Vector4f = Vector!(float, 4);
alias Vector2d = Vector!(double, 2);
alias Vector3d = Vector!(double, 3);
alias Vector4d = Vector!(double, 4);

struct Vector(T, size_t sizeCTA)
if(isNumeric!T && sizeCTA > 0 && sizeCTA <= 4) // CTA is compile time argument
{
public:

	alias size = sizeCTA;
	alias Type = T;

    /**
     *  Constructor with variable number of arguments
     */
    this(T[] values...) pure nothrow @safe
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
    this(T[] values) pure nothrow @safe
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
    this(Vector!(T, size) v) pure nothrow @safe
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
    *  Binary operator +, -, * and / for possible combination of vector and scalar
    */
    Vector!(T, size) opBinary(string op, U)(U right) const pure nothrow @safe
    if((is(U == Vector!(T, size)) && (op == "+" || op == "-")) || (is(U : T) && (op == "*" || op == "/")))
    {
        Vector!(T, size) result = this;
        mixin("result " ~ op ~ "= right;");
        return result;
    }

    /**
     *  Operators += and -= for two vectors
     */
    ref Vector!(T, size) opOpAssign(string op)(Vector!(T, size) right) pure nothrow @safe
    if(op == "+" || op == "-")
    {
        foreach(i; 0..size)
        mixin("coordinates[i] " ~ op ~ "= right.coordinates[i];");
        return this;
    }

    /**
     *  Operators *= and /= for vector and scalar
     */
    ref Vector!(T, size) opOpAssign(string op, U)( U scalar) pure nothrow @safe
    if(is(U : T) && (op == "*" || op == "/"))
    {
        foreach(i; 0..size)
        mixin("coordinates[i] " ~ op ~ "= cast(T)scalar;");
        return this;
    }

    /**
     *  Unary operators + and -
     */
    Vector!(T, size) opUnary(string op)() const pure nothrow @safe
    if(op == "+" || op == "-")
    {
        Vector!(T, size) result;
        foreach(i; 0..size)
        mixin("result.coordinates[i] = " ~ op ~ "coordinates[i];");
        return result;
    }

    /**
     *  Index operator T = Vecrot(T, size)[index]
     */
    T opIndex (this vector)(size_t index) const pure nothrow @safe
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
     *  Assign index operator Vector(T, size)[i] = value
     */
    T opIndexAssign (this vector)(T value, size_t index) pure nothrow @safe
    in
    {
        assert ((0 <= index) && (index < size),
        "Vector!(T,size).opIndexAssign(size_t index): array index out of bounds");
    }
    body
    {
        return coordinates[index] = value;
    }

	/**
	 *   Assign index operator Vector!(T, size)[i] <op>= T
	 *   Indices start with 0
	 */
	T opIndexOpAssign(string op)(T value, size_t index) pure nothrow @safe
	if(op == "+" || op == "-" || op == "*" || op == "/" || op == "^^")
	in
	{
		assert ((0 <= index) && (index < size),
		"Vector!(T,size).opIndexOpAssign(size_t index): array index out of bounds");
	}
	body
	{
		mixin("return coordinates[index] " ~ op ~ "= value;");
	}

    /**
     *  Zero property, for more sweet usability
     */
    @property static Vector!(T, size) zero() pure nothrow @safe
    {
        return Vector!(T, size).init;
    }

	/**
	 *  NaN property
	 */
	static if(isFloatingPoint!T)
	{
		@property static Vector nan() pure nothrow @safe
		{
			return Vector(nanRepresentation);
		}

	}

    /**
     *  Get vector length squared
     */
    @property T lengthsqr() const pure nothrow @safe
    {
        T lensqr = 0;
        foreach (component; coordinates)
        lensqr += component * component;
        return lensqr;
    }

    /**
     *  Get vector length
     */
    @property T length() const pure nothrow @safe
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

	static if (isFloatingPoint!T)
	{

		/**
		 *  Set vector length to 1
		 */
		void normalize() pure nothrow @safe
		{
			T lensqr = lengthsqr();
			if (lensqr > T.epsilon)
			{
				T coef = 1.0 / sqrt(lensqr);
				foreach (ref component; coordinates)
				component *= coef;
			}
		}

		/**
		 *  Return normalized copy
		 */
		@property Vector!(T, size) normalized() const pure nothrow @safe
		{
			Vector!(T, size) result = this;
			result.normalize();
			return result;
		}
	}

    /**
     *  Return true if all components are zero
     */
    @property bool isZero() const pure nothrow @safe
    {
        foreach(i; 0..size)
        if(coordinates[i] != 0)
            return false;

        return true;
    }

    @property string toString() const
    {
        auto writer = appender!string();
        formattedWrite(writer, "%s", coordinates);
        return writer.data;
    }

    /**
     *  Is already used in rigidbody to represent transformation
     */
    static if(size == 3)
    {
        @property SquareMatrix!(T, 4) toMatrix4x4() pure nothrow @safe
        {
            SquareMatrix!(T, 4) result = SquareMatrix!(T, 4).identity;

            result.a14 = this.x;
            result.a24 = this.y;
            result.a34 = this.z;

            return result;
        }
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

	/**
	 *   Declaration zero initialized vector
	 */
	mixin(declaration());

	/**
	 *  Declaration nan representation
	 */
	static if(isFloatingPoint!T){
		mixin(nanEnum());
	}

	/**
	 *   Build compile time zerovector representation
	 */
	static string declaration() pure nothrow @safe
	{
		string result = "T[size] coordinates = [cast(T)";
		foreach(unused; 0..size)
		result ~= "0, ";
		return result ~ "];";
	}

	static string nanEnum()pure nothrow @safe
	{
		string result = "enum T[size] nanRepresentation = [";
		foreach(unused; 0..size)
		result ~= "T.nan, ";
		return result ~ "];";
	}
}

/**
 *  Predicate for Vector
 */
template isLibMathVector(T)
{
	import std.traits;
	static if(__traits(compiles, {T.Type a;}) && __traits(compiles, {auto a = T.size;}))
		enum bool isLibMathVector = is(T == Vector!(T.Type, T.size));
	else
		enum bool isLibMathVector = false;
}

alias isNaN = std.math.isNaN;
/**
 *  The property is true if any element is NaN
 */
bool isNaN(T)(T vector)pure nothrow @safe
if(isLibMathVector!T)
{
	auto result = false;
	for(auto i = 0; !result && i < vector.size; ++i)
		result = result || isNaN(vector.coordinates[i]);
	return result;
}

/**
 * Dot product
 */
T dot(T, size_t size)(Vector!(T, size) a, Vector!(T, size) b) pure nothrow @safe
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
Vector!(T, size) cross(T, size_t size) (Vector!(T, size) a, Vector!(T, size) b) pure nothrow @safe
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
T distance(T, size_t  size)(Vector!(T, size) a, Vector!(T, size) b) pure nothrow @safe
{
    Vector!(T, size) difference =  a - b;
    return difference.length;
}

/**
 *  Compute distance squared between two points
 */
T distancesqr(T) (Vector!(T, size) a, Vector!(T, size) b) pure nothrow @safe
{
    Vector!(T, size) difference =  a - b;
    return difference.lengthsqr;
}

/**
 *  Permutated copy (e.g. for solve equation)
 */
T permutation(T)(T vector, Permutation p)@safe
if(isLibMathVector!T)
in
{
	// Why this don't compile? //assert(T.size == permutation.size, "permutation size mismatch");
}
body
{
	typeof(return) result = vector;
	result.permute(p);
	return result;
}


void permute(T)(ref T vector, Permutation permutation)@safe
if(isLibMathVector!T)
in
{
	assert(vector.size == permutation.size, "permutation size missmatch");
}
body
{
	void set(ref T object, size_t position, T.Type value)
	in
	{
		assert(position < object.size);
	}
	body
	{
		object.coordinates[position] = value;
	}

	T.Type get(ref T object, size_t position)
	in
	{
		assert(position < object.size);
	}
	body
	{
		return object.coordinates[position];
	}

	mixin CorePermute!(vector, set, get, permutation);
	permute();
}

enum OperatorNorm{one=1, two, infinity};
alias one = OperatorNorm.one;
alias two = OperatorNorm.two;
alias infinity = OperatorNorm.infinity;

T operatorNorm(OperatorNorm kind, T, size_t size)(Vector!(T,size) vector)
{
	static if(one == kind)
	{
		auto sum = cast(T)0;
		foreach(x; vector.coordinates)
		sum += abs(x);
		return sum;
	}
	else static if(two == kind)
		return vector.length;
	else static if(infinity == kind)
	{
		auto max = cast(T) - 1;
		foreach(x; vector.coordinates)
		max = std.algorithm.max(max, abs(x));
		return max;
	}
}

unittest
{
	// Testing isLibMathVector
	assert(isLibMathVector!Vector2f);
	assert(isLibMathVector!Vector2i);
	assert(isLibMathVector!Vector4f);
	assert(!isLibMathVector!float);
}

unittest
{
    // Testing default zero initialization
    Vector3f a = Vector3f();
    assert([0.0f, 0.0f, 0.0f] == a.coordinates);
    Vector3f b;
    assert([0.0f, 0.0f, 0.0f] == b.coordinates);
    assert([0.0f, 0.0f, 0.0f] == (Vector3f.init).coordinates);
    assert(Vector3f.zero == Vector3f.init);

    assert([0.0f, 0.0f] == (Vector2f.init).coordinates);
    assert([0.0f, 0.0f, 0.0f] == (Vector3f.init).coordinates);
    assert([0.0f, 0.0f, 0.0f, 0.0f] == (Vector4f.init).coordinates);
    assert([0.0, 0.0] == (Vector2d.init).coordinates);
    assert([0.0, 0.0, 0.0] == (Vector3d.init).coordinates);
    assert([0.0, 0.0, 0.0, 0.0] == (Vector4d.init).coordinates);
}

unittest
{
	// Testing nan
	assert(isNaN(Vector2f.nan));
	assert(isNaN(Vector4f(float.nan, 0.0f, 0.0f, 2.0f)));
	assert("[nan, nan, nan]" == (Vector3f.nan).toString());
}

unittest
{
    // Testing for flexibility of prodyct by scalar
    auto x = Vector3f(1.0, 2.0, 3.0);
    real rAlpha = 2.0L;
    double dAlpha = 2.0;
    float fAlpha = 2.0f;
    long lAlpha = 2L;
    int iAlpha = 2;
    byte bAlpha = 2;
    assert([2.0f, 4.0f, 6.0f] == (x * rAlpha).coordinates);
    assert([2.0f, 4.0f, 6.0f] == (x * dAlpha).coordinates);
    assert([2.0f, 4.0f, 6.0f] == (x * fAlpha).coordinates);
    assert([2.0f, 4.0f, 6.0f] == (x * lAlpha).coordinates);
    assert([2.0f, 4.0f, 6.0f] == (x * iAlpha).coordinates);
    assert([2.0f, 4.0f, 6.0f] == (x * bAlpha).coordinates);
}

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
    // Testing of assign operator and postblit constructor
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
    // Testing parametrical constructors
    Vector2d(1.0f, 2.0f);
    Vector3f([1.0, 2.0, 3.0]);
    auto v = Vector4f([1.0, 2.0, 3.0, 4.0f]);
    Vector4f(v);
}

unittest
{
    // Testing of math operations
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
    // Testing toString
    assert("[0, 0]" == Vector2f.zero.toString);
    assert("[0, 0, 0]" == Vector3f.zero.toString);
    assert("[0, 0, 0, 0]" == Vector4f.zero.toString);
    assert("[0, 0]" == Vector2d.zero.toString);
    assert("[0, 0, 0]" == Vector3d.zero.toString);
    assert("[0, 0, 0, 0]" == Vector4d.zero.toString);

    assert("[0.5, -1]" == Vector2f(0.5, -1.0).toString);
}

unittest
{
    // Testing declaration()
    assert("T[size] coordinates = [cast(T)0, 0, ];" == Vector2f.declaration());
    assert("T[size] coordinates = [cast(T)0, 0, ];" == Vector2d.declaration());
    assert("T[size] coordinates = [cast(T)0, 0, 0, ];" == Vector3f.declaration());
    assert("T[size] coordinates = [cast(T)0, 0, 0, ];" == Vector3d.declaration());
    assert("T[size] coordinates = [cast(T)0, 0, 0, 0, ];" == Vector4f.declaration());
    assert("T[size] coordinates = [cast(T)0, 0, 0, 0, ];" == Vector4d.declaration());
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
    assert(Vector3d().isZero);
    assert(!Vector2d(1.0, 0.0).isZero);
    assert(5.0 == Vector4f(3.0f, 0.0f, 4.0f, 0.0f).length);
    assert(0 == Vector!(int, 4)(3, 0, 4, 0).length);//TODO change semantics
    assert(Vector3f(0.6f, 0.0f, 0.8f) == Vector3f(3.0f, 0.0f, 4.0f).normalized);
}

unittest
{
	// Testing toMatrix4x4
	assert(
	  Matrix4x4f(
	   1f, 0f, 0f, 5f,
	   0f, 1f, 0f, 6f,
	   0f, 0f, 1f, 7f,
	   0f, 0f, 0f, 1f)
	     == Vector3f(5f, 6f, 7f).toMatrix4x4);
}

unittest
{
	// Testing permutationBy
	auto v = Vector4f(1.0f, 2.0f, 3.0f, 4.0f);
	auto p = Permutation(4);
	p.transpose(1,2);
	p.transpose(2,3);
	assert(Vector4f(1.0f, 3.0f, 4.0f, 2.0f) == v.permutation(p));
}

unittest
{
	// Testing operator norm
	assert(7.0f == operatorNorm!one(Vector2f(3.0f, -4.0f)));
	assert(5.0f == operatorNorm!two(Vector2f(3.0f, -4.0f)));
	assert(4.0f == operatorNorm!infinity(Vector2f(3.0f, -4.0f)));
}

unittest
{
	// Testing nanEnum()
	assert("enum T[size] nanRepresentation = [T.nan, T.nan, ];" == Vector2f.nanEnum());
	assert("enum T[size] nanRepresentation = [T.nan, T.nan, T.nan, T.nan, ];" == Vector4f.nanEnum());
}

unittest
{
    // Testing assertattion and contracts
    import core.exception;
    try
    {
        Vector2f(1.0f);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The number of constructor parameters does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector3f(1.0f);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The number of constructor parameters does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector4f(1.0f);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The number of constructor parameters does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector2f(1.0f,2.0f,3.0f,4.0f,5.0f);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The number of constructor parameters does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector3f(1.0f,2.0f,3.0f,4.0f,5.0f);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The number of constructor parameters does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector4f(1.0f,2.0f,3.0f,4.0f,5.0f);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The number of constructor parameters does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector2f([1.0f,2.0f,3.0f,4.0f,5.0f]);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The length of array that transmitted to constructor does not match vector dimension.", "wrong assert mesage");
    }
    try
    {
        Vector4f([1.0f,2.0f,3.0f]);
    }
    catch(AssertError ae)
    {
        assert(ae.msg == "The length of array that transmitted to constructor does not match vector dimension.", "wrong assert mesage");
    }
}
