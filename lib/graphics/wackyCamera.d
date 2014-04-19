module lib.graphics.wackyCamera;

import std.math;

import derelict.glfw3.glfw3;

import wackyEnums;

import lib.math.vector;
import lib.math.quaternion;

/**
 * The class represents first-person camera
 */
class WackyCamera
{
public:

    this (Vector3f position, Vector3f target, Vector3f up, float step)
    {
        cameraData = CameraData(position, target.normalized, up.normalized);
        this.step = step;

        initialize();
    }

    /**
     *  Handles the mouse movements
     */
    auto mouseMoveProcessing(float x, float y)
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
     *  The function processes the keystrokes
     */
    auto keyProcessing(WackyKeys key, WackyActions action)
    {
        if (action == WackyActions.REPEAT)// || action == WackyActions.PRESS)
        {
            switch (key)
            {
            case forwardMoveKey:
                cameraData.position += (cameraData.target * step);
                break;

            case backwardMoveKey:
                cameraData.position -= (cameraData.target * step);
                break;

            case leftwardMoveKey:
                auto left = cross(cameraData.target, cameraData.up).normalized;
                cameraData.position += left * step;
                break;

            case rightwardMoveKey:
                auto right = cross(cameraData.up, cameraData.target).normalized;
                cameraData.position += right * step;
                break;
            default:
                break;
            }
        }
    }

    /**
     *  Setting the camera rotations sensitivity
     */
    auto setSensitivity(float sensitivity)
    {
        if (sensitivity <= 0.0f)
            this.sensitivity = sensitivity;
    }

    /**
     * Setting the unit of distance for the camera movements
     */
    auto setStep(float step)
    {
        this.step = step;
    }

    auto setForwardMoveKey(WackyKeys key)
    {
        forwardMoveKey = key;
    }
    /**
     *  Usual getters
     */
    @property const auto getPosition() pure nothrow
    {
        return cameraData.position;
    }

    @property const auto getTarget() pure nothrow
    {
        return cameraData.target;
    }

    @property const auto getUp() pure nothrow
    {
        return cameraData.up;
    }

private:

    CameraData cameraData;

    float step = 0.01f;
    float sensitivity = 0.0001f;
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
