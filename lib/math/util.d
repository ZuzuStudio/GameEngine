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

	this(T value)
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

unittest
{
	assert(behaveAsFloatingPoint!float);
	assert(behaveAsFloatingPoint!double);
	assert(behaveAsFloatingPoint!real);
	assert(behaveAsFloatingPoint!Float);
	assert(!behaveAsFloatingPoint!byte);
	assert(!behaveAsFloatingPoint!short);
	assert(!behaveAsFloatingPoint!int);
	assert(!behaveAsFloatingPoint!long);
	assert(!behaveAsFloatingPoint!char);
	assert(!behaveAsFloatingPoint!dchar);
	assert(!behaveAsFloatingPoint!wchar);
	assert(!behaveAsFloatingPoint!string);
	assert(!behaveAsFloatingPoint!(float[]));
	assert(!behaveAsFloatingPoint!cdouble);
	assert(!behaveAsFloatingPoint!idouble);
	struct S{}
	assert(!behaveAsFloatingPoint!S);
	assert(!behaveAsFloatingPoint!(S[]));
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

	enum bool hasZero = __traits(compiles, cast(T)0.0);

	enum bool hasIdentity = __traits(compiles, cast(T)1.0);

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
	assert(isAlgebraicField!Float);
	assert(!isAlgebraicField!string);
	assert(!isAlgebraicField!(float[]));
}

/**
 *  Predicate which checks for equality and comparsion
 */
template isLinearComparable(T)
{
	enum bool isLinearComparable = __traits(compiles,{T t; bool result = t == t;}) && __traits(compiles,{T t; bool result = t < t;});
}

unittest
{
	assert(isLinearComparable!int);
	assert(isLinearComparable!byte);
	assert(isLinearComparable!long);
	assert(isLinearComparable!float);
	assert(isLinearComparable!double);
	assert(isLinearComparable!real);
	assert(isLinearComparable!Float);
	assert(isLinearComparable!string);
	assert(isLinearComparable!(float[]));
	struct S{}
	assert(!isLinearComparable!S);
	assert(isLinearComparable!(S[]));//TODO that have not comparable
}

/**
 *  Predicate which checks epsilon property
 */
template hasEpsilon(T)
{
	enum bool hasEpsilon = __traits(compiles,{ auto eps = T.epsilon;});
}

unittest
{
	assert(hasEpsilon!float);
	assert(hasEpsilon!double);
	assert(hasEpsilon!real);
	assert(hasEpsilon!Float);
	assert(!hasEpsilon!int);
	assert(!hasEpsilon!(float[]));
	struct S{}
	assert(!hasEpsilon!S);
	assert(!hasEpsilon!(S[]));
}

/**
 *  Predicate which checks nan property
 */
template hasNan(T)
{
	enum bool hasNan = __traits(compiles,{ auto eps = T.nan;});
}

unittest
{
	assert(hasNan!float);
	assert(hasNan!double);
	assert(hasNan!real);
	assert(hasNan!Float);
	assert(!hasNan!int);
	assert(!hasNan!(float[]));
	struct S{}
	assert(!hasNan!S);
	assert(!hasNan!(S[]));
}

/**
 *  Predicate which checks inf property
 */
template hasInf(T)
{
	enum bool hasInf = __traits(compiles,{ auto eps = T.infinity;});
}

unittest
{
	assert(hasInf!float);
	assert(hasInf!double);
	assert(hasInf!real);
	assert(hasInf!Float);
	assert(!hasInf!int);
	assert(!hasInf!(float[]));
	struct S{}
	assert(!hasInf!S);
	assert(!hasInf!(S[]));
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
