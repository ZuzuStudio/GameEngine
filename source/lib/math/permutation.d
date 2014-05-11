module lib.math.permutation;

import std.stdio;

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
		import std.algorithm;
		auto newRepresentation = selfCopy(_cycleRepresentation);
		swap(newRepresentation, _cycleRepresentation);
	}

	ref Permutation opAssign(Permutation rhs)
	{
		import std.algorithm;
		swap(rhs, this);
		return this;
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

private:
	size_t[][] _cycleRepresentation;

	pure nothrow @safe invariant()
	{
		size_t sum = 0;
		foreach(const ref cycle; _cycleRepresentation)
		sum += cycle.length;
		assert(sum <= _size);
		// TODO
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

unittest
{
	// Testing simple construction and inner representation
	auto p = Permutation(8);
	assert(p.size == 8);
	assert([0, 1, 2, 3, 4, 5 ,6, 7] == p.arrayRepresentation);
	p._cycleRepresentation ~= [1, 3];
	p._cycleRepresentation ~= [0, 7, 5];
	assert([7, 3, 2, 1, 4, 0, 6, 5] == p.arrayRepresentation);
	import std.stdio;
	writeln(p._cycleRepresentation);
	writeln(p.cycleRepresentation);
	auto m = p.matrixRepresentation;
	foreach(const ref row; m)
	{
		foreach(e; row)
		write(e?'1':'.');
		writeln();
	}
}

unittest
{
	auto p = Permutation(3);
	p._cycleRepresentation ~= [0, 1];
	auto q = p;
	assert(q == p);
	q._cycleRepresentation[0] ~= 2;
	assert(q != p);
	p = q;
	assert(q == p);
}
