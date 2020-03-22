using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerController : MonoBehaviour
{
    public float speed;

    private Rigidbody rb;
    
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }


    public float upForce;
    void FixedUpdate()
    {
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");
        
        

        // life the ball
        if (Input.GetKey(KeyCode.I)){ 
            upForce = 9.81f;
        }
        //drop to ball, natural gravity
        else if (Input.GetKey(KeyCode.K))
        {
            upForce = 0.0f;
        }
        else
        {
            // initial floating mode
            upForce = 0.981f;
        }

        Vector3 movement = new Vector3(moveHorizontal, upForce, moveVertical);
        rb.AddForce(movement * speed);
        
    }
}
