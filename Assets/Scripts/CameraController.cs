using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float rotationSpeed = 50f;
    Vector2 currMouse;
    Vector3 currentRotation;
    // Start is called before the first frame update
    void Start()
    {
        currentRotation = transform.eulerAngles;
    }

    // Update is called once per frame
    void Update()
    {
        // Vector2 lastMouse = currentMouse;
        // currentMouse = Input.mousePosition;
        // Vector2 deltaMouse = lastMouse - currentMouse;

        
        if(Input.GetMouseButton(1)){

            Cursor.lockState = CursorLockMode.Locked;
            // Vector2 deltaMosue = currMouse - (Vector2)Input.mousePosition;
            // currMouse = (Vector2)Input.mousePosition;
            Vector2 deltaMouse = new Vector2(-Input.GetAxis("Mouse X"), -Input.GetAxis("Mouse Y"));

            if(Input.GetKey(KeyCode.W)){
                transform.position += transform.forward * Time.deltaTime * moveSpeed;
            }
            if(Input.GetKey(KeyCode.S)){
                transform.position -= transform.forward * Time.deltaTime * moveSpeed;
            }
            if(Input.GetKey(KeyCode.D)){
                transform.position += transform.right * Time.deltaTime * moveSpeed;
            }
            if(Input.GetKey(KeyCode.A)){
                transform.position -= transform.right * Time.deltaTime * moveSpeed;
            }
            if(Input.GetKey(KeyCode.E)){
                transform.position += transform.up * Time.deltaTime * moveSpeed;
            }
            if(Input.GetKey(KeyCode.Q)){
                transform.position -= transform.up * Time.deltaTime * moveSpeed;
            }

            
            Quaternion qX = Quaternion.AngleAxis(-deltaMouse.x * Time.deltaTime * rotationSpeed, Vector3.up);
            Quaternion qY = Quaternion.AngleAxis(deltaMouse.y * Time.deltaTime * rotationSpeed, transform.right);
            Quaternion q = qX * qY;
            Matrix4x4 R = Matrix4x4.Rotate(q);
            Vector3 newCameraPos = R.MultiplyPoint(transform.localPosition);
            transform.localPosition = newCameraPos;
            transform.localRotation = q * transform.localRotation;
   

        }
        else{
            Cursor.lockState = CursorLockMode.None;
        }
    }
}
