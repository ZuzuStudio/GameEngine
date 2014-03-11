module lib.math.vector;

private
{
    import std.math;
    import std.traits;
}

struct Vector(T, int size)
{
public:

    this (Vector!(T, size) v)
    {
        foreach(i; 0..size)
        array[i] = v.array[i];
    }

    void opAssign(int size)(Vector!(T, size) v)
    {
        foreach(i; 0..size)
        array[i] = v.array[i];
    }

    /*
     * -Vector!(T,size)
     */
    Vector!(T,size) opUnary(string s) () const if (s == "-")
        body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = -array[i];
        return res;
    }

    /*
     * +Vector!(T,size)
     */
    Vector!(T,size) opUnary(string s) () const if (s == "+")
        body
    {
        return Vector!(T,size)(this);
    }

    /*
     * Vector!(T,size) + Vector!(T,size)
     */
    Vector!(T,size) opAdd (Vector!(T,size) v) const
    body
    {
        Vector!(T,size) res;
        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] + v.array[i]);
        return res;
    }

    /*
     * Vector!(T,size) - Vector!(T,size)
     */
    Vector!(T,size) opSub (Vector!(T,size) v) const
    body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] - v.array[i]);
        return res;
    }

    /*
     * Vector!(T,size) * Vector!(T,size)
     */
    Vector!(T,size) opBinary(string op) (Vector!(T,size) v) const if (op == "*")
        body
    {
        Vector!(T,size) res;
        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] * v.array[i]);
        return res;
    }


    /*
     * Vector!(T,size) + T
     */
    Vector!(T,size) opAdd (T t) const
    body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] + t);
        return res;
    }

    /*
     * Vector!(T,size) - T
     */
    Vector!(T,size) opSub (T t) const
    body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] - t);
        return res;
    }

    /*
     * Vector!(T,size) * T
     */
    Vector!(T,size) opBinary(string op) (T t) const if (op == "*")
        body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] * t);
        return res;
    }

    /*
     * T * Vector!(T,size)
     */
    Vector!(T,size) opBinaryRight(string op) (T t) const if (op == "*" && isNumeric!T)
        body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] * t);
        return res;
    }

    /*
     * Vector!(T,size) / T
     */
    Vector!(T,size) opDiv (T t) const
    body
    {
        Vector!(T,size) res;

        foreach(i; 0..size)
        res.array[i] = cast(T)(array[i] / t);
        return res;
    }

    /*
     * Vector!(T,size) += Vector!(T,size)
     */
    Vector!(T,size) opAddAssign (Vector!(T,size) v)
    body
    {
        foreach(i; 0..size)
        array[i] += v.array[i];
        return this;
    }

    /*
     * Vector!(T,size) -= Vector!(T,size)
     */
    Vector!(T,size) opSubAssign (Vector!(T,size) v)
    body
    {
        foreach(i; 0..size)
        array[i] -= v.array[i];
        return this;
    }

    /*
     * Vector!(T,size) *= Vector!(T,size)
     */
    Vector!(T,size) opMulAssign (Vector!(T,size) v)
    body
    {
        foreach(i; 0..size)
        array[i] *= v.array[i];
        return this;
    }

    /*
     * Vector!(T,size) += T
     */
    Vector!(T,size) opAddAssign (T t)
    body
    {
        foreach(i; 0..size)
        array[i] += t;
        return this;
    }

    /*
     * Vector!(T,size) -= T
     */
    Vector!(T,size) opSubAssign (T t)
    body
    {
        foreach(i; 0..size)
        array[i] -= t;
        return this;
    }

    /*
     * Vector!(T,size) *= T
     */
    Vector!(T,size) opMulAssign (T t)
    body
    {
        foreach(i; 0..size)
        array[i] *= t;
        return this;
    }

    /*
     * Vector!(T,size) /= T
     */
    Vector!(T,size) opDivAssign (T t)
    body
    {
        foreach(i; 0..size)
        array[i] /= t;
        return this;
    }

    /*
     * T = Vector!(T,size)[index]
     */
    auto ref T opIndex (this X)(size_t index)
    in
    {
        assert ((0 <= index) && (index < size),
        "Vector!(T,size).opIndex(int index): array index out of bounds");
    }
    body
    {
        return array[index];
    }

    /*
     * Vector!(T,size)[index] = T
     */
    void opIndexAssign (T n, size_t index)
    in
    {
        assert ((0 <= index) && (index < size),
        "Vector!(T,size).opIndexAssign(int index): array index out of bounds");
    }
    body
    {
        array[index] = n;
    }


    /*
     * T = Vector!(T,size)[]
     */
    auto opSlice (this X)()
    body
    {
        return array[];
    }

    /*
     * Vector!(T,size)[] = T
     */
    T opSliceAssign (T t)
    body
    {
        foreach(i; 0..size)
        array[i] = t;
        return t;
    }

    static if (isNumeric!(T))
    {
        /*
         * Get vector length squared
         */
        @property T lengthsqr() const
        body
        {
            T res = 0;
            foreach (e; array)
            res += e * e;
            return res;
        }

        /*
         * Get vector length
         */
        @property T length() const
        body
        {
            static if (isFloatingPoint!T)
            {
                T t = 0;
                foreach (e; array)
                t += e * e;
                return sqrt(t);
            }
            else
            {
                T t = 0;
                foreach (e; array)
                t += e * E;
                return cast(T)sqrt(cast(float)t);
            }
        }

        /*
         * Set vector length to 1
         */
        void normalize()
        body
        {
            static if (isFloatingPoint!T)
            {
                T lensqr = lengthsqr();
                if (lensqr > 0)
                {
                    T coef = 1.0 / sqrt(lensqr);
                    foreach (ref e; array)
                    e *= coef;
                }
            }
            else
            {
                T lensqr = lengthsqr();
                if (lensqr > 0)
                {
                    float coef = 1.0 / sqrt(cast(float)lensqr);
                    foreach (ref e; array)
                    e *= coef;
                }
            }
        }

        /*
         * Return normalized copy
         */
        @property Vector!(T,size) normalized() const
        body
        {
            Vector!(T,size) res = this;
            res.normalize();
            return res;
        }

        /*
         * Return true if all components are zero
         */
        @property bool isZero() const
        body
        {
            return (array[] == [0]);
        }
    }

private:
    T [size]array;
}


alias Vector!(float, 3) Vector3f;
