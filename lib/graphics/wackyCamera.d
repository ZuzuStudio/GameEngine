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

        horizontalAngle += deltaX / 300.0f;
        verticalAngle += deltaY / 300.0f;

        updateVectors();
    }

    /**
     *  The function processes the keystrokes
     */
    auto keyProcessing(WackyKeys key, WackyActions action)
    {
        if (action == WackyActions.REPEAT || action == WackyActions.PRESS)
        {
            switch (key)
            {
            case WackyKeys.KEY_UP, WackyKeys.KEY_W:
                cameraData.position += (cameraData.target * step);
                break;

            case WackyKeys.KEY_DOWN, WackyKeys.KEY_S:
                cameraData.position -= (cameraData.target * step);
                break;

            case WackyKeys.KEY_LEFT, WackyKeys.KEY_A:
                auto left = cross(cameraData.target, cameraData.up).normalized;
                cameraData.position += left * step;
                break;

            case WackyKeys.KEY_RIGHT, WackyKeys.KEY_D:
                auto right = cross(cameraData.up, cameraData.target).normalized;
                cameraData.position += right * step;
                break;
            default:
                break;
            }
        }
    }

    /**
     * Setting the unit of distance for the camera movements
     */
    auto setStep(float step)
    {
        this.step = step;
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

    float step;
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
