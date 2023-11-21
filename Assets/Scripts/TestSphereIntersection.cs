using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestSphereIntersection : MonoBehaviour
{
    public Material mat;
    public bool overlayOriginal = false;

    public enum TestMode {
        shapeTest = 1,
        frontIntersectTest = 2,
        backIntersectTest = 3,
        marchTest = 4,
    }

    public TestMode testMode;

    public int numSteps = 1;
    public int rayPerPixel = 1;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetVector("_SphereCenter", transform.position);
        mat.SetFloat("_SphereRadius", transform.localScale.y * 0.5f);

        if(overlayOriginal){
            mat.SetInt("_OverlayOriginal", 1);
        }
        else{
            mat.SetInt("_OverlayOriginal", 0);
        }
        
        mat.SetInt("_TestMode", (int)testMode);
        mat.SetInt("_MarchSteps", numSteps);
        mat.SetInt("_RayPerPixel", rayPerPixel);
    }
}
