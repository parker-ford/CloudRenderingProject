using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ApplyRaycastParameters : MonoBehaviour
{
    public Material material;
    public bool useRayRandomization;
    public int marchSteps = 1;
    public int raysPerPixel = 1;

    void Start()
    {
        Debug.Assert(material != null);

        material.SetTexture("_MainTex", Camera.main.targetTexture);

    }

    void Update(){
        material.SetFloat("_CameraFOV", Camera.main.fieldOfView);
        material.SetFloat("_CameraAspect", Camera.main.aspect);
        material.SetInt("_UsingRandom", useRayRandomization ? 1 : 0);
        material.SetInt("_MarchSteps", marchSteps);
        material.SetInt("_RayPerPixel", raysPerPixel);
    }
}
