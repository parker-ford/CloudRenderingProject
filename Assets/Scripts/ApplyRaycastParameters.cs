using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ApplyRaycastParameters : MonoBehaviour
{
    public Material material;
    public bool useRayRandomization;
    public bool useIncreasingMarchIntervals;
    public int marchSteps = 1;
    public int raysPerPixel = 1;

    private int raycastOptions = 0;
    private int randomBit = 1;
    private int intervalBit = 2;
    [Range(0,20)]
    public float rayOffsetWeight = 1.0f;

    void Start()
    {
        Debug.Assert(material != null);

        material.SetTexture("_MainTex", Camera.main.targetTexture);

    }

    void Update(){
        material.SetFloat("_CameraFOV", Camera.main.fieldOfView);
        material.SetFloat("_CameraAspect", Camera.main.aspect);
        // material.SetInt("_UsingRandom", useRayRandomization ? 1 : 0);
        material.SetInt("_MarchSteps", marchSteps);
        material.SetInt("_RayPerPixel", raysPerPixel);
        material.SetFloat("_RayOffsetWeight", rayOffsetWeight);

        raycastOptions = 0;
        if(useRayRandomization){
            raycastOptions |= randomBit;
        }
        if(useIncreasingMarchIntervals){
            raycastOptions |= intervalBit;
        }

        material.SetInt("_RaycastOptions", raycastOptions);


    }
}
