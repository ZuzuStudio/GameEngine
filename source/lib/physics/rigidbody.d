module lib.physics.rigidbody;

public
{
    import lib.math.vector;
    import lib.math.quaternion;
    import lib.math.squarematrix;
    import lib.geometry.geometry;
    import lib.geometry.sphere;
}

/**
 *  Absolute rigid body
 */
class RigidBody
{
public:
    //this(){}
    /**
     *  Constructor with default parametrs.
     *  by default Vector3f, Quaternionf have zero values
     */

	//TODO documented
    this(float mass, Vector3f position, Quaternionf orientation, Sphere /*Geometry*/ geometry, float bounce = 1.0f ) pure nothrow @safe
    in
    {
        assert(mass > float.epsilon, "RigidBody(float mass, Vector3f position, "
           "Vector3f orientation, Geometry geometry): Invalid mass value. "
           "Mass of rigib body should by more then float.epsilon");
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
        _bounce = bounce;
    }

    this(RigidBody original) pure nothrow @safe
    in
    {
        assert(original !is null, "RigidBody(RigidBody original): original equals to null!");
    }
    body
    {
        _mass = original._mass;
        _invMass = original._invMass;
        _position = original._position;
        _orientation = original._orientation;

        //TODO
        _geometry = new Sphere(original._geometry);
        _inertia = original._inertia;
        _invInertia = original._invInertia;
    }

    @property Matrix4x4f transformation() pure nothrow @safe
    {
        Matrix4x4f composition;

        composition = position.toMatrix4x4();
        composition = composition * orientation.toMatrix4x4();

        return composition;
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

        this.updateGeometry();
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

    void updateGeometry() pure nothrow @safe
    {
        _geometry.center = this.position;
    }

    void resetForces() pure nothrow @safe
    {
        _forceAccumulator = Vector3f(); // by default it's a Vector3f(0, 0 , 0);
        _torqueAccumulator = Vector3f(); // by default it's a Vector3f(0, 0 , 0);
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

    @property float bounce() pure nothrow @safe
    {
        return _bounce;
    }

    void applyLinearVelocity(Vector3f velocity) pure nothrow @safe
    {
        _linearVelocity += velocity;
    }

    void applyAngularVelocity(Vector3f velocity) pure nothrow @safe
    {
        _angularVelocity += velocity;
    }

    //TODO Fix it
    @property Sphere geometry() pure nothrow @safe
    {
        return _geometry;
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

    Sphere _geometry;
    //Geometry _geometry;

    float _bounce;
}

unittest
{
	// Testing constructors
	auto rb = new RigidBody(10f, Vector3f(), Quaternionf(), new Sphere(Vector3f(), 10f));
	assert(10f == rb._mass);
	assert(0.1f == rb._invMass);
	assert(Vector3f() == rb._position);
	assert(Vector3f() == rb._linearVelocity);
	assert(Vector3f() == rb._linearAcceleration);
	assert(Vector3f() == rb._forceAccumulator);
	assert(Matrix3x3f.diagonal(400f, 400f, 400f) == rb._inertia);
	assert(Matrix3x3f.diagonal(0.0025f, 0.0025f, 0.0025f) == rb._invInertia);
	assert(1f == rb._bounce);
}

unittest
{
	// Testing contract
	import core.exception;
	try
	{
		auto rb = new RigidBody(0.0f, Vector3f(), Quaternionf(), new Sphere(Vector3f(), 10.0f));
	}
	catch(AssertError ae)
	{
		assert("RigidBody(float mass, Vector3f position,"
		   " Vector3f orientation, Geometry geometry): "
		   "Invalid mass value. Mass of rigib body "
		   "should by more then float.epsilon" == ae.msg);
	}

	// Testing contract
	import core.exception;
	try
	{
		auto rbcopy = new RigidBody(null);
	}
	catch(AssertError ae)
	{
		assert("RigidBody(RigidBody original): original equals to null!" == ae.msg);
	}
}
