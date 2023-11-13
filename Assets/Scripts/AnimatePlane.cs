using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatePlane : MonoBehaviour
{
    public Material mat;
    public float width;
    public float height;
    public bool animatePosition = false;
    // Start is called before the first frame update
    void Start()
    {
        mat.SetVector("_PlanePosition", new Vector3(0,0,0));
        mat.SetVector("_PlaneNormal", new Vector3(0,0,-1));
        mat.SetVector("_PlaneUp", new Vector3(0,1,0));
        mat.SetFloat("_PlaneWidth", width);
        mat.SetFloat("_PlaneHeight", height);
    }

    // Update is called once per frame
    void Update()
    {
        mat.SetFloat("_PlaneWidth", width);
        mat.SetFloat("_PlaneHeight", height);
        if(animatePosition){
            mat.SetVector("_PlanePosition", new Vector3(0,Mathf.Sin(Time.time),0));
        }
    }
}
