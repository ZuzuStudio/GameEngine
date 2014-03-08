module camera;

import derelict.glfw3.glfw3;
import math3d;
import std.math;

class Camera
{
public:

    this (GLFWwindow* window)
    {
        step = 0.05f;
        positionV = Vector3f(0.0f, 0.0f, 0.0f);
        targetV = Vector3f(0.0f, 0.0f, 1.0f);
        upV = Vector3f(0.0f, 1.0f, 0.0f);

        Init(window
             );
    }

    this (GLFWwindow* window, ref Vector3f a, ref Vector3f b, ref Vector3f c, int d)
    {
        positionV = a;
        targetV = b;
        targetV.Normalize();
        upV = c;
        upV.Normalize();
        step = d;

        Init(window);
    }

    auto Init (GLFWwindow* window)
    {
        auto horizontalTarget = Vector3f (targetV.x, 0.0f, targetV.z);
        horizontalTarget.Normalize();

        if (horizontalTarget.z >= 0.0f)
        {
            if (horizontalTarget.x >= 0.0f)
                horizontalAngle= 360.0f - ToDegree(asin(horizontalTarget.z));

            else
                horizontalAngle = 180.0f + ToDegree(asin(horizontalTarget.z));
        }

        else
        {
            if (horizontalTarget.x >= 0.0f)
                horizontalAngle = ToDegree(asin(-horizontalTarget.z));

            else
                horizontalAngle = 90.0f + ToDegree(asin(-horizontalTarget.z));
        }

        verticalAngle = - ToDegree(asin(targetV.y));

        mousePosition.x  = 0.0f;
        mousePosition.y  = 0.0f;

        glfwSetCursorPos(window, mousePosition.x, mousePosition.y);
    }

    auto MouseProcessing(float x, float y)
    {
        const  float deltaX = x - mousePosition.x;
        const float deltaY = y - mousePosition.y;

        mousePosition.x = x;
        mousePosition.y = y;

        horizontalAngle += deltaX / 25.0f;
        verticalAngle += deltaY / 25.0f;

        Update();
    }

    auto Update()
    {
        Vector3f verticalAxis = Vector3f(0.0f, 1.0f, 0.0f);

        Vector3f view = Vector3f(1.0f, 0.0f, 0.0f);
        view.Rotate(horizontalAngle, verticalAxis);
        view.Normalize();

        Vector3f horizontalAxis = verticalAxis.VecProduct(view);
        horizontalAxis.Normalize();
        view.Rotate(verticalAngle, horizontalAxis);
        view.Normalize();

        targetV = view;
        targetV.Normalize();

        upV = targetV.VecProduct(horizontalAxis);
        upV.Normalize();
    }


    auto KeyboardProcessing(int key, int action)
    {
        if (action == GLFW_REPEAT || action == GLFW_PRESS)
        {
            switch (key)
            {
            case GLFW_KEY_UP, GLFW_KEY_W:
                positionV += (targetV * step);
                break;

            case GLFW_KEY_DOWN, GLFW_KEY_S:
                positionV -= (targetV * step);
                break;

            case GLFW_KEY_LEFT, GLFW_KEY_A:
                auto left = targetV.VecProduct(upV);
                left.Normalize();
                positionV += left * step;
                break;

            case GLFW_KEY_RIGHT, GLFW_KEY_D:
                auto right = upV.VecProduct(targetV);
                right.Normalize();
                positionV += right * step;
                break;
            default:

                break;
            }
        }
    }

    const Vector3f GetPosition()
    {
        return positionV;
    }

    const Vector3f GetTarget()
    {
        return targetV;
    }

    const Vector3f GetUp()
    {
        return upV;
    }

    auto SetStep(int a)
    {
        step = a;
    }

private:
    Vector3f positionV,
             targetV,
             upV;

    float step;

    float horizontalAngle, verticalAngle;

    Vector2f mousePosition;
};
