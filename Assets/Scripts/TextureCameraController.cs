using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextureCameraController : MonoBehaviour
{
    private Camera cam;
    private Vector2 dimensions = new Vector2();

    public enum TextureType{
        CloudCoverage,
        CloudType,
        CloudGradient
    }

    public TextureType textureType;

    public List<RenderTexture> textures;

    public Material mat;

    public Camera texCamera;
    public float camSize;
    public bool viewCam = true;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(viewCam){
            texCamera.depth = Camera.main.depth + 1;
        }
        else{
            texCamera.depth = Camera.main.depth - 1;
        }

        dimensions.y = camSize;
        dimensions.x =  (float)Screen.height / (float)Screen.width * camSize;
        texCamera.rect = new Rect(0,0,dimensions.x, dimensions.y);

        mat.SetTexture("_TextureView", textures[(int)textureType]);
    }
}
