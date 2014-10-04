module lib.math.permutation;

import std.algorithm;

/**
 *  Mixin for implementation permutation of elements of some object in situ.
 *
 *  Object is any kind of set with order and elements are disjoint subsets
 *  of the set which have position.
 *
 *  Objects has to provide two function: set(object, position, value) and
 *  get(object, position) returns value.
 *
 *  Particulary implementation of permuttion has to follow next pattern:
 *
 *  (void | Object) permute(Object object, Permutation permutation)pure @safe
 *  {
 *      // possible checks
 *      // prepare object (e.g. copy original for nonmutable version)
 *      mixin CorePermute!(result, setElement, getElement, permutation);
 *      permute();
 *      return result; // if needed
 *  }
 */
mixin template CorePermute(alias object, alias set, alias get, alias permutation)
{
	void permute()@safe
	{
		auto cycles = permutation.cycleRepresentation;
		foreach(const ref cycle; cycles)
		{
			auto temp = get(object, cycle[$ - 1]);
			for(auto j = cycle.length - 1; j > 0; --j)
				set(object, cycle[j], get(object, cycle[j - 1]));
			set(object, cycle[0], temp);
		}
	}
}

version(unittest)
{
int[4] getCluster(int[][] matrix, size_t index)pure nothrow @safe
{
	auto rows = matrix.length, colls = matrix[0].length;
	assert((rows & 1) == 0 && (colls & 1) == 0);
	auto row = (index / (colls >> 1)) << 1, coll = (index % (colls >> 1)) << 1;
	return [matrix[row][coll], matrix[row][coll + 1], matrix[row + 1][coll], matrix[row + 1][coll + 1]];
}

void setCluster(int[][] matrix, size_t index, int[4] array)pure nothrow @safe
{
	auto rows = matrix.length, colls = matrix[0].length;
	assert((rows & 1) == 0 && (colls & 1) == 0);
	auto row = (index / (colls >> 1)) << 1, coll = (index % (colls >> 1)) << 1;
	matrix[row][coll] = array[0];
	matrix[row][coll + 1] = array[1];
	matrix[row + 1][coll] = array[2];
	matrix[row + 1][coll + 1] = array[3];
}

int[][] permutationClusterBy(int[][] matrix, Permutation permutation)pure @safe
{
	typeof(return) result;
	result = matrix.dup;
	foreach(i; 0..result.length)
	result[i] = matrix[i].dup;
	mixin CorePermute!(result, setCluster, getCluster, permutation);
	permute();
	return result;
}
}

unittest
{
	auto p = Permutation(6);
	p._cycleRepresentation ~= [0, 4];
	p._cycleRepresentation ~= [2, 3, 5];

	assert(
	[[14, 15,  2,  3, 16, 17],
	 [20, 21,  8,  9, 22, 23],
	 [ 4,  5,  0,  1, 12, 13],
	 [10, 11,  6,  7, 18, 19]]

	          ==

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
			for(auto j = 0; j < cycle.length - 1 ; ++j)
				array[cycle[j]] = array[cycle[j + 1]];
			array[cycle[$ - 1]] = temp;
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
	@property ubyte[][] matrixRepresentation()const pure nothrow @safe
	{
		typeof(return) result = new ubyte[][size];
		foreach(i; 0..result.length)
		{
			result[i] = new ubyte[size];
			result[i][i] = 1;
		}

		foreach(const ref cycle; _cycleRepresentation)
		{
			foreach(i; 0..cycle.length)
			{
				result[cycle[i]][cycle[i]] = 0;
				result[cycle[(i +1) %cycle.length]][cycle[i]] = 1;
			}
		}

		return result;
	}

	/**
	 *  Tanspose current permutation
	 */
	void transpose(size_t a, size_t b)pure nothrow @safe
	{
		// TODO more optimal algorithm for such case
		this *= Permutation.transposition(size, a, b);
	}

	/**
	 *  Composition of two permutation.
	 *
	 *  By convention of permutation analyse the composition is left-associative,
	 *  i.e. in p*q*r the 'p' makes the first and the 'r' makes the last.
	 *  N.B! The corresponding permutation matrices (P, Q and so on) are right-associative,
	 *  as usual in math.
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

	/**
	 *  Composition of self and other permutations saved in self. Left associative.
	 */
	ref Permutation opOpAssign(string op)(Permutation rhs)
	if(op == "*")
	{
		this = this * rhs;
		return this;
	}

	string toString()
	{
		if(_cycleRepresentation.length == 0)
			return "(0)";

		string result;
		foreach(const ref cycle; _cycleRepresentation)
		{
			result ~= "(";
			foreach(i;0..cycle.length - 1)
			result ~= std.conv.to!string(cycle[i]) ~ ", ";
			result ~= std.conv.to!string(cycle[$ - 1]) ~ ")";
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

/**
 *  Inversion of permutation
 */
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
	auto r = Permutation(4);
	r.transpose(2, 1);
	assert(r == q);
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
	// Testing '*=' operator
	auto p = Permutation.transposition(4, 1, 2);
	auto q = Permutation.transposition(4, 2, 3);

	auto r = p;
	r *= q;
	assert(r == p * q);
}

unittest
{
	// Testing representation
	auto p = Permutation.transposition(4, 1, 2) * Permutation.transposition(4, 2, 3);
	assert([0, 3, 1, 2] == p.arrayRepresentation);
	assert([[1, 3, 2]] == p.cycleRepresentation);
	assert([[1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1], [0, 1, 0, 0]] == p.matrixRepresentation);
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
	// Testing permute as process
	int[] mul(const ubyte[][] matrix, int[] vector)pure nothrow @safe
	{
		assert(matrix[0].length == vector.length);
		auto result = new int[matrix.length];
		foreach(i; 0..result.length)
		foreach(j; 0..vector.length)
		result[i] += matrix[i][j] * vector[j];
		return result;
	}

	int[] map(const size_t[] mapper, int[] vector)pure nothrow @safe
	{
		assert(mapper.length == vector.length);
		int[] result = new int[vector.length];
		for(auto i = 0; i < mapper.length; ++i)
			result[mapper[i]] = vector[i];
		return result;
	}

	int[] permuteBy(int[] vector, Permutation permutation)pure @safe
	{
		auto result = vector.dup;

		void set(int[] vector, size_t position, int value)
		{
			vector[position] = value;
		}

		int get(int[] vector, size_t position)
		{
			return vector[position];
		}

		mixin CorePermute!(result, set, get, permutation);
		permute();
		return result;
	}

	auto p = Permutation.transposition(4, 1, 2);
	auto q = Permutation.transposition(4, 2, 3);
	auto r = p * q; //left associative

	int[] vector = [-1, 2, 4, 9];
	assert([-1, 4, 9, 2] == map(r.arrayRepresentation, vector));
	assert([-1, 4, 9, 2] == mul(r.matrixRepresentation, vector));
	assert([-1, 4, 9, 2] == permuteBy(vector, r));

	auto P = p.matrixRepresentation, Q = q.matrixRepresentation;
	assert([-1, 4, 9, 2] == mul(Q, mul(P, vector)));// right-associative
}

unittest
{
	// Testing toString
	assert("(0)" == (Permutation(4)).toString);
	auto p = Permutation.transposition(4, 1, 2);
	auto q = Permutation.transposition(4, 2, 3);
	assert("(1, 3, 2)" == (p * q).toString);
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
		cast(void) p.arrayRepresentation;// for invariant call
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

	try
	{
		auto p = Permutation(3);
		p *= Permutation(2);
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
