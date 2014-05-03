import std.stdio;
import std.datetime;
import std.conv;
import std.traits;
import std.typecons;
import lib.math.vector;
import lib.math.squarematrix;




void main()
{
	printBenchmarkResult!(testMulMatrix2x2f);
}

void printBenchmarkResult(alias fun)()
{
	auto statistics = statisticalBenchMark(&fun);
	writefln("%-30s = %10.2f +/- %5.0f \u00B5secs",fullyQualifiedName!fun, statistics[0], statistics[1]);
}

auto statisticalBenchMark(bool function(ref StopWatch) fun)
{
	import std.math;
	StopWatch sw;
	enum n = 100;
	TickDuration[n] times;
	TickDuration last = TickDuration.from!"seconds"(0);
	foreach(i; 0..n)
	{
		fun(sw);		
		times[i] = sw.peek() - last;
		last = sw.peek();
	}
	real sum = 0.0, sumSquare = 0.0;
	foreach(t; times)
	{
		sum += t.usecs;
		sumSquare += t.usecs ^^ 2;
	}
	real average = sum / n;
	real standart = sqrt((sumSquare - (sum ^^ 2) / n) / (n - 1));
	return tuple(average, standart);
} 

bool testMulMatrix2x2f(ref StopWatch sw)
{
	auto accum = Matrix2x2f.identity;
	auto matrix = Matrix2x2f(0.5, 0x1.00008p-1, 0.5, 0.5);
	foreach(unused; 0..1_000_000)
	{
		sw.start();
		accum = accum * matrix;
		sw.stop();
	}
	return accum[0,0] < accum[0,1];
}
