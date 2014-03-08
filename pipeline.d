module pipeline;

import math3d;

class Pipeline
{
public:

    this()
    {
        scaleV = Vector3f (1.0f, 1.0f, 1.0f);
        worldRotationV = Vector3f (0.0f, 0.0f, 0.0f);
        worldPositionV = Vector3f (0.0f, 0.0f, 0.0f);
        result.init;
    }

    void SetScale(float a, float b, float c)
    {
        scaleV=[a,b,c];
        scaleB=true;
    }

    void SetRotation(float a, float b, float c)
    {
        worldRotationV=[a,b,c];
        worldRotationB=true;
    }

    void SetPosition(float a, float b, float c)
    {
        worldPositionV=[a,b,c];
        worldPositionB=true;
    }

    void SetPerspective(float a, float b, float c, float d, float e)
    {
        perspectiveV.angle = a;
        perspectiveV.width = b;
        perspectiveV.height = c;
        perspectiveV.nearestPlane = d;
        perspectiveV.farPlane = e;
        perspectiveB=true;
    }

    void SetCamera(Vector3f _position, Vector3f _target, Vector3f _up)
    {
        cameraV.position = _position;
        cameraV.target = _target;
        cameraV.up = _up;
        camPositionB = camRotationB = true;
    }

    ref Matrix4f GetTransformation()
    {
        isChanged = perspectiveB
                        || camRotationB
                        || camPositionB
                        || worldPositionB
                        || worldRotationB
                        || scaleB;

        if (perspectiveB)
        {
            perspectiveM.InitPerspective(perspectiveV.angle,
                                         perspectiveV.width,
                                         perspectiveV.height,
                                         perspectiveV.nearestPlane,
                                         perspectiveV.farPlane);

            perspectiveB = false;
        }

        if (camRotationB)
        {
            camRotationM.InitCameraTransform(cameraV.target,
                                             cameraV.up);
            camRotationB = false;
        }

        if (camPositionB)
        {
            camPositionM.InitPosition(-cameraV.position.x,
                                     -cameraV.position.y,
                                     -cameraV.position.z);
            camPositionB=false;
        }

        if (worldPositionB)
        {
            worldPositionM.InitPosition(worldPositionV.x, worldPositionV.y, worldPositionV.z);
            worldPositionB = false;
        }

        if (worldRotationB)
        {
            worldRotationM.InitRotation(worldRotationV.x, worldRotationV.y, worldRotationV.z);
            worldRotationB = false;
        }

        if (scaleB)
        {
            scaleM.InitScale(scaleV.x, scaleV.y, scaleV.z);
            scaleB = false;
        }

        if (isChanged)
            result = perspectiveM * camRotationM * camPositionM * worldPositionM * worldRotationM * scaleM;

        return result;
    }

private:

    struct PerspectiveStruct
    {
        float angle;
        float width;
        float height;
        float nearestPlane;
        float farPlane;
    };

    struct CamStruct
    {
        Vector3f position;
        Vector3f target;
        Vector3f up;
    };

    Vector3f scaleV,
                worldRotationV,
                worldPositionV;

    PerspectiveStruct perspectiveV;

    CamStruct cameraV;

    Matrix4f scaleM,
                worldRotationM,
                worldPositionM,
                camPositionM,
                camRotationM,
                perspectiveM,
                result;

    bool scaleB,
        worldRotationB,
        worldPositionB,
        camPositionB,
        camRotationB,
        perspectiveB,
        isChanged;
};
