using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ApplyImageEffectCameraParameters : MonoBehaviour
{
    public Shader imageEffect;
    public GameObject sphere;
    public Light myLight;
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

    }

    void Update(){
        if(myCamera != null){
            Debug.Log(myCamera.fieldOfView);
            material.SetFloat("_CameraFOV", myCamera.fieldOfView);
            material.SetFloat("_CameraAspect", myCamera.aspect);
            material.SetVector("_SpherePosition", sphere.transform.position);
            material.SetFloat("_SphereRadius", sphere.transform.localScale.y / 2f);
            material.SetVector("_LightDirection", -myLight.transform.forward.normalized);
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
