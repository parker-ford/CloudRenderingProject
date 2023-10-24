using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ApplyImageEffectCameraParameters : MonoBehaviour
{
    public Shader imageEffect;
    public GameObject sphere;
    private Material material;
    private Camera myCamera;

    void Start()
    {
        Debug.Assert(imageEffect != null);

        material = new Material(imageEffect)
        {
            hideFlags = HideFlags.HideAndDontSave
        };

        myCamera = Camera.main;
        material.SetTexture("_MainTex", myCamera.targetTexture);
        material.SetVector("_ObjectPosition", sphere.transform.position);
    }

    void Update(){
        if(myCamera != null){
            material.SetVector("_CameraPosition", myCamera.transform.localPosition);
            material.SetVector("_CameraOrientation", myCamera.transform.forward);
            material.SetFloat("_CameraFOV", myCamera.fieldOfView);
            material.SetFloat("_CameraAspect", myCamera.aspect);
            material.SetFloat("_CameraNearPlane", myCamera.nearClipPlane);
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
