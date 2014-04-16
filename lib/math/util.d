import std.math;

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
long floatCompare(real lhs, real rhs, int saveDigit = 10) pure nothrow @safe
{
	assert(isFinite(lhs) && isFinite(rhs));
	return truncation(lhs, saveDigit) - truncation(rhs, saveDigit);
}

/**
 *  Roundig truncation
 */
long truncation(real floatingNumber, int saveDigit) pure nothrow @safe
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