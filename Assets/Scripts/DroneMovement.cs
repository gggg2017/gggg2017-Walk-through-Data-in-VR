using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DroneMovement : MonoBehaviour
{
    Rigidbody ourDrone;

    // Start is called before the first frame update
    void Start()
    {
        ourDrone = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        MovementUpDown();
        MovementForward();
        Rotation();

        ourDrone.AddRelativeForce(Vector3.up * upForce);
        ourDrone.rotation = Quaternion.Euler(new Vector3(0.0f, currentYRotation, 0.0f));
    }

    public float upForce;
    void MovementUpDown()
    {
        // life the ball
        if (Input.GetKey(KeyCode.I))
        {
            upForce = 20.0f;
        }
        //drop to ball, natural gravity
        else if (Input.GetKey(KeyCode.K))
        {
            upForce = 0.0f;
        }
        else
        {
            // initial floating mode
            upForce = 9.81f;
        }
    }

    private float movementForwardSpeed = 10.0f;
    //private float tiltAmountForward = 0;
    //private float tiltVelocityForward;
    void MovementForward()
    {
        if (Input.GetAxis("Vertical")!=0)
        {
            ourDrone.AddRelativeForce(Vector3.forward * Input.GetAxis("Vertical") * movementForwardSpeed);
        }
    }

    private float wantedYRotation;
    private float currentYRotation;
    private float rotateAmoutByKeys = 1.0f;
    private float rotateYVelocity;
    void Rotation()
    {
        if (Input.GetKey(KeyCode.J))
        {
            wantedYRotation -= rotateAmoutByKeys;
        }
        if (Input.GetKey(KeyCode.L))
        {
            wantedYRotation += rotateAmoutByKeys;
        }

        currentYRotation = Mathf.SmoothDamp(currentYRotation, wantedYRotation, ref rotateYVelocity, 0.25f);
    }

}
