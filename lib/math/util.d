import std.math;
import std.traits;

alias Float = TransitiveComparableFloatingPoint!(float);

/**
 *  Wrapper around base floating point types, that provides transitive aproximate comparsion
 */ 
struct TransitiveComparableFloatingPoint(T, int saveDigit = 10)
if(isFloatingPoint!T)
{
	public:

	alias payload this;

	T payload;

	public this(T value)
	{
		payload = value;
	}

	long opCmp(T rhs)
	{
		return floatCompare(this.payload, rhs, saveDigit);
	}

	bool opEquals(T rhs)
	{
		return opCmp(rhs) == 0;
	}
}

unittest
{
	Float a = 0x8.06p-4f;
	Float b = 0x8.08p-4f;
	assert(a == b);
	assert(a.payload != b.payload);
	assert(a == 0x8.08p-4f);
	assert(a == 0x8.06p-4f);
	assert(a != 0x8.04p-4f);
	float f = 0.034f;
	Float c = 0x8.04p-4f;
	assert(__traits(compiles, f = a));
	assert(__traits(compiles, c = f));
	assert(__traits(compiles, b = a));
}

/**
 *  Ducktyping predicate for floating point number
 */
template behaveAsFloatingPoint(T)
{
	enum bool behaveAsFloatingPoint = isAlgebraicField!T && isLinearComparable!T && hasEpsilon!T && hasNan!T && hasInf!T; 
}

/**
 *  Predicate for fields (in algebraic sence) with assumption of computer features
 */
template isAlgebraicField(T)
{
	enum bool hasArithmeticOperation = __traits(compiles,{
	                                                         T result, t;
	                                                         result = t + t;
	                                                         result = t - t;
	                                                         result = t * t;
	                                                         result = t / t;
	                                                         result = +t;
	                                                         result = -t;
	                                                      });

	static if(__traits(compiles, cast(T)0.0))
		enum bool hasZero = (cast(T)0.0 == cast(T)0.0 + cast(T)0.0);
	else 
		enum bool hasZero = false;

	static if(__traits(compiles, cast(T)1.0))
		enum bool hasIdentity = (cast(T)1.0 == cast(T)1.0 * cast(T)1.0);
	else
		enum bool hasIdentity = false;

	enum bool isAlgebraicField = hasArithmeticOperation && hasZero && hasIdentity; 
}

unittest
{
	// Testing isAlgebraicField!T
	assert(isAlgebraicField!int);
	assert(isAlgebraicField!long);
	assert(isAlgebraicField!float);
	assert(isAlgebraicField!double);
	assert(isAlgebraicField!real);
	assert(!isAlgebraicField!string);
	assert(!isAlgebraicField!(float[]));
}

/**
 * Transitive float comparsion
 *
 * $(D long floatCompare(real lhs, real rhs, int saveDigit = 10);)
 *
 * @param left floating point number
 * @param right floating point number
 * @param number of saving binary (sic!) digit after point
 * @return negative value iff lhs < rhs, zero iff lhs == rhs and positive value iff lhs > rhs
 *
 * This comparsion is transitive: if a == b and b == c, then a == c.
 */
private long floatCompare(real lhs, real rhs, int saveDigit = 10) pure nothrow @safe
{
	assert(isFinite(lhs) && isFinite(rhs));
	return truncation(lhs, saveDigit) - truncation(rhs, saveDigit);
}

/**
 *  Roundig truncation
 */
private long truncation(real floatingNumber, int saveDigit) pure nothrow @safe
{
	auto result = cast(long)ldexp(floatingNumber, saveDigit+1);
	auto lastBit = 1L & result;
	result = (result + (result < 0 ? -lastBit : lastBit)) >> 1;
	return result;
}

unittest
{
	// Testing transitivity
	long intransitiveFloatCompare(real lhs, real rhs, int saveDigit = 10)
	{
		auto difference = lhs - rhs;
		auto epsilon = ldexp(1.0L, -saveDigit);
		if(fabs(difference) < epsilon)
			return 0;
		return cast(long)(difference/epsilon);
	}
	auto a = 0x8.04p-4;
	auto b = 0x8.06p-4;
	auto c = 0x8.08p-4;
	assert(floatCompare(a, b) != 0);
	assert(floatCompare(b, c) == 0);
	assert(floatCompare(a, c) != 0);
	
	assert(intransitiveFloatCompare(a, b) == 0);
	assert(intransitiveFloatCompare(b, c) == 0);
	assert(intransitiveFloatCompare(a, c) != 0);	
}