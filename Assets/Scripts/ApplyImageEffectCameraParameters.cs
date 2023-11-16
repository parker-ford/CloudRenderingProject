using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ApplyImageEffectCameraParameters : MonoBehaviour
{
    public Material material;
    private Camera myCamera;

    void Start()
    {
        Debug.Assert(material != null);

        myCamera = Camera.main;
        material.SetTexture("_MainTex", myCamera.targetTexture);

    }

    void Update(){
        if(myCamera != null){
            material.SetFloat("_CameraFOV", myCamera.fieldOfView);
            material.SetFloat("_CameraAspect", myCamera.aspect);
            //SHould not be here 
            // material.SetVector("_SpherePosition", sphere.transform.position);
            // material.SetFloat("_SphereRadius", sphere.transform.localScale.y / 2f);
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
    
        if(material != null){
            Graphics.Blit(source, destination, material);

        }
        else{
            Graphics.Blit(source,destination);
            Debug.LogError("Image effect material is null");
        }
    }
}
