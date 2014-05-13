module lib.math.permutation;

import std.stdio;// TODO <- delete
import std.algorithm;

/**
 * Mixin for implementation permutation of elements of some object
 */
mixin template CorePermute(alias object, alias set, alias get, alias cycles)
{
	void permute()
	{
		foreach(const ref cycle; cycles)
		{
			auto temp = get(object, cycle[$-1]);
			for(auto j = 0; j < cycle.length - 1; ++j)
				set(object, cycle[j+1], get(object, cycle[j]));
			set(object, cycle[0], temp);
		}
	}
}

version(unittest)
{
int[4] getCluster(int[][] matrix, size_t index)
{
	auto rows = matrix.length, colls = matrix[0].length;
	assert((rows & 1) == 0 && (colls & 1) == 0);
	auto row = (index / (colls >> 1)) << 1, coll = (index % (colls >> 1)) << 1;
	return [matrix[row][coll], matrix[row][coll + 1], matrix[row + 1][coll], matrix[row + 1][coll + 1]];
}

void setCluster(int[][] matrix, size_t index, int[4] array)
{
	auto rows = matrix.length, colls = matrix[0].length;
	assert((rows & 1) == 0 && (colls & 1) == 0);
	auto row = (index / (colls >> 1)) << 1, coll = (index % (colls >> 1)) << 1;
	matrix[row][coll] = array[0];
	matrix[row][coll + 1] = array[1];
	matrix[row + 1][coll] = array[2];
	matrix[row + 1][coll + 1] = array[3];
}

int[][] permutationClusterBy(int[][] matrix, Permutation permutation)
{
	typeof(return) result;
	result = matrix.dup;
	foreach(i; 0..result.length)
	result[i] = matrix[i].dup;
	auto cycles = permutation.cycleRepresentation;
	mixin CorePermute!(result, setCluster, getCluster, cycles);
	permute();
	return result;
}
}

unittest
{
	auto p = Permutation(6);
	p._cycleRepresentation ~= [0, 4];
	p._cycleRepresentation ~= [2, 3, 5];

	/*assert(
	[[14, 15,  2,  3, 16, 17],
	 [20, 21,  8,  9, 22, 23],
	 [ 4,  5,  0,  1, 12, 13],
	 [10, 11,  6,  7, 18, 19]]

	          ==*/
	writeln(
	[[ 0,  1,  2,  3,  4,  5],
	 [ 6,  7,  8,  9, 10, 11],
	 [12, 13, 14, 15, 16, 17],
	 [18, 19, 20, 21, 22, 23]].permutationClusterBy(p)
	);
}

/**
 *  Calssical algebraic permutation
 */
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
			result._cycleRepresentation ~= a < b ? [a, b] : [b, a];
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
	Permutation opBinary(string op)(Permutation rhs)const pure nothrow @safe
	if(op == "*")
	in
	{
		assert(size == rhs.size, "size of composed permutations missmatch");
	}
	body
	{
		auto result = Permutation(size);
		auto composedCycles = this._cycleRepresentation ~ rhs._cycleRepresentation;
		auto it = FreeElementIterator(size);
		while(it.hasNext())
		{
			size_t[] newCycle;
			size_t element = it.next;

			do
			{
				newCycle ~= element;
				it.mark(element);
				foreach(const ref cycle; composedCycles)
				element = cycle.map(element);
			}while(element != newCycle[0]);

			if(newCycle.length > 1)
			{
				result._cycleRepresentation ~= newCycle;
				result._rank += newCycle.length - 1;
			}
		}
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
	// Testing identity and transposition
	auto p = Permutation.identity(3);
	assert([0, 1, 2] == p.arrayRepresentation);
	auto q = Permutation.transposition(4, 2, 1);
	assert([0, 2, 1, 3] == q.arrayRepresentation);
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
	// Testing composition
	auto p = Permutation(9);
	p._cycleRepresentation ~= [1, 4, 6, 3, 7];
	p._cycleRepresentation ~= [2, 8];
	auto q = Permutation(9);
	q._cycleRepresentation ~= [1, 4, 7, 8];
	q._cycleRepresentation ~= [2, 5, 3];
	assert([[1, 7, 4, 6, 2], [3, 8, 5]] == (p * q)._cycleRepresentation);
	assert([[1, 6, 3, 8, 4], [2, 5, 7]] == (q * p)._cycleRepresentation);
}

unittest
{
	// Testing representation
	auto p = Permutation.transposition(4, 1, 2) * Permutation.transposition(4, 2, 3);
	assert([0, 3, 1, 2] == p.arrayRepresentation);
	assert([[1, 3, 2]] == p.cycleRepresentation);
	assert([[1, 0, 0, 0], [0, 0, 0, 1], [0, 1, 0, 0], [0, 0, 1, 0]] == p.matrixRepresentation);
}

unittest
{
	// Testing rank and determinant
	assert(0 == Permutation.identity(27).rank);
	assert(1 == Permutation.transposition(8, 2, 7).rank);
	assert(3 == (Permutation.transposition(8, 2, 7) * Permutation.transposition(8, 3, 7) * Permutation.transposition(8, 4, 5)).rank);
	assert(1 == (Permutation.transposition(8, 2, 7) * Permutation.transposition(8, 2, 7) * Permutation.transposition(8, 4, 5)).rank);
	assert(1 == Permutation.identity(27).determinant);
	assert(-1 == Permutation.transposition(8, 2, 7).determinant);
	assert(-1 == (Permutation.transposition(8, 2, 7) * Permutation.transposition(8, 3, 7) * Permutation.transposition(8, 4, 5)).determinant);
	assert(-1 == (Permutation.transposition(8, 2, 7) * Permutation.transposition(8, 2, 7) * Permutation.transposition(8, 4, 5)).determinant);
}

unittest
{
	// Some additional unittests
	auto p = Permutation(9);
	p._cycleRepresentation ~= [1, 4, 6, 3, 7];
	p._cycleRepresentation ~= [2, 8];
	assert(Permutation.identity(9) == p * invert(p));
	assert(Permutation.identity(9) == invert(p) * p);
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

///

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

///

size_t map(const(size_t[]) cycle, size_t argument)pure nothrow @safe
{
	size_t current = 0;
	while(current < cycle.length && cycle[current] != argument)
		++current;
	return current < cycle.length ? cycle[(current + 1) % cycle.length] : argument;
}

unittest
{
	assert(0 == [2, 3].map(0));
	assert(3 == [2, 3].map(2));
	assert(2 == [2, 3].map(3));
	assert(4 == [1, 6, 0, 4, 9].map(0));
}
