using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyDirectionalLight : MonoBehaviour
{
    [NonSerialized]
    public Vector3 lightDirection = new Vector3(0.0f, -1.0f, 0.0f);
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        lightDirection = -transform.position.normalized;
        transform.up = lightDirection;
    }
}
