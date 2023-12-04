using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureCameraResize : MonoBehaviour
{
    // Start is called before the first frame update
    private Camera cam;
    private Vector2 dimensions = new Vector2();
    public float camSize;
    public bool viewCam = true;
    void Start()
    {
        
        cam = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        if(viewCam){
            cam.depth = Camera.main.depth + 1;
        }
        else{
            cam.depth = Camera.main.depth - 1;
        }

        dimensions.y = camSize;
        dimensions.x =  (float)Screen.height / (float)Screen.width * camSize;
        cam.rect = new Rect(0,0,dimensions.x, dimensions.y);
    }
}
