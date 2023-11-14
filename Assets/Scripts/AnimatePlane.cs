using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatePlane : MonoBehaviour
{
    public GameObject planeObj;
    public Material mat;
    public float width = 1.0f;
    public float height = 1.0f;

    public bool animatePositionX = false;
    public bool animatePositionY = false;
    public bool animatePositionZ = false;

    public bool animateRotationX = false;
    public bool animateRotationY = false;
    public bool animateRotationZ = false;

    public bool overlayOriginal = false;

    float xPos = 0;
    float yPos = 0;
    float zPos = 0;
    // Start is called before the first frame update
    void Start()
    {
        mat.SetVector("_PlanePosition", new Vector3(0.0f, 0.0f, 0.0f));
        mat.SetVector("_PlaneNormal", new Vector3(0.0f, 0.0f, -1.0f));
        mat.SetVector("_PlaneUp", new Vector3(0.0f, 1.0f, 0.0f));
        mat.SetFloat("_PlaneWidth", 0.5f);
        mat.SetFloat("_PlaneHeight", 0.5f);
    }

    // Update is called once per frame
    void Update()
    {


        mat.SetVector("_PlanePosition", planeObj.transform.position);
        mat.SetVector("_PlaneNormal", planeObj.transform.forward);
        mat.SetVector("_PlaneUp", planeObj.transform.up);
        mat.SetVector("_PlaneRight", -planeObj.transform.right);
        mat.SetFloat("_PlaneWidth", planeObj.transform.localScale.x * 0.5f);
        mat.SetFloat("_PlaneHeight", planeObj.transform.localScale.y * 0.5f);

        Quaternion xRot = Quaternion.identity;
        Quaternion yRot = Quaternion.identity;
        Quaternion zRot = Quaternion.identity;

        if(animatePositionX){
            xPos = Mathf.Cos(Time.time);
        }
        if(animatePositionY){
            yPos = Mathf.Sin(Time.time);
        }
        if(animatePositionZ){
            zPos = Mathf.Sin(Time.time);
        }
        if(animateRotationX){
            xRot = Quaternion.AngleAxis(Time.deltaTime * 100f, Vector3.right);
        }
        if(animateRotationY){
            yRot = Quaternion.AngleAxis(Time.deltaTime * 100f, Vector3.up);
        }
        if(animateRotationZ){
            zRot = Quaternion.AngleAxis(Time.deltaTime * 100f, Vector3.forward);
        }
        

        planeObj.transform.localScale = new Vector3(width, height, 1.0f);
        planeObj.transform.localPosition = new Vector3(xPos, yPos, zPos);
        planeObj.transform.localRotation = xRot * yRot * zRot * planeObj.transform.localRotation;



        if(overlayOriginal){
            mat.SetInt("_OverlayOriginal", 1);
        }
        else{
            mat.SetInt("_OverlayOriginal", 0);
        }
    }
}
