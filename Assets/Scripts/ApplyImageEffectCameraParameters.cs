using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class ApplyImageEffectCameraParameters : MonoBehaviour
{
    public float aspect;
    public float fov;
    public float near;
    public Shader imageEffect;
    public GameObject sphere;
    private Material material;
    private Camera camera;

    void Start()
    {
        Debug.Assert(imageEffect != null);

        material = new Material(imageEffect)
        {
            hideFlags = HideFlags.HideAndDontSave
        };

        camera = Camera.main;
        material.SetTexture("_MainTex", camera.targetTexture);
        material.SetVector("_ObjectPosition", sphere.transform.position);

        aspect = camera.aspect;
        fov = camera.fieldOfView;
        near = camera.nearClipPlane;


    }

    void Update(){
        if(camera != null){
            material.SetVector("_CameraPosition", camera.transform.localPosition);
            material.SetVector("_CameraOrientation", camera.transform.forward);
            material.SetFloat("_CameraFOV", camera.fieldOfView);
            material.SetFloat("_CameraAspect", camera.aspect);
            material.SetFloat("_CameraNearPlane", camera.nearClipPlane);

            // material.SetVector("_CameraPosition", camera.transform.localPosition);
            // material.SetVector("_CameraOrientation", camera.transform.forward);
            // material.SetFloat("_CameraFOV", fov);
            // material.SetFloat("_CameraAspect", aspect);
            // material.SetFloat("_CameraNearPlane", near);
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
