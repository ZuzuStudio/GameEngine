module lib.physics.rigidbody;

public
{
    import lib.math.vector;
    import lib.math.quaternion;
    import lib.math.squarematrix;
    import lib.geometry.geometry;
}

/**
 *  Absolute rigid body
 */
class RigidBody
{
public: 
    /**
     *  Constructor with default parametrs.
     *  by default Vector3f, Quaternionf have zero values
     */
    this(float mass, Vector3f position, Quaternionf orientation, Geometry geometry) pure nothrow @safe
    in
    {
        assert(mass > float.epsilon, "RigidBody(float mass, Vector3f position, Vector3f orientation, Geometry geometry): Invalid mass vass value. Mass of rigib body should by more then float.epsilon");
    }
    body
    {
        _mass = mass;
        _invMass = 1.0f / mass;
        _position = position;
        _orientation = orientation;
        
        /*  Default zero initialization for:
         *
         *  _linearVelocity;
         *  _linearAcceleration;
         *  _forceAccumulator;
         *
         *  _angularVelocity;
         *  _angularAcceleration;
         *  _torqueAccumulator;
         */
        _geometry = geometry;
        _inertia = geometry.inertiaTensor(_mass);
        _invInertia = _inertia.inverse;
    }
   
    void integrateForces(float dt) pure nothrow @safe
    {
        _linearAcceleration = _forceAccumulator * _invMass;
        _linearVelocity += _linearAcceleration * dt;


        _angularAcceleration = _torqueAccumulator * _invInertia;
        _angularVelocity += _angularAcceleration * dt;
    }

    void integrateVelocities(float dt) pure nothrow @safe
    {
        if (_linearVelocity.length < float.epsilon)
            _linearVelocity = Vector3f();   // by default it's a Vector3f(0, 0 , 0);
        if (_angularVelocity.length < float.epsilon)
            _angularVelocity = Vector3f();  // by default it's a Vector3f(0, 0 , 0);

        _position += _linearVelocity * dt;
        _orientation += 0.5f * Quaternionf(_angularVelocity, 0.0f) * _orientation * dt;
        _orientation.normalize();
    }
    
/*  Candidat for deletion
*
*    void setGeometry(Geometry geometry) pure nothrow @safe
*    {
*        _geometry = geometry;
*
*        _inertia = geometry.inertiaTensor(_mass);
*        //  invInertia = inertia.inverse;
*    }
*/

    void applyForce(Vector3f force) pure nothrow @safe
    {
        _forceAccumulator += force;
    }

    void applyTorque(Vector3f torque) pure nothrow @safe
    {
        _torqueAccumulator += torque;
    }
    
    /**
     *  Gettrs
     */
    @property float mass() pure nothrow @safe
    {
        return _mass;
    }
    
    @property float invMass() pure nothrow @safe
    {
        return _invMass;
    }
    
    @property Vector3f position() pure nothrow @safe
    {
        return _position;
    }
    
    @property Vector3f linearVelocity() pure nothrow @safe
    {
        return _linearVelocity;
    }
    
    @property Vector3f linearAcceleration() pure nothrow @safe
    {
        return _linearAcceleration;
    }
    
    @property Matrix3x3f inertia() pure nothrow @safe
    {
        return _inertia; 
    }
    
    @property Matrix3x3f invInertia() pure nothrow @safe
    {
        return _invInertia; 
    }
    
    @property Quaternionf orientation() pure nothrow @safe
    {
        return _orientation; 
    }
    
    @property Vector3f angularVelocity() pure nothrow @safe
    {
        return _angularVelocity; 
    }
    
    @property Vector3f angularAcceleration() pure nothrow @safe
    {
        return _angularAcceleration; 
    }
    
private:
    float _mass;
    float _invMass;

    /*  By default Vector3f, Quaternionf and Matrix3x3f are created with zero values   */
    Vector3f _position;
    Vector3f _linearVelocity;
    Vector3f _linearAcceleration;
    Vector3f _forceAccumulator;


    Matrix3x3f _inertia;
    Matrix3x3f _invInertia;
    Quaternionf _orientation;
    Vector3f _angularVelocity;
    Vector3f _angularAcceleration;
    Vector3f _torqueAccumulator;

    Geometry _geometry;
}
