module lib.math.permutation;

import std.stdio;// TODO <- delete
import std.algorithm;

struct Permutation
{
public:
	/**
	 *  Permutation has no default constructor.
	 */
	@disable this();

	/**
	 *  Create identity permutation of size element.
	 */
	this(size_t size)pure nothrow @safe
	{
		_size = size;
		_cycleRepresentation = new size_t[][0];
	}

	/**
	 *  Postblit constructor
	 */
	this(this)pure nothrow @safe
	{
		auto newRepresentation = selfCopy(_cycleRepresentation);
		swap(newRepresentation, _cycleRepresentation);
	}

	/**
	 *  Assign operator
	 */
	ref Permutation opAssign(Permutation rhs)pure nothrow @safe
	{
		swap(rhs, this);
		return this;
	}

	/**
	 *  Identity permutation of the size
	 */
	static Permutation identity(size_t size)pure nothrow @safe
	{
		return Permutation(size);
	}

	/**
	 *  Transposition of the elements
	 */
	static Permutation transposition(size_t size, size_t a, size_t b)pure nothrow @safe
	in
	{
		assert(0 <= a && a < size && 0 <= b && b < size, "transposed elements are out of bounds");
	}
	body
	{
		auto result = Permutation(size);
		if(a != b)
		{
			++result._rank;
			result._cycleRepresentation ~= [a, b];
		}
		return result;
	}

	@property size_t size()const pure nothrow @safe
	{
		return _size;
	}

	private size_t _size;

	/**
	 *  Determinant for corresponding matrix of permutation. It equals 1 or -1 only.
	 */
	@property byte determinant()const pure nothrow @safe
	{
		return rank & 1 ? -1 : 1;
	}

	@property size_t rank()const pure nothrow @safe
	{
		return _rank;
	}

	private size_t _rank;

	/**
	 *  Coresponding array representation. E.g. [0, 3, 1, 2].
	 */
	@property size_t[] arrayRepresentation()const pure nothrow @safe
	{
		auto array = new size_t[size];

		foreach(i,ref e;array)
		e = i;

		foreach(const ref cycle; _cycleRepresentation)
		{
			auto temp = array[cycle[0]];
			for(auto j = 0; j < cycle.length - 1; ++j)
				array[cycle[j]] = array[cycle[j + 1]];
			array[cycle[$-1]] = temp;
		}

		return array;
	}

	/**
	 *  Coresponding cycle representation. E.g. (1, 3, 2) i.e. 1 -> 3 -> 2 -> 1
	 */
	@property size_t[][] cycleRepresentation()const pure nothrow @safe
	{
		return selfCopy(_cycleRepresentation);
	}

	/**
	 *  Coresponding matrix representation.
	 *  E.g. [[1, 0, 0, 0],
	 *        [0, 0, 0, 1],
	 *        [0, 1, 0, 0],
	 *        [0, 0, 1, 0]]
	 */
	@property byte[][] matrixRepresentation()const pure nothrow @safe
	{
		typeof(return) result = new byte[][size];
		foreach(i; 0..result.length)
		{
			result[i] = new byte[size];
			result[i][i] = 1;
		}

		foreach(const ref cycle; _cycleRepresentation)
		{
			foreach(i; 0..cycle.length)
			{
				result[cycle[i]][cycle[i]] = 0;
				result[cycle[i]][cycle[(i +1) %cycle.length]] = 1;
			}
		}

		return result;
	}

	/**
	 *  Composition of two permutation.
	 */
	Permutation opBinary(string op)(Permutation rhs)pure nothrow @safe
	if(op == "*")
	in
	{
		assert(size == rhs.size, "size of composed permutations missmatch");
	}
	body
	{
		auto result = Permutation(size);
		// TODO
		return result;
	}

private:
	size_t[][] _cycleRepresentation;

	pure nothrow @safe invariant()
	{
		auto distribution = new size_t[_size];
		size_t previous = 0;
		foreach(const ref cycle; _cycleRepresentation)
		{
			assert(previous <= cycle[0], "cyclces hasn't ascending order");
			previous = cycle[0];
			assert(cycle.length > 1, "fixed point cycle present");
			foreach(e; cycle)
			{
				assert(e >= 0 && e < _size, "impossible member of permutation");
				++distribution[e];
				assert(distribution[e] == 1, "member of cycle isn't unique");
				assert(cycle[0] <= e, "first element of cycle isn't minimal");
			}
		}
	}

	static size_t[][] selfCopy(const size_t[][] _cycleRepresentation)pure nothrow @safe
	{
		size_t[][] newRepresentation = new size_t[][_cycleRepresentation.length];

		foreach(i; 0.._cycleRepresentation.length)
		{
			newRepresentation[i] = new size_t[_cycleRepresentation[i].length];
			foreach(j;0.._cycleRepresentation[i].length)
			newRepresentation[i][j] = _cycleRepresentation[i][j];
		}

		return newRepresentation;
	}
}

Permutation invert(Permutation argument)pure nothrow @safe
{
	foreach(ref cycle; argument._cycleRepresentation)
	for(auto i = 1; i < cycle.length - i; ++i)
		swap(cycle[i], cycle[$-i]);
	return argument;
}

unittest
{
	// Testing simple construction and inner representation
	import std.traits;
	assert(!__traits(compiles, {Permutation p;}));
	auto p = Permutation(8);
	assert(p.size == 8);
	assert([0, 1, 2, 3, 4, 5 ,6, 7] == p.arrayRepresentation);
	p._cycleRepresentation ~= [0, 7, 5];
	p._cycleRepresentation ~= [1, 3];
	assert([7, 3, 2, 1, 4, 0, 6, 5] == p.arrayRepresentation);
}

unittest
{
	// Testing postblit and assign
	auto p = Permutation(3);
	p._cycleRepresentation ~= [0, 1];
	auto q = p;
	assert(q == p);
	q._cycleRepresentation[0] ~= 2;
	assert(q != p);
	p = q;
	assert(q == p);
}

unittest
{
	// Testing inversion
	auto p = Permutation(10);
	p._cycleRepresentation ~= [0, 7, 5];
	p._cycleRepresentation ~= [1, 3];
	p._cycleRepresentation ~= [2, 4, 6, 8, 9];
	assert([7, 3, 4, 1, 6, 0, 8, 5, 9, 2] == p.arrayRepresentation);
	assert([5, 3, 9, 1, 2, 7, 4, 0, 6, 8] == invert(p).arrayRepresentation);
}

unittest
{
	// Testing contracts
	import core.exception;

	try
	{
		auto p = Permutation(3);
		p._cycleRepresentation ~= [0, 2];
		p._cycleRepresentation ~= [1];
		p.arrayRepresentation;// for invariant call
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "fixed point cycle present");
	}

	try
	{
		auto p = Permutation(3);
		p._cycleRepresentation ~= [0, 2, 3];
		p.arrayRepresentation;// for invariant call
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "impossible member of permutation");
	}

	try
	{
		auto p = Permutation(4);
		p._cycleRepresentation ~= [0, 2];
		p._cycleRepresentation ~= [1, 2];
		p.arrayRepresentation;// for invariant call
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "member of cycle isn't unique");
	}

	try
	{
		auto p = Permutation(5);
		p._cycleRepresentation ~= [0, 2];
		p._cycleRepresentation ~= [3, 1, 4];
		p.arrayRepresentation;// for invariant call
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "first element of cycle isn't minimal");
	}

	try
	{
		auto p = Permutation(5);
		p._cycleRepresentation ~= [1, 4, 3];
		p._cycleRepresentation ~= [0, 2];
		p.arrayRepresentation;// for invariant call
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "cyclces hasn't ascending order");
	}

	try
	{
		auto p = Permutation.transposition(4, 2, 4);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "transposed elements are out of bounds");
	}

	try
	{
		Permutation(3) * Permutation(2);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "size of composed permutations missmatch");
	}
}

private struct FreeElementIterator
{
	@disable this();

	this(size_t size)pure nothrow @safe
	{
		array = new bool[size];
		current = 0;
	}

	void mark(size_t position)pure nothrow @safe
	in
	{
		assert(position < array.length, "mark is out of bounds");
	}
	body
	{
		array[position] = true;
	}

	bool hasNext()pure nothrow @safe
	{
		while(current < array.length && array[current])
			++current;
		return current < array.length;
	}

	@property auto next()const pure nothrow @safe
	in
	{
		assert(current < array.length, "calling next without checking hasNext");
	}
	body
	{
		return current;
	}

	bool[] array;
	size_t current;
}

unittest
{
	// Testing simple constructor
	import std.traits;
	assert(!__traits(compiles, {FreeElementIterator it;}));
	auto it = FreeElementIterator(4);
	assert([0, 0, 0, 0] == it.array);
	assert(0 == it.current);
}

unittest
{
	// Testing mark
	auto it = FreeElementIterator(5);
	it.mark(3);
	assert([0, 0, 0, 1, 0] == it.array);
}

unittest
{
	// Testing hasNext
	auto it = FreeElementIterator(5);
	assert(it.hasNext() && it.current == 0);
	it.mark(0);
	it.mark(3);
	it.mark(1);
	assert(it.hasNext() && it.current == 2);
	it.mark(2);
	it.mark(4);
	assert(!it.hasNext() && it.current == 5);
}

unittest
{
	// Testing contracts
	import core.exception;

	try
	{
		auto it = FreeElementIterator(4);
		it.mark(4);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "mark is out of bounds");
	}

	try
	{
		auto it = FreeElementIterator(2);
		it.mark(0);
		it.mark(1);
		it.hasNext();
		it.next;
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "calling next without checking hasNext");
	}
}
