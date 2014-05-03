module wackyCamera;

private
{
    import std.math;

    import derelict.glfw3.glfw3;

    import wackyEnums;

    import lib.math.vector;
    import lib.math.quaternion;
}

/**
 * The class represents first-person camera
 */
class WackyCamera
{
public:

    this()
    {
        initialize();
    }

    this (Vector3f position, Vector3f target, Vector3f up)
    {
        cameraData = CameraData(position, target.normalized, up.normalized);
        initialize();
    }

    /**
     *  Handles the mouse movements
     */
    auto mouseMoveEventHandler(float x, float y)
    {
        const float deltaX = x - mousePosition.x;
        const float deltaY = y - mousePosition.y;

        mousePosition.x = x;
        mousePosition.y = y;

        horizontalAngle += deltaX * sensitivity;
        verticalAngle += deltaY * sensitivity;

        updateVectors();
    }

    /**
     *  Key event handler. The wrap is necessary for
     *  the implementation of an interpolation
     */
    auto keyEventHandler(WackyKeys key, WackyActions action) pure nothrow
    {

        currentKey = key;
        currentAction = action;
    }

    /**
     *  The function processes the keystrokes
     */
    auto keyProcessing()
    {
        if (currentAction != WackyActions.RELEASE)
        {
            switch (currentKey)
            {
            case forwardMoveKey:
                cameraData.position += (cameraData.target * stepSegment);
                break;

            case backwardMoveKey:
                cameraData.position -= (cameraData.target * stepSegment);
                break;

            case leftwardMoveKey:
                auto left = cross(cameraData.target, cameraData.up).normalized;
                cameraData.position += left * stepSegment;
                break;

            case rightwardMoveKey:
                auto right = cross(cameraData.up, cameraData.target).normalized;
                cameraData.position += right * stepSegment;
                break;
            default:
                break;
            }
        }
    }

    /**
     *  Setting the camera rotations sensitivity
     */
    auto setSensitivity(float sensitivity) pure nothrow
    {
        if (sensitivity >= 0.0f)
            this.sensitivity = sensitivity;
    }

    /**
     *  Setting the unit of distance for the camera movements
     */
    auto setStep(float step) pure nothrow
    {
        if (step >= 0.0f)
        {
            this.step = step;
            stepSegment = step / stepDivisor;
        }

    }

    /**
     *  Defines the divisor for the step segment interpolation
     *  and thus the speed of a movement. It's not recommended
     *  to call the function if you don't understand it's sense
     *  (bad value for the divisor may reduce the quality of
     *  the rendered scene while a camera is moving
     */
    auto setStepDivisor(float divisor) pure nothrow
    {
        if (divisor)
        {
            stepDivisor = divisor;
            stepSegment = step / stepDivisor;
        }
    }

    /**
     *  Key setters
     */
    auto setForwardMoveKey(WackyKeys key) nothrow
    {
        forwardMoveKey = key;
    }

    auto setBackwardMoveKey(WackyKeys key) nothrow
    {
        backwardMoveKey = key;
    }

    auto setRightwardMoveKey(WackyKeys key) nothrow
    {
        rightwardMoveKey = key;
    }

    auto setLeftwardMoveKey(WackyKeys key) nothrow
    {
        leftwardMoveKey = key;
    }
    /**
     *  Getters
     */
    @property
    {
        const auto getPosition() pure nothrow
        {
            return cameraData.position;
        }

        const auto getTarget() pure nothrow
        {
            return cameraData.target;
        }

        const auto getUp() pure nothrow
        {
            return cameraData.up;
        }

        const auto getStep() pure nothrow
        {
            return step;
        }

        const auto getStepDivisor() pure nothrow
        {
            return stepDivisor;
        }

        const auto getSensitivity() pure nothrow
        {
            return sensitivity;
        }

        auto getForwardMoveKey() nothrow
        {
            return forwardMoveKey;
        }

        auto getBackwardMoveKey() nothrow
        {
            return backwardMoveKey;
        }

        auto getRightwardMoveKey() nothrow
        {
            return rightwardMoveKey;
        }

        auto getLeftwardMoveKey() nothrow
        {
            return leftwardMoveKey;
        }
    }

private:

    CameraData cameraData;

    float step = 1.0f;
    float stepDivisor = 10.0f;
    float stepSegment = 0.1f;

    float sensitivity = 0.001f;

    WackyKeys currentKey;
    WackyActions currentAction;

    static WackyKeys forwardMoveKey = WackyKeys.KEY_W;
    static WackyKeys backwardMoveKey = WackyKeys.KEY_S;
    static WackyKeys rightwardMoveKey = WackyKeys.KEY_D;
    static WackyKeys leftwardMoveKey = WackyKeys.KEY_A;

    float horizontalAngle, verticalAngle;

    Vector2f mousePosition = Vector2f(0.0f, 0.0f);

    /**
     *  The function performs rotations
     */
    auto updateVectors()
    {
        Vector3f verticalAxis = Vector3f(0.0f, 1.0f, 0.0f);
        Vector3f view = Vector3f(1.0f, 0.0f, 0.0f);

        view = rotate(view, verticalAxis, horizontalAngle).normalized;

        Vector3f horizontalAxis = cross(verticalAxis, view).normalized;
        view = rotate(view, horizontalAxis, verticalAngle).normalized;

        cameraData.target = view;
        cameraData.up = cross(cameraData.target, horizontalAxis).normalized;
    }

    /**
     *  Setting the initial data
     */
    auto initialize ()
    {
        auto horizontalTarget = Vector3f(cameraData.target.x, 0.0f, cameraData.target.z).normalized;

        if (horizontalTarget.z >= 0.0f)
        {
            if (horizontalTarget.x >= 0.0f)
                horizontalAngle = 2.0f * PI - asin(horizontalTarget.z);

            else
                horizontalAngle = PI + asin(horizontalTarget.z);
        }

        else
        {
            if (horizontalTarget.x >= 0.0f)
                horizontalAngle = asin(-horizontalTarget.z);

            else
                horizontalAngle = PI / 2 + asin(-horizontalTarget.z);
        }

        verticalAngle = - asin(cameraData.target.y);
    }
}

/**
 *  Camera data
 */
struct CameraData
{
    Vector3f position = Vector3f(0.0f, 0.0f, 0.0f);
    Vector3f target = Vector3f(0.0f, 0.0f, 1.0f);
    Vector3f up = Vector3f(0.0f, 1.0f, 0.0f);

    @property auto toArray() pure nothrow
    {
        return [position, target, up];
    }
}

unittest
{
    //  Constructor test
    auto camera = new WackyCamera();
    assert(camera.getPosition == Vector3f(0.0f, 0.0f, 0.0f));
    assert(camera.getTarget == Vector3f(0.0f, 0.0f, 1.0f));
    assert(camera.getUp == Vector3f(0.0f, 1.0f, 0.0f));

    //  Mouse handler test
    camera.mouseMoveEventHandler(104.0f, -269.0f);
    assert(abs(camera.getTarget.y) < 0.265f + 0.001f);
    assert(abs(camera.getUp.x) < 0.0275f + 0.0001f);
}
