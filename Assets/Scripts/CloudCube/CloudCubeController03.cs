using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudCubeController03 : MonoBehaviour
{
    public Material material;
    public GameObject cube;
    public float absorption = 0.1f;
    public float noiseTiling = 24;
    // public GameObject myLight;
    public MyDirectionalLight myLight;
    public float lightAbsorption = 1;
    public Color lightColor = Color.white;
    public float lightIntensity = 1;
    void Start()
    {
        cube.GetComponent<MeshRenderer>().enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        material.SetVector("_CubePosition", cube.transform.position);
        material.SetFloat("_CubeLength", cube.transform.localScale.x);
        material.SetFloat("_Absorption", absorption);
        material.SetFloat("_NoiseTiling", noiseTiling);
        //material.SetVector("_LightPosition", myLight.transform.position);
        material.SetVector("_LightDirection", myLight.lightDirection);
        material.SetFloat("_LightAbsorption", lightAbsorption);
        material.SetColor("_LightColor", lightColor);
        material.SetFloat("_LightIntensity", lightIntensity);
    }
}
