module math3d;

import std.math, std.stdio;


pure auto ToRadian (float arg)
{
    return arg / 180 * PI;
}

 pure auto ToDegree (float arg)
{
    return arg * 180 / PI;
}


struct Vector2f
{
    float x, y;
};

struct Vector3f
{
    float x, y, z;

    Vector3f opBinary (string op) (float arg)
    {
        Vector3f result = this;
        static if (op == "*")
        {
            result.x *= arg;
            result.y *= arg;
            result.z *= arg;
        }
        return result;
    }

    void opAssign (float[3] arg)
    {
        x=arg[0];
        y=arg[1];
        z=arg[2];
    }

    void opOpAssign (string op) (Vector3f arg)
    {
        static if (op == "+")
        {
            x += arg.x;
            y += arg.y;
            z += arg.z;
        }
        static if (op == "-")
        {
            x -= arg.x;
            y -= arg.y;
            z -= arg.z;
        }
    }

    auto VecProduct (Vector3f arg)
    {
        const float tempX = y * arg.z - z * arg.y;
        const float tempY = z * arg.x - x * arg.z;
        const float tempZ = x * arg.y - y * arg.x;

        return  Vector3f (tempX, tempY, tempZ);
    }

    ref Vector3f Normalize ()
    {
        const float length = sqrt (x * x + y * y + z * z);

        x /= length;
        y /= length;
        z /= length;

        return this;
    }

    auto Rotate (float angle, Vector3f axis)
    {
        const float sinHalfAngle = sin (ToRadian(angle/2));
        const float cosHalfAngle = cos (ToRadian(angle/2));

        const float tempX = axis.x * sinHalfAngle;
        const float tempY = axis.y * sinHalfAngle;
        const float tempZ = axis.z * sinHalfAngle;
        const float tempW = cosHalfAngle;

    auto rotationQ = Quaternion(tempX, tempY, tempZ, tempW);

    Quaternion conjugateQ = rotationQ.Conjugate();

    Quaternion result = rotationQ * this * conjugateQ;

    x = result.x;
    y = result.y;
    z = result.z;
    }
};


struct Matrix4f
{
    @property nothrow float** ptr ()
    {
        return cast (float**) container.ptr;
    }

    @property nothrow void init ()
    {
        foreach (ushort i; 0..4)
        foreach (ushort j; 0..4)
        {
            if (i==j)
                container[i][j]=1.0f;
            else
                container[i][j]=0.0f;
        }
    }

    nothrow void ToZero ()
    {
        foreach (ref e; container)
        foreach (ref e1; e)
            e1=0.0f;
    }

    float[] opIndex (int i)
    {
        if (i<4 && i>=0)
            return container[i];
        else
            return null;
    }

    Matrix4f opBinary (string op) (ref Matrix4f arg)
    {
        Matrix4f result;
        result.ToZero ();

        static if (op=="*")
        {
            foreach (i; 0..4)
            foreach (j; 0..4)
            foreach (k; 0..4)
                result[i][j]+=this[i][k]*arg[k][j];
        }

        return result;
    }

    auto InitScale (float _x, float _y, float _z)
    {
        this.init;
        this[0][0] = _x;
        this[1][1] = _y;
        this[2][2] = _z;
    }

    auto InitRotation (float _x, float _y, float _z)
    {

        auto x = ToRadian (_x);
        auto y = ToRadian (_y);
        auto z = ToRadian (_z);

        Matrix4f overX, overY, overZ;

        overX.init;
        overX[1][1] = cos(x);
        overX[1][2] = -sin(x);
        overX[2][1] = sin(x);
        overX[2][2] = cos(x);

        // Здесь какой-то глюк
        overY.init;
        overY[0][0] = cos(y);
        overY[0][2] = -sin(y);
        overY[2][0] = sin(y);
        overY[2][2] = cos(y);

        overZ.init;
        overY[0][0] = cos(z);
        overY[0][1] = -sin(z);
        overY[1][0] = sin(z);
        overY[1][1] = cos(z);

        this = overZ*overY*overX;
    }

    auto InitPosition (float _x, float _y, float _z)
    {
        this.init;
        this[0][3] = _x;
        this[1][3] = _y;
        this[2][3] = _z;
    }

    auto InitCameraTransform (ref Vector3f target, ref Vector3f up)
    {
        auto N = target;
        N.Normalize();
        auto U = up;
        U.Normalize();
        U = U.VecProduct(N);
        auto V = N.VecProduct(U);

        this.init;
        this[0][0] = U.x;
        this[0][1] = U.y;
        this[0][2] = U.z;

        this[1][0] = V.x;
        this[1][1] = V.y;
        this[1][2] = V.z;

        this[2][0] = N.x;
        this[2][1] = N.y;
        this[2][2] = N.z;
    }

    auto InitPerspective (float angle, float width, float height, float nearestPlane, float farPlane)
    {
        const float ratio = width / height,
        near = nearestPlane,
        far = farPlane,
        range = near - far,
        tangentHalf = tan (ToRadian(angle / 2.0f));

        this.init;
        this[0][0] = 1.0f / (ratio * tangentHalf);
        this[1][1] = 1.0f / tangentHalf;
        this[2][2] = (-near - far) / range;
        this[2][3] = 2.0f * far * near / range;
        this[3][2] = 1.0f;
        this[3][3] = 0.0f;

    }

private:

    float[4][4] container;
};


struct Quaternion
{
    public:

    float x, y, z, w;

    this (float _x, float _y, float _z, float _w)
    {
        x = _x;
        y = _y;
        z = _z;
        w = _w;
    }

    auto Normalize ()
    {
        float length = sqrt (x * x + y * y + z * z + w * w);
        x /= length;
        y /=length;
        z /= length;
        w /= length;
    }

    auto Conjugate ()
    {
       return Quaternion (-x, -y, -z, w);
    }

    auto opBinary (string op) (ref Quaternion arg)
    {
        static if (op == "*")
        {
            const float tempW = (w * arg.w) - (x * arg.x) - (y * arg.y) - (z * arg.z);
            const float tempX = (x * arg.w) + (w * arg.x) + (y * arg.z) - (z * arg.y);
            const float tempY = (y * arg.w) + (w * arg.y) + (z * arg.x) - (x * arg.z);
            const float tempZ = (z * arg.w) + (w * arg.z) + (x * arg.y) - (y * arg.x);

            return Quaternion (tempX, tempY, tempZ, tempW);
        }
    }

    auto opBinary (string op) (ref Vector3f arg)
    {
        static if (op == "*")
        {
            const float tempW = - (x * arg.x) - (y * arg.y) - (z * arg.z);
            const float tempX =   (w * arg.x) + (y * arg.z) - (z * arg.y);
            const float tempY =   (w * arg.y) + (z * arg.x) - (x * arg.z);
            const float tempZ =   (w * arg.z) + (x * arg.y) - (y * arg.x);

            return Quaternion (tempX, tempY, tempZ, tempW);
        }
    }
 };
