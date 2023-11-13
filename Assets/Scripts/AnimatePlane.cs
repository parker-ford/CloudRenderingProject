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
    public bool animatePositionY = false;

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
        planeObj.transform.localScale = new Vector3(width, height, 1.0f);
        planeObj.transform.localPosition = new Vector3(xPos, yPos, zPos);

        mat.SetVector("_PlanePosition", planeObj.transform.position);
        mat.SetVector("_PlaneNormal", planeObj.transform.forward);
        mat.SetVector("_PlaneUp", planeObj.transform.up);
        mat.SetFloat("_PlaneWidth", planeObj.transform.localScale.x * 0.5f);
        mat.SetFloat("_PlaneHeight", planeObj.transform.localScale.y * 0.5f);

        if(animatePositionY){
            yPos = Mathf.Sin(Time.time);
        }


        if(overlayOriginal){
            mat.SetInt("_OverlayOriginal", 1);
        }
        else{
            mat.SetInt("_OverlayOriginal", 0);
        }
    }
}
