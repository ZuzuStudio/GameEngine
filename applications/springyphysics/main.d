import std.stdio;
import lib.math.vector;

void main()
{
	writeln("Here will be springy bodies project");
	Vector3f v = Vector3f(1.0f, 2.0f, 3.0f);
	writefln("v^2 = %s", dot(v,v));
}
