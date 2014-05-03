module wackyPipeline;

private
{
    import std.math: PI;

    import wackyCamera: CameraData;

    import lib.math.vector;
    import lib.math.squarematrix;
}
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
     *  Setting perspective data.
     *  For width and height parameters values of
     *  glfwGetWindowWidth() should be used
     */
    auto setPerspectiveData(float angle, float width, float height, float nearPlane, float farPlane) pure nothrow
    {
        perspectiveData = PerspectiveData(angle, width, height, nearPlane, farPlane);
    }

    /**
     *  Setting camera data
     */
    auto setCameraData(Vector3f position, Vector3f target, Vector3f up) pure nothrow
    {
        cameraData = CameraData(position, target, up);
    }

    /**
     *  Returns a Matrix4x4f which represents world transformation
     */
    @property auto getWorldTransformation() pure nothrow
    {
        auto worldPositionTransformation = initPositionTransformation(worldPosition);
        auto rotationTransformation = initRotationTransformation(rotationAngles);
        auto scaleTransformation = initScaleTransformation(scale);

        return worldPositionTransformation * rotationTransformation * scaleTransformation;
    }

    /**
     *  Returns the viewport transformation
     */
    @property auto getViewportTransformation()
    {
        auto perspectiveTransformation = initPerspectiveTransformation(perspectiveData.toArray);
        auto cameraRotationTransformation = initCameraTransformation(cameraData.target, cameraData.up);
        auto cameraPositionTransformation = initPositionTransformation( - cameraData.position);

        return perspectiveTransformation
               * cameraRotationTransformation
               * cameraPositionTransformation;

    }

    /**
     *  Returns general transformation (viewport * world)
     */
    @property auto getWVPTransformation()
    {
        return getViewportTransformation() * getWorldTransformation();
    }

private:

    Vector3f scale = Vector3f(1.0f, 1.0f, 1.0f);
    Vector3f worldPosition = Vector3f(0.0f, 0.0f, 0.0f);
    Vector3f rotationAngles;

    PerspectiveData perspectiveData;

    CameraData cameraData;
}

/**
 *  Perspective data
 */
struct PerspectiveData
{
    float angle = 30.0f;
    float width = 0.0f;
    float height = 0.0f;
    float nearPlane = 1.0f;
    float farPlane = 100.0f;

    @property auto toArray() pure nothrow
    {
        return [angle, width, height, nearPlane, farPlane];
    }
}

unittest
{
    // The general function test
    auto pipeline = new WackyPipeline();

    pipeline.setScale(0.01f, 0.01f, 0.01f);
    pipeline.setWorldPosition(2.0f, 0.0f, 3.0f);
    pipeline.setRotation(45.0f / 180.0f * PI, 0.0f, 0.0f);
    pipeline.setCameraData(Vector3f(5.0f, 2.0f, 1.0f), Vector3f(2.0f, 1.3f, 3.0f), Vector3f(1.0f, 2.0f, 2.5f));
    pipeline.setPerspectiveData(45.0f, 12.0f, 3.0f, 6.0f, 20.0f);

    auto matrix = pipeline.getWVPTransformation;
    assert (matrix[0, 0] < 0.0012f + 0.0001f && matrix[0, 0] > 0.0012f - 0.0001f);
    assert (matrix[3, 3] < -0.67f + 0.01f && matrix[3, 3] > -0.67f - 0.01f);
    assert (matrix[2, 1] < 0.014f + 0.001f && matrix[2, 1] > 0.014f - 0.001f);
}
