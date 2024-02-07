using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DimensionalProfileLitController : MonoBehaviour
{
    public Material material;
    public MyDirectionalLight myDirectionalLight;
    public float lightIntensity = 1.0f;
    public float lightAbsorption = 1.0f;
    public float noiseTiling = 128.0f;
    public float absoroption = 1.0f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        material.SetVector("_LightDir", myDirectionalLight.lightDirection);
        material.SetFloat("_LightIntensity", lightIntensity);
        material.SetFloat("_LightAbsorption", lightAbsorption);
        material.SetFloat("_NoiseTiling", noiseTiling);
        material.SetFloat("_Absorption", absoroption);
        
    }
}
