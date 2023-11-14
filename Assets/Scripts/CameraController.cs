using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public float moveSpeed = 5f;
    Vector2 currentMouse;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector2 lastMouse = currentMouse;
        currentMouse = Input.mousePosition;
        Vector2 deltaMouse = lastMouse - currentMouse;

        
        if(Input.GetMouseButton(1)){
            Debug.Log(deltaMouse);
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

            //transform.RotateAround(transform.up, deltaMouse.y);
            transform.Rotate(Vector3.up, -deltaMouse.x * Time.deltaTime * 50f);
            transform.Rotate(Vector3.right, deltaMouse.y* Time.deltaTime * 50f);

        }
    }
}
