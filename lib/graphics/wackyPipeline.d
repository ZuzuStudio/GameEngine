module wackyPipeline;

import lib.math.vector;
import lib.math.squarematrix;
import std.math: PI;

/**
 * The class holds transformations
 */

class WackyPipeline
{
public:
    // Default constructor

    /**
     *  Setting vector with scale data
     */
    auto setScale(Vector3f scale) pure nothrow
    {
        this.scale = scale;
    }

    auto setScale(float scaleX, float scaleY, float scaleZ) pure nothrow
    {
        scale = Vector3f(scaleX, scaleY, scaleZ);
    }

    /**
     *  Setting vector with world position data
     */
    auto setWorldPosition(Vector3f worldPosition) pure nothrow
    {
        this.worldPosition = worldPosition;
    }

    auto setWorldPosition(float x, float y, float z) pure nothrow
    {
        worldPosition = Vector3f(x, y, z);
    }

    /**
     *  Setting vector with rotation data
     */
    auto setRotation(Vector3f rotationAngles) pure nothrow
    {
        this.rotationAngles = rotationAngles;
    }

    auto setRotation(float angleX, float angleY, float angleZ) pure nothrow
    {
        rotationAngles = Vector3f(angleX, angleY, angleZ);
    }

    /**
     *  Returns a Matrix4x4f which represents world transformation
     */
    auto getWorldTransformation() pure nothrow
    {
        auto scaleTransformation = initScaleTransformation(scale);
        auto worldPoistionTransformation = initPositionTransformation(worldPosition);
        auto rotationTransformation = initRotationTransformation(rotationAngles);

        return worldPoistionTransformation * rotationTransformation * scaleTransformation;
    }

private:
    Vector3f scale = Vector3f(1.0f, 1.0f, 1.0f);
    Vector3f worldPosition;
    Vector3f rotationAngles;
};


unittest
{
    auto pipeline = new WackyPipeline();
    pipeline.setScale(0.01f, 0.01f, 0.01f);
    pipeline.setWorldPosition(2.0f, 0.0f, 3.0f);
    pipeline.setRotation(0.0f, 45.0f / 180.0f * PI, 0.0f);
    auto matrix = pipeline.getWorldTransformation();

    assert (matrix[2, 0] < 0.007 + 0.0001 && matrix[2, 0] > 0.007 - 0.0001);
    assert (matrix[2, 3] == 3.0f);
    assert (matrix[1, 1] == 0.01f);
}
