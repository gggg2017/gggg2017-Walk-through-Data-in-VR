using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public GameObject player;

    private Vector3 offset;

    // Start is called before the first frame update
    void Start()
    {
        offset = transform.position - player.transform.position;
    }

    // Update is called once per frame
    void LateUpdate()
    {
        //Move the camera based on the current rotation of the target & the original offset
        float desiredYAngle = player.transform.eulerAngles.y;

        Quaternion rotation = Quaternion.Euler(0, desiredYAngle, 0);
        transform.position = player.transform.position + (rotation * offset);

        //transform.position = player.transform.position + offset;
        transform.LookAt(player.transform);
    }

}
